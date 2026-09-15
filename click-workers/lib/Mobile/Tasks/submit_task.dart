import 'dart:typed_data';

import 'package:click_workers/Mobile/Tasks/task_submitted.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/Home/notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:click_workers/services/api_client.dart';

class SubmitTask extends StatefulWidget {
  const SubmitTask({super.key, required this.taskID, required this.earnings, required this.points, required this.type, required this.treasureID});
  final String taskID;
  final String earnings;
  final String points;
  final String type;
  final String treasureID;

  @override
  State<SubmitTask> createState() => _SubmitTaskState();
}

class _SubmitTaskState extends State<SubmitTask> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedFiles = [];
  final TextEditingController _urlController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    final file = await _picker.pickMedia();
    if (file == null) return;
    final fileSize = await file.length();
    if (fileSize <= 7 * 1024 * 1024) {
      setState(() => _selectedFiles.add(file));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File too large (max 7MB)')));
    }
  }

  Widget buildSelectedFilesPreview() {
    if (_selectedFiles.isEmpty) return const Text('No file selected');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedFiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        final file = _selectedFiles[index];
        final isVideo = file.path.toLowerCase().endsWith('.mp4');
        return Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? Container(color: Colors.black26, child: const Center(child: Icon(Icons.videocam, size: 40, color: Colors.orange)))
                : FutureBuilder<Uint8List>(
                    future: file.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      if (!snapshot.hasData) return const Icon(Icons.broken_image);
                      return Image.memory(snapshot.data!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                    },
                  ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => setState(() => _selectedFiles.removeAt(index)),
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPreviousSubmissions() async {
    final all = await ApiClient.instance.mySubmissions(taskId: widget.taskID);
    final matching = all.cast<Map<String, dynamic>>().toList();
    for (final submission in matching) {
      final proofKeys = (submission['proof_urls'] as List?)?.map((value) => value.toString()).toList() ?? <String>[];
      if (proofKeys.isEmpty) continue;
      try {
        submission['preview_url'] = await ApiClient.instance.proofDownloadUrl(proofKeys.first);
      } catch (_) {
        submission['preview_url'] = '';
      }
    }
    return matching;
  }

  Widget uploadCard() => SizedBox(
        width: 90.w,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upload Evidence of Completion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 3.h),
                InkWell(
                  onTap: _submitting ? null : pickFile,
                  child: Container(
                    width: 80.w,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        SizedBox(height: 3.h),
                        const Icon(Icons.cloud_upload_sharp, size: 48, color: Colors.black),
                        SizedBox(height: 2.h),
                        const Text('Choose files to upload', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 1.h),
                        const Text('Supports PNG, JPG, MP4 (Max 7MB each)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget formCard() => SizedBox(
        width: 90.w,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSelectedFilesPreview(),
                const SizedBox(height: 16),
                const Text('Task URL', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: 'https://…',
                    hintStyle: const TextStyle(color: Color(0xff6b7280)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<List<String>> _uploadSelectedFiles() async {
    final keys = <String>[];
    for (final file in _selectedFiles) {
      final ext = file.path.contains('.') ? file.path.split('.').last.toLowerCase() : 'jpg';
      final presigned = await ApiClient.instance.requestUploadUrl(ext);
      final bytes = await file.readAsBytes();
      await ApiClient.instance.uploadToPresignedUrl(
        presigned['upload_url'] as String,
        bytes,
        contentType: presigned['content_type'] as String,
      );
      keys.add(presigned['file_key'] as String);
    }
    return keys;
  }

  Future<void> _submit() async {
    final link = _urlController.text.trim();
    if (_selectedFiles.isEmpty && link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a proof screenshot or a link before submitting')));
      return;
    }
    if (link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      if (uri == null || !{'http', 'https'}.contains(uri.scheme.toLowerCase()) || uri.host.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid HTTP(S) proof link')));
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final proofKeys = await _uploadSelectedFiles();
      await ApiClient.instance.submitTask(widget.taskID, proofKeys, proofLink: link.isEmpty ? null : link);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskSubmitted(points: widget.points, earnings: widget.earnings, type: widget.type, treasureID: widget.treasureID)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  static Widget _buildSubmissionItem({required String title, required String date, required String comment, required String status, required Color statusColor, required String photoUrl}) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: photoUrl.isEmpty
                  ? const Icon(Icons.link, color: Colors.grey)
                  : Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Submitted $date', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(comment),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: const Text('Task Submission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.of(context).pop()),
          actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Notifications())), icon: const Icon(Icons.notifications_rounded, color: Colors.black))],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getPreviousSubmissions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: Colors.black);
                final submissions = snapshot.data ?? [];
                return Column(
                  children: [
                    SizedBox(height: 2.h),
                    uploadCard(),
                    SizedBox(height: 2.h),
                    formCard(),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: 90.w,
                      child: Card(
                        elevation: 6,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Previous Submissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 3.h),
                              if (submissions.isEmpty)
                                const Text('No submissions yet')
                              else
                                Column(
                                  children: submissions.map((submission) {
                                    final submittedAt = DateTime.tryParse((submission['submitted_at'] ?? '').toString());
                                    final date = submittedAt != null ? '${submittedAt.year}-${submittedAt.month.toString().padLeft(2, '0')}-${submittedAt.day.toString().padLeft(2, '0')}' : '';
                                    final status = (submission['status'] ?? 'pending').toString();
                                    final photoUrl = (submission['preview_url'] ?? '').toString();
                                    final comment = status == 'rejected' ? (submission['rejection_reason'] ?? 'Rejected').toString() : '₦${submission['pay_ngn'] ?? 0}';
                                    final displayStatus = status.isEmpty ? 'Pending' : '${status[0].toUpperCase()}${status.substring(1)}';
                                    final statusColor = status == 'approved' ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: _buildSubmissionItem(
                                        title: (submission['task_title'] ?? '').toString(),
                                        photoUrl: photoUrl,
                                        date: date,
                                        comment: comment,
                                        status: displayStatus,
                                        statusColor: statusColor,
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(width: 90.w, height: 7.h, child: ElevatedButton(onPressed: _submitting ? null : _submit, child: Text(_submitting ? 'Submitting…' : 'Submit'))),
                    SizedBox(height: 2.h),
                  ],
                );
              },
            ),
          ),
        ),
      );
}
import 'package:click_workers/Mobile/Tasks/task_submitted.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/Home/notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:click_workers/services/api_client.dart';

class SubmitTask extends StatefulWidget {
  const SubmitTask({
    super.key,
    required this.taskID,
    required this.earnings,
    required this.points,
    required this.type,
    required this.treasureID,
  });

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

  /// Pick file from gallery/camera
  Future<void> pickFile() async {
    final XFile? file = await _picker.pickMedia();

    if (file != null) {
      final fileSize = await file.length();
      if (fileSize <= 7 * 1024 * 1024) {
        setState(() {
          _selectedFiles.add(file);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File too large (max 7MB)")),
          );
        }
      }
    }
  }

  /// Build preview grid for selected files
  Widget buildSelectedFilesPreview() {
    if (_selectedFiles.isEmpty) return const Text("No file selected");

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedFiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final file = _selectedFiles[index];
        final isVideo = file.path.toLowerCase().endsWith(".mp4");

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isVideo
                  ? Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(Icons.videocam, size: 40, color: Colors.orange),
                      ),
                    )
                  : Image.network(
                      file.path,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFiles.removeAt(index);
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Previous submissions for this specific task. GET /tasks/my-submissions
  /// doesn't take a task_id filter (it's meant for a general history view),
  /// so this filters client-side — the list is capped at 100 server-side,
  /// which is small enough for that to be fine.
  Future<List<Map<String, dynamic>>> getPreviousSubmissions() async {
    final all = await ApiClient.instance.mySubmissions();
    return all
        .where((s) => (s as Map<String, dynamic>)['task_id'] == widget.taskID)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// Widget for upload card
  Widget uploadCard() {
    return SizedBox(
      width: 90.w,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Evidence of Completion',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 3.h),
              InkWell(
                onTap: pickFile,
                child: Container(
                  width: 80.w,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 3.h),
                      const Icon(Icons.cloud_upload_sharp, size: 48, color: Colors.black),
                      SizedBox(height: 2.h),
                      const Text(
                        'Drop files here or click to upload',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      const Text(
                        'Supports PNG, JPG, MP4 (Max 7MB)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
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
  }

  /// Widget for URL form + file preview
  Widget formCard() {
    return SizedBox(
      width: 90.w,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSelectedFilesPreview(),
              const SizedBox(height: 16),
              const Text(
                'Task URL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'http://',
                  hintStyle: const TextStyle(color: Color(0xff6b7280)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Uploads every selected file to its own presigned URL, in order, and
  /// returns the resulting public URLs. Was previously entirely unused —
  /// the original "Submit" button never uploaded anything or called any
  /// backend/Firestore write at all; it just navigated straight to a
  /// confirmation screen regardless of what (if anything) was selected.
  Future<List<String>> _uploadSelectedFiles() async {
    final urls = <String>[];
    for (final file in _selectedFiles) {
      final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
      final presigned = await ApiClient.instance.requestUploadUrl(ext);
      final bytes = await file.readAsBytes();
      await ApiClient.instance.uploadToPresignedUrl(presigned['upload_url'], bytes);
      urls.add(presigned['public_url'] as String);
    }
    return urls;
  }

  /// Widget for submit button
  Widget submitButton() {
    return SizedBox(
      width: 90.w,
      height: 7.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _submitting
            ? null
            : () async {
                if (_selectedFiles.isEmpty && _urlController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Add a proof screenshot or a link before submitting")),
                  );
                  return;
                }
                setState(() => _submitting = true);
                try {
                  final proofUrls = await _uploadSelectedFiles();
                  await ApiClient.instance.submitTask(
                    widget.taskID,
                    proofUrls,
                    proofLink: _urlController.text.trim().isEmpty
                        ? null
                        : _urlController.text.trim(),
                  );
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskSubmitted(
                        points: widget.points,
                        earnings: widget.earnings,
                        type: widget.type,
                        treasureID: widget.treasureID,
                      ),
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    setState(() => _submitting = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
        child: Text(_submitting ? "Submitting…" : "Submit"),
      ),
    );
  }

  /// Widget for individual submission item
  static Widget _buildSubmissionItem({
    required String title,
    required String date,
    required String comment,
    required String status,
    required Color statusColor,
    required String photoUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: photoUrl.isEmpty
                ? const Icon(Icons.link, color: Colors.grey)
                : Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Submitted $date',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Text(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Task Submission',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Notifications()),
            ),
            icon: const Icon(Icons.notifications_rounded, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: getPreviousSubmissions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.black);
              }

              final submissions = snapshot.data ?? [];

              return Column(
                children: [
                  SizedBox(height: 2.h),
                  uploadCard(),
                  SizedBox(height: 2.h),
                  formCard(),
                  SizedBox(height: 2.h),

                  // Previous submissions card
                  SizedBox(
                    width: 90.w,
                    child: Card(
                      elevation: 6,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Previous Submissions',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 3.h),
                            if (submissions.isEmpty)
                              const Text("No submissions yet")
                            else
                              Column(
                                children: submissions.map((submission) {
                                  final submittedAt = DateTime.tryParse(
                                      (submission['submitted_at'] ?? '').toString());
                                  final date = submittedAt != null
                                      ? "${submittedAt.year}-${submittedAt.month.toString().padLeft(2, '0')}-${submittedAt.day}"
                                      : '';
                                  final status = (submission['status'] ?? 'pending').toString();
                                  final proofUrls = (submission['proof_urls'] as List?) ?? [];
                                  final photoUrl = proofUrls.isNotEmpty ? proofUrls.first.toString() : '';
                                  final comment = status == 'rejected'
                                      ? (submission['rejection_reason'] ?? 'Rejected').toString()
                                      : "₦${submission['pay_ngn'] ?? 0}";
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: _buildSubmissionItem(
                                      title: (submission['task_title'] ?? '').toString(),
                                      photoUrl: photoUrl,
                                      date: date,
                                      comment: comment,
                                      status: status[0].toUpperCase() + status.substring(1),
                                      statusColor: status == 'approved'
                                          ? Colors.green
                                          : status == 'rejected'
                                              ? Colors.red
                                              : Colors.orange,
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
                  submitButton(),
                  SizedBox(height: 2.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}



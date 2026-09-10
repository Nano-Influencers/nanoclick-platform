import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/KYC/agreement.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/services/kyc_draft.dart';

class SupportingDocuments extends StatefulWidget {
  const SupportingDocuments({super.key});
  @override
  State<SupportingDocuments> createState() => _SupportingDocumentsState();
}

class _SupportingDocumentsState extends State<SupportingDocuments> {
  String idType = 'Select ID Type';
  PlatformFile? selectedFile;
  bool uploading = false;

  static const idTypes = [
    'National ID', 'Driver’s License', 'International Passport',
    'Voter’s Card', 'Student ID',
  ];

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    setState(() => selectedFile = result.files.single);
  }

  Future<void> _continue() async {
    if (idType == 'Select ID Type' || selectedFile?.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an ID type and upload your document')),
      );
      return;
    }

    setState(() => uploading = true);
    try {
      final file = selectedFile!;
      final ext = (file.extension ?? 'png').toLowerCase();
      final upload = await ApiClient.instance.requestKycUploadUrl(ext);
      await ApiClient.instance.uploadToPresignedUrl(
        upload['upload_url'] as String,
        file.bytes!,
      );
      KycDraft.instance.documentUrl = upload['file_key'] as String;
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Agreement()));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document upload failed. Please try again.')));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification'), backgroundColor: Colors.white),
      backgroundColor: const Color(0xffeeeeee),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Supporting Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              const Text('Select the type of identification you will use.'),
              SizedBox(height: 1.h),
              DropdownButtonFormField<String>(
                value: idType == 'Select ID Type' ? null : idType,
                hint: const Text('Select ID Type'),
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: idTypes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => idType = v ?? idType),
              ),
              SizedBox(height: 2.h),
              const Text('Upload a clear image of the identification document.'),
              SizedBox(height: 1.h),
              SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(
                onPressed: uploading ? null : _pickDocument,
                icon: const Icon(Icons.upload_file),
                label: Text(selectedFile == null ? 'Choose document' : selectedFile!.name),
              )),
              SizedBox(height: 3.h),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: uploading ? null : _continue,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: uploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Continue'),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/KYC/supporting_documents.dart';
import 'package:click_workers/services/kyc_draft.dart';

class SMCheck extends StatefulWidget {
  const SMCheck({super.key});
  @override
  State<SMCheck> createState() => _SMCheckState();
}

class _SMCheckState extends State<SMCheck> {
  String? chatsWithAccount;
  String? hasProfilePicture;
  String? changedPicture;
  String? usesRealName;
  String? usesRealPicture;
  String firstPlatform = 'Select first most active platform';
  String secondPlatform = 'Select second most active platform';

  static const platforms = [
    'Instagram', 'TikTok', 'Twitter (X)', 'Facebook', 'YouTube',
    'LinkedIn', 'Snapchat', 'Threads',
  ];

  bool get complete => chatsWithAccount != null &&
      hasProfilePicture != null && changedPicture != null &&
      usesRealName != null && usesRealPicture != null &&
      firstPlatform != 'Select first most active platform' &&
      secondPlatform != 'Select second most active platform';

  void _continue() {
    if (!complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    final draft = KycDraft.instance;
    draft.isVerifiedOnPlatform = chatsWithAccount == 'Yes';
    draft.usesRealName = usesRealName == 'Yes';
    draft.usesRealPhoto = usesRealPicture == 'Yes';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SupportingDocuments()),
    );
  }

  Widget _yesNo(String title, String? value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Expanded(child: RadioListTile<String>(
            dense: true, contentPadding: EdgeInsets.zero,
            title: const Text('Yes'), value: 'Yes', groupValue: value,
            onChanged: (v) { if (v != null) onChanged(v); },
          )),
          Expanded(child: RadioListTile<String>(
            dense: true, contentPadding: EdgeInsets.zero,
            title: const Text('No'), value: 'No', groupValue: value,
            onChanged: (v) { if (v != null) onChanged(v); },
          )),
        ]),
      ],
    );
  }

  Widget _platform(String label, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value.startsWith('Select') ? null : value,
      hint: Text(label),
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
      onChanged: onChanged,
    );
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
              const Text('Social Media Check', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              _yesNo('Do you currently chat with this account?', chatsWithAccount, (v) => setState(() => chatsWithAccount = v)),
              _yesNo('Does your account have a profile picture?', hasProfilePicture, (v) => setState(() => hasProfilePicture = v)),
              _yesNo('Have you changed your profile picture in the last 3 months?', changedPicture, (v) => setState(() => changedPicture = v)),
              _yesNo('Do you use your real name on your profile?', usesRealName, (v) => setState(() => usesRealName = v)),
              _yesNo('Do you use your real picture on your profile?', usesRealPicture, (v) => setState(() => usesRealPicture = v)),
              SizedBox(height: 2.h),
              const Text('Your 2 most active social media accounts', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 1.h),
              _platform('First most active platform', firstPlatform, (v) => setState(() => firstPlatform = v ?? firstPlatform)),
              SizedBox(height: 1.h),
              _platform('Second most active platform', secondPlatform, (v) => setState(() => secondPlatform = v ?? secondPlatform)),
              SizedBox(height: 3.h),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Continue'),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

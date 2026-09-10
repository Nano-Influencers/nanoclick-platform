import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/services/kyc_draft.dart';

class Agreement extends StatefulWidget {
  const Agreement({super.key});
  @override
  State<Agreement> createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  bool agreed = false;
  bool submitting = false;

  Future<void> _submit() async {
    if (!agreed || submitting) return;
    final draft = KycDraft.instance;
    if (draft.documentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your supporting document first.')),
      );
      return;
    }

    setState(() => submitting = true);
    try {
      await ApiClient.instance.submitKyc(draft.toJson());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC submitted for review.')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC submission failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
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
              const Text('Agreement & Submission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(color: const Color(0xffeeeeee), borderRadius: BorderRadius.circular(14)),
                child: const Text(
                  'By submitting this form, I confirm that the information provided is accurate and complete. I understand that false information may result in disqualification from the ClickWorkers platform.',
                  style: TextStyle(color: Color(0xff6b7280)),
                ),
              ),
              SizedBox(height: 2.h),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: agreed,
                onChanged: submitting ? null : (v) => setState(() => agreed = v ?? false),
                title: const Text('I have read and agree to the Terms and Conditions and Privacy Policy. I confirm that all information provided is accurate and complete.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 2.h),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: agreed && !submitting ? _submit : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Application'),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

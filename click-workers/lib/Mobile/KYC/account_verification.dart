import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'account_check.dart';

class SMAccountVerification extends StatelessWidget {
  const SMAccountVerification({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('KYC Verification'), backgroundColor: Colors.white),
    backgroundColor: const Color(0xffeeeeee),
    body: Padding(
      padding: EdgeInsets.all(5.w),
      child: Card(child: Padding(padding: EdgeInsets.all(5.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Social Media Account Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 2.h),
        const Text('Confirm the social media information requested in the next step. Your answers are kept in the local KYC draft and are submitted once to the backend at the final step.'),
        const Spacer(),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SMCheck())),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text('Continue'),
        )),
      ]))),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../KYC/user_agreement.dart';

class NoKycClaim extends StatefulWidget {
  const NoKycClaim({super.key, required this.controller});

  final PageController controller;

  @override
  State<NoKycClaim> createState() => _NoKycClaimState();
}

class _NoKycClaimState extends State<NoKycClaim> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 8.h,
              ),
              Container(
                width: 90.w,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xff092e57),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("Complete your KYC to be able to Claim Prize",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 4.h),
              Container(
                width: 90.w,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xff9e1d22),
                    borderRadius: BorderRadius.circular(16)),
                child: const Text(
                    "Only worker swho have completed their KYC can Claim Prize. You have 7days to Claim Prize or it would be forfeited",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
              SizedBox(height: 4.h),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserAgreement()),
                  );
                },
                child: Container(
                  width: 40.w,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff092e57),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        spreadRadius: 1,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: const Text("Complete KYC",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              SizedBox(height: 3.h),
              TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Future.delayed(Duration.zero, () {
                      widget.controller.jumpToPage(0);
                    });
                  },
                  child: const Text("Go Home",
                      style: TextStyle(
                          color: Color(0xff092e57),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xff092e57))))
            ],
          ),
        ),
      ),
    );
  }
}

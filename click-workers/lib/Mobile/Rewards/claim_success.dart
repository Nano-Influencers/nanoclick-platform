import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ClaimSuccess extends StatefulWidget {
  const ClaimSuccess({super.key, required this.controller});

  final PageController controller;
  @override
  State<ClaimSuccess> createState() => _ClaimSuccessState();
}

class _ClaimSuccessState extends State<ClaimSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffeeeeee),
        body: Center(
          child: Column(children: [
            SizedBox(height: 6.h),
            Container(
                padding: const EdgeInsets.all(20),
                width: 90.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: 90.w,
                      decoration: BoxDecoration(
                          color: const Color(0xff092e57),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text("Prize Claimed Successfully",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xff00d300),
                      child: Icon(Icons.check, color: Colors.white, size: 80),
                    ),
                    SizedBox(height: 1.h),
                  ],
                )),
            SizedBox(height: 3.h),
            InkWell(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Future.delayed(Duration.zero, () {
                  widget.controller.jumpToPage(1);
                });
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
                child: const Text("Continue to Tasks",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
            SizedBox(height: 2.h),
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
          ]),
        ));
  }
}

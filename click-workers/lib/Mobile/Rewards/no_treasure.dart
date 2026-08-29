import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NoTreasure extends StatefulWidget {
  const NoTreasure({
    super.key,
    required this.controller,
  });
  final PageController controller;

  @override
  State<NoTreasure> createState() => _NoTreasureState();
}

class _NoTreasureState extends State<NoTreasure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffeeeeee),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(height: 4.h),
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
                        child: Text("No Treasure Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    const Text(
                      "Check in Shortly",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xfffe6929)),
                    ),
                    SizedBox(height: 2.h),
                    Image.network(
                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1757514099/REWARDS_CLICKWORKERS__13___1_-removebg-preview_j6lb8x.png",
                        scale: 4),
                    SizedBox(height: 1.h),
                  ],
                )),
            SizedBox(height: 2.h),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(Duration.zero, () {
                    widget.controller.jumpToPage(0);
                  });
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(40.w, 3.h), // width, height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // round corners
                  ),
                ),
                child: const Text("GO HOME"))
          ]),
        ));
  }
}

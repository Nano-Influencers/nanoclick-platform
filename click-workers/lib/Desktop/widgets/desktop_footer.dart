import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/authentication/sign_up.dart';

class DesktopFooter extends StatelessWidget {
  final ScrollController scrollController;
  const DesktopFooter({super.key, required this.scrollController});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 4.5.w,vertical: 5.h),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Column(children: [
                    Row(
                      children: [
                        Image.asset("assets/logo_icon.png", scale: 8),
                        SizedBox(width: 2.w),
                        const Text("Click Workers",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    const Text(
                        "ClickWorkers helps you earn\nmoney and win prizes by\ncompleting simple tasks in your\nspare time.",
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    SizedBox(height: 2.h),
                    Row(children: [
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset("assets/Facebook.png")),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset("assets/instagram.png")),
                      IconButton(
                          onPressed: () {}, icon: Image.asset("assets/X.png")),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset("assets/LinkedIn.png")),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset("assets/Youtube.png")),
                    ]),
                  ]),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Quick Links",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      TextButton(
                          onPressed: () {
                            scrollController.animateTo(
                              0, // Top of the screen
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text("Home",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {},
                          child: const Text("About Us",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent /
                                  14, // Top of the screen
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text("How it works",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: const Text("Tasks",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: const Text("Rewards",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: const Text("Testimonials",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                    ],
                  ),
                  SizedBox(width: 4.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Support",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      TextButton(
                          onPressed: () {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent /
                                  1.2, // Top of the screen
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text("FAQs",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {},
                          child: const Text("Contact Us",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {},
                          child: const Text("Privacy Policy",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                      TextButton(
                          onPressed: () {},
                          child: const Text("Terms and Conditions",
                              style: TextStyle(
                                color: Colors.white,
                              ))),
                    ],
                  ),
SizedBox(width:6.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contact Info",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 1.h),
                      const Text(" Address",
                          style: TextStyle(color: Color(0xffd5d2d2))),
                      const Text(" Awka, Anambra State",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 1.h),
                      const Text(" Email Address",
                          style: TextStyle(color: Color(0xffd5d2d2))),
                      const Text(" info@clickworker.com",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 1.h),
                      const Text(" Phone Number",
                          style: TextStyle(color: Color(0xffd5d2d2))),
                      const Text(" 09067655677",
                          style: TextStyle(color: Colors.white)),
                      const Text(" 09067655677",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 4.h),
                   
                    ],
                  ),
                  SizedBox(width:6.w),
                ]),
                SizedBox(height: 7.h,),
                Row(
                  children: [
                       RichText(
                          text: const TextSpan(
                              text: "© 2025 ",
                              style: TextStyle(color: Colors.white),
                              children: [
                            TextSpan(
                              text: "ClickWorkers.",
                              style: TextStyle(color: Color(0xffff6533)),
                            ),
                            TextSpan(
                              text: " All rights reserved",
                              style: TextStyle(color: Colors.white),
                            ),
                          ])),
                          Spacer(),
                    TextButton(
                        onPressed: () {},
                        child: const Text("Privacy Policy",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white))),
                    TextButton(
                        onPressed: () {},
                        child: const Text("Terms of Service",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white))),
                    TextButton(
                        onPressed: () {},
                        child: const Text("Cookies Policy",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white))),
                  ],
                )
              ],
            )));
  }
}

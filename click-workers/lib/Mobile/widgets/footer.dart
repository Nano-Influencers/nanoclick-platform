import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/authentication/sign_up.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  final ScrollController scrollController;
  const Footer({super.key, required this.scrollController});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Image.asset("assets/logo_icon.png", scale: 8),
                SizedBox(width: 2.w),
                const Text("Click Workers",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ]),
              SizedBox(height: 3.h),
              const Text(
                  "ClickWorkers helps you earn\nmoney and win prizes by\ncompleting simple tasks in your\nspare time.",
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              SizedBox(height: 2.h),
              Row(children: [
                IconButton(
                    onPressed: () {
                      openLink('https://www.facebook.com/Clickworkers/');
                    },
                    icon: Image.asset("assets/Facebook.png")),
                IconButton(
                    onPressed: () {
                      openLink('https://www.instagram.com/click_workers/');
                    },
                    icon: Image.asset("assets/instagram.png")),
                IconButton(
                    onPressed: () {
                      openLink('https://x.com/ClikWorkers');
                    },
                    icon: Image.asset("assets/X.png")),
                IconButton(
                    onPressed: () {
                      openLink('https://whatsapp.com/channel/0029VbCSFtQDJ6GyzVXm0l3A');
                    }, icon: Image.asset("assets/whatsapp2.png",)),
               
                IconButton(
                    onPressed: () {
                      openLink(
                          'https://www.tiktok.com/@click_workers');
                    },
                    icon: Image.asset("assets/tiktok.png")),
                    IconButton(
                    onPressed: () {
                      openLink(
                          'https://t.me/+w2PbuF3r0LcyNTZk');
                    },
                    icon: Image.asset("assets/telegram2.png",)),
                IconButton(
                    onPressed: () {
                      openLink(
                          'https://www.youtube.com/channel/UCECrZ4-3sJmd7Oa-rIxn8DQ');
                    },
                    icon: Image.asset("assets/Youtube.png")),
              ]),
              SizedBox(height: 2.h),
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
                      MaterialPageRoute(builder: (context) => const SignUp()),
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
                      MaterialPageRoute(builder: (context) => const SignUp()),
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
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: const Text("Testimonials",
                      style: TextStyle(
                        color: Colors.white,
                      ))),
              SizedBox(height: 2.h),
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
                  onPressed: () {
                    openGmailLink();
                  },
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
              SizedBox(height: 2.h),
              const Text("Contact Info",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 1.h),
              const Text(" Address",
                  style: TextStyle(color: Color(0xffd5d2d2))),
              const Text(" Abuja, Nigeria",
                  style: TextStyle(color: Colors.white)),
              SizedBox(height: 1.h),
              const Text(" Email Address",
                  style: TextStyle(color: Color(0xffd5d2d2))),
              const Text(" info@clickworker.com",
                  style: TextStyle(color: Colors.white)),     
              SizedBox(height: 4.h),
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
              Row(children: [
                TextButton(
                    onPressed: () {
                      openLink('https://docs.google.com/document/d/1_NepunQdFUiS3kJkadvvkhHv0oATsBOrvIWu4Wsg3Zw/preview');
                    },
                    child: const Text("Privacy Policy",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white))),
                TextButton(
                    onPressed: () {
                      openLink(
                          'https://docs.google.com/document/d/1bdNWsB2GuHBHnRFQwhKGLKQUOdzee7-BEEXrCWkedMU/preview');
                    },
                    child: const Text("Terms of Service",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white))),
              ])
            ])));
  }

  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch$url';
    }
  }

  Future<void> openGmailLink() async {
    final emailUri = Uri(
        scheme: 'mailto',
        path: 'theclickworkers@gmail.com',
        query: 'subject=Hello&body= Hi there');
    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      throw 'Could not email';
    }
  }
}

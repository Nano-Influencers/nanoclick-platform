import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'kyc_personal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAgreement extends StatefulWidget {
  const UserAgreement({super.key});

  @override
  State<UserAgreement> createState() => _UserAgreementState();
}

class _UserAgreementState extends State<UserAgreement> {
  bool isChecked = false;
  late YoutubePlayerController _controller;
  @override
  void initState() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'OHz0xIR8uwI',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: true,
      ),
    );
    super.initState();
  }

  Future<void> updateKycProgress(double value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("No user logged in");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.set(
      {
        "kycProgress": value,
      },
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('User Agreement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xffeeeeee),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 90.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),
                const Text(
                  "Account Rule & Limitations",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 1.h),
                const Text(
                  "Important guidelines for KYC verification and account usage. Please read carefully before proceeding.",
                  style: TextStyle(
                      color: Color(0xff6b7280), fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Icon(
                                  CupertinoIcons.exclamationmark_shield_fill,
                                  color: Color(0xff1c274c)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Why these rules matter",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "These rules ensure platform integrity and maximize your earning potential. Non-compliance may limit your account functionality.",
                              style: TextStyle(color: Color(0xff6b7280)))
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("1",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Follow Limitations",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Users cannot have more than ¼ following-follower ratio. For example, if you have 25 followers, you cannot follow more than 100 people.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: const Color(0xffd1d5db),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        const Icon(
                                            CupertinoIcons
                                                .person_crop_circle_badge_checkmark,
                                            color: Color(0xff6b7280)),
                                        SizedBox(width: 1.w),
                                        const Text("Following",
                                            style: TextStyle(
                                                color: Color(0xff6b7280)))
                                      ]),
                                      const Text("Max 100",
                                          style: TextStyle(
                                              color: Color(0xff6b7280)))
                                    ]),
                                SizedBox(height: 1.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 1, // from 0.0 to 1.0
                                    minHeight: 6,
                                    backgroundColor: Color(0xffd9d9d9),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        const Icon(
                                            CupertinoIcons
                                                .person_badge_plus_fill,
                                            color: Color(0xff6b7280)),
                                        SizedBox(width: 1.w),
                                        const Text("Followers",
                                            style: TextStyle(
                                                color: Color(0xff6b7280)))
                                      ]),
                                      const Text("Min 25",
                                          style: TextStyle(
                                              color: Color(0xff6b7280)))
                                    ]),
                                SizedBox(height: 1.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.25, // from 0.0 to 1.0
                                    minHeight: 6,
                                    backgroundColor: Colors.white,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                ),
                              ]))
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("2",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Social Media Account Adding",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Users can add up to 10 unique verified social media accounts under ClickWorkers.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffe3ebf9),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Image.asset("assets/Facebook.png",
                                        color: const Color(0xff0866ff))),
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffe3ebf9),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Image.asset(
                                      "assets/telegram.png",
                                    )),
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffe3ebf9),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Image.asset(
                                      "assets/whatsapp.png",
                                    )),
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: const Color(0xfff4dbd8),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Image.asset(
                                      "assets/insta.png",
                                    )),
                              ])
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("3",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Withdrawal Requirements",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "You cannot perform withdrawal if your account hasn't completed KYC verification.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xffd1d5db),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Image.asset("assets/icons/wallet.png",
                                          color: Colors.black),
                                      SizedBox(width: 2.w),
                                      const Text("Withdrawal",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ]),
                                    Row(children: [
                                      const Icon(Icons.lock,
                                          color: Colors.black),
                                      SizedBox(width: 2.w),
                                      const Text("Locked",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ]),
                                  ])),
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("4",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Real Social Accounts Only",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 3.h,
                          ),
                          const Text(
                              "Users must use their real social accounts for ads and tasks. Do not create new accounts for ads or tasks, unless you are new to the platform.",
                              style: TextStyle(color: Color(0xff6b7280))),
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("5",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Username Requirements",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Usernames must not contain any spaces, numbers or special characters. Multiple names should be joined by an underscore.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xfff4c7c8),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                const Icon(Icons.close,
                                    color: Color(0xffff0004)),
                                SizedBox(width: 3.w),
                                const Text("michael 1099308979",
                                    style: TextStyle(
                                        color: Color(0xff6b7280),
                                        fontWeight: FontWeight.bold))
                              ])),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xffc7efd6),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                const Icon(Icons.check,
                                    color: Color(0xff22c55e)),
                                SizedBox(width: 3.w),
                                const Text("michael_johnson",
                                    style: TextStyle(
                                        color: Color(0xff6b7280),
                                        fontWeight: FontWeight.bold))
                              ])),
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("6",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("ID Verification",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Account username must match the real name on your ID card that you provide for KYC verification.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                  color: const Color(0xffd1d5db),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.badge,
                                          color: Colors.black)),
                                  title: Text("ID Card Name",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text("Must match your username",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff6b7280))))),
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("7",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Complete Profile Setup",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Your account must be properly set-up: add description, profession, etc. Accounts without completing all major steps of social media account creation would be flagged by the admin as fake.",
                              style: TextStyle(color: Color(0xff6b7280))),
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("8",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Posting Requirements",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Your account must be properly set-up: add description, profession, etc. Accounts without completing all major steps of social media account creation would be flagged by the admin as fake.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          Container(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("1-2 personal posts per week",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 0.5.h),
                                    const Text(
                                        "On added social media (Instagram, Facebook, TikTok, etc.)",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xff6b7280))),
                                  ])),
                          Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("1 generic post",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 0.5.h),
                                    const Text(
                                        "To qualify for weekly/daily/monthly giveaways and leaderboard competitions",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xff6b7280))),
                                  ])),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xffd1d5db),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                      CupertinoIcons
                                          .exclamationmark_shield_fill,
                                      color: Colors.black),
                                ),
                                SizedBox(width: 2.w),
                                const Text(
                                    "Your account would be flagged as\nfake if you are not posting regularly\non social media",
                                    style: TextStyle(
                                        color: Color(0xff6b7280), fontSize: 12))
                              ])),
                        ],
                      )),
                ),
                SizedBox(height: 2.h),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("9",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Trusted Worker Status",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Complete KYC and work consistently to earn special benefits.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: const Color(0xffd1d5db),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.verified_user,
                                            color: Colors.black),
                                        SizedBox(width: 1.w),
                                        const Text("Qualification",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
                                      ]),
                                    ]),
                                SizedBox(height: 1.h),
                                const Text(
                                    "Complete KYC verification and work consistently for one month",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff6b7280))),
                                SizedBox(height: 3.h),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Image.asset("assets/icons/hand.png"),
                                        SizedBox(width: 1.w),
                                        const Text("1 generic post",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))
                                      ]),
                                    ]),
                                SizedBox(height: 1.h),
                                Row(children: [
                                  const Icon(Icons.check,
                                      color: Color(0xff22c55e)),
                                  SizedBox(width: 2.w),
                                  const Text(
                                      "Raffle draws for social media\nblue tick",
                                      style: TextStyle(
                                          color: Color(0xff6b7280),
                                          fontSize: 12))
                                ]),
                                Row(children: [
                                  const Icon(Icons.check,
                                      color: Color(0xff22c55e)),
                                  SizedBox(width: 2.w),
                                  const Text(
                                      "Promotional campaigns to gain\nat least 200 real followers",
                                      style: TextStyle(
                                          color: Color(0xff6b7280),
                                          fontSize: 12))
                                ]),
                              ]))
                        ],
                      )),
                ),
                SizedBox(height: 2.h),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("10",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("ClickWorker Verified Status",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "Users who link all their verified social media accounts qualify for ClickWorker Verified status.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                  color: const Color(0xffd1d5db),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.verified,
                                          color: Colors.black)),
                                  title: Text("Verified Status",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      "Link all your social media accounts",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff6b7280))))),
                        ],
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xffb8becd),
                              child: Text("11",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 2.w),
                            const Text("Follower Ratio Rule",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Text(
                              "ClickWorkers must maintain a follow-to-follower ratio of at most 1:4 to avoid limiting earning and Admin flagging as a pseudo account.",
                              style: TextStyle(color: Color(0xff6b7280))),
                          SizedBox(
                            height: 2.h,
                          ),
                          const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Followers"),
                                Text("Following"),
                              ]),
                          Container(
                              width: 90.w,
                              decoration: BoxDecoration(
                                  color: const Color(0xff6b7280),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 5.w,
                                      child: const Text("  1",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                    Container(
                                        width: 60.w,
                                        decoration: BoxDecoration(
                                            color: const Color(0xffd1d5db),
                                            border: Border.all(
                                              width: 1.w,
                                              color: const Color(0xffd1d5db),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Align(
                                            alignment: Alignment.centerRight,
                                            child: Text("4  ",
                                                style: TextStyle(
                                                    color: Colors.white))))
                                  ])),
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xffd1d5db),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                      CupertinoIcons
                                          .exclamationmark_shield_fill,
                                      color: Colors.black),
                                ),
                                SizedBox(width: 2.w),
                                const Text(
                                    "Exceeding this ratio will limit your\nearning potential",
                                    style: TextStyle(
                                        color: Color(0xff6b7280),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold))
                              ])),
                        ],
                      )),
                ),
                SizedBox(height: 2.h),
                Center(
                  child: Container(
                      width: 85.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffd9d9d9),
                        borderRadius:
                            BorderRadius.circular(16), // 👈 Rounded corners
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: YoutubePlayer(
                          controller: _controller,
                          aspectRatio: 16 / 9,
                        ),
                      )),
                ),
                SizedBox(height: 5.h),
                Row(children: [
                  const CircleAvatar(
                      radius: 10,
                      backgroundColor: Color(0xffd1d5db),
                      child: Icon(Icons.check, color: Colors.white, size: 12)),
                  SizedBox(width: 2.w),
                  const Text("Aknowledgement",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ]),
                SizedBox(height: 2.h),
                const Text(
                    "By proceeding with KYC verification, you acknowledge that you have read and agree to follow all the account rules and limitations outlined above.",
                    style: TextStyle(fontSize: 12, color: Color(0xff6b7280))),
                SizedBox(height: 2.h),
                Row(children: [
                  Checkbox(
                    activeColor: Colors.black,
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = !isChecked;
                      });
                    },
                  ),
                  SizedBox(width: 2.w),
                  const Text(
                      "I have read and agreed to all rules and limitations",
                      style: TextStyle(fontSize: 12))
                ]),
                SizedBox(height: 2.h),
                SizedBox(
                    width: 90.w,
                    height: 8.h,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: !isChecked
                            ? null
                            : () async {
                                await updateKycProgress(0.1);
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const KycPersonal()),
                                  );
                                }
                              },
                        child: const Text("Continue to KYC Verification"))),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

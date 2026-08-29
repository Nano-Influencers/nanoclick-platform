import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../KYC/user_agreement.dart';
import '../authentication/utils/profile_photo_state.dart';
import '../widgets/task_stream.dart';
import '../widgets/wallet_stream.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.controller,
    required this.otherFirestore,
  });

  final PageController controller;
  final FirebaseFirestore? otherFirestore;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
   late YoutubePlayerController _controller;
  bool isVerified = true;
  bool isLinkClicked = false;

  @override
  initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'OHz0xIR8uwI',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffeeeeee),
        body: StreamBuilder<List<dynamic>>(
            stream: multiDataStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.black));
              }

              final walletData = snapshot.data![0] as DocumentSnapshot;
              final userData = snapshot.data![1] as DocumentSnapshot;
              final walletDoc =
                  walletData.data() as Map<String, dynamic>? ?? {};
              final userDoc = userData.data() as Map<String, dynamic>? ?? {};
              final leaderboardDoc = snapshot.data![2]!.docs;

              //  firestoreValue = userDoc['status'];

              return SingleChildScrollView(
                  child: Center(
                      child: Column(children: [
                SizedBox(height: 3.h),
                SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FirebaseAuth.instance.currentUser!.photoURL ==
                                      null
                                  ? CircleAvatar(
                                      radius: 40,
                                      backgroundColor: const Color(0xffeeeeee),
                                      child: Center(
                                          child: Text(
                                              FirebaseAuth.instance.currentUser!
                                                  .displayName![0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.bold))))
                                  : ValueListenableBuilder<String?>(
                                      valueListenable:
                                          ProfilePhotoState.photoUrl,
                                      builder: (context, photoUrl, _) {
                                        return CircleAvatar(
                                          radius: 40,
                                          backgroundImage: photoUrl != null &&
                                                  photoUrl.isNotEmpty
                                              ? NetworkImage(
                                                  FirebaseAuth.instance
                                                      .currentUser!.photoURL
                                                      .toString(),
                                                )
                                              : null,
                                          child: photoUrl == null ||
                                                  photoUrl.isEmpty
                                              ? Center(
                                                  child: Text(
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .displayName![0]
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                          fontSize: 40,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .bold))) // placeholder icon
                                              : null,
                                        );
                                      }),
                              SizedBox(width: 3.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    FirebaseAuth
                                        .instance.currentUser!.displayName!
                                        .split(" ")
                                        .map((w) =>
                                            w[0].toUpperCase() + w.substring(1))
                                        .join(" "),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    userDoc['status'] == "Verified"
                                        ? "  verified"
                                        : "  Non verified",
                                    style: TextStyle(
                                        color: FirebaseAuth.instance
                                                .currentUser!.emailVerified
                                            ? Colors.white
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              SizedBox(width: 1.w),
                              userDoc['status'] == "Verified"
                                  ? const Icon(Icons.check_circle,
                                      color: Color(0xff22c55e), size: 22)
                                  : const SizedBox(
                                      height: 0,
                                    )
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(children: [
                                  const Text("Total click Points",
                                      style:
                                          TextStyle(color: Color(0xffd1d5db))),
                                  Text(
                                      (walletDoc['totalPoints'] ?? 0)
                                          .toString()
                                          .replaceAllMapped(
                                              RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                              (match) => ','),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ]),
                                Column(children: [
                                  const Text("Current Rank",
                                      style:
                                          TextStyle(color: Color(0xffd1d5db))),
                                  Text(walletDoc['currentRank'] ?? 'Platinum',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ]),
                              ])
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                SizedBox(
                    width: 90.w,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(15),
                              width: 40.w,
                              decoration: BoxDecoration(
                                  color: const Color(0xffb0b2b7),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(children: [
                                const Text("Total Earnings",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff6b7280),
                                    )),
                                SizedBox(height: 1.h),
                                Text(
                                    "₦${(walletDoc['totalEarnings'] ?? 0).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ])),
                          Container(
                              padding: const EdgeInsets.all(15),
                              width: 40.w,
                              decoration: BoxDecoration(
                                  color: const Color(0xffb0b2b7),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(children: [
                                const Text("Available Balance",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff6b7280),
                                    )),
                                SizedBox(height: 1.h),
                                Text(
                                    "₦${(walletDoc['availableEarnings'] ?? 0).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ])),
                        ])),
                SizedBox(
                  height: 3.h,
                ),
                SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const CircleAvatar(
                                  radius: 15,
                                  child: Icon(Icons.account_circle,
                                      color: Colors.black),
                                ),
                                SizedBox(width: 2.w),
                                const Text("Kyc Status",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ]),
                              ElevatedButton(
                                onPressed: () {
                                  if (userDoc["kycCompleted"] == true) {
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserAgreement()),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // <-- Adjust the radius
                                  ),
                                ),
                                child: Text(
                                    userDoc["kycCompleted"] == true
                                        ? "Completed"
                                        : "Complete Kyc",
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Progress",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Text(
                                    '${((userDoc['kycProgress'] ?? 0.0) * 100).round()}%',
                                    style: const TextStyle(
                                        color: Color(0xff6b7280),
                                        fontSize: 12)),
                              ]),
                          SizedBox(height: 1.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: userDoc['kycProgress'], // from 0.0 to 1.0
                              minHeight: 6,
                              backgroundColor: const Color(0xffd9d9d9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: const Text("Task Summary",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Ongoing Task",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(userDoc['ongoingTasks'].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          const Divider(color: Color(0xffd1d5db), thickness: 2),
                          SizedBox(height: 1.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Completed Task",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(userDoc['completedTasks'].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff22c55e))),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          const Divider(color: Color(0xffd1d5db), thickness: 2),
                          SizedBox(height: 1.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Missed Task",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(userDoc['missedTasks'].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffff0000))),
                            ],
                          ),
                          SizedBox(height: 1.h),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: 90.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Trending Tasks",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {
                            widget.controller.jumpToPage(1);
                          },
                          child: const Text("see more",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6b7280))))
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: TaskStream(
                    otherFirestore: widget.otherFirestore!,
                    isVertical: true,
                    limit: 2,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 90.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Leader Board",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {
                            widget.controller.jumpToPage(2);
                          },
                          child: const Text("View All",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6b7280))))
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Row(children: [
                          const CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xffffb33a),
                              child: Text("1")),
                          SizedBox(width: 2.w),
                          CircleAvatar(
                              radius: 20,
                              backgroundImage: leaderboardDoc[0]['dp'] == ''
                                  ? const NetworkImage(
                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png")
                                  : NetworkImage(leaderboardDoc[0]['dp'])),
                          SizedBox(width: 3.w),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(leaderboardDoc[0]['name'] ?? "Unnamed",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "${leaderboardDoc[0]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} points",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ])
                        ])),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Row(children: [
                          const CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xffd9d9d9),
                              child: Text("2")),
                          SizedBox(width: 2.w),
                          CircleAvatar(
                              radius: 20,
                              backgroundImage: leaderboardDoc[1]['dp'] == ''
                                  ? const NetworkImage(
                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png")
                                  : NetworkImage(leaderboardDoc[1]['dp'])),
                          SizedBox(width: 3.w),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(leaderboardDoc[1]['name'] ?? "Unnamed",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "${leaderboardDoc[1]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} points",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ])
                        ])),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Row(children: [
                          const CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xffa67629),
                              child: Text("3")),
                          SizedBox(width: 2.w),
                          CircleAvatar(
                              radius: 20,
                              backgroundImage: leaderboardDoc[2]['dp'] == ''
                                  ? const NetworkImage(
                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png")
                                  : NetworkImage(leaderboardDoc[2]['dp'])),
                          SizedBox(width: 3.w),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(leaderboardDoc[2]['name'] ?? "Unnamed",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "${leaderboardDoc[2]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} points",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ])
                        ])),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: const Text("Achievements",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                    width: 90.w,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Level Progress",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Text("Level 1",
                                    style: TextStyle(
                                        color: Color(0xff6b7280),
                                        fontSize: 12)),
                              ]),
                          SizedBox(height: 1.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 0.1, // from 0.0 to 1.0
                              minHeight: 6,
                              backgroundColor: Color(0xffd9d9d9),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          const Text("2,500 pts to next level",
                              style: TextStyle(
                                  color: Color(0xff6b7280), fontSize: 12)),
                        ])),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 22.w,
                        height: 14.h,
                        child: Card(
                          elevation: 6, // adds shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                        radius: 20,
                                        child: Image.asset(
                                            "assets/icons/streak.png")),
                                    SizedBox(height: 0.5.h),
                                    const Text("Streak Master",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ])),
                        ),
                      ),
                      SizedBox(
                        width: 22.w,
                        height: 14.h,
                        child: Card(
                          elevation: 6, // adds shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                        radius: 20,
                                        child: Image.asset(
                                            "assets/icons/star.png")),
                                    SizedBox(height: 1.h),
                                    const Text("Elite",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ])),
                        ),
                      ),
                      SizedBox(
                        width: 22.w,
                        height: 14.h,
                        child: Card(
                          elevation: 6, // adds shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                        radius: 20,
                                        child: Image.asset(
                                            "assets/icons/cup.png")),
                                    SizedBox(height: 1.h),
                                    const Text("Champion",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ])),
                        ),
                      ),
                      SizedBox(
                        width: 22.w,
                        height: 14.h,
                        child: Card(
                          elevation: 6, // adds shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                        radius: 20,
                                        child: Image.asset(
                                            "assets/icons/crown.png")),
                                    SizedBox(height: 1.h),
                                    const Text("Legend",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ])),
                        ),
                      ),
                    ],
                  ),
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
                SizedBox(height: 4.h),
                Container(
                    width: 85.w,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xfffe6929),
                          Color(0xfff45e2a),
                          Color(0xffc23707),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Refer & Earn 5% Extra",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 2.h),
                          const Text(
                              "Invite your friends to join ClickWorkers and earn 5% of their earnings for life. The more friends you refer, the more you earn",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          SizedBox(height: 3.h),
                          const Text("Your Referral Link",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 2.h),
                          Container(
                              padding: const EdgeInsets.only(right: 1.0),
                              width: 80.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width: 58.w,
                                        height: 8.h,
                                        decoration: const BoxDecoration(
                                          color: Color(0xfffe6929),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(30.0),
                                            topLeft: Radius.circular(30.0),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                              "https://click-workers.com/${userDoc['refID']}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        )),
                                    InkWell(
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text:
                                                  "https://click-workers.com/${userDoc['refID']}"));
                                          setState(() {
                                            isLinkClicked = true;
                                          });
                                        },
                                        child: Container(
                                            width: 50,
                                            padding: const EdgeInsets.all(5),
                                            child: isLinkClicked
                                                ? const Icon(Icons.check,
                                                    color: Color(0xfffe6929),
                                                    size: 12)
                                                : const Text(" Copy",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xfffe6929),
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                  ])),
                          SizedBox(height: 2.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Referrals:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                Text(
                                    "${walletDoc['referrals'].toString()} person(s)",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ]),
                          SizedBox(height: 1.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Earnings from Referrals:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                Text("₦${walletDoc['totalReferralEarnings']}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ]),
                        ])),
                SizedBox(height: 3.h),
              ])));
            }));
  }
}


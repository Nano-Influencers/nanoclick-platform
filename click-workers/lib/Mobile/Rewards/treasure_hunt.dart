import 'package:click_workers/Mobile/Rewards/treasure_history.dart';
import 'package:click_workers/Mobile/Rewards/treasure_hunters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:responsive_sizer/responsive_sizer.dart';

//import 'no_kyc.dart';

class TreasureHunt extends StatefulWidget {
  const TreasureHunt({
    super.key,
    required this.controller,
    required this.kycCompleted,
  });
  final PageController controller;
  final bool kycCompleted;

  @override
  State<TreasureHunt> createState() => _TreasureHuntState();
}

class _TreasureHuntState extends State<TreasureHunt> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool showAll = false;
  String points = "0";
  String balance = "0";
  bool hint = false;
  bool isActive = true;
  String hintText = "";
  int found = 0;
  int hintUsed = 0;
  int huntedDown = 0;
  int participated = 0;
  List itemsWon = ["None Yet"];
  String spentEarnings = "₦0";
  String spentPoints = "0RCPs";
  String weeklyStatus = "Participating";

  @override
  void initState() {
    super.initState();
    getPointBal();
    getTreasureData(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> getPointBal() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('wallets')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      //  Update a variable in your state

      setState(() {
        points = data!['availableReferralPoints'].toString();
        balance = data['availableEarnings'];
        //totalPoints = data['totalPoints'];
      });
    }
  }

  Future<void> unlockHint(BuildContext context, String uid,
      {bool useEarnings = false}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final walletRef = FirebaseFirestore.instance.collection('wallets').doc(uid);
    final hintRef =
        FirebaseFirestore.instance.collection('announcements').doc('treasures');

    // Get last hint usage
    final userDoc = await userRef.get();
    final lastHintUsed = userDoc['lastHintUsed'];
    final now = DateTime.now();

    // Check if used already this week
    if (lastHintUsed != null) {
      final lastDate = (lastHintUsed as Timestamp).toDate();
      final currentWeek =
          DateTime(now.year, now.month, now.day - now.weekday + 1);
      final lastWeek = DateTime(
          lastDate.year, lastDate.month, lastDate.day - lastDate.weekday + 1);

      if (currentWeek.year == lastWeek.year &&
          currentWeek.month == lastWeek.month &&
          currentWeek.day == lastWeek.day) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You already used a hint this week.")),
          );
        }
        return;
      }
    }

    // Get wallet balance
    final walletDoc = await walletRef.get();
    final points =
        int.tryParse(walletDoc['availableReferralPoints'].toString()) ?? 0;
    final earnings =
        int.tryParse(walletDoc['availableEarnings'].toString()) ?? 0;

    // Cost setup
    final cost = useEarnings ? 100 : 500;
    final balance = useEarnings ? earnings : points;

    if (balance < cost) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Not enough ${useEarnings ? "balance" : "referral points"}")),
        );
      }
      return;
    }

    // Deduct balance (FIX 1)
    await walletRef.update({
      useEarnings ? 'availableEarnings' : 'availableReferralPoints':
          (balance - cost).toString(),
    });

    // Get hints
    final hintDoc = await hintRef.get();
    final hints = List<String>.from(hintDoc['hints'] ?? []);
    if (hints.isEmpty) return;

    final randomHint = hints[Random().nextInt(hints.length)];

    // Save lastHintUsed
    await userRef.update({'lastHintUsed': Timestamp.fromDate(now)});

    // Show hint
    setState(() {
      hintText = randomHint;
      hint = true;
      isActive = true;
    });
  }

  Future<void> getTreasureData(String userId) async {
    final treasureRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('treasures');

    final snapshot = await treasureRef.get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();

      setState(() {
        found = data['found'] ?? 0;
        hintUsed = data['hintUsed'] ?? 0;
        huntedDown = data['huntedDown'] ?? 0;
        itemsWon = List<String>.from(data['itemsWon'] ?? ["None Yet"]);
        participated = data['participated'] ?? 0;
        spentEarnings = data['spentEarnings']?.toString() ?? "₦0";
        spentPoints = data['spentPoints']?.toString() ?? "0RCPs";
        weeklyStatus = data['weeklyStatus']?.toString() ?? "Participating";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xffeeeeee),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
            onPressed: () {
              Navigator.of(context).pop(); // Go back
            },
          ),
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Treasure Hunt',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TreasureHunters()),
                  );
                },
                icon: const Icon(CupertinoIcons.bell_fill))
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("announcements")
                    .doc("treasures")
                    .collection("treasureDetails")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No treasures available"));
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: 3.h,
                      ),
                      Container(
                        width: 85.w,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xff092e57),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text("On This Week's Treasure",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 1.w),
                            // Left arrow
                            InkWell(
                              onTap: () {
                                if (_currentIndex > 0) {
                                  _controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.arrow_back_ios,
                                size: 24,
                                color: Color(0xff606060),
                              ),
                            ),

                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 85.w,
                                padding: const EdgeInsets.all(20),
                                
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x40000000),
                                      blurRadius: 2,
                                      offset: Offset(2, 2),
                                    )
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 100.w,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Status: ",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Colors.black, // label color
                                              ),
                                            ),
                                            TextSpan(
                                              text: (docs[_currentIndex].data()
                                                      as Map<String,
                                                          dynamic>)["status"] ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: (docs[_currentIndex]
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              "status"] ==
                                                          "NOT FOUND YET"
                                                      ? Colors.green
                                                      : Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100.w,
                                      height: 250,
                                      child: PageView.builder(
                                        controller: _controller,
                                        itemCount: docs.length,
                                        onPageChanged: (index) {
                                          setState(() => _currentIndex = index);
                                        },
                                        itemBuilder: (context, index) {
                                          final data = docs[index].data()
                                              as Map<String, dynamic>;
                                          return Image.network(
                                              data["imageUrl"] ?? "",
                                              fit: BoxFit.contain);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 0.5.w),
                            // Right arrow
                            InkWell(
                              onTap: () {
                                if (_currentIndex < docs.length - 1) {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                size: 24,
                                color: Color(0xff606060),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(docs.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 8 : 6,
                            height: _currentIndex == index ? 8 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                          padding: const EdgeInsets.all(15),
                          width: 85.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xff000000),
                                  blurRadius: 2,
                                  offset: Offset(2, 2))
                            ],
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                    child: Text(
                                  "Details of the Item",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                )),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Builder(
                                  builder: (context) {
                                    final data = docs[_currentIndex].data()
                                        as Map<String, dynamic>;
                                    final details = data["details"]
                                            as Map<String, dynamic>? ??
                                        {};
                                    final name = data["name"] ?? "";

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (name.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xfffe6929)),
                                            ),
                                          ),
                                        if (details.isEmpty)
                                          const Text("No details available")
                                        else
                                          ...details.entries.map((entry) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${entry.key}: ",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      entry.value.toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                      ],
                                    );
                                  },
                                )
                              ])),
                      SizedBox(
                        height: 3.h,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffa64221),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              fixedSize: Size(50.w, 7.h)),
                          onPressed: () {
                            Navigator.pop(context);
                            Future.delayed(Duration.zero, () {
                              widget.controller.jumpToPage(1);
                            });
                          },
                          child: const Text("Start Hunt",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(
                          width: 85.w,
                          child: Card(
                              elevation: 6, // adds shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.black,
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Center(
                                          child: Text("Quick Rules",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      Colors.white)),
                                        ),
                                        SizedBox(height: 2.h),
                                        const Text("1 KYC Required",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              SizedBox(width: 1.w),
                                              const Text("●",
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.white)),
                                              SizedBox(width: 1.w),
                                              const Text(
                                                  "You must complete and pass KYC before\njoining treasure hunts.",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white)),
                                            ]),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              SizedBox(width: 1.w),
                                              const Text("●",
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.white)),
                                              SizedBox(width: 1.w),
                                              const Text(
                                                  "Only KYCed accounts can win treasures.",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white)),
                                            ]),
                                        SizedBox(height: 2.h),
                                        const Text("2 One Account per Person",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              SizedBox(width: 1.w),
                                              const Text("●",
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.white)),
                                              SizedBox(width: 1.w),
                                              const Text(
                                                  "No cheating, exploiting, or using multiple\naccounts.",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white)),
                                            ]),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              SizedBox(width: 1.w),
                                              const Text("●",
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.white)),
                                              SizedBox(width: 1.w),
                                              const Text(
                                                  "Any violation voids rewards.",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white)),
                                            ]),
                                        SizedBox(height: 2.h),
                                        !showAll
                                            ? const SizedBox(height: 0)
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                    const Text(
                                                        "3 Approved Tasks Only",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Only approved submissions count.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Rejected/low-quality tasks are not eligible.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    const Text(
                                                        "4 Dynamic Placement",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Treasures can appear in any type of task\n(Grouped, Repeating etc. ).",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "They can drop at any time, on any day of\nthat week.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Some days may have multiple treasures,\nsome days none.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Always be available and turn on Notification.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    const Text(
                                                        "5 How Winners Are Picked",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Treasure is tied to a task.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "The first to perform and submit tasks tied\nto the reward would be reviewed first.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "The first Approved submission claims it.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    const Text("6 Win Limit",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Maximum 1 treasure win per worker per week.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Ensures fairness for everyone.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    const Text(
                                                        "7 Claiming Prizes",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Winners must confirm delivery details\nwithin 48 hours.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Otherwise, prize may pass to a backup winner.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Winners are reached out to via the Email or\nWhatsApp phone number provided during KYC.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    const Text("8 Fulfillment",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Digital rewards = instant credit.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          SizedBox(width: 1.w),
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(width: 1.w),
                                                          const Text(
                                                              "Physical items = 7–14 business days for\ndelivery.",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white)),
                                                        ]),
                                                  ]),
                                        Center(
                                          child: TextButton(
                                            onPressed: () {
                                              setState(
                                                  () => showAll = !showAll);
                                            },
                                            child: Text(
                                              showAll ? "See less" : "See more",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      ])))),

                      SizedBox(height: 2.h),
                      SizedBox(
                          width: 85.w,
                          child: Card(
                              elevation: 6, // adds shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(children: [
                                    SizedBox(height: 2.h),
                                    Container(
                                      width: 50.w,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: const Color(0xff9e1d22),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Text("Get Hint Lead",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          const Text("●",
                                              style: TextStyle(fontSize: 6)),
                                          SizedBox(width: 1.w),
                                          RichText(
                                              text: const TextSpan(
                                                  text: "You can use your ",
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                  children: [
                                                TextSpan(
                                                    text: "referral points",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text: " or a ",
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text:
                                                        "portion of\nyour earnings",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text: " to unlock a hint.",
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                              ]))
                                        ]),
                                    SizedBox(height: 2.h),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          const Text("●",
                                              style: TextStyle(fontSize: 6)),
                                          SizedBox(width: 1.w),
                                          const Text(
                                              "Hints are not tied to a specific treasure —\ninstead, they reveal a clue like: “Between 12PM\n– 2PM, one of the treasures will appear in\na task.”",
                                              style: TextStyle(fontSize: 11))
                                        ]),
                                    SizedBox(height: 2.h),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          const Text("●",
                                              style: TextStyle(fontSize: 6)),
                                          SizedBox(width: 1.w),
                                          RichText(
                                              text: const TextSpan(
                                                  text: "You can only use ",
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                  children: [
                                                TextSpan(
                                                    text:
                                                        "one hint per Treasure Hunt\nweek",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text:
                                                        " even if multiple treasures are available.",
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                              ]))
                                        ]),
                                    SizedBox(height: 2.h),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          const Text("●",
                                              style: TextStyle(fontSize: 6)),
                                          SizedBox(width: 1.w),
                                          RichText(
                                              text: const TextSpan(
                                                  text:
                                                      "Hints can guide you on any of one of these: ",
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                  children: [
                                                TextSpan(
                                                    text: "type\nof task",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text: " it is located,",
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text: " day ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text: "it would appear, or",
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text: " time\nwindow ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 11)),
                                                TextSpan(
                                                    text:
                                                        "where a treasure might appear.",
                                                    style: TextStyle(
                                                        fontSize: 11)),
                                              ]))
                                        ]),
                                    SizedBox(height: 2.h),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          const Text("●",
                                              style: TextStyle(fontSize: 6)),
                                          SizedBox(width: 1.w),
                                          const Text(
                                              "Hints make the hunt less harder but do not\nguarantee a win. Use them wisely!",
                                              style: TextStyle(fontSize: 11))
                                        ]),
                                    SizedBox(height: 3.h),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 30.w,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        padding: const EdgeInsets
                                                                .all(
                                                            10), // Padding inside button
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                      ),
                                                      onPressed: (int.tryParse(
                                                                      points) ??
                                                                  0) >=
                                                              500
                                                          ? !isActive
                                                              ? null
                                                              : () {
                                                                  setState(() {
                                                                    isActive =
                                                                        false;
                                                                  });
                                                                  unlockHint(
                                                                      context,
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid,
                                                                      useEarnings:
                                                                          false);
                                                                }
                                                          : null,
                                                      child: const Text(
                                                          'Use Referral Points',
                                                          style: TextStyle(
                                                              fontSize: 10))),
                                                ),
                                                SizedBox(height: 1.h),
                                                Row(children: [
                                                  const CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          Color(0xff007a3f)),
                                                  SizedBox(width: 1.w),
                                                  Text(
                                                      'Available: ${points}RCPs',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xff007a3f)))
                                                ]),
                                                Row(children: [
                                                  const CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          Color(0xffe70e17)),
                                                  SizedBox(width: 1.w),
                                                  const Text(
                                                      'Hint Cost: 500RCPs',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xffe70e17)))
                                                ]),
                                              ]),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 30.w,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                                0xff092e57),
                                                        padding: const EdgeInsets
                                                                .fromLTRB(
                                                            8,
                                                            10,
                                                            8,
                                                            10), // Padding inside button
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                      ),
                                                      onPressed: (int.tryParse(
                                                                      balance) ??
                                                                  0) >=
                                                              100
                                                          ? !isActive
                                                              ? null
                                                              : () {
                                                                  setState(() {
                                                                    isActive =
                                                                        false;
                                                                  });
                                                                  unlockHint(
                                                                      context,
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid,
                                                                      useEarnings:
                                                                          true);
                                                                }
                                                          : null,
                                                      child: const Text(
                                                          'Use Earnings',
                                                          style: TextStyle(
                                                              fontSize: 10))),
                                                ),
                                                SizedBox(height: 1.h),
                                                Row(children: [
                                                  const CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          Color(0xff007a3f)),
                                                  SizedBox(width: 1.w),
                                                  Text('Available: ₦$balance',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xff007a3f)))
                                                ]),
                                                Row(children: [
                                                  const CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          Color(0xffe70e17)),
                                                  SizedBox(width: 1.w),
                                                  const Text('Hint Cost: ₦100',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                              0xffe70e17)))
                                                ]),
                                              ]),
                                        ])
                                  ])))),
                      SizedBox(height: 3.h),
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
                          child: Column(children: [
                            hint
                                ? const Text("Hint:",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        decorationColor: Colors.white,
                                        decoration: TextDecoration.underline))
                                : const Text("No Hint For You",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        decorationColor: Colors.white,
                                        decorationThickness: 3,
                                        decoration: TextDecoration.underline)),
                            SizedBox(height: 2.h),
                            hint
                                ? Text(hintText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ))
                                : const Text(
                                    "Unfortunately you have to do more tasks to earn up to ₦100 to be able to get a Hint or try using your referral points if available",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ))
                          ])),
                      SizedBox(height: 2.h),
                      SizedBox(
                          width: 85.w,
                          child: Card(
                              elevation: 6, // adds shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 50.w,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: const Color(0xff092e57),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: const Text("Treasure Log",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      RichText(
                                          text: TextSpan(
                                              text:
                                                  "Number of times Participated in Treasure Hunts: ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              children: [
                                            TextSpan(
                                                text: "$participated",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 11))
                                          ])),
                                      SizedBox(height: 2.h),
                                      RichText(
                                          text: TextSpan(
                                              text:
                                                  "Number of Treasure Hunted Down: ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              children: [
                                            TextSpan(
                                                text: "$huntedDown",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 11))
                                          ])),
                                      SizedBox(height: 2.h),
                                      RichText(
                                          text: TextSpan(
                                              text:
                                                  "Number of Treasure Found: ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              children: [
                                            TextSpan(
                                                text: "$found",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 11))
                                          ])),
                                      SizedBox(height: 2.h),
                                      const Text("List of Items Won so far:",
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                      ...itemsWon.map((item) => Text(item,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xfffe6929)))),
                                      SizedBox(height: 2.h),
                                      RichText(
                                          text: TextSpan(
                                              text:
                                                  "This week Treasure Hunt Participation Status: ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              children: [
                                            TextSpan(
                                                text: weeklyStatus,
                                                style: const TextStyle(
                                                    color: Color(0xff007a3f),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 11))
                                          ])),
                                      SizedBox(height: 2.h),
                                      RichText(
                                          text: TextSpan(
                                              text: "Use of Hint Status: ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              children: [
                                            TextSpan(
                                                text: "Used $hintUsed time(s)",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 11))
                                          ])),
                                      SizedBox(height: 2.h),
                                      RichText(
                                          text: TextSpan(
                                              text:
                                                  "Referral Points Spent so far on Hints: ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              children: [
                                            TextSpan(
                                                text: "$spentPoints RCPs",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 11))
                                          ])),
                                      SizedBox(height: 2.h),
                                      RichText(
                                          text: TextSpan(
                                              text:
                                                  "Earnings Spent so far on Hints: ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              children: [
                                            TextSpan(
                                                text: "₦$spentEarnings",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 11))
                                          ])),
                                      SizedBox(height: 3.h),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    backgroundColor:
                                                        const Color(0xff583f2f),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    fixedSize: Size(
                                                      30.w,
                                                      5.h,
                                                    )),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const TreasureHistory()),
                                                  );
                                                },
                                                child: const Text(
                                                    "My Treasure History",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ))),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    backgroundColor:
                                                        const Color(0xffb8860b),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    fixedSize: Size(
                                                      30.w,
                                                      5.h,
                                                    )),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const TreasureHunters()),
                                                  );
                                                },
                                                child: const Text(
                                                    "View All Hunters",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ))),
                                          ]),
                                    ]),
                              ))),
                      SizedBox(height: 3.h),
                    ],
                  );
                }),
          ),
        ));
  }
}

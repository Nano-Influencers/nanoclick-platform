import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../widgets/arrow_animation.dart';



class Ranking extends StatefulWidget {
  const Ranking({super.key});

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  late YoutubePlayerController _controller;
  String isSelected = "Top Tasks Performance";
  bool isLoading = true;
  bool viewPrizes = false;
  bool weeklyPrizes = false;
  bool monthlyPrizes = false;
  bool isEmpty = false;
  Stream<QuerySnapshot>? _stream;
  List<DocumentSnapshot> _cachedDocs = [];
  int _totalPages = 1;
  int currentPage = 1;
  bool isWeekly = true;
  int daysSinceMonthStart = 0;
  int daysSinceLastSunday = 0;
  //  Find current user's entry
  ValueNotifier<QueryDocumentSnapshot?> userDoc = ValueNotifier(null);
  ValueNotifier<int> rank = ValueNotifier(0);
  String weeklyFirstPrize = "";
  String weeklySecondPrize = "";
  String weeklyThirdPrize = "";
  String weeklyFourthPrize = "";
  String weeklyFifthPrize = "";
  String weeklyConsolation1 = "";
  String weeklyConsolation2 = "";
  String monthlyFirstPrize = "";
  String monthlySecondPrize = "";
  String monthlyThirdPrize = "";
  String monthlyFourthPrize = "";
  String monthlyFifthPrize = "";
  String monthlyConsolation1 = "";
  String monthlyConsolation2 = "";
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _calculateDays();
    _initPagination();
    _getPrizes();
     _controller = YoutubePlayerController.fromVideoId(
      videoId: 'OHz0xIR8uwI',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: true,
      ),
    );
    _controller.loadVideoById(videoId: 'OHz0xIR8uwI');
    // simulate loading delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    });
  }

  Future<void> _initPagination() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy('performanceScore', descending: true)
        .get();

    setState(() {
      _cachedDocs = snapshot.docs;
      _totalPages = (snapshot.docs.length / 10).ceil();
    });
    _updateStream(1, "performanceScore");
  }

  void _updateStream(int page, String orderBy) async {
    if (_cachedDocs.isEmpty) return;

    // Find the start document
    int startIndex = (page - 1) * 10;
    if (startIndex >= _cachedDocs.length) startIndex = 0;

    Query query = FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy(orderBy, descending: true)
        .limit(10);

    if (page > 1 && startIndex < _cachedDocs.length) {
      query = query.startAfterDocument(_cachedDocs[startIndex - 1]);
    }

    setState(() {
      currentPage = page;
      _stream = query.snapshots();
    });
  }

  void _calculateDays() {
    final now = DateTime.now();

    //Days since start of month
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final diffMonth = now.difference(firstOfMonth).inDays;

    //Days since last Sunday
    // (weekday: Mon=1 ... Sun=7)
    final lastSunday = now.subtract(Duration(days: now.weekday % 7));
    final diffWeek = now.difference(lastSunday).inDays;

    setState(() {
      daysSinceMonthStart = diffMonth;
      daysSinceLastSunday = diffWeek;
    });
  }

  Future<void> _getPrizes() async {
    try {
      final weeklyDoc = await FirebaseFirestore.instance
          .collection('announcements')
          .doc('weeklyLeaderboardPrizes')
          .get();

      final monthlyDoc = await FirebaseFirestore.instance
          .collection('announcements')
          .doc('monthlyLeaderboardPrizes')
          .get();

      if (mounted) {
        if (monthlyDoc.data()?['first'] != null) {
          setState(() {
            monthlyPrizes = true;
          });
        }
        if (weeklyDoc.data()?['first'] != null) {
          setState(() {
            weeklyPrizes = true;
          });
        }
        setState(() {
          weeklyFirstPrize = weeklyDoc.data()?['first']?.toString() ?? 'None';
          weeklySecondPrize = weeklyDoc.data()?['second']?.toString() ?? 'None';
          weeklyThirdPrize = weeklyDoc.data()?['third']?.toString() ?? 'None';
          weeklyFourthPrize = weeklyDoc.data()?['fourth']?.toString() ?? 'None';
          weeklyFifthPrize = weeklyDoc.data()?['fifth']?.toString() ?? 'None';
          weeklyConsolation1 =
              weeklyDoc.data()?['consolation1']?.toString() ?? 'None';
          weeklyConsolation2 =
              weeklyDoc.data()?['consolation2']?.toString() ?? 'None';
          monthlyFirstPrize = monthlyDoc.data()?['first']?.toString() ?? 'None';
          monthlySecondPrize =
              monthlyDoc.data()?['second']?.toString() ?? 'None';
          monthlyThirdPrize = monthlyDoc.data()?['third']?.toString() ?? 'None';
          monthlyFourthPrize =
              monthlyDoc.data()?['fourth']?.toString() ?? 'None';
          monthlyFifthPrize = monthlyDoc.data()?['fifth']?.toString() ?? 'None';
          monthlyConsolation1 =
              monthlyDoc.data()?['consolation1']?.toString() ?? 'None';
          monthlyConsolation2 =
              monthlyDoc.data()?['consolation2']?.toString() ?? 'None';
        });
      }
    } catch (e) {
      debugPrint('Error fetching prizes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(padding: const EdgeInsets.only(bottom: 20), children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              color: const Color(0xffeeeeee),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 30.w,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSelected = "Top Tasks Performance";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor:
                                isSelected == "Top Tasks Performance"
                                    ? Colors.black
                                    : Colors.white,
                            foregroundColor: const Color(0xffff6533)),
                        child: const Text("Top Tasks Performance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      width: 30.w,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSelected = "Top ClickPoints";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: isSelected == "Top ClickPoints"
                                ? Colors.black
                                : Colors.white,
                            foregroundColor: const Color(0xffff6533)),
                        child: const Text("Top ClickPoints",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      width: 30.w,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSelected = "Top Referral Points";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: isSelected == "Top Referral Points"
                                ? Colors.black
                                : Colors.white,
                            foregroundColor: const Color(0xffff6533)),
                        child: const Text("Top Referral Points",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      width: 30.w,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSelected = "Top Streaks";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: isSelected == "Top Streaks"
                                ? Colors.black
                                : Colors.white,
                            foregroundColor: const Color(0xffff6533)),
                        child: const Text("Top Streaks",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(children: [
              SizedBox(width: 8.w),
              const SizedBox(
                  width: 40,
                  child: ArrowCircleAnimation(
                    borderColor: Colors.black,
                    borderWidth: 1,
                  )),
              SizedBox(width: 1.w),
              SizedBox(
                  width: 35.w,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isWeekly = !isWeekly;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          backgroundColor: const Color(0xffff6533),
                          foregroundColor: Colors.white),
                      child: Text(
                          isWeekly
                              ? "View Monthly Ranking"
                              : "View Weekly Ranking",
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))))
            ]),
            SizedBox(height: 2.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                  isWeekly
                      ? "Started: $daysSinceLastSunday day(s) ago"
                      : "Started: $daysSinceMonthStart day(s) ago",
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          viewPrizes = false;
                        });
                      },
                      child: Container(
                          width: 36.w,
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 7),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xffff6533),
                              ),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                              isWeekly
                                  ? "This week Ranking"
                                  : "This month Ranking",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffff6533),
                              ))),
                    ),
                    viewPrizes
                        ? TextButton(
                            onPressed: () {
                              setState(() {
                                viewPrizes = false;
                              });
                            },
                            child: Text(
                                isWeekly
                                    ? "View Ranking for this Week"
                                    : "View Ranking for this Month",
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.black)))
                        : TextButton(
                            onPressed: () {
                              setState(() {
                                viewPrizes = true;
                              });
                            },
                            child: Text(
                                isWeekly
                                    ? "View Prizes Available for this Week"
                                    : "View Prizes Available for this Month",
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.black)))
                  ]),
            ),
            Container(
              padding: const EdgeInsets.all(15.0),
              child: isSelected == "Top ClickPoints"
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _stream,
                      builder: (context, snapshot) {
                        //  Loading state
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: Colors.black,
                          ));
                        }

                        //  Error state
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        if (viewPrizes) {
                          final target =
                              DateTime.parse('2025-11-04T10:00:00+01:00');
                          final now = DateTime.now();
                          final durationLeft = target.difference(now);
                          final days = durationLeft.inDays;
                          final hours = durationLeft.inHours % 24;
                          final minutes = durationLeft.inMinutes % 60;
                          if (isWeekly) {
                            if (weeklyPrizes) {
                              return Column(
                                children: [
                                  SizedBox(
                                      width: 90.w,
                                      child: Card(
                                          elevation: 6,
                                          shadowColor: Colors.black
                                              .withOpacity(0.3), // adds shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      18, 20, 18, 20),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        width: 90.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: Colors.black,
                                                        ),
                                                        child: const Text(
                                                            "On this Week Prize",
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white))),
                                                    SizedBox(height: 4.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "1st Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      weeklyFirstPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "2nd Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      weeklySecondPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "3rd Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      weeklyThirdPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "4th Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      weeklyFourthPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "5th Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      weeklyFifthPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 2.h),
                                                    Container(
                                                        width: 60.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: const Color(
                                                              0xffff6533),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1), // shadow color
                                                              blurRadius: 8,
                                                              spreadRadius:
                                                                  2, // how far it spreads
                                                              offset: const Offset(
                                                                  0,
                                                                  4), // x, y offset
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "6th - 20th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          weeklyConsolation1,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                      ))
                                                                ])),
                                                            SizedBox(
                                                                height: 2.h),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "21st - 100th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          weeklyConsolation2,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                      ))
                                                                ])),
                                                          ],
                                                        )),
                                                  ])))),
                                  SizedBox(height: 6.h),
                                  const Text(
                                      "Watch to Understand how Task Performance Leaderboard Works",
                                      style: TextStyle(
                                        fontSize: 10,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black,
                                        color: Colors.black,
                                      )),
                                  SizedBox(height: 1.h),
                                  SizedBox(
                                      width: 300,
                                      height: 150,
                                      child: YoutubePlayer(
                                        controller: _controller,
                                        aspectRatio: 16 / 9,
                                      )),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(
                                      width: 90.w,
                                      child: Card(
                                          elevation: 6,
                                          shadowColor: Colors.black
                                              .withOpacity(0.3), // adds shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      18, 20, 18, 20),
                                              child: Column(children: [
                                                Container(
                                                    width: 90.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: const Color(
                                                          0xffff6533),
                                                    ),
                                                    child: const Text(
                                                        "No Prizes Available Yet for the Week",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white))),
                                                SizedBox(height: 2.h),
                                                Image.network(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                    scale: 3),
                                                SizedBox(height: 2.h),
                                                const Text("Check in Shortly",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        color:
                                                            Color(0xffff6533))),
                                                Text(
                                                    "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xffff6533))),
                                              ])))),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "Begins on Tuesday 4th of November 2025, 10am WAT",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xff545454),
                                          fontWeight: FontWeight.bold))
                                ],
                              );
                            }
                          } else {
                            if (monthlyPrizes) {
                              return Column(
                                children: [
                                  SizedBox(
                                      width: 90.w,
                                      child: Card(
                                          elevation: 6,
                                          shadowColor: Colors.black
                                              .withOpacity(0.3), // adds shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      18, 20, 18, 20),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        width: 90.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: Colors.black,
                                                        ),
                                                        child: const Text(
                                                            "On this Month Prize",
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white))),
                                                    SizedBox(height: 4.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "1st Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      monthlyFirstPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "2nd Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      monthlySecondPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "3rd Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      monthlyThirdPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "4th Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      monthlyFourthPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                      children: [
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                            scale: 4),
                                                        SizedBox(width: 2.w),
                                                        RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "5th Prize: ",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                children: [
                                                              TextSpan(
                                                                  text:
                                                                      monthlyFifthPrize,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey))
                                                            ]))
                                                      ],
                                                    ),
                                                    SizedBox(height: 2.h),
                                                    Container(
                                                        width: 60.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: const Color(
                                                              0xffff6533),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1), // shadow color
                                                              blurRadius: 8,
                                                              spreadRadius:
                                                                  2, // how far it spreads
                                                              offset: const Offset(
                                                                  0,
                                                                  4), // x, y offset
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "6th - 20th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          monthlyConsolation1,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                      ))
                                                                ])),
                                                            SizedBox(
                                                                height: 2.h),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "21st - 100th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          monthlyConsolation2,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                      ))
                                                                ])),
                                                          ],
                                                        )),
                                                  ])))),
                                  SizedBox(height: 6.h),
                                  const Text(
                                      "Watch to Understand how Task Performance Leaderboard Works",
                                      style: TextStyle(
                                        fontSize: 10,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black,
                                        color: Colors.black,
                                      )),
                                  SizedBox(height: 1.h),
                                  SizedBox(
                                      width: 300,
                                      height: 150,
                                      child: YoutubePlayer(
                                        controller: _controller,
                                        aspectRatio: 16 / 9,
                                      )),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(
                                      width: 90.w,
                                      child: Card(
                                          elevation: 6,
                                          shadowColor: Colors.black
                                              .withOpacity(0.3), // adds shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      18, 20, 18, 20),
                                              child: Column(children: [
                                                Container(
                                                    width: 90.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: const Color(
                                                          0xffff6533),
                                                    ),
                                                    child: const Text(
                                                        "No Prizes Available Yet for the Month",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white))),
                                                SizedBox(height: 2.h),
                                                Image.network(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                    scale: 3),
                                                SizedBox(height: 2.h),
                                                const Text("Check in Shortly",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        color:
                                                            Color(0xffff6533))),
                                                Text(
                                                    "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xffff6533))),
                                              ])))),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "Begins on Tuesday 4th of November 2025, 10am WAT",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xff545454),
                                          fontWeight: FontWeight.bold))
                                ],
                              );
                            }
                          }
                        }

                        // Success
                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty && _isReady) {
                          setState(() {
                            isEmpty = true;
                          });
                          final target =
                              DateTime.parse('2025-11-04T10:00:00+01:00');
                          final now = DateTime.now();
                          final durationLeft = target.difference(now);
                          final days = durationLeft.inDays;
                          final hours = durationLeft.inHours % 24;
                          final minutes = durationLeft.inMinutes % 60;
                          if (isWeekly) {
                            return Column(
                              children: [
                                SizedBox(
                                    width: 90.w,
                                    child: Card(
                                        elevation: 6,
                                        shadowColor: Colors.black
                                            .withOpacity(0.3), // adds shadow
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        color: Colors.white,
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                18, 20, 18, 20),
                                            child: Column(children: [
                                              Container(
                                                  width: 90.w,
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color:
                                                        const Color(0xffff6533),
                                                  ),
                                                  child: const Text(
                                                      "No Available Ranking Yet This Week",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.white))),
                                              SizedBox(height: 2.h),
                                              Image.network(
                                                  "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                  scale: 3),
                                              SizedBox(height: 2.h),
                                              const Text("Check in Shortly",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      color:
                                                          Color(0xffff6533))),
                                              Text(
                                                  "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xffff6533))),
                                            ])))),
                                SizedBox(height: 2.h),
                                const Text(
                                    "Begins on Tuesday 4th of November 2025, 10am WAT",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xff545454),
                                        fontWeight: FontWeight.bold))
                              ],
                            );
                          }
                          return Column(
                            children: [
                              SizedBox(
                                  width: 90.w,
                                  child: Card(
                                      elevation: 6,
                                      shadowColor: Colors.black
                                          .withOpacity(0.3), // adds shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      color: Colors.white,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18, 20, 18, 20),
                                          child: Column(children: [
                                            Container(
                                                width: 90.w,
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color:
                                                      const Color(0xffff6533),
                                                ),
                                                child: const Text(
                                                    "No Available Ranking Yet This Month",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            SizedBox(height: 2.h),
                                            Image.network(
                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                scale: 3),
                                            SizedBox(height: 2.h),
                                            const Text("Check in Shortly",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w100,
                                                    color: Color(0xffff6533))),
                                            Text(
                                                "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xffff6533))),
                                          ])))),
                              SizedBox(height: 2.h),
                              const Text(
                                  "Begins on Tuesday 4th of November 2025, 10am WAT",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff545454),
                                      fontWeight: FontWeight.bold))
                            ],
                          );
                        }

                        try {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            userDoc.value = docs.firstWhere(
                              (doc) => doc['uid'] == currentUser?.uid,
                            );
                            rank.value = docs.indexOf(userDoc.value!) + 1;
                          });
                        } catch (e) {
                          userDoc.value = null;
                        }

                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: docs.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final name = data['name'] ?? 'Unnamed';
                              final dp = data['dp'] == ""
                                  ? 'https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png'
                                  : data['dp'];
                              final weeklyPoints =
                                  data['weeklyClickPoints'] ?? "0";
                              final monthlyPoints = data['clickPoints'] ?? "0";
                              final id = data["ID"] ?? "";

                              return SizedBox(
                                width: 90.w,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          18, 20, 18, 20),
                                      child: Column(
                                        children: [
                                          Row(children: [
                                            CircleAvatar(
                                                radius: 22,
                                                backgroundColor: index + 1 == 1
                                                    ? const Color(0xffffb33a)
                                                    : index + 1 == 2
                                                        ? const Color(
                                                            0xffa8a7a7)
                                                        : index + 1 == 3
                                                            ? const Color(
                                                                0xff875403)
                                                            : const Color(
                                                                0xffd1d5db),
                                                child: Text("${index + 1}",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(width: 2.w),
                                            CircleAvatar(
                                                radius: 20,
                                                backgroundImage:
                                                    NetworkImage(dp)),
                                            SizedBox(width: 3.w),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 50.w,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(name,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text("ID: $id",
                                                            style: const TextStyle(
                                                                fontSize: 8,
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                  ),
                                                ])
                                          ]),
                                          SizedBox(height: 2.h),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    width: 50.w,
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xffd4d5d7),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Column(children: [
                                                      const Text(
                                                          "Total CPs for the Month",
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      SizedBox(height: 1.h),
                                                      Text(
                                                          isWeekly
                                                              ? "$weeklyPoints CPs"
                                                              : "$monthlyPoints CPs",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xffff6533),
                                                              fontSize: 10)),
                                                    ])),
                                              ])
                                        ],
                                      )),
                                ),
                              );
                            });
                      })
                  : isSelected == "Top Referral Points"
                      ? StreamBuilder<QuerySnapshot>(
                          stream: _stream,
                          builder: (context, snapshot) {
                            //  Loading state
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              ));
                            }

                            //  Error state
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            if (viewPrizes) {
                              final target =
                                  DateTime.parse('2025-11-04T10:00:00+01:00');
                              final now = DateTime.now();
                              final durationLeft = target.difference(now);
                              final days = durationLeft.inDays;
                              final hours = durationLeft.inHours % 24;
                              final minutes = durationLeft.inMinutes % 60;
                              if (isWeekly) {
                                if (weeklyPrizes) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                          width: 90.w,
                                          child: Card(
                                              elevation: 6,
                                              shadowColor: Colors.black
                                                  .withOpacity(
                                                      0.3), // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          18, 20, 18, 20),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 90.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            child: const Text(
                                                                "On this Week Prize",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white))),
                                                        SizedBox(height: 4.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "1st Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          weeklyFirstPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "2nd Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          weeklySecondPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "3rd Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          weeklyThirdPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "4th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          weeklyFourthPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "5th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          weeklyFifthPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 2.h),
                                                        Container(
                                                            width: 60.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: const Color(
                                                                  0xffff6533),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.1), // shadow color
                                                                  blurRadius: 8,
                                                                  spreadRadius:
                                                                      2, // how far it spreads
                                                                  offset: const Offset(
                                                                      0,
                                                                      4), // x, y offset
                                                                ),
                                                              ],
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "6th - 20th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyConsolation1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                          ))
                                                                    ])),
                                                                SizedBox(
                                                                    height:
                                                                        2.h),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "21st - 100th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyConsolation2,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                          ))
                                                                    ])),
                                                              ],
                                                            )),
                                                      ])))),
                                      SizedBox(height: 6.h),
                                      const Text(
                                          "Watch to Understand how Task Performance Leaderboard Works",
                                          style: TextStyle(
                                            fontSize: 10,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.black,
                                            color: Colors.black,
                                          )),
                                      SizedBox(height: 1.h),
                                      SizedBox(
                                          width: 300,
                                          height: 150,
                                          child: YoutubePlayer(
                                            controller: _controller,
                                            aspectRatio: 16 / 9,
                                          )),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      SizedBox(
                                          width: 90.w,
                                          child: Card(
                                              elevation: 6,
                                              shadowColor: Colors.black
                                                  .withOpacity(
                                                      0.3), // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          18, 20, 18, 20),
                                                  child: Column(children: [
                                                    Container(
                                                        width: 90.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: const Color(
                                                              0xffff6533),
                                                        ),
                                                        child: const Text(
                                                            "No Prizes Available Yet for the Week",
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white))),
                                                    SizedBox(height: 2.h),
                                                    Image.network(
                                                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                        scale: 3),
                                                    SizedBox(height: 2.h),
                                                    const Text(
                                                        "Check in Shortly",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            color: Color(
                                                                0xffff6533))),
                                                    Text(
                                                        "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xffff6533))),
                                                  ])))),
                                      SizedBox(height: 2.h),
                                      const Text(
                                          "Begins on Tuesday 4th of November 2025, 10am WAT",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xff545454),
                                              fontWeight: FontWeight.bold))
                                    ],
                                  );
                                }
                              } else {
                                if (monthlyPrizes) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                          width: 90.w,
                                          child: Card(
                                              elevation: 6,
                                              shadowColor: Colors.black
                                                  .withOpacity(
                                                      0.3), // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          18, 20, 18, 20),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            width: 90.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            child: const Text(
                                                                "On this Month Prize",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white))),
                                                        SizedBox(height: 4.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "1st Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          monthlyFirstPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "2nd Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          monthlySecondPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "3rd Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          monthlyThirdPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "4th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          monthlyFourthPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 1.h),
                                                        Row(
                                                          children: [
                                                            Image.network(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                                scale: 4),
                                                            SizedBox(
                                                                width: 2.w),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "5th Prize: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                    children: [
                                                                  TextSpan(
                                                                      text:
                                                                          monthlyFifthPrize,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey))
                                                                ]))
                                                          ],
                                                        ),
                                                        SizedBox(height: 2.h),
                                                        Container(
                                                            width: 60.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: const Color(
                                                                  0xffff6533),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.1), // shadow color
                                                                  blurRadius: 8,
                                                                  spreadRadius:
                                                                      2, // how far it spreads
                                                                  offset: const Offset(
                                                                      0,
                                                                      4), // x, y offset
                                                                ),
                                                              ],
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "6th - 20th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyConsolation1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                          ))
                                                                    ])),
                                                                SizedBox(
                                                                    height:
                                                                        2.h),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "21st - 100th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyConsolation2,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                          ))
                                                                    ])),
                                                              ],
                                                            )),
                                                      ])))),
                                      SizedBox(height: 6.h),
                                      const Text(
                                          "Watch to Understand how Task Performance Leaderboard Works",
                                          style: TextStyle(
                                            fontSize: 10,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.black,
                                            color: Colors.black,
                                          )),
                                      SizedBox(height: 1.h),
                                      SizedBox(
                                          width: 300,
                                          height: 150,
                                          child: YoutubePlayer(
                                            controller: _controller,
                                            aspectRatio: 16 / 9,
                                          )),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      SizedBox(
                                          width: 90.w,
                                          child: Card(
                                              elevation: 6,
                                              shadowColor: Colors.black
                                                  .withOpacity(
                                                      0.3), // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          18, 20, 18, 20),
                                                  child: Column(children: [
                                                    Container(
                                                        width: 90.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: const Color(
                                                              0xffff6533),
                                                        ),
                                                        child: const Text(
                                                            "No Prizes Available Yet for the Month",
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white))),
                                                    SizedBox(height: 2.h),
                                                    Image.network(
                                                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                        scale: 3),
                                                    SizedBox(height: 2.h),
                                                    const Text(
                                                        "Check in Shortly",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            color: Color(
                                                                0xffff6533))),
                                                    Text(
                                                        "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xffff6533))),
                                                  ])))),
                                      SizedBox(height: 2.h),
                                      const Text(
                                          "Begins on Tuesday 4th of November 2025, 10am WAT",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xff545454),
                                              fontWeight: FontWeight.bold))
                                    ],
                                  );
                                }
                              }
                            }

                            // Success
                            final docs = snapshot.data?.docs ?? [];

                            if (docs.isEmpty && _isReady) {
                              setState(() {
                                isEmpty = true;
                              });
                              final target =
                                  DateTime.parse('2025-11-04T10:00:00+01:00');
                              final now = DateTime.now();
                              final durationLeft = target.difference(now);
                              final days = durationLeft.inDays;
                              final hours = durationLeft.inHours % 24;
                              final minutes = durationLeft.inMinutes % 60;
                              if (isWeekly) {
                                return Column(
                                  children: [
                                    SizedBox(
                                        width: 90.w,
                                        child: Card(
                                            elevation: 6,
                                            shadowColor: Colors.black
                                                .withOpacity(
                                                    0.3), // adds shadow
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            color: Colors.white,
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        18, 20, 18, 20),
                                                child: Column(children: [
                                                  Container(
                                                      width: 90.w,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: const Color(
                                                            0xffff6533),
                                                      ),
                                                      child: const Text(
                                                          "No Available Ranking Yet This Week",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white))),
                                                  SizedBox(height: 2.h),
                                                  Image.network(
                                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                      scale: 3),
                                                  SizedBox(height: 2.h),
                                                  const Text("Check in Shortly",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w100,
                                                          color: Color(
                                                              0xffff6533))),
                                                  Text(
                                                      "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xffff6533))),
                                                ])))),
                                    SizedBox(height: 2.h),
                                    const Text(
                                        "Begins on Tuesday 4th of November 2025, 10am WAT",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xff545454),
                                            fontWeight: FontWeight.bold))
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  SizedBox(
                                      width: 90.w,
                                      child: Card(
                                          elevation: 6,
                                          shadowColor: Colors.black
                                              .withOpacity(0.3), // adds shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      18, 20, 18, 20),
                                              child: Column(children: [
                                                Container(
                                                    width: 90.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: const Color(
                                                          0xffff6533),
                                                    ),
                                                    child: const Text(
                                                        "No Available Ranking Yet This Month",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white))),
                                                SizedBox(height: 2.h),
                                                Image.network(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                    scale: 3),
                                                SizedBox(height: 2.h),
                                                const Text("Check in Shortly",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        color:
                                                            Color(0xffff6533))),
                                                Text(
                                                    "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xffff6533))),
                                              ])))),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "Begins on Tuesday 4th of November 2025, 10am WAT",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xff545454),
                                          fontWeight: FontWeight.bold))
                                ],
                              );
                            }
                            try {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                userDoc.value = docs.firstWhere(
                                  (doc) => doc['uid'] == currentUser?.uid,
                                );
                                rank.value = docs.indexOf(userDoc.value!) + 1;
                              });
                            } catch (e) {
                              userDoc.value = null;
                            }

                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: docs.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final data = docs[index].data()
                                      as Map<String, dynamic>;
                                  final name = data['name'] ?? 'Unnamed';
                                  final dp = data['dp'] == ""
                                      ? 'https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png'
                                      : data['dp'];
                                  final weeklyReferrals =
                                      data['weeklyReferrals'] ?? "0";
                                  final monthlyReferrals =
                                      data['referrals'] ?? "0";
                                  final id = data["ID"] ?? "";

                                  return SizedBox(
                                    width: 90.w,
                                    child: Card(
                                      elevation: 6, // adds shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      color: Colors.white,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18, 20, 18, 20),
                                          child: Column(
                                            children: [
                                              Row(children: [
                                                CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor: index +
                                                                1 ==
                                                            1
                                                        ? const Color(
                                                            0xffffb33a)
                                                        : index + 1 == 2
                                                            ? const Color(
                                                                0xffa8a7a7)
                                                            : index + 1 == 3
                                                                ? const Color(
                                                                    0xff875403)
                                                                : const Color(
                                                                    0xffd1d5db),
                                                    child: Text("${index + 1}",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                                SizedBox(width: 2.w),
                                                CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(dp)),
                                                SizedBox(width: 3.w),
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: 50.w,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(name,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            Text("ID: $id",
                                                                style: const TextStyle(
                                                                    fontSize: 8,
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        ),
                                                      ),
                                                    ])
                                              ]),
                                              SizedBox(height: 2.h),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        width: 50.w,
                                                        decoration: BoxDecoration(
                                                            color: const Color(
                                                                0xffd4d5d7),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child:
                                                            Column(children: [
                                                          const Text(
                                                              "Total KYC’ed Referrals",
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(height: 1.h),
                                                          Text(
                                                              isWeekly
                                                                  ? "$weeklyReferrals RPs"
                                                                  : "$monthlyReferrals RPs",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xffff6533),
                                                                  fontSize:
                                                                      10)),
                                                        ])),
                                                  ])
                                            ],
                                          )),
                                    ),
                                  );
                                });
                          })
                      : isSelected == "Top Streaks"
                          ? StreamBuilder<QuerySnapshot>(
                              stream: _stream,
                              builder: (context, snapshot) {
                                //  Loading state
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ));
                                }

                                //  Error state
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (viewPrizes) {
                                  final target = DateTime.parse(
                                      '2025-11-04T10:00:00+01:00');
                                  final now = DateTime.now();
                                  final durationLeft = target.difference(now);
                                  final days = durationLeft.inDays;
                                  final hours = durationLeft.inHours % 24;
                                  final minutes = durationLeft.inMinutes % 60;
                                  if (isWeekly) {
                                    if (weeklyPrizes) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                                width: 90.w,
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                child: const Text(
                                                                    "On this Week Prize",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white))),
                                                            SizedBox(
                                                                height: 4.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "1st Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyFirstPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "2nd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklySecondPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "3rd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyThirdPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "4th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyFourthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "5th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyFifthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 2.h),
                                                            Container(
                                                                width: 60.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: const Color(
                                                                      0xffff6533),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.1), // shadow color
                                                                      blurRadius:
                                                                          8,
                                                                      spreadRadius:
                                                                          2, // how far it spreads
                                                                      offset: const Offset(
                                                                          0,
                                                                          4), // x, y offset
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "6th - 20th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: weeklyConsolation1,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                    SizedBox(
                                                                        height:
                                                                            2.h),
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "21st - 100th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: weeklyConsolation2,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                  ],
                                                                )),
                                                          ])))),
                                          SizedBox(height: 6.h),
                                          const Text(
                                              "Watch to Understand how Task Performance Leaderboard Works",
                                              style: TextStyle(
                                                fontSize: 10,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.black,
                                                color: Colors.black,
                                              )),
                                          SizedBox(height: 1.h),
                                          SizedBox(
                                              width: 300,
                                              height: 150,
                                              child: YoutubePlayer(
                                                controller: _controller,
                                                aspectRatio: 16 / 9,
                                              )),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(children: [
                                                        Container(
                                                            width: 90.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: const Color(
                                                                  0xffff6533),
                                                            ),
                                                            child: const Text(
                                                                "No Prizes Available Yet for the Week",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white))),
                                                        SizedBox(height: 2.h),
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                            scale: 3),
                                                        SizedBox(height: 2.h),
                                                        const Text(
                                                            "Check in Shortly",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Color(
                                                                    0xffff6533))),
                                                        Text(
                                                            "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xffff6533))),
                                                      ])))),
                                          SizedBox(height: 2.h),
                                          const Text(
                                              "Begins on Tuesday 4th of November 2025, 10am WAT",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff545454),
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      );
                                    }
                                  } else {
                                    if (monthlyPrizes) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                                width: 90.w,
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                child: const Text(
                                                                    "On this Month Prize",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white))),
                                                            SizedBox(
                                                                height: 4.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "1st Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyFirstPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "2nd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlySecondPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "3rd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyThirdPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "4th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyFourthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "5th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyFifthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 2.h),
                                                            Container(
                                                                width: 60.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: const Color(
                                                                      0xffff6533),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.1), // shadow color
                                                                      blurRadius:
                                                                          8,
                                                                      spreadRadius:
                                                                          2, // how far it spreads
                                                                      offset: const Offset(
                                                                          0,
                                                                          4), // x, y offset
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "6th - 20th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: monthlyConsolation1,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                    SizedBox(
                                                                        height:
                                                                            2.h),
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "21st - 100th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: monthlyConsolation2,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                  ],
                                                                )),
                                                          ])))),
                                          SizedBox(height: 6.h),
                                          const Text(
                                              "Watch to Understand how Task Performance Leaderboard Works",
                                              style: TextStyle(
                                                fontSize: 10,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.black,
                                                color: Colors.black,
                                              )),
                                          SizedBox(height: 1.h),
                                          SizedBox(
                                              width: 300,
                                              height: 150,
                                              child: YoutubePlayer(
                                                controller: _controller,
                                                aspectRatio: 16 / 9,
                                              )),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(children: [
                                                        Container(
                                                            width: 90.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: const Color(
                                                                  0xffff6533),
                                                            ),
                                                            child: const Text(
                                                                "No Prizes Available Yet for the Month",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white))),
                                                        SizedBox(height: 2.h),
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                            scale: 3),
                                                        SizedBox(height: 2.h),
                                                        const Text(
                                                            "Check in Shortly",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Color(
                                                                    0xffff6533))),
                                                        Text(
                                                            "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xffff6533))),
                                                      ])))),
                                          SizedBox(height: 2.h),
                                          const Text(
                                              "Begins on Tuesday 4th of November 2025, 10am WAT",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff545454),
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      );
                                    }
                                  }
                                }

                                // Success
                                final docs = snapshot.data?.docs ?? [];

                                if (docs.isEmpty) {
                                  setState(() {
                                    isEmpty = true;
                                  });
                                  final target = DateTime.parse(
                                      '2025-11-04T10:00:00+01:00');
                                  final now = DateTime.now();
                                  final durationLeft = target.difference(now);
                                  final days = durationLeft.inDays;
                                  final hours = durationLeft.inHours % 24;
                                  final minutes = durationLeft.inMinutes % 60;
                                  if (isWeekly) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                            width: 90.w,
                                            child: Card(
                                                elevation: 6,
                                                shadowColor: Colors.black
                                                    .withOpacity(
                                                        0.3), // adds shadow
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                color: Colors.white,
                                                child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        18, 20, 18, 20),
                                                    child: Column(children: [
                                                      Container(
                                                          width: 90.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: const Color(
                                                                0xffff6533),
                                                          ),
                                                          child: const Text(
                                                              "No Available Ranking Yet This Week",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white))),
                                                      SizedBox(height: 2.h),
                                                      Image.network(
                                                          "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                          scale: 3),
                                                      SizedBox(height: 2.h),
                                                      const Text(
                                                          "Check in Shortly",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                              color: Color(
                                                                  0xffff6533))),
                                                      Text(
                                                          "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                          style: const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xffff6533))),
                                                    ])))),
                                        SizedBox(height: 2.h),
                                        const Text(
                                            "Begins on Tuesday 4th of November 2025, 10am WAT",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xff545454),
                                                fontWeight: FontWeight.bold))
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      SizedBox(
                                          width: 90.w,
                                          child: Card(
                                              elevation: 6,
                                              shadowColor: Colors.black
                                                  .withOpacity(
                                                      0.3), // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          18, 20, 18, 20),
                                                  child: Column(children: [
                                                    Container(
                                                        width: 90.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: const Color(
                                                              0xffff6533),
                                                        ),
                                                        child: const Text(
                                                            "No Available Ranking Yet This Month",
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white))),
                                                    SizedBox(height: 2.h),
                                                    Image.network(
                                                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                        scale: 3),
                                                    SizedBox(height: 2.h),
                                                    const Text(
                                                        "Check in Shortly",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            color: Color(
                                                                0xffff6533))),
                                                    Text(
                                                        "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xffff6533))),
                                                  ])))),
                                      SizedBox(height: 2.h),
                                      const Text(
                                          "Begins on Tuesday 4th of November 2025, 10am WAT",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xff545454),
                                              fontWeight: FontWeight.bold))
                                    ],
                                  );
                                }
                                try {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    userDoc.value = docs.firstWhere(
                                      (doc) => doc['uid'] == currentUser?.uid,
                                    );
                                    rank.value =
                                        docs.indexOf(userDoc.value!) + 1;
                                  });
                                } catch (e) {
                                  userDoc.value = null;
                                }

                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: docs.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final data = docs[index].data()
                                          as Map<String, dynamic>;
                                      final name = data['name'] ?? 'Unnamed';
                                      final dp = data['dp'] == ""
                                          ? 'https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png'
                                          : data['dp'];
                                      final weeklyStreak =
                                          data['weeklyStreak'] ?? "0";
                                      final monthlyStreak =
                                          data['streak'] ?? "0";
                                      final id = data["ID"] ?? "";

                                      return SizedBox(
                                        width: 90.w,
                                        child: Card(
                                          elevation: 6, // adds shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      18, 20, 18, 20),
                                              child: Column(
                                                children: [
                                                  Row(children: [
                                                    CircleAvatar(
                                                        radius: 22,
                                                        backgroundColor: index +
                                                                    1 ==
                                                                1
                                                            ? const Color(
                                                                0xffffb33a)
                                                            : index + 1 == 2
                                                                ? const Color(
                                                                    0xffa8a7a7)
                                                                : index + 1 == 3
                                                                    ? const Color(
                                                                        0xff875403)
                                                                    : const Color(
                                                                        0xffd1d5db),
                                                        child: Text(
                                                            "${index + 1}",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))),
                                                    SizedBox(width: 2.w),
                                                    CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(dp)),
                                                    SizedBox(width: 3.w),
                                                    Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: 50.w,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(name,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text("ID: $id",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ],
                                                            ),
                                                          ),
                                                        ])
                                                  ]),
                                                  SizedBox(height: 2.h),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            width: 50.w,
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xffd4d5d7),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Column(
                                                                children: [
                                                                  const Text(
                                                                      "Total Streaks",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  SizedBox(
                                                                      height:
                                                                          1.h),
                                                                  Text(
                                                                      isWeekly
                                                                          ? "$weeklyStreak days"
                                                                          : "$monthlyStreak days",
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color(
                                                                              0xffff6533),
                                                                          fontSize:
                                                                              10)),
                                                                ])),
                                                      ])
                                                ],
                                              )),
                                        ),
                                      );
                                    });
                              })
                          : StreamBuilder<QuerySnapshot>(
                              stream: _stream,
                              builder: (context, snapshot) {
                                //  Loading state
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ));
                                }

                                //  Error state
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }

                                if (viewPrizes) {
                                  final target = DateTime.parse(
                                      '2025-11-04T10:00:00+01:00');
                                  final now = DateTime.now();
                                  final durationLeft = target.difference(now);
                                  final days = durationLeft.inDays;
                                  final hours = durationLeft.inHours % 24;
                                  final minutes = durationLeft.inMinutes % 60;
                                  if (isWeekly) {
                                    if (weeklyPrizes) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                                width: 90.w,
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                child: const Text(
                                                                    "On this Week Prize",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white))),
                                                            SizedBox(
                                                                height: 4.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "1st Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyFirstPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "2nd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklySecondPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "3rd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyThirdPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "4th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyFourthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "5th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              weeklyFifthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 2.h),
                                                            Container(
                                                                width: 60.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: const Color(
                                                                      0xffff6533),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.1), // shadow color
                                                                      blurRadius:
                                                                          8,
                                                                      spreadRadius:
                                                                          2, // how far it spreads
                                                                      offset: const Offset(
                                                                          0,
                                                                          4), // x, y offset
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "6th - 20th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: weeklyConsolation1,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                    SizedBox(
                                                                        height:
                                                                            2.h),
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "21st - 100th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: weeklyConsolation2,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                  ],
                                                                )),
                                                          ])))),
                                          SizedBox(height: 6.h),
                                          const Text(
                                              "Watch to Understand how Task Performance Leaderboard Works",
                                              style: TextStyle(
                                                fontSize: 10,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.black,
                                                color: Colors.black,
                                              )),
                                          SizedBox(height: 1.h),
                                          SizedBox(
                                              width: 300,
                                              height: 150,
                                              child: YoutubePlayer(
                                                controller: _controller,
                                                aspectRatio: 16 / 9,
                                              )),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(children: [
                                                        Container(
                                                            width: 90.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: const Color(
                                                                  0xffff6533),
                                                            ),
                                                            child: const Text(
                                                                "No Prizes Available Yet for the Week",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white))),
                                                        SizedBox(height: 2.h),
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                            scale: 3),
                                                        SizedBox(height: 2.h),
                                                        const Text(
                                                            "Check in Shortly",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Color(
                                                                    0xffff6533))),
                                                        Text(
                                                            "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xffff6533))),
                                                      ])))),
                                          SizedBox(height: 2.h),
                                          const Text(
                                              "Begins on Tuesday 4th of November 2025, 10am WAT",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff545454),
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      );
                                    }
                                  } else {
                                    if (monthlyPrizes) {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                                width: 90.w,
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                child: const Text(
                                                                    "On this Month Prize",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white))),
                                                            SizedBox(
                                                                height: 4.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___1_-removebg-preview_axgii8.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "1st Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyFirstPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___2_-removebg-preview_ne4r33.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "2nd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlySecondPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___3_-removebg-preview_fzglrx.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "3rd Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyThirdPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066349/Leaderboard_For_Clickworkers__3___4_-removebg-preview_t3jjoc.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "4th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyFourthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1761066350/Leaderboard_For_Clickworkers__3___5_-removebg-preview_rlklqq.png",
                                                                    scale: 4),
                                                                SizedBox(
                                                                    width: 2.w),
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "5th Prize: ",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                        children: [
                                                                      TextSpan(
                                                                          text:
                                                                              monthlyFifthPrize,
                                                                          style: const TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey))
                                                                    ]))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 2.h),
                                                            Container(
                                                                width: 60.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        20),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: const Color(
                                                                      0xffff6533),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.1), // shadow color
                                                                      blurRadius:
                                                                          8,
                                                                      spreadRadius:
                                                                          2, // how far it spreads
                                                                      offset: const Offset(
                                                                          0,
                                                                          4), // x, y offset
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "6th - 20th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: monthlyConsolation1,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                    SizedBox(
                                                                        height:
                                                                            2.h),
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "21st - 100th Prize: ",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Colors.white),
                                                                            children: [
                                                                          TextSpan(
                                                                              text: monthlyConsolation2,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                              ))
                                                                        ])),
                                                                  ],
                                                                )),
                                                          ])))),
                                          SizedBox(height: 6.h),
                                          const Text(
                                              "Watch to Understand how Task Performance Leaderboard Works",
                                              style: TextStyle(
                                                fontSize: 10,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: Colors.black,
                                                color: Colors.black,
                                              )),
                                          SizedBox(height: 1.h),
                                          SizedBox(
                                              width: 300,
                                              height: 150,
                                              child: YoutubePlayer(
                                                controller: _controller,
                                                aspectRatio: 16 / 9,
                                              )),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          SizedBox(
                                              width: 90.w,
                                              child: Card(
                                                  elevation: 6,
                                                  shadowColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // adds shadow
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 20, 18, 20),
                                                      child: Column(children: [
                                                        Container(
                                                            width: 90.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: const Color(
                                                                  0xffff6533),
                                                            ),
                                                            child: const Text(
                                                                "No Prizes Available Yet for the Month",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white))),
                                                        SizedBox(height: 2.h),
                                                        Image.network(
                                                            "https://res.cloudinary.com/dihpawfyc/image/upload/v1761062166/Leaderboard_For_Clickworkers__2___1_-removebg-preview_tuaa1a.png",
                                                            scale: 3),
                                                        SizedBox(height: 2.h),
                                                        const Text(
                                                            "Check in Shortly",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w100,
                                                                color: Color(
                                                                    0xffff6533))),
                                                        Text(
                                                            "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xffff6533))),
                                                      ])))),
                                          SizedBox(height: 2.h),
                                          const Text(
                                              "Begins on Tuesday 4th of November 2025, 10am WAT",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xff545454),
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      );
                                    }
                                  }
                                }

                                // Success
                                final docs = snapshot.data?.docs ?? [];

                                if (docs.isEmpty && _isReady) {
                                  isEmpty = true;

                                  final target = DateTime.parse(
                                      '2025-11-04T10:00:00+01:00');
                                  final now = DateTime.now();
                                  final durationLeft = target.difference(now);
                                  final days = durationLeft.inDays;
                                  final hours = durationLeft.inHours % 24;
                                  final minutes = durationLeft.inMinutes % 60;
                                  if (isWeekly) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                            width: 90.w,
                                            child: Card(
                                                elevation: 6,
                                                shadowColor: Colors.black
                                                    .withOpacity(
                                                        0.3), // adds shadow
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                color: Colors.white,
                                                child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        18, 20, 18, 20),
                                                    child: Column(children: [
                                                      Container(
                                                          width: 90.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: const Color(
                                                                0xffff6533),
                                                          ),
                                                          child: const Text(
                                                              "No Available Ranking Yet This Week",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white))),
                                                      SizedBox(height: 2.h),
                                                      Image.network(
                                                          "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                          scale: 3),
                                                      SizedBox(height: 2.h),
                                                      const Text(
                                                          "Check in Shortly",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                              color: Color(
                                                                  0xffff6533))),
                                                      Text(
                                                          "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                          style: const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xffff6533))),
                                                    ])))),
                                        SizedBox(height: 2.h),
                                        const Text(
                                            "Begins on Tuesday 4th of November 2025, 10am WAT",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xff545454),
                                                fontWeight: FontWeight.bold))
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      SizedBox(
                                          width: 90.w,
                                          child: Card(
                                              elevation: 6,
                                              shadowColor: Colors.black
                                                  .withOpacity(
                                                      0.3), // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          18, 20, 18, 20),
                                                  child: Column(children: [
                                                    Container(
                                                        width: 90.w,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: const Color(
                                                              0xffff6533),
                                                        ),
                                                        child: const Text(
                                                            "No Available Ranking Yet This Month",
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white))),
                                                    SizedBox(height: 2.h),
                                                    Image.network(
                                                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1760917675/Leaderboard_For_Clickworkers__1_-removebg-preview_jhzra1.png",
                                                        scale: 3),
                                                    SizedBox(height: 2.h),
                                                    const Text(
                                                        "Check in Shortly",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w100,
                                                            color: Color(
                                                                0xffff6533))),
                                                    Text(
                                                        "Begins in ${days}days: ${hours}hrs: ${minutes}mins From Now",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xffff6533))),
                                                  ])))),
                                      SizedBox(height: 2.h),
                                      const Text(
                                          "Begins on Tuesday 4th of November 2025, 10am WAT",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xff545454),
                                              fontWeight: FontWeight.bold))
                                    ],
                                  );
                                }
                                if (_isReady) {
                                  try {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      userDoc.value = docs.firstWhere(
                                        (doc) => doc['uid'] == currentUser?.uid,
                                      );
                                      rank.value =
                                          docs.indexOf(userDoc.value!) + 1;
                                    });
                                  } catch (e) {
                                    userDoc.value = null;
                                  }
                                }

                                return FutureBuilder(
                                    future: Future.delayed(
                                        const Duration(seconds: 2)),
                                    builder: (context, delaySnap) {
                                      if (delaySnap.connectionState !=
                                          ConnectionState.done) {
                                        return const Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.black));
                                      }
                                      return Column(
                                        children: [
                                          rank.value != 1
                                              ? ValueListenableBuilder(
                                                  valueListenable: userDoc,
                                                  builder: (context, user, __) {
                                                    //current user card
                                                    if (userDoc.value != null) {
                                                      return SizedBox(
                                                        width: 92.w,
                                                        height: 200,
                                                        child: Card(
                                                          elevation:
                                                              6, // adds shadow
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          color: Colors.white,
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      18,
                                                                      20,
                                                                      18,
                                                                      20),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                            radius:
                                                                                22,
                                                                            backgroundColor:
                                                                                Colors.grey,
                                                                            child: Text("${rank.value}", style: const TextStyle(fontWeight: FontWeight.bold))),
                                                                        SizedBox(
                                                                            width:
                                                                                2.w),
                                                                        CircleAvatar(
                                                                            radius:
                                                                                20,
                                                                            backgroundImage: user!['dp'] != ""
                                                                                ? NetworkImage(user['dp'])
                                                                                : const NetworkImage("https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png")),
                                                                        SizedBox(
                                                                            width:
                                                                                3.w),
                                                                        Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 50.w,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                                    Text("ID: ${user['ID']}", style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 1.h),
                                                                              Row(
                                                                                children: [
                                                                                  const Icon(Icons.bolt, size: 16),
                                                                                  const Text("Task Speed Score", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(width: 0.5.w),
                                                                                  Text(isWeekly ? "${user['weeklySpeedScore']}/20" : "${user['speedScore']}/20", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 1.h),
                                                                              Row(
                                                                                children: [
                                                                                  const Text("⭐ Client/Advertiser Rating",
                                                                                      style: TextStyle(
                                                                                        fontSize: 10,
                                                                                      )),
                                                                                  SizedBox(width: 0.5.w),
                                                                                  Text(isWeekly ? "${user['weeklyRating']}/30" : "${user['rating']}/30", style: const TextStyle(fontSize: 10, color: Color(0xffff6533))),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 1.h),
                                                                              Row(
                                                                                children: [
                                                                                  const Icon(Icons.check_circle_outline, size: 12),
                                                                                  const Text(" Approval Rate Score", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                                                  SizedBox(width: 0.5.w),
                                                                                  Text(isWeekly ? "${user['weeklyApprovalScore']}/10" : "${user['approvalScore']}/10", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))
                                                                                ],
                                                                              ),
                                                                            ])
                                                                      ]),
                                                                  SizedBox(
                                                                      height:
                                                                          2.h),
                                                                  Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                            padding:
                                                                                const EdgeInsets.all(8),
                                                                            width: 38.w,
                                                                            decoration: BoxDecoration(color: const Color(0xffd4d5d7), borderRadius: BorderRadius.circular(10)),
                                                                            child: Column(
                                                                              children: [
                                                                                Row(children: [
                                                                                  const Text("Task Quantity Score: ", style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                  Text(isWeekly ? "${user['weeklyQuantityScore']}/20" : "${user['quantityScore']}/20", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffff6533), fontSize: 9)),
                                                                                ]),
                                                                                SizedBox(height: 1.h),
                                                                                Row(children: [
                                                                                  const Text("Task Diversity Score: ", style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                                  Text(isWeekly ? "${user['weeklyDiversityScore']}/20" : "${user['diversityScore']}/20", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffff6533), fontSize: 9)),
                                                                                ]),
                                                                              ],
                                                                            )),
                                                                        Container(
                                                                            padding:
                                                                                const EdgeInsets.all(8),
                                                                            width: 38.w,
                                                                            decoration: BoxDecoration(color: const Color(0xffd4d5d7), borderRadius: BorderRadius.circular(10)),
                                                                            child: Column(children: [
                                                                              const Text("Task Performance Score", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                                              SizedBox(height: 1.h),
                                                                              Text(isWeekly ? "${user['weeklyPerformanceScore']}/100" : "${user['performanceScore']}/100", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffff6533), fontSize: 10)),
                                                                            ])),
                                                                      ])
                                                                ],
                                                              )),
                                                        ),
                                                      );
                                                    } else {
                                                      return const SizedBox(
                                                          height: 0);
                                                    }
                                                  })
                                              : const SizedBox(height: 0),
                                          SizedBox(height: 1.h),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: docs.length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                final data = docs[index].data()
                                                    as Map<String, dynamic>;
                                                final name =
                                                    data['name'] ?? 'Unnamed';
                                                final dp = data['dp'] == ""
                                                    ? 'https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png'
                                                    : data['dp'];
                                                final speedScore =
                                                    data["speedScore"] ?? "0";
                                                final weeklySpeedScore =
                                                    data["weeklySpeedScore"] ??
                                                        "0";
                                                final clientRating =
                                                    data["rating"] ?? "0";
                                                final weeklyClientRating =
                                                    data["weeklyRating"] ?? "0";
                                                final approvalScore =
                                                    data["approvalScore"] ??
                                                        "0";
                                                final weeklyApprovalScore =
                                                    data["weeklyApprovalScore"] ??
                                                        "0";
                                                final weeklyDiversityScore =
                                                    data["weeklyDiversityScore"] ??
                                                        "0";
                                                final diversityScore =
                                                    data["diversityScore"] ??
                                                        "0";
                                                final quantityScore =
                                                    data["quantityScore"] ??
                                                        "0";
                                                final weeklyQuantityScore =
                                                    data["weeklyQuantityScore"] ??
                                                        "0";
                                                final performanceScore =
                                                    data["performanceScore"] ??
                                                        "0";
                                                final weeklyPerformanceScore =
                                                    data["weeklyPerformanceScore"] ??
                                                        "0";
                                                final id = data["ID"] ?? "";

                                                return SizedBox(
                                                  width: 90.w,
                                                  child: Card(
                                                    elevation: 6, // adds shadow
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    color: Colors.white,
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                18, 20, 18, 20),
                                                        child: Column(
                                                          children: [
                                                            Row(children: [
                                                              CircleAvatar(
                                                                  radius: 22,
                                                                  backgroundColor: index +
                                                                              1 ==
                                                                          1
                                                                      ? const Color(
                                                                          0xffffb33a)
                                                                      : index + 1 ==
                                                                              2
                                                                          ? const Color(
                                                                              0xffa8a7a7)
                                                                          : index + 1 ==
                                                                                  3
                                                                              ? const Color(
                                                                                  0xff875403)
                                                                              : const Color(
                                                                                  0xffd1d5db),
                                                                  child: Text(
                                                                      "${index + 1}",
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold))),
                                                              SizedBox(
                                                                  width: 2.w),
                                                              CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                          dp)),
                                                              SizedBox(
                                                                  width: 3.w),
                                                              Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          50.w,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                              name,
                                                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                          Text(
                                                                              "ID: $id",
                                                                              style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            1.h),
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .bolt,
                                                                            size:
                                                                                16),
                                                                        const Text(
                                                                            "Task Speed Score",
                                                                            style:
                                                                                TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                                        SizedBox(
                                                                            width:
                                                                                0.5.w),
                                                                        Text(
                                                                            isWeekly
                                                                                ? "$weeklySpeedScore/20"
                                                                                : "$speedScore/20",
                                                                            style: const TextStyle(
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.grey))
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            1.h),
                                                                    Row(
                                                                      children: [
                                                                        const Text(
                                                                            "⭐ Client/Advertiser Rating",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 10,
                                                                            )),
                                                                        SizedBox(
                                                                            width:
                                                                                0.5.w),
                                                                        Text(
                                                                            isWeekly
                                                                                ? "$weeklyClientRating/30"
                                                                                : "$clientRating/30",
                                                                            style:
                                                                                const TextStyle(fontSize: 10, color: Color(0xffff6533))),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            1.h),
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .check_circle_outline,
                                                                            size:
                                                                                12),
                                                                        const Text(
                                                                            " Approval Rate Score",
                                                                            style:
                                                                                TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                                        SizedBox(
                                                                            width:
                                                                                0.5.w),
                                                                        Text(
                                                                            isWeekly
                                                                                ? "$weeklyApprovalScore/10"
                                                                                : "$approvalScore/10",
                                                                            style: const TextStyle(
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.grey))
                                                                      ],
                                                                    ),
                                                                  ])
                                                            ]),
                                                            SizedBox(
                                                                height: 2.h),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      width: 38
                                                                          .w,
                                                                      decoration: BoxDecoration(
                                                                          color: const Color(
                                                                              0xffd4d5d7),
                                                                          borderRadius: BorderRadius.circular(
                                                                              10)),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(children: [
                                                                            const Text("Task Quantity Score: ",
                                                                                style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                            Text(isWeekly ? "$weeklyQuantityScore/20" : "$quantityScore/20",
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffff6533), fontSize: 9)),
                                                                          ]),
                                                                          SizedBox(
                                                                              height: 1.h),
                                                                          Row(children: [
                                                                            const Text("Task Diversity Score: ",
                                                                                style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                            Text(isWeekly ? "$weeklyDiversityScore/20" : "$diversityScore/20",
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffff6533), fontSize: 9)),
                                                                          ]),
                                                                        ],
                                                                      )),
                                                                  Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      width: 38
                                                                          .w,
                                                                      decoration: BoxDecoration(
                                                                          color: const Color(
                                                                              0xffd4d5d7),
                                                                          borderRadius: BorderRadius.circular(
                                                                              10)),
                                                                      child: Column(
                                                                          children: [
                                                                            const Text("Task Performance Score",
                                                                                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                                            SizedBox(height: 1.h),
                                                                            Text(isWeekly ? "$weeklyPerformanceScore/100" : "$performanceScore/100",
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffff6533), fontSize: 10)),
                                                                          ])),
                                                                ])
                                                          ],
                                                        )),
                                                  ),
                                                );
                                              }),
                                        ],
                                      );
                                    });
                              }),
            ),
            !viewPrizes || !isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalPages, (index) {
                          final page = index + 1;
                          final selected = currentPage == page;
                          return TextButton(
                            onPressed: isSelected == "Top ClickPoints"
                                ? () {
                                    _updateStream(page, "clickPoints");
                                  }
                                : isSelected == "Top Referral Points"
                                    ? () {
                                        _updateStream(page, "referrals");
                                      }
                                    : isSelected == "Top Streak"
                                        ? () {
                                            _updateStream(page, "streak");
                                          }
                                        : () {
                                            _updateStream(
                                                page, "performanceScore");
                                          },
                            child: Text("$page",
                                style: TextStyle(
                                  color: selected
                                      ? const Color(0xffff6533)
                                      : Colors.black,
                                  fontSize: 14,
                                )),
                          );
                        }),
                      ),
                    ),
                  )
                : const SizedBox(height: 0),
          ]),
        ],
      ),
    );
  }
}

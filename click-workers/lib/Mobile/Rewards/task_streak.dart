import 'package:click_workers/Mobile/Rewards/streak_achievements.dart';
import 'package:click_workers/Mobile/widgets/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskStreak extends StatefulWidget {
  final String endsIn;
  final bool checkedIn;
  final int streak;
  final PageController controller;
  const TaskStreak(
      {super.key,
      required this.endsIn,
      required this.checkedIn,
      required this.controller,
      required this.streak});

  @override
  State<TaskStreak> createState() => _TaskStreakState();
}

class _TaskStreakState extends State<TaskStreak> {
  DateTime _focusedDay = DateTime.now();
  Set<String> _checkinDates = {};
  int approved = 0;
  int submitted = 0;
  int clickPoints = 0;
  int longestStreak = 0;
  int weeklyStreak = 0;
  DateTime? createdOn;
  bool _loadingCheckins = false;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String _dateKey(DateTime d) =>
      _dateFormat.format(DateTime(d.year, d.month, d.day));

  Map<String, bool> levels = {
    "Rookie": true,
    "Novice": false,
    "Apprentice": false,
    "Junior": false,
    "Skilled": false,
    "Pro": false,
    "Expert": false,
    "Elite": false,
    "Master": false,
    "Grand Master": false,
  };

  String getDisplayText(Map<String, bool> flags, int weeks) {
    // Defensive: avoids division by zero or negative weeks
    if (weeks <= 0) return "0%";

    final keys = flags.keys.toList();

    // finds the last index where the flag is true
    int lastTrueIndex = -1;
    for (int i = keys.length - 1; i >= 0; i--) {
      if (flags[keys[i]] == true) {
        lastTrueIndex = i;
        break;
      }
    }

    if (lastTrueIndex == -1) {
      return "0%"; // no true flags
    }

    final indexValue = lastTrueIndex + 1; // convert 0-based -> 1-based
    double rawPercent = (indexValue / weeks) * 100;

    // round as requested
    int percent = rawPercent.round();

    // optional: clamps between 0 and 100
    percent = percent.clamp(0, 100);

    return "$percent%";
  }

  @override
  void initState() {
    super.initState();
    _loadCheckinsForMonth(_focusedDay);
    getTaskDetails();
    getUserAndRewardDetails();
    getWeeklyStreak();
  }

  Future<void> getWeeklyStreak() async {
    final docRef = FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data() as Map<String, dynamic>;
      final streak = data['weeklyStreak'];

      setState(() {
        weeklyStreak = streak;
      });
    }
  }

  Future<void> _loadCheckinsForMonth(DateTime focusedDay) async {
    setState(() => _loadingCheckins = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('rewards');

    final start = DateTime(focusedDay.year, focusedDay.month, 1);
    final end = DateTime(focusedDay.year, focusedDay.month + 1, 1); // exclusive

    final snapshot = await col
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    final Set<String> found = snapshot.docs.map((d) {
      final data = d.data();
      final dateField = data['date'];
      if (dateField is Timestamp) {
        return _dateKey(dateField.toDate());
      }
      // fallback: if you used docId as date string
      return d.id;
    }).toSet();

    setState(() {
      _checkinDates = found;
      _loadingCheckins = false;
    });
  }

  void setLevel(String selectedKey) {
    final keys = levels.keys.toList();
    final index = keys.indexOf(selectedKey);

    setState(() {
      for (int i = 0; i < keys.length; i++) {
        levels[keys[i]] = i <= index;
      }
    });
  }

  //get streak log details
  Future<void> getTaskDetails() async {
    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks');

    // Normalize today's date to midnight
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTimestamp = Timestamp.fromDate(today);

    final approvedSnap = await tasksRef
        .where('submissionStatus', isEqualTo: 'approved')
        .where('date', isEqualTo: todayTimestamp)
        .get();

    final submittedSnap = await tasksRef
        .where('status', isEqualTo: 'submitted')
        .where('date', isEqualTo: todayTimestamp)
        .get();

    setState(() {
      approved = approvedSnap.docs.length;
      submitted = submittedSnap.docs.length;
    });
  }

  Future<void> getUserAndRewardDetails() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final rewardsRef = userRef.collection('rewards');

    // format today's date as yyyy-MM-dd
    final now = DateTime.now();
    final todayString =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // fetch both in parallel
    final results = await Future.wait([
      userRef.get(),
      rewardsRef.where('date', isEqualTo: todayString).limit(1).get(),
    ]);

    final userSnap = results[0] as DocumentSnapshot;
    final rewardsSnap = results[1] as QuerySnapshot;

    if (userSnap.exists) {
      final userData = userSnap.data() as Map<String, dynamic>;
      final createdOnValue = userData['createdOn'].toDate();
      final streakRank = userData['streakRank'];
      final longestStreakValue = userData['longestStreak'];
      setLevel(streakRank);

      setState(() {
        createdOn = createdOnValue;
        longestStreak = longestStreakValue;
      });
    }

    if (rewardsSnap.docs.isNotEmpty) {
      final rewardData = rewardsSnap.docs.first.data() as Map<String, dynamic>;
      final clickPointsValue = rewardData['clickPoints'];

      setState(() {
        clickPoints = clickPointsValue ?? 0;
      });
    }
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
            child: Text('Task Streak',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xffeeeeee),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 2.h,
                ),
                SizedBox(
                  width: 85.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.red,
                          ),
                          SizedBox(
                            width: 0.5.w,
                          ),
                          const Text(
                            "Missed",
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.green,
                          ),
                          SizedBox(
                            width: 0.5.w,
                          ),
                          const Text(
                            "Checked-in",
                            style: TextStyle(fontSize: 10, color: Colors.green),
                          )
                        ],
                      ),
                      Text(
                        widget.checkedIn
                            ? "Checked In"
                            : "Todays Check In Ends: ${widget.endsIn.trim()}",
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xffa87967),
                            fontSize: 10,
                            color: Color(0xffa87967)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 4.h,
                ),
                SizedBox(
                  width: 85.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat("MMMM ''yy")
                            .format(_focusedDay)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900, // bold/heavy
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  width: 85.w,
                  decoration: BoxDecoration(
                      color: const Color(0xff092e57),
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("SUN",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text("MON",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text("TUE",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text("WED",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text("THU",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text("FRI",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text("SAT",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                SizedBox(
                    height: 315,
                    width: 95.w,
                    child: CustomCheckInCalendar(
                      createdOn: createdOn ?? DateTime.now(),
                      loadingCheckins: _loadingCheckins,
                      checkinDates: _checkinDates,
                      focusedDay: _focusedDay,
                      onPageChanged: (newDay) {
                        setState(() {
                          _focusedDay = newDay;
                        });
                        _loadCheckinsForMonth(_focusedDay);
                      },
                    )),
                DateFormat("MMMM ''yy").format(_focusedDay).toUpperCase() ==
                            "AUGUST '25" ||
                        DateFormat("MMMM ''yy")
                                .format(_focusedDay)
                                .toUpperCase() ==
                            "MARCH '25" ||
                        DateFormat("MMMM ''yy")
                                .format(_focusedDay)
                                .toUpperCase() ==
                            "NOVEMBER '25"
                    ? SizedBox(height: 2.h)
                    : const SizedBox(
                        height: 0,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Quick Rules",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white)),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: const TextSpan(
                                          text: "1. Keep your streak: ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          children: [
                                        TextSpan(
                                            text:
                                                "Perform at least 5 task each day to mark your daily check-in.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12))
                                      ])),
                                  SizedBox(height: 2.h),
                                  SizedBox(
                                      width: 99.w,
                                      child: RichText(
                                          text: const TextSpan(
                                              text: "2. Miss a day: ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              children: [
                                            TextSpan(
                                                text: "Streak resets to 0.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12))
                                          ]))),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: const TextSpan(
                                          text: "3. Inactivity Deduction: ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          children: [
                                        TextSpan(
                                            text:
                                                "After 7 consecutive inactive days, 1% of your current ClickPoints balance is deducted everyday until you complete a task.",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12))
                                      ])),
                                ])))),
                SizedBox(height: 4.h),
                SizedBox(
                    width: 85.w,
                    child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xfffe6929),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text("Today Streak Log",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white))),
                                  ),
                                  SizedBox(
                                    height: 3.h,
                                  ),
                                  RichText(
                                      text: TextSpan(
                                          text: "Number of Tasks Performed: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "$submitted",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: TextSpan(
                                          text: "Number of Tasks Approved: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "$approved",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: TextSpan(
                                          text:
                                              "Remaining task to complete streak: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: 5 - submitted > 0
                                                ? "${5 - submitted}"
                                                : "0",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: TextSpan(
                                          text: "Today's streak status: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: widget.checkedIn
                                                ? "Kept"
                                                : "Incomplete",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: TextSpan(
                                          text: "Streak Day: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "${widget.streak}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: TextSpan(
                                          text:
                                              "Daily Check-in Click Points Earned: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "${clickPoints}CPs",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: const TextSpan(
                                          text:
                                              "Reward After Streak Completion: ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "50,000CPs",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: TextSpan(
                                          text: "Longest Streak: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "$longestStreak days",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: TextSpan(
                                          text: "Signed up: ",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: createdOn != null
                                                ? "${DateTime.now().difference(createdOn!).inDays} days ago"
                                                : "",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: const TextSpan(
                                          text: "Total Active Days: ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "12",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: const TextSpan(
                                          text: "First Login Today: ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "3:30AM WAT",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                  SizedBox(height: 2.h),
                                  RichText(
                                      text: const TextSpan(
                                          text: "Number of Logins Today: ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          children: [
                                        TextSpan(
                                            text: "5 times",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))
                                      ])),
                                ])))),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 85.w,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Task Streak Leaderboard",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            Future.delayed(Duration.zero, () {
                              widget.controller.jumpToPage(2);
                            });
                          },
                          child: const Text("View All",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline)),
                        )
                      ]),
                ),
                SizedBox(
                  width: 85.w,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('leaderboard')
                          .orderBy('weeklyStreak', descending: true)
                          .limit(3)
                          .snapshots(),
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

                        // Success
                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(
                              child: Text('Nothing to see here.'));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final name = data['name'] ?? 'Unnamed';
                            final dp = data['dp'] ?? '';
                            final totalPoints = data['points'];

                            final weeklyStreak = data['weeklyStreak'];

                            return SizedBox(
                              width: 85.w,
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
                                                      ? const Color(0xffa8a7a7)
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
                                                Text(name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(width: 1.w),
                                                const Text("Total Points",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12)),
                                                SizedBox(width: 1.w),
                                                Text(
                                                    "${totalPoints.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} pts",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                                SizedBox(width: 1.w),
                                                Text(
                                                    "Weekly 🔥: $weeklyStreak week(s)")
                                              ])
                                        ]),
                                      ],
                                    )),
                              ),
                            );
                          },
                        );
                      }),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                    width: 85.w,
                    child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("My Streak Achievement",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StreakAchievements(
                                                        controller:
                                                            widget.controller,
                                                        levels: levels,
                                                        weeklyStreak:
                                                            weeklyStreak)),
                                          );
                                        },
                                        child: const Text("View All",
                                            style: TextStyle(
                                                fontSize: 12,
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Colors.black)))
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xff774e40),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Image.asset(
                                                  "assets/rewards/rookie.png",
                                                  scale: 4),
                                              const Text("  Rookie",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(width: 3.w),
                                              Text("$weeklyStreak/1 Week",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white))
                                            ])),
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff007a3f),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              const Text("Completed",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white)),
                                              SizedBox(width: 1.w),
                                              const Icon(Icons.check_circle,
                                                  color: Colors.white, size: 16)
                                            ]))
                                  ]),
                              SizedBox(height: 2.h),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                       padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xff774e40),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Image.asset(
                                                  "assets/rewards/novice.png",
                                                  scale: 4),
                                              const Text("  Novice",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(width: 3.w),
                                              Text("$weeklyStreak/2 Week",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white))
                                            ])),
                                    levels["Novice"] == true
                                        ? Container(
                                           padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff007a3f),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Text("Completed",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 16)
                                                ]))
                                        : Container(
                                           padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff606060),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                      "${getDisplayText(levels, 2)} Complete",
                                                      style: const TextStyle(
                                                          fontSize: 8,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  Image.asset(
                                                      "assets/rewards/loader.png",
                                                      scale: 8)
                                                ]))
                                  ]),
                              SizedBox(height: 2.h),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xff774e40),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Image.asset(
                                                  "assets/rewards/apprentice.png",
                                                  scale: 4),
                                              const Text("  Apprentice",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(width: 1.w),
                                              Text("$weeklyStreak/3 Week",
                                                  style: const TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.white))
                                            ])),
                                    levels["Apprentice"] == true
                                        ? Container(
                                           padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff007a3f),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Text("Completed",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 16)
                                                ]))
                                        : Container(
                                           padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff606060),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                      "${getDisplayText(levels, 3)} Complete",
                                                      style: const TextStyle(
                                                          fontSize: 8,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  Image.asset(
                                                      "assets/rewards/loader.png",
                                                      scale: 8)
                                                ]))
                                  ]),
                              SizedBox(height: 2.h),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xff774e40),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Image.asset(
                                                  "assets/rewards/jr.png",
                                                  scale: 4),
                                              const Text("  Junior",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(width: 3.w),
                                              Text("$weeklyStreak/4 Week",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white))
                                            ])),
                                    levels["Junior"] == true
                                        ? Container(
                                           padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff007a3f),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Text("Completed",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 16)
                                                ]))
                                        : Container(
                                          padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff606060),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                      "${getDisplayText(levels, 4)} Complete",
                                                      style: const TextStyle(
                                                          fontSize: 8,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  Image.asset(
                                                      "assets/rewards/loader.png",
                                                      scale: 8)
                                                ]))
                                  ]),
                              SizedBox(height: 2.h),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xff774e40),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Image.asset(
                                                  "assets/rewards/skilled.png",
                                                  scale: 4),
                                              const Text("  Skilled",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                              SizedBox(width: 3.w),
                                              Text("$weeklyStreak/5 Week",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white))
                                            ])),
                                    levels["Skilled"] == true
                                        ? Container(
                                            padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff007a3f),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Text("Completed",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  const Icon(Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 16)
                                                ]))
                                        : Container(
                                           padding: const EdgeInsets.fromLTRB(
                                            13, 13, 13, 13),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff606060),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                      "${getDisplayText(levels, 12)}  Complete",
                                                      style: const TextStyle(
                                                          fontSize: 8,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  Image.asset(
                                                      "assets/rewards/loader.png",
                                                      scale: 8)
                                                ]))
                                  ]),
                            ])))),
                SizedBox(height: 3.h),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(Duration.zero, () {
                        widget.controller.jumpToPage(1);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(30, 18, 30, 18),
                        backgroundColor: const Color(0xffa64221)),
                    child: const Text("GO TO TASKS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ))),
                SizedBox(height: 1.h),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(Duration.zero, () {
                        widget.controller.jumpToPage(0);
                      });
                    },
                    child: const Text("Go back to Homepage",
                        style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline))),
              ],
            ),
          ),
        ));
  }
}

import 'package:click_workers/Mobile/Rewards/gratis_achievements.dart';
import 'package:click_workers/Mobile/Rewards/grit_achievements.dart';
import 'package:click_workers/Mobile/Rewards/no_treasure.dart';
import 'package:click_workers/Mobile/Rewards/streak_achievements.dart';
import 'package:click_workers/Mobile/Rewards/task_streak.dart';
import 'package:click_workers/Mobile/Rewards/treasure_hunt.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart' as intl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import '../widgets/arrow_animation.dart';

class Rewards extends StatefulWidget {
  const Rewards({
    super.key,
    required this.controller,
    required this.kycCompleted,
  });

  final PageController controller;
  final bool kycCompleted;
  @override
  State<Rewards> createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> with SingleTickerProviderStateMixin {
  bool checkedIn = false;
  final List<String> labels = [
    '500CPs',
    '15%\nPts',
    '15mins\n2x Pts',
    'Free\nSpin',
    'Hunt\nHint',
    '₦5,000',
    '30CPs',
    '₦200'
  ];
  Map<String, Map<String, dynamic>> docsByDate = {};
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  int streak = 0;
  String totalPoints = "0";
  int completedTasks = 0;
  String streakRank = "Rookie";
  String gritLevel = "1";
  bool spinned = false;
  String gratisLevel = "1";
  int pointCount = 5;
  int weeklyStreak = 0;
  String points = "0";
  String balance = "0";
  int earningsCount = 5;
  int weeklyTreasureCount = 0;
  int availableTreasureCount = 0;
  String? _result;
  late List<Map<String, String>> weekDays;
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

  @override
  void initState() {
    super.initState();
    checkIfSpinned();
    _loadStreak();
    getPointBal();
    getWeeklyStreak();
    getAchievements();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    // Initialize _animation to a default value
    _animation = AlwaysStoppedAnimation(_currentAngle);

    final now = DateTime.now();

    weekDays = List.generate(6, (i) {
      final date = now.add(Duration(days: i - 2)); // today at index 2
      return {
        "weekday": intl.DateFormat.E().format(date), // Mon, Tue, Wed...
      };
    });
    _loadDocs();
    checkTodayDoc();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getAchievements() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      //  Update a variable in your state
      setState(() {
        streakRank = data!['streakRank'] ?? "Rookie";
        gritLevel = data['gritLevel'] ?? "1";
        gratisLevel = data['gratisLevel'] ?? "1";
        completedTasks = data['completedTasks'] ?? 0;
      });
      setLevel(streakRank);
    }
  }

  Future<void> _loadStreak() async {
    final fetchedStreak = await getRewardStreak("userId123");
    setState(() {
      streak = fetchedStreak;
    });
  }

  Future<Map<String, Map<String, dynamic>>> fetchAllDocs() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('rewards')
        .get();

    // Convert to { "2025-08-23": {data...}, ... }
    final Map<String, Map<String, dynamic>> docsByDate = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = data['date'] as String?;
      if (date != null) {
        docsByDate[date] = data;
      }
    }

    return docsByDate;
  }

  //load docs
  Future<void> _loadDocs() async {
    getWeeklyTreasureCount();
    final fetchedDocs = await fetchAllDocs();
    setState(() {
      docsByDate = fetchedDocs;
    });
  }

  Future<void> getWeeklyTreasureCount() async {
    final doc = await FirebaseFirestore.instance
        .collection('announcements')
        .doc('treasures')
        .get();

    if (doc.exists) {
      setState(() {
        weeklyTreasureCount = doc['thisWeek'];
        availableTreasureCount = doc['remaining'];
      });
    }
  }

  int _getWeightedIndex() {
    final weights = [0, 10, 10, 0, 10, 30, 0, 30];

    final expanded = <int>[];
    for (int i = 0; i < weights.length; i++) {
      expanded.addAll(List.filled(weights[i], i));
    }

    final random = Random();
    return expanded[random.nextInt(expanded.length)];
  }

  // int _getRandomIndex() {
  //   final random = Random();
  //   return random.nextInt(labels.length); // all labels equally likely
  // }

  void _spinWheel() {
    if (_controller.isAnimating) return;

    final random = Random();
    const spins = 5; // 5 full spins
    final anglePerSegment = 2 * pi / labels.length;
    final targetIndex = _getWeightedIndex(); // randomchoice
    final targetOffset =
        random.nextDouble() * anglePerSegment; // random inside that slice

    final double spinAngle =
        spins * 2 * pi + targetIndex * anglePerSegment + targetOffset;

    _animation = Tween<double>(
      begin: 0,
      end: spinAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.reset();
    _controller.forward();

    _animation.addListener(() {
      setState(() {
        _currentAngle = _animation.value;
      });
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final anglePerSegment = 2 * pi / labels.length;
        final double finalAngle = _animation.value % (2 * pi);

        double corrected = finalAngle % (2 * pi);
        if (corrected < 0) corrected += 2 * pi;

        int index = (corrected / anglePerSegment).floor();
        index = labels.length - 1 - index;
        if (index < 0) index += labels.length;

        setState(() {
          _result = labels[index];
          spinned = true;
        });
        debugPrint(_result);

        if (_result == "₦5,000" || _result == "₦200") {
          addOrUpdateDoc(
              DateTime.now(), {'cashGift': _result, 'spinned': true});
        } else if (_result == "30CPs" ||
            _result == "500CPs" ||
            _result == "15%\nPts" ||
            _result == "15mins\n2x Pts") {
          addOrUpdateDoc(DateTime.now(), {'spinned': true});
        } else if (_result == "Hunt\nHint") {
          addOrUpdateDoc(DateTime.now(), {'spinned': true});
        } else {
          addOrUpdateDoc(DateTime.now(), {'spinned': false});
          setState(() {
            spinned = false;
          });
        }
      }
    });
  }

  Future<void> addOrUpdateDoc(
      DateTime date, Map<String, dynamic> otherFields) async {
    final firestore = FirebaseFirestore.instance;
    final dateString =
        date.toIso8601String().split('T').first; // e.g. "2025-08-25"

    // Reference to the collection
    final collection = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('rewards');

    // Query if a doc with this date exists
    final snapshot =
        await collection.where('date', isEqualTo: dateString).limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      // Update the existing document
      final docId = snapshot.docs.first.id;
      await collection.doc(docId).update(otherFields);
    } else {
      // Create a new document with the date field
      await collection.add({
        'date': dateString,
        ...otherFields,
      });
    }
  }

  String getTimeLeftInDay(bool isSpin) {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day + 1); // midnight next day
    final diff = tomorrow.difference(now); // Duration

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (isSpin) {
      return "Refreshes in ${hours}hrs:${minutes}mins";
    } else {
      return "Ends:${hours}hrs:${minutes}mins   ";
    }
  }

//check if a doc for today exists
  Future<void> checkTodayDoc() async {
    final firestore = FirebaseFirestore.instance;
    final todayString =
        DateTime.now().toIso8601String().split('T').first; // "2025-08-25"

    final snapshot = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('rewards')
        .where('date', isEqualTo: todayString)
        .where('status', isEqualTo: "checked In")
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      //  Update a variable in your state
      setState(() {
        checkedIn = true;
        pointCount = snapshot.docs[0]['spinCount'];
        earningsCount = snapshot.docs[0]['spinCount2'];
      });
    }
  }

//check if a doc for today exists
  Future<void> checkIfSpinned() async {
    final firestore = FirebaseFirestore.instance;
    final todayString =
        DateTime.now().toIso8601String().split('T').first; // "2025-08-25"

    final snapshot = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('rewards')
        .where('date', isEqualTo: todayString)
        .where('spinned', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        spinned = true;
      });
    }
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
        points = data!['availablePoints'] ?? "0";
        balance = data['availableEarnings'] ?? "0";
        totalPoints = data['totalPoints'] ?? "0";
      });
    }
  }

  Future<int> getSubmittedTasksCount(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    // Get today's start and end times
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Query only by date range
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    // Now filter client-side for submitted status
    final submittedDocs = snapshot.docs.where((doc) {
      return (doc['status'] as String?) == 'submitted';
    });

    return submittedDocs.length; // number of submitted tasks today
  }

  Future<int> getRewardStreak(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    int streak = 0;
    DateTime currentDay = DateTime(now.year, now.month, now.day);

    while (true) {
      final dateString =
          currentDay.toIso8601String().split('T').first; // "YYYY-MM-DD"

      final query = await firestore
          .collection('users')
          .doc(userId)
          .collection('rewards')
          .where('date', isEqualTo: dateString)
          .where('status', isEqualTo: 'checked In')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        streak++;
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else {
        break; // streak ends
      }
    }

    return streak;
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

  void setLevel(String selectedKey) {
    final keys = levels.keys.toList();
    final index = keys.indexOf(selectedKey);

    setState(() {
      for (int i = 0; i < keys.length; i++) {
        levels[keys[i]] = i <= index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final endsIn = getTimeLeftInDay(false);
    final refreshIn = getTimeLeftInDay(true);

    // 2 days before today, today itself, and 3 days after today
    final checkinDays = [
      today.subtract(const Duration(days: 2)),
      today.subtract(const Duration(days: 1)),
      today,
      today.add(const Duration(days: 1)),
      today.add(const Duration(days: 2)),
      today.add(const Duration(days: 3)),
    ];
    const size = 250.0;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Divider(thickness: 0.5, color: Colors.grey),
            SizedBox(
              height: 1.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "   Daily Check-in",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(checkedIn ? "Checked In" : endsIn,
                        style: const TextStyle(
                            color: Color(0xffa87967),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    SizedBox(width: 0.5.w),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            ),
            Container(
              width: double.infinity,
              color: const Color(0xffeeeeee),
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: checkinDays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final date = entry.value;
                  final dateString = date.toIso8601String().split('T').first;
                  final data = docsByDate[dateString];

                  final bool hasPoints =
                      data != null && (data['clickPoints'] ?? 0) > 0;
                  Widget iconWidget;
                  BoxDecoration decoration;
                  TextStyle dayStyle;
                  TextStyle pointStyle;
                  String point;
                  if (index <= 1) {
                    iconWidget = Icon(
                      hasPoints ? Icons.check_circle : Icons.cancel,
                      color: hasPoints ? Colors.green : Colors.red,
                    );
                    decoration = BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xffff6533)), // optional
                      borderRadius: BorderRadius.circular(12),
                    );
                    pointStyle = const TextStyle(
                        fontSize: 7,
                        color: Colors.red,
                        fontWeight: FontWeight.bold);
                    point = "0CPs";
                    dayStyle =
                        const TextStyle(color: Color(0xff6b7280), fontSize: 12);
                  } else if (index == 2) {
                    iconWidget = checkedIn
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text("Check-in",
                                style: TextStyle(
                                    fontSize: 7.5, color: Colors.white)));
                    decoration = BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                          color: const Color(0xff000000)), // optional
                      borderRadius:
                          BorderRadius.circular(12), // rounded corners
                    );
                    pointStyle = const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: Colors.white);
                    point = "+10,000CPs";
                    dayStyle =
                        const TextStyle(color: Colors.white, fontSize: 12);
                  } else if (index == 3) {
                    // Tomorrow → reward image
                    iconWidget =
                        Image.asset("assets/icons/reward.png", scale: 1.2);
                    decoration = BoxDecoration(
                      color: const Color(0xffeeeeee),
                      border: Border.all(
                          color: const Color(0xff808080)), // optional
                      borderRadius:
                          BorderRadius.circular(12), // rounded corners
                    );
                    pointStyle = const TextStyle(
                        fontSize: 7,
                        color: Color(0xff6b7280),
                        fontWeight: FontWeight.bold);
                    point = "10,000CPs";
                    dayStyle =
                        const TextStyle(color: Color(0xff6b7280), fontSize: 12);
                  } else {
                    // Next tomorrow and the day after that → lock icon
                    iconWidget = const cupertino.Icon(
                      cupertino.CupertinoIcons.lock_fill,
                      size: 20,
                      color: Color(0xff6b7280),
                    );
                    decoration = BoxDecoration(
                      color: const Color(0xffeeeeee),
                      border: Border.all(
                          color: const Color(0xff808080)), // optional
                      borderRadius:
                          BorderRadius.circular(12), // rounded corners
                    );
                    pointStyle = const TextStyle(
                        fontSize: 7,
                        color: Color(0xff6b7280),
                        fontWeight: FontWeight.bold);
                    point = "10,000CPs";
                    dayStyle =
                        const TextStyle(color: Color(0xff6b7280), fontSize: 12);
                  }

                  return InkWell(
                    onTap: index == 2
                        ? () async {
                            final count = await getSubmittedTasksCount(
                                FirebaseAuth.instance.currentUser!.uid);

                            if (count >= 5) {
                              addOrUpdateDoc(DateTime.now(), {
                                'clickPoints': 10000,
                                'status': "checked In"
                              });
                              setState(() {
                                checkedIn = true;
                              });
                            } else {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Check-in Requirement"),
                                    content: Text(
                                        "You need to submit at least 5 tasks to check in. Currently: $count submitted"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    child: Container(
                      width: 15.w,
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      decoration: decoration,
                      child: Column(
                        children: [
                          Text(weekDays[index]['weekday'] ?? "",
                              style: dayStyle),
                          SizedBox(
                            height: 0.5.h,
                          ),
                          iconWidget,
                          SizedBox(
                            height: 0.5.h,
                          ),
                          Text(point, style: pointStyle)
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 4.h),
            Center(
                child: Container(
                    width: 90.w,
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: const Color(0xffd1d5db)),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      SizedBox(
                          width: 90.w,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Task Streak",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor:
                                                const Color(0xffeeeeee),
                                            child: Image.asset(
                                                "assets/icons/streak.png"),
                                          ),
                                          SizedBox(width: 1.w),
                                          RichText(
                                              text: TextSpan(
                                                  text: "$streak",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: const [
                                                TextSpan(
                                                    text: "days",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280)))
                                              ])),
                                        ],
                                      ),
                                    ]),
                                SizedBox(height: 1.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: (streak % 7) / 7, // from 0.0 to 1.0
                                    minHeight: 6,
                                    backgroundColor: const Color(0xffd9d9d9),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.black),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    (streak % 7) / 7 != 1
                                        ? RichText(
                                            text: TextSpan(
                                                text:
                                                    "${7 - (streak % 7)} more days to get streak reward of",
                                                style: const TextStyle(
                                                    color: Color(0xff6b7280),
                                                    fontSize: 10),
                                                children: const [
                                                  TextSpan(
                                                    text: "\n50,000CPs",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff6b7280),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ]),
                                          )
                                        : RichText(
                                            text: const TextSpan(
                                                text: "Claim your ",
                                                style: TextStyle(
                                                    color: Color(0xff6b7280),
                                                    fontSize: 10),
                                                children: [
                                                TextSpan(
                                                  text: "50,000 CPs",
                                                  style: TextStyle(
                                                      color: Color(0xff6b7280),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ])),
                                    Row(
                                      children: [
                                        const SizedBox(
                                            width: 40,
                                            child: ArrowCircleAnimation()),
                                        SizedBox(width: 1.w),
                                        SizedBox(
                                            width: 20.w,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TaskStreak(
                                                              controller: widget
                                                                  .controller,
                                                              streak: streak,
                                                              checkedIn:
                                                                  checkedIn,
                                                              endsIn: endsIn
                                                                  .substring(
                                                                      5))),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xff583f2f),
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                alignment: Alignment.center,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8), // <-- corner radius
                                                ),
                                              ),
                                              child: const Text(
                                                  "Check Streak Details",
                                                  style: TextStyle(fontSize: 9),
                                                  textAlign: TextAlign.center),
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              ])),
                      SizedBox(height: 2.h),
                    ]))),
            SizedBox(height: 3.h),
            Center(
              child: SizedBox(
                width: 90.w,
                child: Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Treasure Hunt Task",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 3.h),
                              Text(
                                  "This week, $weeklyTreasureCount treasures\nare hidden across\nrandom tasks.",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffd1d5db))),
                              SizedBox(height: 2.h),
                              SizedBox( 
                                  width: 30.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset('assets/treasure_anim.gif',
                                          scale: 5),
                                      ElevatedButton(
                                          onPressed: () {
                                            if (weeklyTreasureCount == 0) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NoTreasure(
                                                            controller: widget
                                                                .controller)),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TreasureHunt(
                                                            controller: widget
                                                                .controller,
                                                            kycCompleted: widget
                                                                .kycCompleted)),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(5),
                                            fixedSize: Size(30.w, 40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // Rounded corners
                                            ),
                                            backgroundColor:
                                                const Color(0xffa64221),
                                          ),
                                          child: const Text("View Treasures",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12))),
                                    ],
                                  ))
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xff7e3118),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                    "$availableTreasureCount treasures left",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 2.h),
                              Image.asset("assets/treasur.png", scale: 4)
                            ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Center(
                child: SizedBox(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Spin & Win",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(refreshIn,
                                                style: const TextStyle(
                                                    color: Color(0xff6b7280),
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 12)),
                                            SizedBox(height: 0.5.h),
                                            spinned
                                                ? const Text(
                                                    "0 free spin remaining",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff6b7280),
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 12))
                                                : const Text("1 free remaining",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff6b7280),
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 12)),
                                            SizedBox(height: 2.h),
                                          ])
                                    ],
                                  ),
                                  SizedBox(height: 3.h),
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // OUTER CIRCLE (GREY BORDER)
                                        Container(
                                          width: size,
                                          height: size,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.grey.shade400,
                                                width: 12),
                                          ),
                                        ),

                                        // INNER CIRCLE (BLACK BORDER)
                                        Container(
                                          width: size - 20,
                                          height: size - 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black, width: 40),
                                          ),
                                        ),
                                        Transform.rotate(
                                          angle: _animation.value,
                                          child: CustomPaint(
                                            size: const Size(
                                                size - 30, size - 30),
                                            painter:
                                                WheelPainter(segments: labels),
                                          ),
                                        ),
                                        // Center Spin Button
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            backgroundColor: Colors.grey[300],
                                            padding: const EdgeInsets.all(24),
                                          ),
                                          onPressed: _controller.isAnimating
                                              ? null
                                              : spinned
                                                  ? null
                                                  : _spinWheel,
                                          child: const Text("Spin",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                        // Pointer on top
                                        const Positioned(
                                          top: 0,
                                          child: Icon(Icons.location_on,
                                              size: 36, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Spin with point: $pointCount Remaining",
                                                  style: const TextStyle(
                                                      color: Color(0xff6b7280),
                                                      fontSize: 10)),
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
                                                    onPressed: () {
                                                      if (pointCount > 0 &&
                                                          int.tryParse(
                                                                  points)! >
                                                              200) {
                                                        _spinWheel();
                                                      } else {
                                                        // Show popup
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Not Enough Points"),
                                                              content: const Text(
                                                                  "You need at least 200 CPs to spin."),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                  child:
                                                                      const Text(
                                                                          "OK"),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: const Text(
                                                        'Spin Using Points',
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
                                                    'Available CPs: ${points}CPs',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xff007a3f)))
                                              ]),
                                              Row(children: [
                                                const CircleAvatar(
                                                    radius: 4,
                                                    backgroundColor:
                                                        Color(0xffe70e17)),
                                                SizedBox(width: 1.w),
                                                const Text('Spin Cost: 200CPs',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xffe70e17)))
                                              ]),
                                            ]),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Spin with Bal: $earningsCount Remaining",
                                                  style: const TextStyle(
                                                      color: Color(0xff6b7280),
                                                      fontSize: 10)),
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
                                                    onPressed: () async {
                                                      if (earningsCount > 0 &&
                                                          (int.tryParse(balance
                                                                      .replaceAll(
                                                                          ',',
                                                                          '')) ??
                                                                  0) >
                                                              10) {
                                                        _spinWheel();
                                                      } else {
                                                        // Show popup
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  "Not Enough Balance"),
                                                              content: const Text(
                                                                  "You need at least ₦10 to spin."),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                  child:
                                                                      const Text(
                                                                          "OK"),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: const Text(
                                                        'Spin Using Earnings',
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
                                                Text('Available Bal: ₦$balance',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xff007a3f)))
                                              ]),
                                              Row(children: [
                                                const CircleAvatar(
                                                    radius: 4,
                                                    backgroundColor:
                                                        Color(0xffe70e17)),
                                                SizedBox(width: 1.w),
                                                const Text('Spin Cost: ₦10',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xffe70e17)))
                                              ]),
                                            ]),
                                      ])
                                ]))))),
            SizedBox(height: 2.h),
            Center(
                child: Container(
                    width: 90.w,
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: const Color(0xffd1d5db)),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      SizedBox(
                          width: 90.w,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Achievements",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(height: 1.h),
                              ])),
                      SizedBox(height: 2.h),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  width: 27.w,
                                  height: 16.h,
                                  child: Card(
                                    elevation: 6, // adds shadow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    color: const Color(0xffc2c5cd),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 10, 5, 10),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                  backgroundColor:
                                                      const Color(0xfff2bebe),
                                                  radius: 20,
                                                  child: Image.asset(
                                                      "assets/icons/streak.png")),
                                              SizedBox(height: 0.5.h),
                                              const Text("Streak Rank",
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(streakRank,
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                  )),
                                            ])),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                SizedBox(
                                    width: 27.w,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xff774e40)),
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
                                        child: const Text("See More",
                                            style: TextStyle(fontSize: 11))))
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: 27.w,
                                  height: 16.h,
                                  child: Card(
                                    elevation: 6, // adds shadow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    color: const Color(0xffc2c5cd),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 10, 5, 10),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const CircleAvatar(
                                                  backgroundColor:
                                                      Color(0xffc5f2d6),
                                                  radius: 20,
                                                  child: Icon(Icons.verified,
                                                      color:
                                                          Color(0xff22c55e))),
                                              SizedBox(height: 1.h),
                                              const Text("Grit Level",
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text("Level $gritLevel",
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                  )),
                                            ])),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                SizedBox(
                                    width: 27.w,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xffaf4c0f)),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GritAchievements(
                                                        controller:
                                                            widget.controller,
                                                        kycCompleted: widget
                                                            .kycCompleted)),
                                          );
                                        },
                                        child: const Text("See More",
                                            style: TextStyle(fontSize: 11))))
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: 27.w,
                                  height: 16.h,
                                  child: Card(
                                    elevation: 6, // adds shadow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    color: const Color(0xffc2c5cd),
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 10, 5, 10),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                  backgroundColor:
                                                      const Color(0xffceb0f2),
                                                  radius: 20,
                                                  child: Image.asset(
                                                      "assets/icons/star.png")),
                                              SizedBox(height: 1.h),
                                              const Text("Gratis Level",
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text("Level $gratisLevel",
                                                  style: const TextStyle(
                                                    fontSize: 9,
                                                  )),
                                            ])),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                SizedBox(
                                    width: 27.w,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xff9e1d22)),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    GratisAchievements(
                                                        controller:
                                                            widget.controller,
                                                        kycCompleted: widget
                                                            .kycCompleted)),
                                          );
                                        },
                                        child: const Text("See More",
                                            style: TextStyle(fontSize: 11))))
                              ],
                            ),
                          ])
                    ]))),
            SizedBox(height: 4.h),
            Center(
                child: SizedBox(
              width: 90.w,
              child: const Text("Quick Stats",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            )),
            SizedBox(height: 2.h),
            Center(
                child: SizedBox(
              width: 90.w,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 35.w,
                        height: 20.h,
                        child: Card(
                          elevation: 6, // adds shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: const Color(0xffd2f2df),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                        radius: 25,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff22c55e),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: const Icon(Icons.checklist,
                                              color: Colors.white),
                                        )),
                                    SizedBox(height: 0.5.h),
                                    Text(completedTasks.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 0.5.h),
                                    const Text("Completed Task",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff6b7280))),
                                  ])),
                        ),
                      ),
                      SizedBox(
                        width: 35.w,
                        height: 20.h,
                        child: Card(
                          elevation: 6, // adds shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: const Color(0xfff4b1b1),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      child: Image.asset(
                                          "assets/icons/streak.png"),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text("$streak days",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 0.5.h),
                                    const Text("Streak",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff6b7280))),
                                  ])),
                        ),
                      ),
                      SizedBox(
                        width: 35.w,
                        height: 20.h,
                        child: Card(
                          elevation: 6, // adds shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: const Color(0xfff6b39c),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      child: Image.asset(
                                          "assets/icons/points.png"),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(totalPoints,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 0.5.h),
                                    const Text("Points",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff6b7280))),
                                  ])),
                        ),
                      ),
                    ]),
              ),
            )),
            SizedBox(height: 4.h),
          ]),
        ));
  }
}

class WheelPainter extends CustomPainter {
  final List<String> segments;
  WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final angle = 2 * pi / segments.length;
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < segments.length; i++) {
      paint.color = (i % 2 == 0) ? const Color(0xffff6533) : Colors.black;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * angle - pi / 2,
        angle,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: segments[i],
          style:  TextStyle(
              color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final theta = angle * i + angle / 2 - pi / 2;

      final offset = Offset(
        center.dx + radius * 0.6 * cos(theta) - textPainter.width / 2,
        center.dy + radius * 0.6 * sin(theta) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

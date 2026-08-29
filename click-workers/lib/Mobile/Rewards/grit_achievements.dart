import 'package:click_workers/Mobile/Rewards/claim_success.dart';
import 'package:click_workers/Mobile/Rewards/no_kyc_claim.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

enum LevelState { inProgress, notStarted, completed }

class GritAchievements extends StatefulWidget {
  const GritAchievements({
    super.key,
    required this.kycCompleted,
    required this.controller,
  });

  final bool kycCompleted;
  final PageController controller;
  @override
  State<GritAchievements> createState() => _GritAchievementsState();
}

class _GritAchievementsState extends State<GritAchievements> {
  String gritLevel = "Level 1";
  int difficulty = 0;

  Map<String, LevelState> levels = {
    "Level 1": LevelState.inProgress,
    "Level 2": LevelState.notStarted,
    "Level 3": LevelState.notStarted,
    "Level 4": LevelState.notStarted,
    "Level 5": LevelState.notStarted,
    "Level 6": LevelState.notStarted,
    "Level 7": LevelState.notStarted,
    "Level 8": LevelState.notStarted,
    "Level 9": LevelState.notStarted,
    "Level 10": LevelState.notStarted,
  };

  //get gritLevel
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
        gritLevel = data!['gritLevel'];
      });
      setLevel("Level $gritLevel");
    }
  }

  //gets level text
  int getLevelText(LevelState state) {
    switch (state) {
      case LevelState.completed:
        return 20;
      case LevelState.inProgress:
        return difficulty;
      case LevelState.notStarted:
      default:
        return 0;
    }
  }

  //sets level
  void setLevel(String selectedKey) {
    final keys = levels.keys.toList();
    final index = keys.indexOf(selectedKey);

    setState(() {
      for (int i = 0; i < keys.length; i++) {
        if (i < index) {
          levels[keys[i]] = LevelState.completed;
        } else if (i == index) {
          levels[keys[i]] = LevelState.inProgress;
        } else {
          levels[keys[i]] = LevelState.notStarted;
        }
      }
    });
  }

  //get hard tasks num
  Future<void> fetchHardTasksCount() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("tasks")
          .where("difficulty", isEqualTo: "Hard")
          .get();

      final hardTasksCount = querySnapshot.docs.length;

      // calculate difficulty (always 1–20)
      final newDifficulty = (hardTasksCount % 20 == 0 && hardTasksCount > 0)
          ? 20
          : (hardTasksCount % 20);

      if (mounted) {
        setState(() {
          difficulty = newDifficulty;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching tasks: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getAchievements();
    fetchHardTasksCount();
  }

  @override
  void dispose() {
    // e.g. ValueNotifier
    super.dispose();
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
            child: Text('Grit Achievements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black,
                    ),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                            text:
                                "This simply shows how often you perform tasks rated ",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: "“Difficult Tasks (Longer time)” ",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "and how well you do it. It has from ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "Level 1 ",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "to ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "Level 10. ",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    "The metrics are simple, if you perform 20 difficult tasks you get to the next level. Share of ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "₦1,000,000 Monthly ",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "for all workers that get to ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: "Level 10. ",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]))),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 1",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 1']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 1"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
 mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 1"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 2",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 2']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 2"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                       mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 2"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                        .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 3",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 2.w),
                                      Text(
                                          "${getLevelText(levels['Level 3']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 3"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 3"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 4",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 4']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 4"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 4"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 5",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 5']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 5"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 5"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 6",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 6']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 6"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 6"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                   MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 7",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 7']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 7"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 7"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 8",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 8']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 8"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 8"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                    SizedBox(height: 2.h),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50.w,
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xff353535),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text("Level 9",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(width: 3.w),
                                      Text(
                                          "${getLevelText(levels['Level 9']!)}/20 Difficult Task\nPerformed",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white))
                                    ])),
                          ),
                          levels["Level 9"]!.name == "notStarted"
                              ? SizedBox(
                                  width: 30.w,
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 13, 5, 13),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff9e1d22),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text("Not Started",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white)),
                                            SizedBox(width: 1.w),
                                            const Icon(Icons.flag_outlined,
                                                color: Colors.white, size: 16)
                                          ])))
                              : levels["Level 9"]!.name == "inProgress"
                                  ? SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffb8860b),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                              children: [
                                                const Text("In Progress",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white)),
                                                SizedBox(width: 1.w),
                                                Image.asset(
                                                    "assets/rewards/loader.png",
                                                    scale: 4)
                                              ])))
                                  : SizedBox(
                                      width: 30.w,
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 13, 5, 13),
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
                                              ])))
                        ]),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                  child: levels["Level 10"]!.name == "completed"
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xff583f2f),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 50.w,
                                        child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: const Color(0xff092e57),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Text("Level 10",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  Text(
                                                      "${getLevelText(levels['Level 10']!)}/20 Difficult Task\nPerformed",
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white))
                                                ])),
                                      ),
                                      levels["Level 10"]!.name == "notStarted"
                                          ? SizedBox(
                                              width: 30.w,
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 13, 5, 13),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff9e1d22),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                     mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                      children: [
                                                        const Text(
                                                            "Not Started",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 1.w),
                                                        const Icon(
                                                            Icons.flag_outlined,
                                                            color: Colors.white,
                                                            size: 16)
                                                      ])))
                                          : levels["Level 10"]!.name ==
                                                  "inProgress"
                                              ? SizedBox(
                                                  width: 30.w,
                                                  child: Container(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                              5, 13, 5, 13),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xffb8860b),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            const Text(
                                                                "In Progress",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white)),
                                                            SizedBox(
                                                                width: 1.w),
                                                            Image.asset(
                                                                "assets/rewards/loader.png",
                                                                scale: 4)
                                                          ])))
                                              : SizedBox(
                                                  width: 30.w,
                                                  child: Container(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                              5, 13, 5, 13),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff007a3f),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child:
                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                                        const Text("Completed",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 1.w),
                                                        const Icon(
                                                            Icons.check_circle,
                                                            color: Colors.white,
                                                            size: 16)
                                                      ])))
                                    ]),
                                SizedBox(height: 1.h),
                                Image.network(
                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1757687605/REWARDS_CLICKWORKERS__21_-removebg-preview_vchhxj.png",
                                    scale: 3),
                                SizedBox(height: 1.h),
                                RichText(
                                    textAlign: TextAlign.center,
                                    text: const TextSpan(
                                        text:
                                            "Congratulations you have Won a Share of ",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                            text: "₦1,000,000",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff007a3f)),
                                          )
                                        ])),
                                SizedBox(height: 2.h),
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black,
                                    ),
                                    child: Column(children: [
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            const Text("●",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white)),
                                            SizedBox(width: 2.w),
                                            const Text(
                                                "Your winning share will be credited to your ClickWorker\nwallet for withdrawal.",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white))
                                          ]),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            const Text("●",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white)),
                                            SizedBox(width: 2.w),
                                            const Text(
                                                "Tap on 'Claim Prize' to have your share funded into\nyour wallet.",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white))
                                          ]),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            const Text("●",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white)),
                                            SizedBox(width: 2.w),
                                            const Text(
                                                "Make sure your KYC is completed before claiming\nyour prize.",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white))
                                          ]),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            const Text("●",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white)),
                                            SizedBox(width: 2.w),
                                            const Text(
                                                "Levels reset once prizes are claimed.",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white))
                                          ]),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            const Text("●",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white)),
                                            SizedBox(width: 2.w),
                                            RichText(
                                                text: const TextSpan(
                                                    text: "You have only ",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white),
                                                    children: [
                                                  TextSpan(
                                                    text: "7days ",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "to Claim Prize after achieving",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "\nlevel 10 ",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "or else it would be forfeited and level starts\nafresh. ",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ]))
                                          ]),
                                    ])),
                                SizedBox(height: 4.h),
                                InkWell(
                                  onTap: widget.kycCompleted
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ClaimSuccess(
                                                        controller:
                                                            widget.controller)),
                                          );
                                        }
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NoKycClaim(
                                                        controller:
                                                            widget.controller)),
                                          );
                                        },
                                  child: Container(
                                    width: 40.w,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff007a3f),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black87,
                                          spreadRadius: 1,
                                          offset: Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Text("Claim Prize",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ]))
                      : Container(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xff583f2f),
                              width: 1,
                            ),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 50.w,
                                        child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: const Color(0xff774e40),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  const Text("Level 10",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                  SizedBox(width: 1.w),
                                                  Text(
                                                      "${getLevelText(levels['Level 10']!)}/20 Difficult Task\nPerformed",
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white))
                                                ])),
                                      ),
                                      levels["Level 10"]!.name == "notStarted"
                                          ? SizedBox(
                                              width: 30.w,
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 13, 5, 13),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff9e1d22),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                      children: [
                                                        const Text(
                                                            "Not Started",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 1.w),
                                                        const Icon(
                                                            Icons.flag_outlined,
                                                            color: Colors.white,
                                                            size: 16)
                                                      ])))
                                          : levels["Level 10"]!.name ==
                                                  "inProgress"
                                              ? SizedBox(
                                                  width: 30.w,
                                                  child: Container(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                              5, 13, 5, 13),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xffb8860b),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                          children: [
                                                            const Text(
                                                                "In Progress",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white)),
                                                            SizedBox(
                                                                width: 1.w),
                                                            Image.asset(
                                                                "assets/rewards/loader.png",
                                                                scale: 4)
                                                          ])))
                                              : SizedBox(
                                                  width: 30.w,
                                                  child: Container(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                              5, 13, 5, 13),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff007a3f),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child:
                                                          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                                        const Text("Completed",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 1.w),
                                                        const Icon(
                                                            Icons.check_circle,
                                                            color: Colors.white,
                                                            size: 16)
                                                      ])))
                                    ]),
                                Image.network(
                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1757685474/REWARDS_CLICKWORKERS__19___1_-removebg-preview_kqmvfi.png",
                                    scale: 3),
                                RichText(
                                    textAlign: TextAlign.center,
                                    text: const TextSpan(
                                        text:
                                            "Get to Level 10 and win a share of ",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                            text: "₦1,000,000",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff007a3f)),
                                          )
                                        ]))
                              ])))
            ],
          ),
        ));
  }
}

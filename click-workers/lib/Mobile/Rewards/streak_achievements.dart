import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StreakAchievements extends StatefulWidget {
  const StreakAchievements(
      {super.key,
      required this.weeklyStreak,
      required this.levels,
      required this.controller});

  final int weeklyStreak;
  final Map<String, bool> levels;
  final PageController controller;

  @override
  State<StreakAchievements> createState() => _StreakAchievementsState();
}

class _StreakAchievementsState extends State<StreakAchievements> {
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
            child: Text('Streak Achievements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              SizedBox(height: 1.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/rookie.png", scale: 4),
                            const Text("  Rookie",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/1 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                SizedBox(
                  width: 30.w,
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                      decoration: BoxDecoration(
                        color: const Color(0xff007a3f),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(" Completed",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                            SizedBox(width: 1.w),
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 16)
                          ])),
                )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/novice.png", scale: 4),
                            const Text("  Novice",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/2 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Novice"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])))
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 2)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])))
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/apprentice.png",
                                scale: 4),
                            const Text("  Apprentice",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 2.w),
                            Text("${widget.weeklyStreak}/3 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Apprentice"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 3)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/jr.png", scale: 4),
                            const Text("  Junior",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/4 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Junior"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 4)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/skilled.png", scale: 4),
                            const Text("  Skilled",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/5 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Skilled"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 5)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/pro.png", scale: 4),
                            const Text("  Pro",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/6 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Pro"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 6)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/expert.png", scale: 4),
                            const Text("  Expert",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/7 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Expert"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 7)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/elite.png", scale: 4),
                            const Text("  Elite",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/8 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Elite"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 8)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/master.png", scale: 4),
                            const Text("  Master",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 3.w),
                            Text("${widget.weeklyStreak}/9 Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Master"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 9)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                  width: 50.w,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xff774e40),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset("assets/rewards/grand_master.png",
                                scale: 4),
                            const Text("  Grand Master",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(width: 1.w),
                            Text("${widget.weeklyStreak}/12Week",
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white))
                          ])),
                ),
                widget.levels["Grand Master"] == true
                    ? SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 13, 5, 13),
                            decoration: BoxDecoration(
                              color: const Color(0xff007a3f),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(" Completed",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 16)
                                ])),
                      )
                    : SizedBox(
                        width: 30.w,
                        child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff606060),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${getDisplayText(widget.levels, 12)} Complete",
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                  SizedBox(width: 1.w),
                                  Image.asset("assets/rewards/loader.png",
                                      scale: 4)
                                ])),
                      )
              ]),
              SizedBox(height: 4.h),
              InkWell(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Future.delayed(Duration.zero, () {
                    widget.controller.jumpToPage(2);
                  });
                },
                child: Container(
                  width: 50.w,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff092e57),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xff000000),
                          blurRadius: 3,
                          offset: Offset(2, 4))
                    ],
                  ),
                  child: const Text("Go To Streak Leaderboard",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              SizedBox(height: 3.h),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Go to My Streak Details",
                      style: TextStyle(
                          color: Color(0xffa64221),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xffa64221))))
            ]),
          ),
        ));
  }
}

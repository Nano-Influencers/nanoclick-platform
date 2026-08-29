// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:click_workers/Mobile/widgets/arrow_animation.dart';

List<Performance> performance = [
  Performance(
      firstAvatar: '1',
      secondAvatar: 'assets/icons/leadboard_avatar1.png',
      name: 'Fidelis',
      speed: '0/20',
      star: 'assets/icons/leader_star.png',
      spark: 'assets/icons/spark.png',
      rating: '0/30',
      approval: '0/10',
      quantity: '0/20',
      diversity: '0/20',
      taskPerformance: '0/100'),
  Performance(
      firstAvatar: '1',
      secondAvatar: 'assets/icons/leadboard_avatar1.png',
      name: 'Fidelis',
      speed: '0/20',
      star: 'assets/icons/leader_star.png',
      spark: 'assets/icons/spark.png',
      rating: '0/30',
      approval: '0/10',
      quantity: '0/20',
      diversity: '0/20',
      taskPerformance: '0/100'),
  Performance(
      firstAvatar: '1',
      secondAvatar: 'assets/icons/leadboard_avatar1.png',
      name: 'Fidelis',
      speed: '0/20',
      star: 'assets/icons/leader_star.png',
      spark: 'assets/icons/spark.png',
      rating: '0/30',
      approval: '0/10',
      quantity: '0/20',
      diversity: '0/20',
      taskPerformance: '0/100'),
  Performance(
      firstAvatar: '1',
      secondAvatar: 'assets/icons/leadboard_avatar1.png',
      name: 'Fidelis',
      speed: '0/20',
      star: 'assets/icons/leader_star.png',
      spark: 'assets/icons/spark.png',
      rating: '0/30',
      approval: '0/10',
      quantity: '0/20',
      diversity: '0/20',
      taskPerformance: '0/100'),
  Performance(
      firstAvatar: '1',
      secondAvatar: 'assets/icons/leadboard_avatar1.png',
      name: 'Fidelis',
      speed: '0/20',
      star: 'assets/icons/leader_star.png',
      spark: 'assets/icons/spark.png',
      rating: '0/30',
      approval: '0/10',
      quantity: '0/20',
      diversity: '0/20',
      taskPerformance: '0/100'),
  Performance(
      firstAvatar: '1',
      secondAvatar: 'assets/icons/leadboard_avatar1.png',
      name: 'Fidelis',
      speed: '0/20',
      star: 'assets/icons/leader_star.png',
      spark: 'assets/icons/spark.png',
      rating: '0/30',
      approval: '0/10',
      quantity: '0/20',
      diversity: '0/20',
      taskPerformance: '0/100'),
  Performance(
      firstAvatar: '1',
      secondAvatar: 'assets/icons/leadboard_avatar1.png',
      name: 'Fidelis',
      speed: '0/20',
      star: 'assets/icons/leader_star.png',
      spark: 'assets/icons/spark.png',
      rating: '0/30',
      approval: '0/10',
      quantity: '0/20',
      diversity: '0/20',
      taskPerformance: '0/100'),
];

class LeaderboardScreen extends StatefulWidget implements DeskTopHeader {
  const LeaderboardScreen({super.key});
  @override
  String get title => "Dashboard";

  @override
  String? get subtitle => "Welcome back, Azuka";

  @override
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int selectedIndex = 0;

  final List<String> _tabs = [
    'Task performance',
    'Points',
    'Referrals',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_tabs.length, (index) {
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: _tabBarItems(
                      selectedIndex: isSelected,
                      color: isSelected ? Colors.black : Colors.white,
                      title: _tabs[index],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
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
              width: 330,
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 1.5.h, horizontal: 1.5.w),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      backgroundColor: const Color(0xffff6533),
                      foregroundColor: Colors.white),
                  child: const Text("View Monthly Ranking",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))))
        ]),
        SizedBox(height: 2.h),
        const Text("Started: 1 day(s) ago",
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: () {
              setState(() {});
            },
            child: Container(
                width: 330,
                padding:
                    EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.2.w),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xffff6533),
                    ),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text("This month Ranking",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffff6533),
                    ))),
          ),
          TextButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text("View Prizes Available for this Month",
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black)))
        ]),
        SizedBox(
          height: 2.h,
        ),
        ...List.generate(
          performance.length,
          (index) {
            return performanceItem(performance[index]);
          },
        )
      ],
    );
  }

  Widget _tabBarItems(
      {required Color color,
      required String title,
      required bool selectedIndex}) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(horizontal: 0.8.w),
      padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xffFF6533),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget performanceItem(Performance performance) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Card(
        elevation: 6,
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xffFFB33A),
                  child: Text(performance.firstAvatar,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                SizedBox(width: 0.5.w),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(performance.secondAvatar),
                ),
                SizedBox(
                  width: 0.5.w,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performance.name,
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Image.asset(performance.spark),
                        SizedBox(
                          width: 0.2.w,
                        ),
                        Text(
                          'Task Speed Score',
                          style: TextStyle(
                              fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 0.5.w),
                        Text(performance.speed,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey))
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Image.asset(performance.star),
                        SizedBox(
                          width: 0.2.w,
                        ),
                        Text(
                          'Client/Advertiser Rating',
                          style: TextStyle(
                              fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 0.5.w),
                        Text(performance.rating,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffff6533)))
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 12),
                        const Text(" Approval Rate Score",
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        SizedBox(width: 0.5.w),
                        Text(performance.approval,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey))
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ID: 20x1HP',
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.normal),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: const Color(0xffd4d5d7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Task Quantity Score: ',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xff6B7280),
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 0.5.h,
                                  ),
                                  Text(performance.quantity,
                                      style: TextStyle(
                                        color: const Color(0xffff6533),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Task Diversity Score: ',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xff6B7280),
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 0.5.h,
                                  ),
                                  Text(performance.diversity,
                                      style: TextStyle(
                                        color: const Color(0xffff6533),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 1.5.w,
                        ),
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: const Color(0xffd4d5d7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Task performance score',
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xff6B7280),
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Text(performance.taskPerformance,
                                  style: TextStyle(
                                    color: const Color(0xffff6533),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}

class Performance {
  final String firstAvatar;
  final String secondAvatar;
  final String name;
  final String speed;
  final String star;
  final String spark;
  final String rating;
  final String approval;
  final String quantity;
  final String diversity;
  final String taskPerformance;
  Performance({
    required this.firstAvatar,
    required this.secondAvatar,
    required this.name,
    required this.speed,
    required this.star,
    required this.spark,
    required this.rating,
    required this.approval,
    required this.quantity,
    required this.diversity,
    required this.taskPerformance,
  });
}

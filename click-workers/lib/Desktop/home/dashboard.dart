import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DesktopDashboard extends StatelessWidget  implements DeskTopHeader {
  const DesktopDashboard({super.key});

  
  @override
  String get title => "Dashboard";

  @override
  String? get subtitle => "Welcome back, Azuka";


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userStatsCard(),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trending Tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
                onPressed: () {},
                child: const Text(
                  'See more',
                  style: TextStyle(fontSize: 11, color: Colors.black),
                ))
          ],
        ),
        Wrap(
          spacing: 1.5.w,
          runSpacing: 1.5.w,
          children: [
            trendingTaskCard(
              "Like 10 Posts",
              "Browse through community posts and like 10 relevant post",
              '100 pts',
              const Color(0xff22C55E),
              const Color(0xff22C55E),
              'Simple',
            ),
            trendingTaskCard(
                'Marketing Campaign',
                "Create a viral marketing campaign for our upcoming product launch",
                'N100,000 pts ',
                const Color(0xffFF0000),
                const Color(0xffFF0000),
                'Urgent Contest'),
            trendingTaskCard(
                'Marketing Campaign',
                "Create a viral marketing campaign for our upcoming product launch",
                'N100,000 pts ',
                const Color(0xffFF0000),
                const Color(0xffFF0000),
                'Urgent Contest'),
          ],
        ),
        SizedBox(height: 5.h),
        dashboardBottomSection(),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget userStatsCard() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage("assets/stats_profile.png"),
            ),
            SizedBox(width: 0.5.w),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          "Chimaobi Azuka",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(
                        "assets/icons/checkbox.png",
                        height: 9,
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        "Verified",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  const Row(
                    children: [
                      Text("Total Points",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                      SizedBox(width: 30),
                      Text("Current Rank",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                  const Row(
                    children: [
                      Text("12,450",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 58),
                      Text("Platinum",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 1.w,
                runSpacing: 1.h,
                children: [
                  _amount("Total Earnings", "₦12,450"),
                  _amount("Available Balance", "₦5000"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amount(String title, String value) {
    return Container(
      width: 120,
      padding: EdgeInsets.all(1.2.w),
      decoration: BoxDecoration(
        color: const Color(0xffD1D5DB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xff6B7280),
                  fontWeight: FontWeight.bold)),
          Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  trendingTaskCard(String title, String description, String points,
      Color conatinerColor, Color containerTextColor, String containerTextC) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 300,
        height: 180,
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: conatinerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                      textAlign: TextAlign.center,
                      containerTextC,
                      style:
                          TextStyle(fontSize: 10, color: containerTextColor)),
                ),
                const Spacer(),
                Image.asset(
                  "assets/icons/flag.png",
                  height: 11,
                  width: 11,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 1.h),
            Text(description,
                style: const TextStyle(color: Color(0xff6B7280), fontSize: 12)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Text(points,
                    style: const TextStyle(color: Colors.green, fontSize: 12)),
                SizedBox(width: 2.w),
                const Text('10mins ago',
                    style: TextStyle(color: Color(0xff6B7280), fontSize: 11)),
                const Spacer(),
                SizedBox(
                  width: 50,
                  height: 25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Accept",
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardBottomSection() {
    return Wrap(
      spacing: 1.5.w,
      runSpacing: 1.5.h,
      children: [
        taskSummaryCard(),
        achievementsCard(),
        leaderboardCard(),
      ],
    );
  }

  Widget taskSummaryCard() {
    return _dashboardCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle("Task Summary"),
          SizedBox(height: 2.h),
          _taskRow("Ongoing Task", "4", Colors.black),
          const Divider(color: Color(0xffd1d5db), thickness: 2),
          _taskRow("Completed Task", "23", Colors.green),
          const Divider(color: Color(0xffd1d5db), thickness: 2),
          _taskRow("Missed Task", "2", Colors.red),
        ],
      ),
    );
  }

  Widget achievementsCard() {
    return _dashboardCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle("Achievements"),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Level Progress",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
              Text("Level 25", style: _smallGreyText()),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: 0.25,
            backgroundColor: const Color(0xffD9D9D9),
            color: Colors.black,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 0.8.h),
          const Text("2,500 pts to next level",
              style: TextStyle(
                fontSize: 11,
                color: Color(0xff6B7280),
              )),
          SizedBox(height: 2.h),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AchievementIcon("Streak\nMaster", 'streak_master'),
              _AchievementIcon("Elite", 'elite'),
              _AchievementIcon("Champion", 'champion'),
              _AchievementIcon("Legend", 'legend'),
            ],
          ),
        ],
      ),
    );
  }

  Widget leaderboardCard() {
    return _dashboardCard(
      isLeaderBoard: true,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Leader Board',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
              Text(
                'See more',
                style:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 11.sp),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _leaderItem(
              1, const Color(0xffFFB33A), 'assets/icons/leadboard_avatar1.png'),
          _leaderItem(
              2, const Color(0xffD9D9D9), 'assets/icons/leadboard_avatar2.png'),
          _leaderItem(
              3, const Color(0xffA67629), 'assets/icons/leadboard_avatar3.png'),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required Widget child,
    required Color color,
    bool isLeaderBoard = false,
  }) {
    return Card(
      elevation:isLeaderBoard ? 0 : 6,
      clipBehavior: Clip.hardEdge,
      color:isLeaderBoard?Colors.transparent: Colors.white,
      child: Container(
        width: 300,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _cardTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  TextStyle _smallGreyText() {
    return const TextStyle(
      fontSize: 11,
      color: Color(0xff6B7280),
    );
  }

  Widget _taskRow(String title, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11)),
          Text(value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }

  Widget _leaderItem(int rank, Color color, String avatar) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: Colors.white),
            child: Row(
              children: [
                SizedBox(
                  width: 0.7.w,
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: color,
                  child: Text("$rank",
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                SizedBox(width: 0.5.w),
                CircleAvatar(
                  radius: 10,
                  backgroundImage: AssetImage(avatar),
                ),
                SizedBox(width: 0.5.w),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chidera Ofogbu",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text("12,839 pts",
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

class _AchievementIcon extends StatelessWidget {
  final String label;
  final String images;
  const _AchievementIcon(
    this.label,
    this.images,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      color: Colors.white,
      child: SizedBox(
        height: 45,
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: const Color(0xffD9D9D9),
              backgroundImage: AssetImage('assets/icons/$images.png'),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 6),
            ),
          ],
        ),
      ),
    );
  }
}

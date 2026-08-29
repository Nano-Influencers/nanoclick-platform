import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:click_workers/Mobile/Rewards/rewards.dart';
import 'package:click_workers/Mobile/widgets/arrow_animation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DesktopRewards extends StatefulWidget implements DeskTopHeader {
  const DesktopRewards({super.key});

  @override
  String get title => "Rewards";

  @override
  String? get subtitle => "";

  @override
  State<DesktopRewards> createState() => _DesktopRewardsState();
}

class _DesktopRewardsState extends State<DesktopRewards> {
  late Animation<double> _animation;
  final double _currentAngle = 0.0;
  final size = 250.0;

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

  @override
  void initState() {
    _animation = AlwaysStoppedAnimation(_currentAngle);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dailyCheckIn(),
        SizedBox(height: 2.h),
        _taskStreak(),
        SizedBox(height: 2.h),
        _treasureHunt(),
        SizedBox(height: 2.h),
        Wrap(
          runSpacing: 1.5.w,
          spacing: 1.5.w,
          children: [_spinAndWin(), _achievements(), _quickStats()],
        ),
      ],
    );
  }

  // ================= DAILY CHECK IN =================
  Widget _dailyCheckIn() {
    // Example: first 3 days are checked in
    final List<String> days = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
      "Sun",
      "Sun",
      "Sat",
      "Sat",
      "Sat",
    ];
    final List<bool> checkedIn = [
      true,
      true,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    final List<bool> isBoarderSide = [
      true,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daily Check-in",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 1.w,
          runSpacing: 1.w,
          children: List.generate(days.length, (index) {
            final isChecked = checkedIn[index];
            final boarderSide = isBoarderSide[index];
            final isToday = index == DateTime.now().day - 14;
            final isGifted = index == DateTime.now().weekday - 3;
            return Container(
              width: 5.w,
              padding: EdgeInsets.only(
                  left: 0.5.w, right: 0.5.w, top: 0.5.w, bottom: 0.5.w),
              decoration: BoxDecoration(
                color: isToday ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: boarderSide
                        ? const Color(0xffFF6533)
                        : Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isToday ? Colors.white : const Color(0xff6B7280),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  isChecked
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 15,
                        )
                      : isGifted
                          ? Image.asset(
                              'assets/icons/reward.png',
                              height: 2.h,
                              width: 2.w,
                            )
                          : Image.asset(
                              'assets/icons/lock.png',
                              height: 2.h,
                              width: 2.w,
                            ),
                  SizedBox(height: 0.5.h),
                  Text("+${(index + 1) * 10}",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isToday ? Colors.white : const Color(0xff6B7280),
                      )),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _treasureHunt() {
    return Center(
      child: SizedBox(
        width: double.infinity,
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
                      const Text(
                          "This week,  treasures\nare hidden across\nrandom tasks.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffd1d5db))),
                      SizedBox(height: 2.h),
                      SizedBox(
                          width: 30.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/treasure_anim.gif', scale: 5),
                              ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(5),
                                    fixedSize: Size(30.w, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Rounded corners
                                    ),
                                    backgroundColor: const Color(0xffa64221),
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
                        child: const Text(" treasures left",
                            style: TextStyle(
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
    );
  }

  Widget _taskStreak() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
        padding:
            EdgeInsets.only(left: 1.w, right: 1.w, top: 1.h, bottom: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Task Streak",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const Spacer(),
                Image.asset(
                  'assets/icons/fire.png',
                  height: 27,
                  width: 27,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  width: 0.5.w,
                ),
                Text(
                  "7 days",
                  style: TextStyle(color: Colors.black, fontSize: 9.5.sp),
                ),
                // Chip(
                //   label: const Text("7 days"),
                //   backgroundColor: Colors.grey.shade200,
                // )
              ],
            ),
            SizedBox(height: 1.h),
            LinearProgressIndicator(
              value: 0.90,
              backgroundColor: const Color(0xffD9D9D9),
              color: Colors.black,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("1 more day to get streak reward",
                        style: TextStyle(
                            color: const Color(0xff6B7280),
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.bold)),
                    Text("50,000CPs",
                        style: TextStyle(
                            color: const Color(0xff6B7280),
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                const SizedBox(width: 40, child: ArrowCircleAnimation()),
                SizedBox(width: 1.w),
                SizedBox(
                    width: 20.w,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff583f2f),
                        padding: const EdgeInsets.all(2.0),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // <-- corner radius
                        ),
                      ),
                      child: const Text("Check Streak Details",
                          style: TextStyle(fontSize: 9),
                          textAlign: TextAlign.center),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  // ================= SPIN & WIN =================
  Widget _spinAndWin() {
    return _card(
      title: "Spin & Win",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),
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
                      border:
                          Border.all(color: Colors.grey.shade400, width: 12),
                      gradient: const LinearGradient(
                        begin: AlignmentGeometry.topLeft,
                        end: AlignmentGeometry.bottomLeft,
                        colors: [Color(0xffD9D9D9), Color(0xff737373)],
                      )),
                ),

                // INNER CIRCLE (BLACK BORDER)
                Container(
                  width: size - 20,
                  height: size - 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 40),
                  ),
                ),
                Transform.rotate(
                  angle: _animation.value,
                  child: CustomPaint(
                    size: Size(size - 30, size - 30),
                    painter: WheelPainter(segments: labels),
                  ),
                ),
                Positioned(
                  top: 95,
                  child: Container(
                    alignment: AlignmentGeometry.center,
                    height: 65,
                    width: 65,
                    padding: EdgeInsets.only(
                        left: 1.w, right: 1.w, top: 1.h, bottom: 1.h),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[300]),
                    child: const Text(
                        textAlign: TextAlign.center,
                        "Spin",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                // Pointer on top
                const Positioned(
                  top: 0,
                  child: Icon(Icons.location_on, size: 36, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          const Text("Spin with point: 5 Remaining",
              style: TextStyle(color: Color(0xff6b7280), fontSize: 10)),
          SizedBox(height: 0.6.h),
          spinAndWinButton(
              text: "Spin using points", color: const Color(0xffF4B19A)),
          SizedBox(
            height: 0.4.h,
          ),
          spinAndWinText(
              text: 'Available CPs: 0CPs', color: const Color(0xff007a3f)),
          spinAndWinText(
              text: 'Spin Cost: 200CPs', color: const Color(0xffe70e17)),
          SizedBox(height: 1.5.h),
          spinAndWinButton(
              text: "Spin using earnings", color: Colors.grey.shade200),
          SizedBox(
            height: 0.4.h,
          ),
          spinAndWinText(
              text: 'Available Bal: ₦50000', color: const Color(0xff007a3f)),
          spinAndWinText(
              text: 'Spin Cost: ₦10', color: const Color(0xffe70e17)),
        ],
      ),
    );
  }

  spinAndWinText({required String text, required Color color}) {
    return Row(children: [
      CircleAvatar(radius: 4, backgroundColor: color),
      SizedBox(width: 1.w),
      Text(text, style: const TextStyle(fontSize: 10, color: Color(0xff007a3f)))
    ]);
  }

  spinAndWinButton({required String text, required Color color}) {
    return SizedBox(
      height: 40,
      width: 300,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8)),
            backgroundColor: color),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACHIEVEMENTS =================
  Widget _achievements() {
    return _card(
      title: "Achievements",
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 2.h,
            ),
            _achievementTile("Streak Master", Icons.local_fire_department,
                Colors.red, 'streak'),
           _achievementButton(const Color(0xff774e40)),
            SizedBox(height: 2.h),
            _achievementTile("Expert", Icons.verified, Colors.green, 'check'),
              _achievementButton(    const Color(0xffaf4c0f)),
            SizedBox(height: 2.h),
            _achievementTile("Elite", Icons.star, Colors.purple, 'star'),
              _achievementButton(    const Color(0xff9e1d22)),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  _achievementButton(Color color) {
    return SizedBox(
        width: 250,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {},
            child: const Text("See More", style: TextStyle(fontSize: 11))));
  }

  Widget _achievementTile(
      String title, IconData icon, Color color, String image) {
    return Container(
      height: 135,
      width: 250,
      margin: EdgeInsets.only(bottom: 1.h),
      padding:
          EdgeInsets.only(left: 1.5.w, right: 1.5.w, bottom: 2.5.w, top: 2.5.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Image.asset(
              'assets/icons/$image.png',
              height: 20,
              width: 20,
            ),
          ),
          SizedBox(width: 1.w),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _quickStats() {
    return _card(
      title: "Quick Stats",
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 2.h,
            ),
            _statTile(
                "247", "Completed Task", Colors.green.shade100, 'task_square'),
            _statTile("150 days", "Streak", Colors.red.shade100, 'streak'),
            _statTile("10,47 pts", "Points", Colors.orange.shade100, 'points'),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String value, String label, Color bg, String image) {
    return Container(
      height: 135,
      width: 250,
      margin: EdgeInsets.only(bottom: 1.h),
      padding:
          EdgeInsets.only(left: 1.5.w, right: 1.5.w, bottom: 2.w, top: 2.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Image.asset(
              'assets/icons/$image.png',
              height: 20,
              width: 20,
            ),
          ),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label,
              style: const TextStyle(color: Color(0xff6B7280), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 300,
        padding:
            EdgeInsets.only(left: 1.w, right: 1.w, top: 1.h, bottom: 3.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            child,
          ],
        ),
      ),
    );
  }
}

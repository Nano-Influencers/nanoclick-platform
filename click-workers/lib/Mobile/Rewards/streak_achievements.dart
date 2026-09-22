import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StreakAchievements extends StatelessWidget {
  const StreakAchievements({super.key, required this.streakDays, required this.controller});
  final int streakDays;
  final PageController controller;

  static const milestones = <Map<String, Object>>[
    {'name': 'Rookie', 'days': 1, 'icon': Icons.emoji_events_outlined},
    {'name': 'Novice', 'days': 2, 'icon': Icons.workspace_premium_outlined},
    {'name': 'Apprentice', 'days': 3, 'icon': Icons.school_outlined},
    {'name': 'Junior', 'days': 4, 'icon': Icons.star_outline},
    {'name': 'Pro', 'days': 6, 'icon': Icons.bolt_outlined},
    {'name': 'Expert', 'days': 7, 'icon': Icons.auto_awesome_outlined},
    {'name': 'Elite', 'days': 8, 'icon': Icons.diamond_outlined},
    {'name': 'Master', 'days': 9, 'icon': Icons.military_tech_outlined},
    {'name': 'Grand Master', 'days': 12, 'icon': Icons.workspace_premium},
  ];

  @override
  Widget build(BuildContext context) {
    final reached = milestones.where((m) => streakDays >= m['days'] as int).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Streak achievements')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: Padding(padding: EdgeInsets.all(4.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${streakDays} day streak', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text('${reached} of ${milestones.length} milestones reached', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            SizedBox(height: 1.5.h),
            LinearProgressIndicator(value: reached / milestones.length),
          ]))),
          SizedBox(height: 2.h),
          ...milestones.map((milestone) {
            final name = milestone['name'] as String;
            final days = milestone['days'] as int;
            final icon = milestone['icon'] as IconData;
            final complete = streakDays >= days;
            final previous = milestones.where((m) => (m['days'] as int) < days).fold<int>(0, (max, m) => (m['days'] as int) > max ? m['days'] as int : max);
            final progress = complete ? 1.0 : ((streakDays - previous) / (days - previous)).clamp(0.0, 1.0).toDouble();
            return Card(margin: EdgeInsets.only(bottom: 1.2.h), child: Padding(padding: EdgeInsets.all(3.5.w), child: Row(children: [
              CircleAvatar(child: Icon(complete ? Icons.check : icon)), SizedBox(width: 3.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: .5.h),
                Text('${days} day${days == 1 ? '' : 's'}', style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
                SizedBox(height: 1.h), LinearProgressIndicator(value: progress),
              ])), SizedBox(width: 2.w),
              Text(complete ? 'Completed' : '${streakDays.clamp(0, days)}/${days}', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: complete ? Colors.green : Colors.black54)),
            ])));
          }),
          SizedBox(height: 2.h),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.popUntil(context, (route) => route.isFirst); Future.delayed(Duration.zero, () => controller.jumpToPage(2)); }, child: const Text('Go to Streak Leaderboard'))),
          SizedBox(height: 1.h),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Rewards'))),
        ]),
      ),
    );
  }
}
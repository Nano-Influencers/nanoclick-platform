import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TaskSubmitted extends StatelessWidget {
  const TaskSubmitted({super.key, required this.earnings, required this.points, required this.type, required this.treasureID});
  final String earnings;
  final String points;
  final String type;
  final String treasureID;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Task submitted'), backgroundColor: Colors.white),
    body: Center(child: Padding(
      padding: EdgeInsets.all(7.w),
      child: Card(child: Padding(padding: EdgeInsets.all(7.w), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, size: 64),
        SizedBox(height: 2.h),
        const Text('Submission received', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 1.h),
        Text('Potential earnings: ₦$earnings'),
        Text('Click points: $points'),
        SizedBox(height: 2.h),
        const Text('Final earnings are credited by the backend after review. The client does not write wallet balances directly.'),
        SizedBox(height: 2.h),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text('Done'))),
      ]))),
    )),
  );
}

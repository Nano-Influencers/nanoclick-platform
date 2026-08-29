import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TaskDetailsScreen extends StatelessWidget implements DeskTopHeader {
  const TaskDetailsScreen({
    super.key,
    required this.onNavigate,
  });
  final Function(DesktopPage) onNavigate;
  @override
  String get title => "Tasks";

  @override
  String? get subtitle => "Marketing Campaign";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        trendingTaskCard(
            'Marketing Campaign',
            "Create a viral marketing campaign for our upcoming product launch",
            'N100,000 pts ',
            const Color(0xffFF0000),
            const Color(0xffFF0000),
            'Urgent Contest'),
        SizedBox(
          height: 1.h,
        ),
        Card(
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('2/5 completed',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                SizedBox(
                  width: 250,
                  child: LinearProgressIndicator(
                    value: 0.25,
                    backgroundColor: const Color(0xffD9D9D9),
                    color: const Color(0xffFF6533),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Started',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                    Text('In Progress',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                    Text('Review and Submit',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Task Description',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(
                  height: 2.h,
                ),
                const Text(
                    'Design a viral marketing campaign for our new fitness tracking app "FitTrack Pro" launching on May 1st. The campaign should include social media content, engagement strategies, and innovative promotional ideas.',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        instructionCard(),
        SizedBox(
          height: 2.h,
        ),
        GestureDetector(
          onTap: () {
            onNavigate(DesktopPage.taskSubmission);
          },
          child: Container(
              width: double.infinity,
              height: 42,
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: const Color(0xffD1D5DB),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                textAlign: TextAlign.center,
                'Submit  Task',
                style: TextStyle(
                    color: Color(0xff6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.normal),
              )),
        ),
      ],
    );
  }

  Widget trendingTaskCard(String title, String description, String points,
      Color containerColor, Color containerTextColor, String containerTextC) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
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
                    color: containerColor.withOpacity(0.2),
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
                const Text('Time Left :',
                    style: TextStyle(color: Colors.black, fontSize: 12)),
                SizedBox(width: 3.5.w),
                const Text('5h 45m',
                    style: TextStyle(color: Colors.red, fontSize: 11)),
              ],
            ),
            Row(
              children: [
                Text(points,
                    style: const TextStyle(color: Colors.green, fontSize: 12)),
                SizedBox(width: 2.w),
                Text('10mins ago',
                    style: TextStyle(
                        color: const Color(0xff6B7280), fontSize: 10.sp)),
                const Spacer(),
                Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xffFF6533).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                      textAlign: TextAlign.center,
                      'In Progress',
                      style: TextStyle(fontSize: 10, color: Color(0xffFF6533))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget instructionCard() {
    return Card(
        elevation: 6,
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        child: Container(
          width: double.infinity,
          height: 360,
          padding: EdgeInsets.all(2.w),
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
              const Text('Step-by-Step Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(
                height: 2.5.h,
              ),
              instructionItems(
                  title: 'Research & Analysis',
                  description:
                      'Study competitor campaigns and identify market trends',
                  number: '1'),
              instructionItems(
                  title: 'Strategy Development',
                  description:
                      'Create a comprehensive campaign strategy document',
                  number: '2'),
              instructionItems(
                  title: 'Content Creation',
                  description: 'Design and produce all required content assets',
                  number: '3'),
              instructionItems(
                  title: 'Viral Challenge Design',
                  description: 'Create an engaging viral challenge concept',
                  number: '4'),
              instructionItems(
                  title: 'Campaign Documentation',
                  description:
                      'Compile all materials into final submission package View tips',
                  number: '5')
            ],
          ),
        ));
  }

  Widget instructionItems(
      {required String title,
      required String description,
      required String number}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Colors.green,
            child: Text(
              number,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 1.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text(description,
                  style: const TextStyle(color: Colors.black, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}

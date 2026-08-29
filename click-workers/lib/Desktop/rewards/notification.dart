// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Desktop/widgets/desktop.dart';

List<Notifications> notification = [
  Notifications(
      title: 'Task Comleted Payment',
      trailingIcon: 'start_task',
      description: 'You earned N3,500 from completing the review task',
      duration: 'Just now',
      subTitle: 'Start Task'),
  Notifications(
      title: 'Task Submission Rejected',
      trailingIcon: 'view_details',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: '2h ago',
      subTitle: 'View Details'),
  Notifications(
      title: 'Withdrawal Successful',
      trailingIcon: 'task_check',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: '2m ago',
      subTitle: ''),
  Notifications(
      title: 'Withdrawal Proccessed',
      trailingIcon: 'start_task',
      description: 'Your withdrawal request of N3,500 has been proccessed',
      duration: '2h ago',
      subTitle: 'task_naira'),
  Notifications(
      title: 'Task Expiring Soon',
      trailingIcon: 'view_details',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: '2h ago',
      subTitle: 'Open Task'),
  Notifications(
      title: 'New Task Available',
      trailingIcon: 'start_task',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: 'Just now',
      subTitle: 'Start Task'),
  Notifications(
      title: 'Task Deadline Approaching',
      trailingIcon: 'continue_task',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: '2h ago',
      subTitle: 'Continue Task'),
  Notifications(
      title: 'Leaderboard Update',
      trailingIcon: 'task_cup',
      description: 'Congrats! You’ve moved up to #3 on the weekly leaderboard!',
      duration: '30m ago',
      subTitle: ''),
  Notifications(
      title: 'Task Submission Successful',
      trailingIcon: 'task_check',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: '30m ago',
      subTitle: 'View Details'),
  Notifications(
      title: 'New Task Available',
      trailingIcon: 'start_task',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: '2m ago',
      subTitle: 'Start Task'),
  Notifications(
      title: 'Task Submission Successful',
      trailingIcon: 'task_check',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: 'Just now',
      subTitle: 'View Details'),
  Notifications(
      title: 'Task Submission Rejected',
      trailingIcon: 'view_details',
      description: 'A new website testing task ia available, reward is N3,000',
      duration: '2h ago',
      subTitle: 'View Details'),
];

class NotificationScreen extends StatefulWidget implements DeskTopHeader {
  const NotificationScreen({super.key});

  @override
  String get title => "Dashboard";

  @override
  String? get subtitle => "Welcome back, Azuka";
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int selectedIndex = 0;

  final List<String> _tabs = [
    'All',
    'Task',
    'Earnings',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            elevation: 6,
            clipBehavior: Clip.hardEdge,
            child: Container(
              width: double.infinity,
                  height: 70,
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
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_tabs.length, (index) {
                      final isSelected = selectedIndex == index;
                      return Padding(
                           padding:  EdgeInsets.symmetric(vertical: 3.h),
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
            )),
        SizedBox(
          height: 2.h,
        ),
        ...List.generate(
          notification.length,
          (index) {
            return notificationItems(notification[index]);
          },
        )
      ],
    );
  }

  Widget _tabBarItems(
      {required Color color,
      required String title,
      required bool selectedIndex}) {
    return IntrinsicWidth(
      child: Container(
        width: 23.w,
        margin: EdgeInsets.symmetric(horizontal: 0.8.w),
        padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 0.5.h),
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
            style: TextStyle(
              color: selectedIndex ? const Color(0xffFF6533) : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget notificationItems(Notifications notification) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Card(
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Container(
              width: double.infinity,
              padding:
                  EdgeInsets.only(left: 1.w, right: 1.w, top: 1.h, bottom: 1.h),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(
                      'assets/icons/${notification.trailingIcon}.png',
                    ),
                  ),
                  SizedBox(
                    width: 1.w,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                            fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text(
                        notification.description,
                        style: TextStyle(
                            fontSize: 10.sp, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text(
                        notification.subTitle,
                        style: TextStyle(
                            fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(notification.duration,
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.normal)),
                ],
              ))),
    );
  }
}

class Notifications {
  final String title;
  final String trailingIcon;
  final String description;
  final String duration;
  final String subTitle;
  Notifications({
    required this.title,
    required this.trailingIcon,
    required this.description,
    required this.duration,
    required this.subTitle,
  });
}

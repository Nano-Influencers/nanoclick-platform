import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:click_workers/Desktop/widgets/search_and_filters.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TaskScreen extends StatefulWidget implements DeskTopHeader {
  const TaskScreen({super.key, required this.onNavigate});
  final Function(DesktopPage) onNavigate;

  @override
  String get title => "Tasks";

  @override
  String? get subtitle => "Manage your tasks";

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int selectedIndex = 0;

  final List<String> _tabs = [
    'All Tasks',
    'Repeating',
    'High-Earning',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_tabs.length, (index) {
                  final isSelected = selectedIndex == index;
                  return GestureDetector(
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
                  );
                }),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
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
              child: const SearchAndFilters(
                borderRadius: 10,
                firstCategory: 'Category',
                secondCategory: 'Urgency',
                thirdCategory: 'Payout',
              ),
            )),
        SizedBox(height: 2.h),
        selectedIndex == 0
            ? Wrap(
                runSpacing: 1.5.w,
                spacing: 1.5.w,
                children: List.generate(9, (index) {
                  return TaskCard(
                    onNavigate: () {
                      widget.onNavigate(DesktopPage.taskDetails);
                    },
                    title: "Marketing Campaign",
                    description:
                        "Create a viral marketing campaign for our upcoming product launch",
                    points: "₦100,000 pts",
                    tag: "Urgent Contest",
                    tagColor: const Color(0xffFEE2E2),
                    tagTextColor: const Color(0xffDC2626),
                  );
                }),
              )
            : const SizedBox.shrink(),
        SizedBox(height: 3.h),
        selectedIndex == 0 ? const _Pagination() : const SizedBox.shrink(),
      ],
    );
  }

  Widget _tabBarItems(
      {required Color color,
      required String title,
      required bool selectedIndex}) {
    return IntrinsicWidth(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
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
}

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String points;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final Function() onNavigate;

  const TaskCard(
      {super.key,
      required this.title,
      required this.description,
      required this.points,
      required this.tag,
      required this.tagColor,
      required this.tagTextColor,
      required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onNavigate();
      },
      child: Card(
        elevation: 6,
        child: Container(
          width: 300,
          height: 180,
          padding: EdgeInsets.all(1.4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(.06),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                        horizontal: 0.8.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        textAlign: TextAlign.center,
                        tag,
                        style: TextStyle(fontSize: 10, color: tagTextColor)),
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
              SizedBox(height: 1.h),
              Text(description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Color(0xff6B7280), fontSize: 12)),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(points,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.green, fontSize: 12)),
                  SizedBox(width: 2.w),
                  const Text('10mins ago',
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageButton(icon: Icons.chevron_left),
          _PageNumber("1", active: true),
          _PageNumber("2"),
          _PageNumber("2"),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("..."),
          ),
          _PageNumber("2"),
          _PageButton(icon: Icons.chevron_right),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  const _PageButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final String text;
  final bool active;
  const _PageNumber(this.text, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xffF97316) : Colors.transparent,
        border: Border.all(
            width: active ? 0 : 2,
            color: active ? Colors.transparent : const Color(0xffD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

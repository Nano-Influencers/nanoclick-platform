import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/Mobile/Tasks/task_details.dart';

/// Was ~1,600 lines of 7 near-identical StreamBuilder<QuerySnapshot> blocks
/// (one per filter tab), each querying a second Firebase app's Firestore
/// 'tasks' collection directly via an otherFirestore param this widget
/// used to require. That second Firebase app (initialized in
/// signed_in.dart as "Nano Influencers" — the two apps in this monorepo
/// used to share one Firestore project for task/campaign data) has been
/// removed entirely now that this was its last consumer. Replaced with
/// one GET /tasks fetch, filtered client-side per tab — the dataset is
/// capped at 50 tasks server-side already (see app/routers/tasks.py), so
/// client-side filtering across 7 tabs is simpler than either duplicating
/// 7 near-identical backend query variants or extending the endpoint with
/// a multi-value category filter it doesn't need for anything else.
class Tasks extends StatefulWidget {
  const Tasks(
      {super.key,
      required this.isSelected,
      required this.payout,
      required this.urgency,
      required this.category});

  final String isSelected;
  final String payout;
  final String category;
  final String urgency;

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  late String isSelected;
  bool isLoading = true;
  String? error;
  List<dynamic> _allTasks = [];

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
    _load();
  }

  Future<void> _load() async {
    try {
      final tasks = await ApiClient.instance.listTasks();
      if (mounted) setState(() { _allTasks = tasks; isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); isLoading = false; });
    }
  }

  List<dynamic> get _filtered {
    switch (isSelected) {
      case "Repeating":
        return _allTasks.where((t) =>
            (t['cw_task_category'] as String? ?? '').startsWith('repeating')).toList();
      case "Non Repeating":
        return _allTasks.where((t) =>
            !(t['cw_task_category'] as String? ?? '').startsWith('repeating') &&
            (t['cw_task_category'] as String? ?? '') != 'unpaid').toList();
      case "High-Earning":
      case "High-Points":
        return _allTasks.where((t) => t['is_high_earning'] == true).toList();
      case "Simple":
        return _allTasks.where((t) => t['difficulty'] == 'simple').toList();
      case "Unpaid":
        return _allTasks.where((t) => t['cw_task_category'] == 'unpaid').toList();
      default: // "All Tasks"
        return _allTasks;
    }
  }

  Widget _tabButton(String label, {double width = 30, double fontSize = 12}) {
    return SizedBox(
      width: width.w,
      child: ElevatedButton(
        onPressed: () => setState(() => isSelected = label),
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: isSelected == label ? Colors.black : Colors.white,
            foregroundColor: isSelected == label ? const Color(0xffff6533) : Colors.black),
        child: Text(label, style: TextStyle(fontSize: fontSize), textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
          color: const Color(0xffeeeeee),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tabButton("All Tasks"),
                SizedBox(width: 6.w),
                _tabButton("Repeating"),
                SizedBox(width: 6.w),
                _tabButton("High-Earning", fontSize: 10),
                SizedBox(width: 4.w),
                _tabButton("Non Repeating", fontSize: 10),
                SizedBox(width: 4.w),
                _tabButton("High-Points", fontSize: 10),
                SizedBox(width: 4.w),
                _tabButton("Simple", fontSize: 10),
                SizedBox(width: 4.w),
                _tabButton("Unpaid", fontSize: 10),
              ],
            ),
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: Colors.black)),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(child: Text('Error: $error')),
          )
        else if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('No tasks in this category right now.')),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              children: _filtered.map((data) => _taskCard(context, data as Map<String, dynamic>)).toList(),
            ),
          ),
      ]),
    );
  }

  Widget _taskCard(BuildContext context, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Untitled';
    final platform = (data['platform'] ?? '').toString();
    final actionType = (data['action_type'] ?? '').toString();
    final subtitle = platform.isNotEmpty && actionType.isNotEmpty
        ? "${actionType[0].toUpperCase()}${actionType.substring(1)} on ${platform[0].toUpperCase()}${platform.substring(1)}"
        : (data['description'] ?? '').toString();
    final payNgn = (data['pay_ngn'] as num?) ?? 0;
    final pay = payNgn.toStringAsFixed(0);
    final taskId = (data['id'] ?? '').toString();
    final rawDifficulty = (data['difficulty'] ?? 'simple').toString();
    final difficulty = rawDifficulty.isNotEmpty
        ? "${rawDifficulty[0].toUpperCase()}${rawDifficulty.substring(1)}"
        : 'Simple';
    final createdAt = DateTime.tryParse((data['created_at'] ?? '').toString());
    String timeAgo = 'Just now';
    if (createdAt != null) {
      final difference = DateTime.now().difference(createdAt);
      if (difference.inMinutes < 60) {
        timeAgo = '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        timeAgo = '${difference.inHours} hours ago';
      } else {
        timeAgo = '${difference.inDays} days ago';
      }
    }
    final link = (data['target_url'] ?? '').toString();
    final description = (data['description'] ?? '').toString();
    final expiresAt = DateTime.tryParse((data['expires_at'] ?? '').toString());
    String timeLeft = 'N/A';
    if (expiresAt != null) {
      final expiring = expiresAt.difference(DateTime.now());
      timeLeft = "${expiring.inHours}hrs ${expiring.inMinutes % 60}m";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: difficulty == 'Simple' ? 25.w : 30.w,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: difficulty == 'Simple'
                        ? const Color(0xffb6e5c7)
                        : const Color(0xbdfb8282),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(difficulty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: difficulty == 'Simple'
                              ? const Color(0xff22C55E)
                              : const Color(0xffff0000)))),
              SizedBox(height: 2.h),
              Text(title),
              SizedBox(height: 1.h),
              Text(subtitle, style: const TextStyle(color: Color(0xff6b7280))),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(
                          text: "₦$pay ",
                          style: const TextStyle(fontSize: 12, color: Color(0xff22c55e)),
                          children: [
                        TextSpan(
                          text: timeAgo,
                          style: const TextStyle(fontSize: 10, color: Color(0xff6b7280)),
                        )
                      ])),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TaskDetails(
                                    title: title,
                                    type: actionType,
                                    subtitle: subtitle,
                                    uid: taskId,
                                    taskID: taskId,
                                    pay: pay,
                                    clickPoints: '',
                                    difficulty: difficulty,
                                    timeLeft: timeLeft,
                                    link: link,
                                    description: description,
                                    treasureID: '',
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(22.w, 5.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text("Accept",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

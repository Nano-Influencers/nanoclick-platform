import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

import '../Tasks/task_details.dart';

/// Replaces a raw Firestore query (commencement <= now <= expiry) with
/// GET /tasks, which is actually more correct than the old query: it
/// already excludes full/inactive tasks, tasks the worker has already
/// accepted, and — for a non-KYC-verified worker — tasks belonging to a
/// *targeted* campaign they wouldn't be eligible for anyway (see
/// app/routers/tasks.py's list_tasks). None of that eligibility logic
/// existed client-side before.
///
/// No push/real-time channel exists yet (see docs/architecture.md), so
/// this polls on an interval rather than getting instant Firestore
/// .snapshots() updates — acceptable for a task list that doesn't need
/// sub-second freshness.
class TaskStream extends StatefulWidget {
  final bool isVertical;
  final int limit;

  /// Optional callback when the Accept button is pressed. Parent can
  /// navigate or handle acceptance logic. taskJson is the raw backend
  /// Task object (see GET /tasks in app/routers/tasks.py).
  final void Function(Map<String, dynamic> taskJson)? onAccept;

  const TaskStream({
    super.key,
    required this.isVertical,
    required this.limit,
    this.onAccept,
  });

  @override
  State<TaskStream> createState() => _TaskStreamState();
}

class _TaskStreamState extends State<TaskStream> {
  List<dynamic>? _tasks;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tasks = await ApiClient.instance.listTasks();
      if (mounted) setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_tasks == null) {
      return Container();
    }
    final docs = _tasks!.take(widget.limit).toList();

    if (docs.isEmpty) {
      return const Center(child: Text('No tasks yet.'));
    }
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: widget.isVertical ? Axis.vertical : Axis.horizontal,
        itemCount: docs.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final data = docs[index] as Map<String, dynamic>;
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
          final type = actionType;
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

          return Container(
              padding: widget.isVertical
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(bottom: 20),
              width: 85.w,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: difficulty == 'Simple'
                                      ? 25.w
                                      : 30.w,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: difficulty == 'Simple'
                                        ? const Color(0xffb6e5c7)
                                        : const Color(0xbdfb8282),
                                    borderRadius:
                                        BorderRadius.circular(30),
                                  ),
                                  child: Text(difficulty,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: difficulty == 'Simple'
                                              ? const Color(0xff22C55E)
                                              : const Color(
                                                  0xffff0000)))),
                            ]),
                        SizedBox(height: 2.h),
                        Text(title),
                        SizedBox(height: 1.h),
                        Text(subtitle,
                            style: const TextStyle(
                                color: Color(0xff6b7280))),
                        SizedBox(height: 2.h),
                        Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                  text: TextSpan(
                                      text: "₦$pay ",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff22c55e)),
                                      children: [
                                    TextSpan(
                                      text: timeAgo,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xff6b7280)),
                                    )
                                  ])),
                              ElevatedButton(
                                  onPressed: () async {
                                    // The original UI navigated straight to
                                    // TaskDetails (and, if onAccept was set,
                                    // also fired that callback) with no real
                                    // acceptance call anywhere — tapping
                                    // "Accept" didn't actually reserve the
                                    // task. Now it does, for both call
                                    // shapes this widget supports.
                                    try {
                                      await ApiClient.instance.acceptTask(taskId);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                      return;
                                    }
                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TaskDetails(
                                                title: title,
                                                type: type,
                                                subtitle: subtitle,
                                                uid: taskId,
                                                taskID: taskId,
                                                pay: pay,
                                                // No per-task click-points
                                                // value exists ahead of
                                                // submission — see
                                                // app/services/clickpoints.py,
                                                // which computes it at
                                                // submission time from
                                                // category/urgency/time-
                                                // of-day, not stored on
                                                // the task itself. Showing
                                                // a precise-looking
                                                // fabricated number would
                                                // be worse than showing
                                                // none.
                                                clickPoints: '',
                                                difficulty: difficulty,
                                                timeLeft: timeLeft,
                                                link: link,
                                                description: description,
                                                treasureID: '',
                                              )),
                                    );
                                    widget.onAccept?.call(data);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(
                                        22.w, 5.h), // width, height
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text("Accept",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)))
                            ])
                      ]),
                ),
              ));
        });
  }
}

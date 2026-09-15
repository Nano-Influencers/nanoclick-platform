import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/Mobile/Tasks/task_details.dart';

/// Worker task list backed by the FastAPI /tasks endpoint.
///
/// The API performs worker-specific targeting eligibility before pagination,
/// so this screen only needs to paginate/filter the returned eligible stream.
class Tasks extends StatefulWidget {
  const Tasks({
    super.key,
    required this.isSelected,
    required this.payout,
    required this.urgency,
    required this.category,
  });

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
  final Set<String> _acceptingTaskIds = <String>{};

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }
    try {
      final tasks = await ApiClient.instance.listTasks();
      if (mounted) {
        setState(() {
          _allTasks = tasks;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
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
      default:
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
          foregroundColor: isSelected == label ? const Color(0xffff6533) : Colors.black,
        ),
        child: Text(label, style: TextStyle(fontSize: fontSize), textAlign: TextAlign.center),
      ),
    );
  }

  Future<void> _acceptTask(BuildContext context, Map<String, dynamic> data) async {
    final taskId = (data['id'] ?? '').toString();
    if (taskId.isEmpty || _acceptingTaskIds.contains(taskId)) return;

    setState(() => _acceptingTaskIds.add(taskId));
    try {
      await ApiClient.instance.acceptTask(taskId);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskDetails(
            title: (data['title'] ?? 'Untitled').toString(),
            type: (data['action_type'] ?? '').toString(),
            subtitle: _subtitle(data),
            uid: taskId,
            taskID: taskId,
            pay: ((data['pay_ngn'] as num?) ?? 0).toStringAsFixed(0),
            clickPoints: '',
            difficulty: _difficulty(data),
            timeLeft: _timeLeft(data),
            link: (data['link'] ?? '').toString(),
            description: (data['description'] ?? '').toString(),
            treasureID: '',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _acceptingTaskIds.remove(taskId));
    }
  }

  String _subtitle(Map<String, dynamic> data) {
    final platform = (data['platform'] ?? '').toString();
    final actionType = (data['action_type'] ?? '').toString();
    if (platform.isNotEmpty && actionType.isNotEmpty) {
      return "${actionType[0].toUpperCase()}${actionType.substring(1)} on ${platform[0].toUpperCase()}${platform.substring(1)}";
    }
    return (data['description'] ?? '').toString();
  }

  String _difficulty(Map<String, dynamic> data) {
    final raw = (data['difficulty'] ?? 'simple').toString();
    return raw.isNotEmpty ? "${raw[0].toUpperCase()}${raw.substring(1)}" : 'Simple';
  }

  String _timeLeft(Map<String, dynamic> data) {
    final expiresAt = DateTime.tryParse((data['expires_at'] ?? '').toString());
    if (expiresAt == null) return 'N/A';
    final minutes = expiresAt.difference(DateTime.now()).inMinutes;
    if (minutes <= 0) return 'Expired';
    return "${minutes ~/ 60}hrs ${minutes % 60}m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
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
                  children: _filtered
                      .map((data) => _taskCard(context, data as Map<String, dynamic>))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(BuildContext context, Map<String, dynamic> data) {
    final title = (data['title'] ?? 'Untitled').toString();
    final platform = (data['platform'] ?? '').toString();
    final actionType = (data['action_type'] ?? '').toString();
    final subtitle = _subtitle(data);
    final payNgn = (data['pay_ngn'] as num?) ?? 0;
    final pay = payNgn.toStringAsFixed(0);
    final taskId = (data['id'] ?? '').toString();
    final difficulty = _difficulty(data);
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
    final description = (data['description'] ?? '').toString();
    final timeLeft = _timeLeft(data);
    final accepting = _acceptingTaskIds.contains(taskId);

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
                  color: difficulty == 'Simple' ? const Color(0xffb6e5c7) : const Color(0xbdfb8282),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  difficulty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: difficulty == 'Simple' ? const Color(0xff22C55E) : const Color(0xffff0000),
                  ),
                ),
              ),
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
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: accepting ? null : () => _acceptTask(context, data),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(22.w, 5.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    child: accepting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Accept", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (platform.isEmpty && actionType.isEmpty && description.isNotEmpty)
                const SizedBox.shrink(),
              if (timeLeft == 'Expired')
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('This task has expired.', style: TextStyle(color: Colors.red, fontSize: 11)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/Mobile/Tasks/task_details.dart';

/// Worker task list backed by the FastAPI /tasks endpoint.
///
/// The API performs worker-specific targeting eligibility before pagination.
/// This screen keeps pagination server-side and uses local filtering only for
/// composite tabs such as Repeating and Non Repeating.
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
  static const int _pageSize = 50;

  late String isSelected;
  bool isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? error;
  List<dynamic> _allTasks = [];
  final Set<String> _acceptingTaskIds = <String>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant Tasks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _selectTab(widget.isSelected);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore || isLoading) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Map<String, dynamic> _serverFilters() {
    switch (isSelected) {
      case 'High-Earning':
      case 'High-Points':
        return {'isHighEarning': true};
      case 'Simple':
        return {'difficulty': 'simple'};
      case 'Unpaid':
        return {'category': 'unpaid'};
      default:
        // Repeating/Non Repeating are composite views and therefore remain
        // locally filtered across the accumulated server pages.
        return {};
    }
  }

  Future<void> _load({required bool reset}) async {
    if (_isLoadingMore && !reset) return;

    if (mounted) {
      setState(() {
        if (reset) {
          isLoading = true;
          _isLoadingMore = false;
          _hasMore = true;
          _allTasks = [];
        } else {
          _isLoadingMore = true;
        }
        error = null;
      });
    }

    try {
      final filters = _serverFilters();
      final tasks = await ApiClient.instance.listTasks(
        category: filters['category'] as String?,
        difficulty: filters['difficulty'] as String?,
        isHighEarning: filters['isHighEarning'] as bool?,
        limit: _pageSize,
        offset: reset ? 0 : _allTasks.length,
      );

      if (!mounted) return;
      setState(() {
        if (reset) {
          _allTasks = tasks;
          isLoading = false;
        } else {
          _allTasks = [..._allTasks, ...tasks];
          _isLoadingMore = false;
        }
        _hasMore = tasks.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        if (reset) {
          isLoading = false;
        } else {
          _isLoadingMore = false;
        }
      });
    }
  }

  Future<void> _loadMore() => _load(reset: false);

  Future<void> _refresh() async {
    await _load(reset: true);
  }

  void _selectTab(String label) {
    if (label == isSelected && _allTasks.isNotEmpty) return;
    setState(() => isSelected = label);
    _load(reset: true);
  }

  List<dynamic> get _filtered {
    switch (isSelected) {
      case 'Repeating':
        return _allTasks.where((t) =>
            (t['cw_task_category'] as String? ?? '').startsWith('repeating')).toList();
      case 'Non Repeating':
        return _allTasks.where((t) =>
            !(t['cw_task_category'] as String? ?? '').startsWith('repeating') &&
            (t['cw_task_category'] as String? ?? '') != 'unpaid').toList();
      default:
        return _allTasks;
    }
  }

  Widget _tabButton(String label, {double width = 30, double fontSize = 12}) {
    return SizedBox(
      width: width.w,
      child: ElevatedButton(
        onPressed: () => _selectTab(label),
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
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
              color: const Color(0xffeeeeee),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tabButton('All Tasks'),
                    SizedBox(width: 6.w),
                    _tabButton('Repeating'),
                    SizedBox(width: 6.w),
                    _tabButton('High-Earning', fontSize: 10),
                    SizedBox(width: 4.w),
                    _tabButton('Non Repeating', fontSize: 10),
                    SizedBox(width: 4.w),
                    _tabButton('High-Points', fontSize: 10),
                    SizedBox(width: 4.w),
                    _tabButton('Simple', fontSize: 10),
                    SizedBox(width: 4.w),
                    _tabButton('Unpaid', fontSize: 10),
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
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Text('No tasks in this category right now.'),
                    if (_hasMore) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _isLoadingMore ? null : _loadMore,
                        child: _isLoadingMore
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Load more'),
                      ),
                    ],
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  children: filtered
                      .map((data) => _taskCard(context, data as Map<String, dynamic>))
                      .toList(),
                ),
              ),
            if (!isLoading && error == null && filtered.isNotEmpty && _hasMore)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Center(
                  child: OutlinedButton(
                    onPressed: _isLoadingMore ? null : _loadMore,
                    child: _isLoadingMore
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Load more tasks'),
                  ),
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
                      text: '₦$pay ',
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
                        : const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

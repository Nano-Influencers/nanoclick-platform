import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

class Rewards extends StatefulWidget {
  const Rewards({super.key, required this.controller, required this.kycCompleted});
  final PageController controller;
  final bool kycCompleted;
  @override
  State<Rewards> createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
  bool loading = true;
  bool actionLoading = false;
  String? error;
  Map<String, dynamic> progress = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.rewardsProgress();
      if (mounted) setState(() { progress = data; loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { error = e.message; loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'Unable to load rewards.'; loading = false; });
    }
  }

  Future<void> _action(Future<Map<String, dynamic>> Function() request) async {
    setState(() => actionLoading = true);
    try {
      await request();
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward action completed.')));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward action failed. Please try again.')));
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  dynamic _value(String key, [dynamic fallback = 0]) => progress[key] ?? fallback;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Rewards', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 1.h),
          if (error != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(error!))),
          if (error == null) ...[
            _stat('Points', '${_value('points')}', Icons.stars),
            _stat('Completed tasks', '${_value('approved_tasks', _value('completed_tasks'))}', Icons.task_alt),
            _stat('Streak', '${_value('streak_days')}', Icons.local_fire_department),
            _stat('Reward level', '${_value('level', 'Rookie')}', Icons.workspace_premium),
            SizedBox(height: 2.h),
            const Text('Daily actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Row(children: [
              Expanded(child: SizedBox(height: 50, child: ElevatedButton.icon(
                onPressed: actionLoading ? null : () => _action(ApiClient.instance.checkin),
                icon: const Icon(Icons.check_circle_outline), label: const Text('Check in'),
              ))),
              SizedBox(width: 3.w),
              Expanded(child: SizedBox(height: 50, child: ElevatedButton.icon(
                onPressed: actionLoading ? null : () => _action(ApiClient.instance.spin),
                icon: const Icon(Icons.casino_outlined), label: const Text('Spin'),
              ))),
            ]),
          ],
          if (actionLoading) ...[SizedBox(height: 2.h), const Center(child: CircularProgressIndicator())],
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) => Card(
    child: ListTile(leading: Icon(icon), title: Text(label), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
  );
}

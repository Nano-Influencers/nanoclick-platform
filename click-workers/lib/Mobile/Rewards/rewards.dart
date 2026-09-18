import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

class Rewards extends StatefulWidget {
  const Rewards({super.key, required this.controller, required this.kycCompleted});
  final PageController controller;
  final bool kycCompleted;
  @override State<Rewards> createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> {
  bool loading = true;
  bool actionLoading = false;
  String? error;
  Map<String, dynamic> progress = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.rewardsProgress();
      if (!mounted) return;
      setState(() { progress = data; loading = false; error = null; });
    } on ApiException catch (e) {
      if (mounted) setState(() { error = e.message; loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'Unable to load rewards.'; loading = false; });
    }
  }

  Future<void> _runAction(
    Future<Map<String, dynamic>> Function() request, {
    required String action,
  }) async {
    if (actionLoading) return;
    setState(() => actionLoading = true);
    try {
      final result = await request();
      await _load();
      if (!mounted) return;
      if (action == 'spin') {
        _showSpinResult(result);
      } else {
        final rewardNgn = result['reward_ngn'];
        final streakDay = result['streak_day'];
        final message = rewardNgn != null
            ? 'Check-in complete: ₦${_formatNumber(rewardNgn)}${streakDay != null ? ' • Day $streakDay streak' : ''}'
            : 'Check-in complete.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action == 'spin' ? 'Spin failed. Please try again.' : 'Check-in failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  void _showSpinResult(Map<String, dynamic> result) {
    final kind = result['kind']?.toString();
    final value = result['value'];
    String message;
    if (kind == 'cash_kobo' && value is num) {
      message = 'You won ₦${_formatNumber(value / 100)}';
    } else if (kind == 'click_points' && value is num) {
      message = 'You won ${value.toInt()} click points';
    } else {
      message = 'Your spin reward has been added to your account.';
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [const Icon(Icons.casino_outlined), SizedBox(width: 2.w), const Text('Spin Result')]),
        content: Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Continue'))],
      ),
    );
  }

  String _formatNumber(num value) => value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);

  int _intValue(String key) {
    final value = progress[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _boolValue(String key) => progress[key] == true;

  Widget _trackCard({
    required String title,
    required String description,
    required int level,
    required int completed,
    required int toNext,
    required int perLevel,
    required bool level10Reached,
    required bool poolClaimed,
    required IconData icon,
  }) {
    final currentLevelProgress = level10Reached ? perLevel : (completed % perLevel).clamp(0, perLevel);
    final progressValue = level10Reached ? 1.0 : (currentLevelProgress / perLevel).clamp(0.0, 1.0);
    return Card(
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(child: Icon(icon)),
            SizedBox(width: 3.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: .5.h),
              Text(description, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            ])),
            Text('Lv. $level', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: 2.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(level10Reached ? 'Level 10 reached' : '$completed approved', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(level10Reached ? 'MAX' : '$toNext to next level', style: const TextStyle(color: Colors.black54)),
          ]),
          SizedBox(height: 1.h),
          LinearProgressIndicator(value: progressValue),
          SizedBox(height: 1.h),
          Text(
            level10Reached
                ? (poolClaimed ? 'Level 10 pool reward already distributed.' : 'Level 10 reached • pool reward pending distribution.')
                : '$currentLevelProgress / $perLevel toward the next level',
            style: TextStyle(fontSize: 11.sp, color: Colors.black54),
          ),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

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
            _trackCard(
              title: 'Grit',
              description: 'Progress through difficult approved tasks.',
              level: _intValue('grit_level'),
              completed: _intValue('grit_difficult_tasks_approved'),
              toNext: _intValue('grit_tasks_to_next_level'),
              perLevel: 20,
              level10Reached: _boolValue('grit_level10_reached'),
              poolClaimed: _boolValue('grit_level10_pool_claimed'),
              icon: Icons.fitness_center,
            ),
            _trackCard(
              title: 'Gratis',
              description: 'Progress through approved unpaid tasks.',
              level: _intValue('gratis_level'),
              completed: _intValue('gratis_unpaid_tasks_approved'),
              toNext: _intValue('gratis_tasks_to_next_level'),
              perLevel: 100,
              level10Reached: _boolValue('gratis_level10_reached'),
              poolClaimed: _boolValue('gratis_level10_pool_claimed'),
              icon: Icons.volunteer_activism,
            ),
            _stat('Grit approved tasks', '${_intValue('grit_difficult_tasks_approved')}', Icons.task_alt),
            _stat('Gratis approved tasks', '${_intValue('gratis_unpaid_tasks_approved')}', Icons.assignment_turned_in),
            SizedBox(height: 2.h),
            const Text('Daily actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Row(children: [
              Expanded(child: SizedBox(height: 50, child: ElevatedButton.icon(
                onPressed: actionLoading ? null : () => _runAction(ApiClient.instance.checkin, action: 'checkin'),
                icon: const Icon(Icons.check_circle_outline), label: const Text('Check in'),
              ))),
              SizedBox(width: 3.w),
              Expanded(child: SizedBox(height: 50, child: ElevatedButton.icon(
                onPressed: actionLoading ? null : () => _runAction(ApiClient.instance.spin, action: 'spin'),
                icon: const Icon(Icons.casino_outlined), label: const Text('Spin'),
              ))),
            ]),
          ],
          if (actionLoading) ...[SizedBox(height: 2.h), const Center(child: CircularProgressIndicator())],
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:click_workers/services/api_client.dart';

class DesktopRewards extends StatefulWidget implements DeskTopHeader {
  const DesktopRewards({super.key});
  @override String get title => 'Rewards';
  @override String? get subtitle => '';
  @override State<DesktopRewards> createState() => _DesktopRewardsState();
}

class _DesktopRewardsState extends State<DesktopRewards> {
  Map<String, dynamic> data = {};
  bool loading = true;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final value = await ApiClient.instance.rewardsProgress(); if (mounted) setState(() { data = value; loading = false; }); }
    catch (_) { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: loading ? const CircularProgressIndicator() : ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Padding(padding: const EdgeInsets.all(40), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Rewards', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _card('Points', '${data['points'] ?? 0}'),
        _card('Completed tasks', '${data['approved_tasks'] ?? data['completed_tasks'] ?? 0}'),
        _card('Streak', '${data['streak_days'] ?? 0} days'),
        _card('Level', '${data['level'] ?? 'Rookie'}'),
        const SizedBox(height: 20),
        Row(children: [
          ElevatedButton(onPressed: () async { await ApiClient.instance.checkin(); _load(); }, child: const Text('Check in')),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: () async { await ApiClient.instance.spin(); _load(); }, child: const Text('Spin')),
        ]),
      ]),),
    )),
  );

  Widget _card(String label, String value) => Card(child: ListTile(title: Text(label), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))));
}

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

class Ranking extends StatefulWidget {
  const Ranking({super.key});
  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  String period = 'weekly';
  bool loading = true;
  String? error;
  List<dynamic> rows = [];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await ApiClient.instance.leaderboard(period);
      if (mounted) setState(() { rows = data; loading = false; error = null; });
    } on ApiException catch (e) { if (mounted) setState(() { error = e.message; loading = false; }); }
    catch (_) { if (mounted) setState(() { error = 'Unable to load leaderboard.'; loading = false; }); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ranking'), backgroundColor: Colors.white),
    backgroundColor: const Color(0xffeeeeee),
    body: Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(children: [
        SegmentedButton<String>(segments: const [
          ButtonSegment(value: 'daily', label: Text('Daily')),
          ButtonSegment(value: 'weekly', label: Text('Weekly')),
          ButtonSegment(value: 'monthly', label: Text('Monthly')),
        ], selected: {period}, onSelectionChanged: (v) { setState(() => period = v.first); _load(); }),
        SizedBox(height: 2.h),
        Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : error != null
          ? Center(child: Text(error!))
          : RefreshIndicator(onRefresh: _load, child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (_, index) {
                final row = (rows[index] as Map).cast<String, dynamic>();
                final name = '${row['full_name'] ?? row['name'] ?? 'Worker'}';
                final score = '${row['points'] ?? row['score'] ?? row['total_earned'] ?? 0}';
                return Card(child: ListTile(leading: CircleAvatar(child: Text('${index + 1}')), title: Text(name), trailing: Text(score, style: const TextStyle(fontWeight: FontWeight.bold))));
              },
            ))),
      ]),
    ),
  );
}

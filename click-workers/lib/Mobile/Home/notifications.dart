import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});
  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool loading = true;
  String? error;
  List<dynamic> items = [];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.listNotifications();
      if (mounted) setState(() { items = data; loading = false; });
    } on ApiException catch (e) { if (mounted) setState(() { error = e.message; loading = false; }); }
    catch (_) { if (mounted) setState(() { error = 'Unable to load notifications.'; loading = false; }); }
  }

  Future<void> _read(String id) async {
    try { await ApiClient.instance.markNotificationRead(id); } catch (_) {}
    await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.white),
    backgroundColor: const Color(0xffeeeeee),
    body: loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
      onRefresh: _load,
      child: error != null ? ListView(children: [Padding(padding: EdgeInsets.all(8.w), child: Text(error!, textAlign: TextAlign.center))]) :
      ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = (items[index] as Map).cast<String, dynamic>();
          final id = '${item['id'] ?? ''}';
          final title = '${item['title'] ?? 'Notification'}';
          final body = '${item['body'] ?? ''}';
          final read = item['read'] == true;
          return Card(child: ListTile(
            leading: Icon(read ? Icons.notifications_none : Icons.notifications_active),
            title: Text(title, style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold)),
            subtitle: Text(body),
            onTap: id.isEmpty ? null : () => _read(id),
          ));
        },
      ),
    ),
  );
}

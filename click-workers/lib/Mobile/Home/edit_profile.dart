import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool loading = true;
  String name = '';
  String email = '';

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final user = await ApiClient.instance.me();
      if (mounted) setState(() { name = user.fullName; email = user.email; loading = false; });
    } catch (_) { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.white),
    backgroundColor: const Color(0xffeeeeee),
    body: loading ? const Center(child: CircularProgressIndicator()) : Padding(
      padding: EdgeInsets.all(5.w),
      child: Card(child: Padding(padding: EdgeInsets.all(5.w), child: Column(children: [
        TextFormField(initialValue: name, readOnly: true, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder())),
        SizedBox(height: 2.h),
        TextFormField(initialValue: email, readOnly: true, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        SizedBox(height: 2.h),
        const Text('Profile identity is managed by the NanoClick backend. Additional profile-edit endpoints will be enabled here when the backend exposes them.', style: TextStyle(color: Color(0xff666666))),
      ]))),
    ),
  );
}

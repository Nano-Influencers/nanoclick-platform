import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/Home/sign_out.dart';
import 'package:click_workers/Mobile/Home/change_profile_picture.dart';
import 'package:click_workers/Mobile/Home/edit_profile.dart';
import 'package:click_workers/Mobile/Home/delete_account.dart';
import 'package:click_workers/Mobile/Home/change_password.dart';
import 'package:click_workers/Mobile/Home/preferred_language.dart';
import 'package:click_workers/Mobile/Home/preferred_currency.dart';
import 'package:click_workers/services/api_client.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key, required this.status, required this.id});
  final String id;
  final String status;
  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  bool loading = true;
  String name = 'Worker';
  String email = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final user = await ApiClient.instance.me();
      if (mounted) setState(() { name = user.fullName; email = user.email; loading = false; });
    } catch (_) { if (mounted) setState(() => loading = false); }
  }

  void _push(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      appBar: AppBar(title: const Text('Account Settings'), backgroundColor: Colors.white),
      body: loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(children: [
          Card(child: ListTile(leading: CircleAvatar(child: Text(name.isEmpty ? 'W' : name[0].toUpperCase())), title: Text(name), subtitle: Text(email), trailing: Text(widget.status))),
          SizedBox(height: 1.h),
          _item(Icons.person, 'Edit profile', () => _push(const EditProfile())),
          _item(Icons.photo_camera, 'Profile picture', () => _push(const ChangeDP())),
          _item(Icons.lock, 'Change password', () => _push(const ChangePassword())),
          _item(Icons.language, 'Preferred language', () => _push(const PreferredLanguage())),
          _item(Icons.payments, 'Preferred currency', () => _push(const PreferredCurrency())),
          _item(Icons.delete_forever, 'Delete account', () => _push(const DeleteAccount())),
          _item(Icons.logout, 'Sign out', () => _push(const SignOut())),
        ]),
      ),
    );
  }

  Widget _item(IconData icon, String title, VoidCallback onTap) => Card(
    child: ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap),
  );
}

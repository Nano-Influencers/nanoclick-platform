import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:click_workers/services/app_user.dart';
import '../Mobile/signed_in.dart';
import '../Mobile/landing.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  bool isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user != null) {
      return const SignedIn();
    } else {
      return const Landing();
    }
  }
}

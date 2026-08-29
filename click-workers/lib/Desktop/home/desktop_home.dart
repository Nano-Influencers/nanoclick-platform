import 'package:click_workers/Desktop/widgets/landing_page.dart';
import 'package:click_workers/Mobile/signed_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';


class DesktopHome extends StatefulWidget {
  const DesktopHome({super.key});

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  bool isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user != null) {
      return const SignedIn();
    } else {
      return const LandingPage();
    }
  }
}

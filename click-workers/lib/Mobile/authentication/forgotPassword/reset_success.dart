import 'dart:async';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:flutter/material.dart';

class ResetSuccess extends StatefulWidget {
  const ResetSuccess({super.key});

  @override
  State<ResetSuccess> createState() => _ResetSuccessState();
}

class _ResetSuccessState extends State<ResetSuccess> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignIn()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xff22c55e),
                  child: Icon(Icons.check, color: Colors.white, size: 48),
                ),
                SizedBox(height: 20),
                Text(
                  'Password Reset was Successful',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xff797979)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Pleasd wait\n\nYou will be redirected to the sign in page',
                  style: TextStyle(color: Color(0xff797979)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/authentication/sign_up.dart';
import 'package:click_workers/Mobile/widgets/footer.dart';
import 'package:click_workers/Mobile/widgets/task_stream.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});
  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final ScrollController _scrollController = ScrollController();
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'OHz0xIR8uwI',
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: false, showControls: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _auth(BuildContext context, Widget page) => Navigator.push(
        context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(children: [
          SafeArea(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Image.asset('assets/logo.png', width: 42.w),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'login') _auth(context, const SignIn());
                  if (value == 'signup') _auth(context, const SignUp());
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'login', child: Text('Sign in')),
                  PopupMenuItem(value: 'signup', child: Text('Create account')),
                ],
              ),
            ]),
          )),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(6.w, 7.h, 6.w, 6.h),
            color: const Color(0xffeeeeee),
            child: Column(children: [
              const Text('Earn by completing digital tasks', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              const Text('Find eligible tasks, complete them, submit proof and get paid through NanoClick.',
                  textAlign: TextAlign.center, style: TextStyle(color: Color(0xff555555))),
              SizedBox(height: 3.h),
              Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
                ElevatedButton(onPressed: () => _auth(context, const SignUp()), child: const Text('Get started')),
                OutlinedButton(onPressed: () => _auth(context, const SignIn()), child: const Text('Sign in')),
              ]),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(children: [
              const Text('How it works', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              _step('1', 'Create your worker account'),
              _step('2', 'Complete KYC when required'),
              _step('3', 'Choose an eligible task and submit proof'),
              _step('4', 'Approved earnings are credited to your backend wallet'),
              SizedBox(height: 3.h),
              ClipRRect(borderRadius: BorderRadius.circular(14), child: YoutubePlayer(controller: _controller)),
            ]),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(5.w),
            color: const Color(0xffeeeeee),
            child: Column(children: [
              const Text('Available tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              SizedBox(height: 42.h, child: TaskStream(isVertical: false, limit: 6, onAccept: (_) => _auth(context, const SignIn()))),
            ]),
          ),
          Padding(padding: EdgeInsets.all(5.w), child: const Text(
            'Your balance, withdrawals, task earnings, notifications and KYC submission are handled by the NanoClick backend. The worker app does not write financial or identity data directly to Firebase.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff666666)),
          )),
          Footer(scrollController: _scrollController),
        ]),
      ),
    );
  }

  Widget _step(String number, String text) => ListTile(
    leading: CircleAvatar(backgroundColor: Colors.black, child: Text(number, style: const TextStyle(color: Colors.white))),
    title: Text(text),
  );
}

import 'package:flutter/material.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/authentication/sign_up.dart';
import 'package:click_workers/Mobile/widgets/task_stream.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: SingleChildScrollView(padding: const EdgeInsets.all(48), child: Column(children: [
        const Text('NanoClick Workers', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Complete eligible digital tasks and receive approved earnings through the NanoClick backend.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Wrap(spacing: 12, children: [
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUp())), child: const Text('Create account')),
          OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignIn())), child: const Text('Sign in')),
        ]),
        const SizedBox(height: 48),
        const Text('Available tasks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(height: 420, child: TaskStream(isVertical: true, limit: 10, onAccept: (_) => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignIn())))),
      ]),),
    )),
  );
}

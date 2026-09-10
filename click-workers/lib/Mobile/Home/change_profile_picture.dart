import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChangeDP extends StatelessWidget {
  const ChangeDP({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile Picture'), backgroundColor: Colors.white),
    backgroundColor: const Color(0xffeeeeee),
    body: Padding(
      padding: EdgeInsets.all(5.w),
      child: Card(child: Padding(padding: EdgeInsets.all(5.w), child: Column(children: [
        const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 44)),
        SizedBox(height: 2.h),
        const Text('Profile-picture storage is not yet exposed by the backend. The previous implementation wrote directly to Firebase, so it has been disabled rather than retaining an insecure client-side write.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff666666))),
      ]))),
    ),
  );
}

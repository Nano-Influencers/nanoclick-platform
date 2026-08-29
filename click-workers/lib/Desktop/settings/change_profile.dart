
import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChangeProfileScreen extends StatelessWidget implements DeskTopHeader {
  const ChangeProfileScreen({super.key, required this.onNavigate});
    final Function(DesktopPage) onNavigate;
 @override
  String get title => "Account Setting";

  @override
  String? get subtitle => "Change profile picture";

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: 400,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xffD9D9D9),
                child: Image.asset(
                  'assets/icons/profile.png',
                  height: 50,
                  width: 50,
                )),
            SizedBox(
              height: 3.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/zoom_out.png',
                  height: 30,
                  width: 30,
                ),
                SizedBox(
                  width: 2.w,
                ),
                Image.asset(
                  'assets/icons/crop.png',
                  height: 30,
                  width: 30,
                ),
                SizedBox(
                  width: 2.w,
                ),
                Image.asset(
                  'assets/icons/zoom_in.png',
                  height: 30,
                  width: 30,
                )
              ],
            ),
            SizedBox(
              height: 3.h,
            ),
            button(
                color: Colors.black,
                text: 'Take Photo',
                textColor: Colors.white,
                image: 'assets/icons/camera.png'),
            button(
                color: const Color(0xffD1D5DB),
                text: 'Choose from Gallery',
                textColor: Colors.black,
                image: 'assets/icons/gallery.png'),
            button(
                color: const Color(0xffD1D5DB),
                textColor: Colors.red,
                text: 'Remove Photo',
                image: 'assets/icons/delete.png')
          ],
        ),
      ),
    );
  }

  Widget button(
      {required Color color, required String text, required String image,required Color textColor}) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 1.h),
      child: Container(
        width: 400,
        height: 38,
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: 20,
              width: 20,
              fit: BoxFit.contain,
            ),
            SizedBox(
              width: 0.5.w,
            ),
            Text(
              text,
              style:  TextStyle(
                  color:textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.normal),
            )
          ],
        ),
      ),
    );
  }
}

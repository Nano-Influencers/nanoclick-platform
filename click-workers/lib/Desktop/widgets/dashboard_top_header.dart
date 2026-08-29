import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DashboardTopHeader extends StatelessWidget {
  const DashboardTopHeader({super.key, required this.leading});
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      color: Colors.white,
      child: Row(
        children: [
          leading,
          const Spacer(),
          Row(
            children: [
              Image.asset(
                "assets/icons/notification.png",
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 0.6.w),
               const CircleAvatar(radius: 22,backgroundImage: AssetImage(
                "assets/profile.png",
              ),),
              SizedBox(width: .5.w),
               Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("Chimaobi Azuka",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                  Text("Premium Member",
                      style: TextStyle(fontSize: 12, color: const Color(0xff6B7280))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

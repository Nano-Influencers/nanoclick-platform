import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DesktopSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  final List<String> menuItems = const [
    "Home",
    "Task",
    "Ranking",
    "Rewards",
    "Wallet",
    "Settings",
  ];

  String _getIcon(String title) {
    switch (title) {
      case "Home":
        return "assets/icons/home.png";
      case "Task":
        return "assets/icons/task.png";
      case "Ranking":
        return "assets/icons/ranking.png";
      case "Rewards":
        return "assets/icons/reward.png";
      case "Wallet":
        return "assets/icons/wallet.png";
      case "Settings":
        return "assets/icons/settings.png";
      case "Logout":
        return "assets/icons/logout.png";
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 1.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              height: 6.h,
              width: 15.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4.h),
            ...List.generate(menuItems.length, (index) {
              final bool isSelected = widget.selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.onItemSelected(index);
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0.5.h),
                  height: 6.h,
                  width: 15.w,
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF6533).withOpacity(0.1)
                        : const Color(0xffD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        _getIcon(menuItems[index]),
                        color: isSelected
                            ? const Color(0xFFFF6533)
                            : const Color(0xff6B7280),
                        width: 2.5.w,
                        height: 2.5.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 1.5.w),
                      Flexible(
                        child: Text(
                          menuItems[index],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFFF6533)
                                : const Color(0xff6B7280),
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(
              height: 6.h,
            ),
            referAndEarnCard(context),
            SizedBox(
              height: 3.h,
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 6.h,
                width: 15.w,
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                decoration: BoxDecoration(
                  color: const Color(0xffD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/logout.png",
                      color: const Color(0xff6B7280),
                      width: 2.5.w,
                      height: 2.5.h,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Logout",
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h,)
          ],
        ),
      ),
    );
  }

  referAndEarnCard(BuildContext context) {
    return Container(
      width: 15.w,
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.5.w),
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xff993D1F),
            Color(0xffFF6533),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Refer & Earn 5% Extra",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            "Your Referral Link",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 0.8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 2.w,
              vertical: 0.8.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white54),
            ),
            child: Text(
              "clickworkers.com/ref/username",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: double.infinity,
            height: 4.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
              onPressed: () {},
              child: Text(
                "Copy",
                style: TextStyle(
                  color: const Color(0xffEA580C),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.2.h),
          _infoText("Total Referrals", "24 people"),
          _infoText("Earnings from Referrals:", "₦45,320"),
        ],
      ),
    );
  }

  Widget _infoText(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Colors.white70,
              fontSize: 8.sp,
              fontWeight: FontWeight.w400,
              overflow: TextOverflow.ellipsis),
        ),
        SizedBox(height: 0.3.h),
        Flexible(
          child: Text(
            value,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 8.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

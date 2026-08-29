import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DesktopSettings extends StatelessWidget implements DeskTopHeader {
  const DesktopSettings({super.key, required this.onNavigate});
  final Function(DesktopPage) onNavigate;
  @override
  String get title => "Account Setting";

  @override
  String? get subtitle => "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Account Status',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              'ID: #28401',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(
          height: 1.h,
        ),
        accountStatusCard(),
        SizedBox(
          height: 2.h,
        ),
        accountEdit(),
        SizedBox(
          height: 2.h,
        ),
        accountLevel()
      ],
    );
  }

  Widget accountStatusCard() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
        padding:
            EdgeInsets.only(left: 1.w, right: 1.w, top: 2.h, bottom: 0.3.h),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/user.png',
                  height: 18,
                  width: 18,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  width: 0.5.w,
                ),
                const Text("Non-Verified User",
                    style: TextStyle(color: Colors.black, fontSize: 13)),
                const Spacer(),
                Container(
                  padding: EdgeInsets.only(
                      left: 1.w, right: 1.w, top: 1.h, bottom: 1.h),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Text(
                      textAlign: TextAlign.center,
                      "Basic",
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              ],
            ),
            SizedBox(height: 1.5.h),
            const Text("Current Level",
                style: TextStyle(color: Colors.black, fontSize: 13)),
            SizedBox(height: 1.h),
            LinearProgressIndicator(
              value: 0.25,
              backgroundColor: const Color(0xffD9D9D9),
              color: Colors.black,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(height: 0.8.h),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Non Verified",
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xff6B7280),
                    )),
                Text("Verified",
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xff6B7280),
                    )),
                Text("Pro",
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xff6B7280),
                    )),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  accountEdit() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 1.w, right: 1.w, top: 2.h, bottom: 2.h),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            accountEditItem(
              title: 'Complete KYC Verification',
              isArrow: true,
              onTap: () {
                onNavigate(DesktopPage.upgradePlan);
              },
            ),
            accountEditItem(
              title: 'Edit profile',
              isArrow: true,
              onTap: () {
                onNavigate(DesktopPage.editProfile);
              },
            ),
            accountEditItem(
              title: 'Change password',
              isArrow: true,
              onTap: () {
                 onNavigate(DesktopPage.changePassword);
              },
            ),
            accountEditItem(
              title: 'Change profile picture',
              isArrow: true,
              onTap: () {
                onNavigate(DesktopPage.changeProfilePics);
              },
            ),
            accountEditItem(
                onTap: () {
                  onNavigate(DesktopPage.preferredLanguage);
                },
                title: 'Preferred language',
                isArrow: false,
                subTitle: 'English (UK)'),
            accountEditItem(
                onTap: () {
                   onNavigate(DesktopPage.preferredCurrency);
                },
                title: 'Choose preferred currency',
                isArrow: false,
                subTitle: 'USD'),
            accountEditItem(
                onTap: () {},
                title: 'Delete Account',
                isArrow: true,
                isDeleted: true)
          ],
        ),
      ),
    );
  }

  accountEditItem({
    isArrow = true,
    required String title,
    String? subTitle,
    isDeleted = false,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  color: isDeleted ? const Color(0xffFF0004) : Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            isArrow
                ? Image.asset(
                    'assets/icons/arrow.png',
                    height: 18,
                    width: 18,
                    fit: BoxFit.contain,
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.3.w),
                    child: Text(
                      subTitle ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  accountLevel() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 1.w, right: 1.w, top: 2.h, bottom: 2.h),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Level Benefits',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 2.h,
            ),
            Wrap(
              spacing: 0.6.w,
              runSpacing: 0.6.w,
              children: [
                accountLevelCard(
                    isPremium: false,
                    firstTitle: 'Non Verified',
                    secondTitle: 'Current',
                    children: [
                      accountLevelText(text: 'Limited task access'),
                      accountLevelText(text: 'N5k withdrawal Limit'),
                      accountLevelText(text: 'Basic features only'),
                    ]),
                accountLevelCard(
                    isPremium: false,
                    firstTitle: 'Verified',
                    secondTitle: 'Next',
                    children: [
                      accountLevelText(text: 'Full task access'),
                      accountLevelText(text: 'Standard rewards'),
                      accountLevelText(text: '5% referral commission'),
                      accountLevelText(text: 'N50k withdrawal Limit'),
                      accountLevelText(text: 'All non verified features'),
                    ]),
                accountLevelCard(
                    isPremium: true,
                    firstTitle: 'pro',
                    secondTitle: 'Premium',
                    children: [
                      accountLevelText(text: 'Higher points per task access'),
                      accountLevelText(text: 'Unlimited withdrawal Limit'),
                      accountLevelText(text: '10% referral commission'),
                      accountLevelText(text: '1 Daily free spin'),
                      accountLevelText(text: 'Pro badge display'),
                    ])
              ],
            )
          ],
        ),
      ),
    );
  }

  accountLevelCard(
      {bool isPremium = false,
      required String firstTitle,
      required String secondTitle,
      required List<Widget> children}) {
    return Container(
      width: 305,
      padding: EdgeInsets.only(left: 1.w, right: 1.w, top: 2.h, bottom: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: isPremium
            ? const LinearGradient(
                colors: [
                  Color(0xffFF6533),
                  Color(0xffC5522D),
                  Color(0xff9E4529),
                  Color(0xff4C2920),
                  Color(0xff16171A),
                  Color(0xff16171A),
                  Color(0xff16171A),
                  Color(0xff16171A),
                  Color(0xff16171A),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
        color: isPremium ? null : const Color(0xff4B5563),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding:
                EdgeInsets.only(left: 1.w, right: 1.w, top: 1.h, bottom: 1.h),
            width: 300,
            height: 45,
            decoration: BoxDecoration(
              color: isPremium
                  ? const Color(0xff4C2920)
                  : const Color.fromARGB(255, 89, 101, 117),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: isPremium
                      ? const Color(0xff4C2920)
                      : const Color.fromARGB(255, 89, 101, 117),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  firstTitle,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: 0.5.w, right: 0.5.w, top: 1.h, bottom: 1.h),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      secondTitle,
                      style: const TextStyle(
                          color: Color(0xffFF6533), fontSize: 11)),
                )
              ],
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          Container(
            height: isPremium ? 160 : 195,
            padding: EdgeInsets.only(
              left: 1.w,
              right: 1.w,
              top: 1.h,
            ),
            width: 300,
            decoration: BoxDecoration(
              color: isPremium
                  ? const Color(0xff4C2920)
                  : const Color.fromARGB(255, 89, 101, 117),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: isPremium
                      ? const Color(0xff4C2920)
                      : const Color.fromARGB(255, 89, 101, 117),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          isPremium
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                      left: 1.w, right: 1.w, top: 0.5.h, bottom: 0.5.h),
                  width: 300,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xffFF6533),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: accountLevelText(text: 'Upgrade to Pro'))
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  accountLevelText({required String text}) {
    return Padding(
      padding: EdgeInsets.all(0.5.w),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

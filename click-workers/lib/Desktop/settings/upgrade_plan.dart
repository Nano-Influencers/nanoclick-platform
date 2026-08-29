import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UpgradePlanScreen extends StatelessWidget implements DeskTopHeader {
  const UpgradePlanScreen({super.key, required this.onNavigate});
   final Function(DesktopPage) onNavigate;
  @override
  String get title => "Dashboard";

  @override
  String? get subtitle => "Upgrade to Pro Plan";

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: 470,
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
          children: [
            Container(
                width: double.infinity,
                height: 90,
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: Colors.black,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pro Plan',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: 0.5.w, right: 0.5.w, top: 1.h, bottom: 1.h),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Text(
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              'Premium',
                              style: TextStyle(
                                  color: Color(0xffFF6533), fontSize: 10)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            'N5,000/',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        Text(
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            'month',
                            style:
                                TextStyle(color: Colors.white, fontSize: 9.sp)),
                      ],
                    ),
                    const Text(
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        'Unlock all Premium features and benefits',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                )),
            SizedBox(
              height: 2.h,
            ),
            _plansItems(
                title: 'Unlimited withdrawal Limit',
                description: 'No limits on withdrawal amounts'),
            _plansItems(
                title: 'Higher Points Per Task',
                description: 'Earn more points for each completed task'),
            _plansItems(
                title: '10% referral commission',
                description: 'Higher Commission on referral earnings'),
            _plansItems(
                title: '1 Daily free spin',
                description: 'Get one free spin every day'),
            _plansItems(
                title: 'Pro badge display',
                description: 'Get a display badge that shows that you have been verified'),
                
            SizedBox(
              height: 2.h,
            ),
                 Container(
                  width: double.infinity,
                  height: 42,
                  padding: EdgeInsets.all(1.w),
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
                  child: const Text(
                    textAlign: TextAlign.center,
                    'Upgrade to Pro Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  )),
          ],
        ),
      ),
    );
  }

  _plansItems({required String title, required String description}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.w),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/plan_check.png',
            height: 11,
            width: 11,
          ),
          SizedBox(
            width: 1.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              Text(
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  description,
                  style: const TextStyle(color: Colors.black, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}

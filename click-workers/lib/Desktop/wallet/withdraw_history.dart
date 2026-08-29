import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:click_workers/Desktop/widgets/search_and_filters.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WithdrawHistoryScreen extends StatelessWidget implements DeskTopHeader {
  const WithdrawHistoryScreen({super.key});
  @override
  String get title => "wallet";

  @override
  String? get subtitle => "Withdraw History";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            elevation: 6,
            clipBehavior: Clip.hardEdge,
            child: Container(
              width: double.infinity,
              height: 70,
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
              child: const SearchAndFilters(
                borderRadius: 18,
                firstCategory: 'Date Range',
                secondCategory: 'Status',
                thirdCategory: 'Amount Range',
              ),
            )),
        SizedBox(
          height: 3.h,
        ),
        history(),
        history(),
        history(),
        history(),
        history()
      ],
    );
  }

  history() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
        height: 90,
        padding: EdgeInsets.all(1.w),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'April 15, 2025 : 10:23 AM',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xff22C55E).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                      textAlign: TextAlign.center,
                      'Completed',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xff22C55E),
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 0.5.h,
            ),
            const Text(
                textAlign: TextAlign.center,
                'N12,700.00',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 0.5.h,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GTBank **** 47584',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                Text(
                  'Ref: WDR233445555533',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

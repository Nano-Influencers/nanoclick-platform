import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:click_workers/Desktop/wallet/transaction_history.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

List<TransactionHistory> history = [
  TransactionHistory(
      data: 'Apr 16, 2025',
      description: 'Website Redesign Project',
      amount: '+\$1,200.00',
      status: Status.completed),
  TransactionHistory(
      data: 'Apr 16, 2025',
      description: 'Mobile App UI Design',
      amount: '-\$1,200.00',
      status: Status.completed),
  TransactionHistory(
      data: 'Apr 16, 2025',
      description: 'Website Redesign Project',
      amount: '+\$1,200.00',
      status: Status.pending),
  TransactionHistory(
      data: 'Apr 16, 2025',
      description: 'E-commerce Development',
      amount: '-\$1,200.00',
      status: Status.completed),
  TransactionHistory(
      data: 'Apr 16, 2025',
      description: 'Withdrawal to PayPal',
      amount: '+\$1,200.00',
      status: Status.completed),
  TransactionHistory(
      data: 'Apr 16, 2025',
      description: 'Logo Design Project',
      amount: '-\$1,200.00',
      status: Status.pending),
  TransactionHistory(
      data: 'Apr 16, 2025',
      description: 'Marketing Campaign Design',
      amount: '-\$1,200.00',
      status: Status.completed),
];

class DeskTopWallet extends StatelessWidget implements DeskTopHeader {
  const DeskTopWallet({super.key, required this.onNavigate});
  final Function(DesktopPage) onNavigate;
  @override
  String get title => "Wallet";

  @override
  String? get subtitle => "Manage your earnings and payments";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Card(
                elevation: 6,
                clipBehavior: Clip.hardEdge,
                child: Container(
                    width: 550,
                    padding: EdgeInsets.only(
                        bottom: 4.w, left: 2.w, right: 2.w, top: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: userStatsCardItem()),
              ),
              SizedBox(
                width: 1.5.w,
              ),
              Card(
                elevation: 6,
                clipBehavior: Clip.hardEdge,
                child: Container(
                    width: 350,
                    padding: EdgeInsets.only(
                        bottom: 2.w, left: 2.w, right: 2.w, top: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: userCategoryBreakdown()),
              )
            ],
          ),
        ),
        SizedBox(height: 2.h),
        const Text(
          'Transaction History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 1.h),
        Card(
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.only(bottom: 2.w, left: 2.w, right: 2.w, top: 2.h),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: userHistoryCard(),
          ),
        ),
        SizedBox(height: 2.h),
        Card(
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Container(
              width: double.infinity,
              padding:
                  EdgeInsets.only(bottom: 2.w, left: 2.w, right: 2.w, top: 2.h),
              decoration: BoxDecoration(
                  color: const Color(0xff6B7280),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icons/notice.png',
                    height: 18,
                    width: 18,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    width: 0.5.w,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Notice',
                        style: TextStyle(
                            fontSize: 9.5.sp, color: const Color(0xffFF6533)),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Minimum withdrawal amount is N30,000. External deposits are not allowed. All earnings must come from completed tasks',
                        style: TextStyle(
                            fontSize: 9.5.sp, color: const Color(0xffD1D5DB)),
                      ),
                    ],
                  )
                ],
              )),
        ),
      ],
    );
  }

  Widget userStatsCardItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome chucks',
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            cardTitles(
                firstTitle: 'Avaliable balance',
                secondTitle: 'N2,750.00',
                thirdTitle: '+12.3%',
                fourthTitle: ' from yesterday'),
            GestureDetector(
              onTap: () {
                onNavigate(DesktopPage.withdrawFunds);
              },
              child: Container(
                height: 30,
                width: 110,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: const Color(0xffFF6533),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/wallet.png',
                      height: 20,
                      width: 20,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      'Withdraw Funds',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            cardTitles(
                firstTitle: 'Total Earnings',
                secondTitle: 'N12,750.00',
                thirdTitle: '+12.3%',
                fourthTitle: ' from yesterday'),
            cardTitles(
                firstTitle: 'Total Points',
                secondTitle: 'N2,750.00',
                thirdTitle: '+12.3%',
                fourthTitle: ' from yesterday'),
          ],
        )
      ],
    );
  }

  cardTitles({
    required String firstTitle,
    required String secondTitle,
    required String thirdTitle,
    required String fourthTitle,
  }) {
    return Container(
        width: 200,
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(
          color: Color(0xff6b7280),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firstTitle,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            SizedBox(
              height: 0.5.h,
            ),
            Text(
              secondTitle,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 0.5.h,
            ),
            Row(
              children: [
                Text(
                  thirdTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                  ),
                ),
                Text(
                  fourthTitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            )
          ],
        ));
  }

  userCategoryBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        categoryItems(
            image: 'repeating', title: 'Repeating Task', amount: 'N425.40'),
        categoryItems(
            image: 'naira', title: 'High-Earning Task', amount: 'N5,825.40'),
        categoryItems(
            image: 'high_point', title: 'High-Point Task', amount: 'N5,325pts'),
        categoryItems(image: 'simple', title: 'Simple Task', amount: 'N325.40'),
        categoryItems(
            image: 'reward_based',
            title: 'Reward-Based Task',
            amount: 'N2,425.40'),
      ],
    );
  }

  categoryItems(
      {required String image, required String title, required String amount}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.4.w, vertical: 0.4.h),
      width: 300,
      padding:
          EdgeInsets.only(bottom: 1.w, top: 1.w, left: 0.5.w, right: 0.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xffD1D5DB)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/$image.png',
            height: 11,
            width: 11,
            fit: BoxFit.contain,
          ),
          SizedBox(
            width: 0.5.w,
          ),
          Text(
            title,
            style: const TextStyle(
                fontSize: 11, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
                fontSize: 11, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  userHistoryCard() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
              bottom: 1.5.w, left: 1.5.w, right: 1.5.w, top: 2.h),
          width: double.infinity,
          decoration: const BoxDecoration(
              color: Color(0xffEEEEEE),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              historyText(title: 'All Transactions', color: Colors.black),
              historyText(title: 'Earnings', color: Colors.black),
              historyText(title: 'Withdrawal', color: Colors.black)
            ],
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(bottom: 1.5.w, left: 3.w, right: 3.w, top: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              historyText(title: 'Date', color: const Color(0xff6B7280)),
              historyText(title: 'Description', color: const Color(0xff6B7280)),
              historyText(title: 'Amount', color: const Color(0xff6B7280)),
              historyText(title: 'Status', color: const Color(0xff6B7280))
            ],
          ),
        ),
        ...List.generate(
          history.length,
          (index) {
            final amountColor = history[index].status == Status.completed;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: 1.5.w, left: 3.w, right: 3.w, top: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  historyText(
                      title: history[index].data,
                      color: const Color(0xff6B7280)),
                  historyText(
                    title: history[index].description,
                    color: Colors.black,
                  ),
                  historyText(
                      title: history[index].amount,
                      color: amountColor
                          ? const Color(0xff22C55E)
                          : const Color(0xffFF0004)),
                  Container(
                    padding: EdgeInsets.only(
                        bottom: 0.5.w, left: 0.8.w, right: 0.8.w, top: 0.5.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: amountColor
                            ? const Color(0xff22C55E).withOpacity(0.2)
                            : const Color(0xffFF0004).withOpacity(0.2)),
                    child: historyText(
                        title: history[index].status.name,
                        color: amountColor
                            ? const Color(0xff22C55E)
                            : const Color(0xffFF0004)),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }

  historyText({
    required String title,
    required Color color,
  }) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
    );
  }
}

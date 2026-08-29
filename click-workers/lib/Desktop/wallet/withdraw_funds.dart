// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:click_workers/Desktop/widgets/desktop.dart';

class WithdrawFundsScreen extends StatefulWidget implements DeskTopHeader {
  const WithdrawFundsScreen({super.key, required this.onNavigate});
     final Function(DesktopPage) onNavigate;
  @override
  String get title => "wallet";

  @override
  String? get subtitle => "Withdraw Funds";

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  int selectedIndex = 0;
  List<Banks> banks = [
    Banks(
        bankName: 'GTBank',
        accountNumber: '**** **** 4582',
        color: const Color(0xffFF6533),
        image: 'assets/icons/bank.png'),
    Banks(
        bankName: 'First Bank',
        accountNumber: '**** **** 7463',
        color: const Color(0xff2756FF),
        image: 'assets/icons/bank.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        availableBalanceCard(),
        SizedBox(
          height: 5.h,
        ),
        const Text(
            textAlign: TextAlign.center,
            'Available Balance',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        ...List.generate(
          banks.length,
          (index) {
            final selectedBank = selectedIndex == index;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Container(
                  width: double.infinity,
                  height: 64,
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xffFF6533), width: 2),
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: banks[index].color.withOpacity(0.2),
                        child: Image.asset(
                          banks[index].image,
                          height: 20,
                          width: 20,
                          color: banks[index].color,
                        ),
                      ),
                      SizedBox(
                        width: 1.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            banks[index].bankName,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            banks[index].accountNumber,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                            width: 20,
                            alignment: AlignmentGeometry.center,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: selectedBank
                                      ? const Color(0xff22C55E)
                                      : const Color(0xff6B7280),
                                  width: 2),
                              color: selectedBank
                                  ? const Color(0xff22C55E)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/plan_check.png',
                              color: selectedBank
                                  ? Colors.white
                                  : const Color(0xff6B7280),
                              height: 10,
                              width: 10,
                            )),
                      )
                    ],
                  )),
            );
          },
        ),
        SizedBox(
          height: 1.h,
        ),
        DottedBorder(
          options: const RoundedRectDottedBorderOptions(
            radius: Radius.circular(10),
            strokeWidth: 1,
            dashPattern: [3, 1],
            color: Color(0xff6B7280),
           padding: EdgeInsets.zero, // important

          ),
          child: SizedBox(
            width: double.infinity,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Image.asset(
                  'assets/icons/add.png',
                  height: 20,
                  width: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  textAlign: TextAlign.center,
                  'Add New Bank Account',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        const Text(
          textAlign: TextAlign.center,
          'Amount to Withdraw',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 1.h,
        ),
        Card(
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: double.infinity,
            height: 85,
            padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  width: 250,
                  child: TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        MoneyInputFormatter(
                          leadingSymbol: '',
                          useSymbolPadding: false,
                          thousandSeparator: ThousandSeparator.Comma,
                          mantissaLength: 2,
                        ),
                      ],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        prefixText: "N ",
                        hintText: "0.00",
                        prefixStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.bold),
                        contentPadding: EdgeInsets.zero,
                        border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Color(0xff6B7280))),
                        // Optional: custom colors
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff6B7280), width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff6B7280), width: 2),
                        ),
                      )),
                ),
                SizedBox(
                  height: 1.h,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      'Min: N1,000',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      'Min: N50,000',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            amountSuggestionCard(text: 'N5,000'),
            amountSuggestionCard(text: 'N10,000'),
            amountSuggestionCard(text: 'N20,000'),
          ],
        ),
        SizedBox(
          height: 5.h,
        ),
        Column(
          children: [
            rowWidget(
                name: 'Amount',
                amount: 'N0.00',
                nameColor: const Color(0xff6B7280),
                amountColor: Colors.black),
            rowWidget(
                name: 'Fee',
                amount: 'N0.00',
                nameColor: const Color(0xff6B7280),
                amountColor: const Color(0xff6B7280)),
            rowWidget(
                name: 'Total',
                amount: 'N0.00',
                nameColor: Colors.black,
                amountColor: Colors.black),
          ],
        ),
        SizedBox(
          height: 2.h,
        ),
        Container(
            width: double.infinity,
            height: 42,
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: const Color(0xff6B7280),
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
              'Withdraw Now',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.normal),
            )),
        SizedBox(
          height: 1.h,
        ),
        GestureDetector(
          onTap: () {
               widget.onNavigate(DesktopPage.withdrawHistory);
          },
          child: const Center(
            child: Text(
              textAlign: TextAlign.center,
              'View WithdrawalHistory',
              style: TextStyle(
                  color: Color(0xffFF6533),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  availableBalanceCard() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
        height: 120,
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                textAlign: TextAlign.center,
                'Available Balance',
                style: TextStyle(fontSize: 14, color: Colors.black)),
            SizedBox(
              height: 1.h,
            ),
            const Text(
                textAlign: TextAlign.center,
                'N12,700.00',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 1.h,
            ),
            Row(
              children: [
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
                      'Verified Account',
                      style: TextStyle(fontSize: 10, color: Color(0xff22C55E))),
                ),
                SizedBox(
                  width: 3.w,
                ),
                const Text(
                    textAlign: TextAlign.center,
                    'Daily Limit: N50,000',
                    style: TextStyle(fontSize: 11, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  amountSuggestionCard({required String text}) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 180,
        height: 30,
        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.2.w),
        ),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  rowWidget(
      {required String name,
      required String amount,
      required Color nameColor,
      required Color amountColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          textAlign: TextAlign.center,
          name,
          style: TextStyle(
            color: nameColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          textAlign: TextAlign.center,
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class Banks {
  final String bankName;
  final String accountNumber;
  final Color color;
  final String image;
  Banks({
    required this.bankName,
    required this.accountNumber,
    required this.color,
    required this.image,
  });
}

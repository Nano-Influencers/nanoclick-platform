// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:click_workers/Desktop/widgets/desktop.dart';

class PreferredCurrencyScreen extends StatefulWidget implements DeskTopHeader {
  const PreferredCurrencyScreen({super.key});
  @override
  String get title => "Account Setting";

  @override
  String? get subtitle => "Preferred Currency";

  @override
  State<PreferredCurrencyScreen> createState() =>
      _PreferredCurrencyScreenState();
}

class _PreferredCurrencyScreenState extends State<PreferredCurrencyScreen> {
  int selectedIndex = 0;
  List<Currencies> currencies = [
    Currencies(title: 'NGN', description: 'Nigerian Naira (₦)'),
    Currencies(title: 'EUR', description: 'Euro (€)'),
    Currencies(title: 'GBP', description: 'British Pound (£)'),
    Currencies(title: 'JPY', description: 'Japanese Yen (¥)'),
    Currencies(title: 'INR', description: 'Indian Rupee (₹)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: 480,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(width: 2, color: Color(0xffD1D5DB))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(width: 2, color: Color(0xffD1D5DB))),
                hintText: 'Search currencies',
                prefixIcon: SizedBox(
                  height: 11,
                  width: 11,
                  child: Image.asset(
                    'assets/icons/search.png',
                  ),
                ),
                hintStyle: const TextStyle(fontSize: 12, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(width: 2, color: Color(0xffD1D5DB)),
                ),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            const Text(
              'Popular Currencies',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(
              height: 1.h,
            ),
            ...List.generate(
              currencies.length,
              (index) {
                final selectedCurrency = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: selectedCurrency
                        ? Container(
                            width: double.infinity,
                            height: 60,
                            padding: EdgeInsets.only(
                                left: 0.6.w, right: 1.w, top: 1.w, bottom: 1.w),
                            decoration: BoxDecoration(
                              color: const Color(0xffD1D5DB),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child:Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                               Text(
                              textAlign: TextAlign.start,
                              currencies[index].title,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                             Text(
                              textAlign: TextAlign.start,
                              currencies[index].description,
                              style: const TextStyle(
                                  color: Color(0xff6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )
                            ],))
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.6.w),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                              Text(
                              textAlign: TextAlign.start,
                              currencies[index].title,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              textAlign: TextAlign.start,
                              currencies[index].description,
                              style: const TextStyle(
                                  color: Color(0xff6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            ],)
                          ),
                  ),
                );
              },
            ),
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
                  'Apply',
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
}

class Currencies {
  final String title;
  final String description;
  Currencies({
    required this.title,
    required this.description,
  });
}

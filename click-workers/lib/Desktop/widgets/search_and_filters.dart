import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SearchAndFilters extends StatelessWidget {
  const SearchAndFilters(
      {super.key,
      required this.borderRadius,
      required this.firstCategory,
      required this.secondCategory,
      required this.thirdCategory});
  final double borderRadius;
  final String firstCategory;
  final String secondCategory;
  final String thirdCategory;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 0.8.w,),
          SizedBox(
            height: 38,
            width: 400,
            child: TextField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(width: 2, color: Color(0xffD1D5DB))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(width: 2, color: Color(0xffD1D5DB))),
                prefixIcon: Image.asset(
                  'assets/icons/search.png',
                  height: 11,
                  width: 11,
                ),
                hintText: "Search tasks...",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(width: 2, color: Color(0xffD1D5DB)),
                ),
              ),
            ),
          ),
          SizedBox(width: 1.w),
           FilterButton(firstCategory,borderRadius: borderRadius,),
           FilterButton(secondCategory,borderRadius: borderRadius,),
           FilterButton(thirdCategory,borderRadius: borderRadius,),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  const FilterButton(this.label, {super.key, required this.borderRadius});
 final double borderRadius;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.5.w),
      width: 125,
      height: 38,
      padding:
          EdgeInsets.only(left: 0.5.w, right: 0.5.w, top: 0.5.h, bottom: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xffD1D5DB), width: 2),
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
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
          SizedBox(
            width: 0.5.w,
          ),
          Image.asset(
            'assets/icons/arrow_down.png',
            height: 12,
            width: 12,
          )
        ],
      ),
    );
  }
}

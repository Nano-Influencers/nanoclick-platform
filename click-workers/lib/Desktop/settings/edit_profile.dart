import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditProfileScreen extends StatelessWidget implements DeskTopHeader {
  const EditProfileScreen({super.key, required this.onNavigate});
    final Function(DesktopPage) onNavigate;
  @override
  String get title => "Account Setting";

  @override
  String? get subtitle => "Edit Profile";

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 6,
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        child: Container(
          width: double.infinity,
          height: 450,
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
              _headerText(text: 'Full Name'),
              textField(hintText: 'James Wilson'),
              SizedBox(
                height: 2.h,
              ),
              _headerText(text: 'Username'),
              textField(hintText: 'jameswilson'),
              SizedBox(
                height: 2.h,
              ),
              _headerText(text: 'Email'),
              textField(hintText: 'james.wilson@gmail.com'),
              SizedBox(
                height: 2.h,
              ),
              _headerText(text: 'Phone Number'),
              textField(hintText: '+234 81 585 9303'),
              SizedBox(
                height: 2.h,
              ),
              _headerText(text: 'Date of Birth'),
              textField(hintText: '05/15/19990', isDateOfBirth: true),
              SizedBox(
                height: 3.h,
              ),
              Container(
                  width: double.infinity,
                  height: 42,
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
                  child: const Text(
                    textAlign: TextAlign.center,
                    'Save Changes',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  )),
            ],
          ),
        ));
  }

  Widget _headerText({required String text}) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget textField({required String hintText, bool isDateOfBirth = false}) {
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: TextField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Color(0xffD1D5DB))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Color(0xffD1D5DB))),
          hintText: hintText,
          suffixIcon: isDateOfBirth
              ? Image.asset(
                  'assets/icons/calender.png',
                  height: 11,
                  width: 11,
                )
              : null,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2, color: Color(0xffD1D5DB)),
          ),
        ),
      ),
    );
  }
}

import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TaskSubmissionScreen extends StatelessWidget implements DeskTopHeader {
  const TaskSubmissionScreen({super.key});
  @override
  String get title => "Tasks";

  @override
  String? get subtitle => "Task Submission";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        uploadPhotoCard(),
        SizedBox(
          height: 2.h,
        ),
        taskUrlCard(),
        SizedBox(
          height: 2.h,
        ),
        submissionCard()
      ],
    );
  }

  uploadPhotoCard() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
          width: double.infinity,
          height: 220,
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1.2.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Evidence of Completion',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 1.h,
              ),
              Container(
                width: double.infinity,
                height: 150,
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffD1D5DB)),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.2.w),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/upload.png',
                      height: 50,
                      width: 50,
                    ),
                    const Text(
                      'Drop files here or click to upload',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Supports PNG, JPG, MP4 (Max 10MB)',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  taskUrlCard() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
          width: double.infinity,
          height: 220,
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1.2.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  taskImage(),
                  SizedBox(
                    width: 1.w,
                  ),
                  taskImage()
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              const Text(
                'Task URL',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 0.5.h,
              ),
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
                  hintText: 'http://',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
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
            ],
          )),
    );
  }

  taskImage() {
    return Container(
      alignment: Alignment.topRight,
      width: 100,
      height: 100,
      padding:
          EdgeInsets.only(left: 1.5.w, bottom: 1.5.w, right: 0.5.w, top: 0.5.w),
      decoration: BoxDecoration(
        color: const Color(0xffD9D9D9),
        borderRadius: BorderRadius.circular(1.2.w),
      ),
      child: Image.asset(
        'assets/icons/cancel.png',
        height: 25,
        width: 25,
      ),
    );
  }

  submissionCard() {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Previous Submissions',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            submissionItems(
                title: 'Content Strategy Draft',
                description: 'Submitted Fed 15, 2024',
                subTitle: 'Please include more detailed Competitor analysis'),
            submissionItems(
                title: 'Content Strategy Draft',
                description: 'Submitted Fed 15, 2024',
                subTitle: 'Please include more detailed Competitor analysis'),
          ],
        ),
      ),
    );
  }

  submissionItems(
      {required String title,
      required String description,
      required String subTitle}) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 0.5.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 140,
                height: 150,
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: const Color(0xffD9D9D9),
                  borderRadius: BorderRadius.circular(1.2.w),
                ),
              ),
              SizedBox(
                width: 1.w,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    subTitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 0.5.h,
          ),
          const Divider(
            thickness: 2,
            color: Color(0xffD1D5DB),
          )
        ],
      ),
    );
  }
}

import 'package:click_workers/Mobile/Tasks/report_task.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/Tasks/submit_task.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetails extends StatefulWidget {
  const TaskDetails(
      {required this.title,
      required this.subtitle,
      required this.pay,
      required this.difficulty,
      required this.clickPoints,
      required this.type,
      required this.timeLeft,
      required this.link,
      required this.uid,
      required this.description,
      required this.taskID,
      required this.treasureID,
      super.key});

  final String title;
  final String subtitle;
  final String pay;
  final String difficulty;
  final String clickPoints;
  final String type;
  final String timeLeft;
  final String link;
  final String uid;
  final String taskID;
  final String description;
  final String treasureID;

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  //launch url
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
            onPressed: () {
              Navigator.of(context).pop(); // Go back
            },
          ),
          centerTitle: false,
          title: Text(widget.title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: const Color(0xffeeeeee),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: widget.difficulty == 'Simple'
                                        ? 25.w
                                        : 30.w,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: widget.difficulty == 'Simple'
                                          ? const Color(0xffb6e5c7)
                                          : const Color(0xbdfb8282),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(widget.difficulty,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: widget.difficulty == 'Simple'
                                                ? const Color(0xff22C55E)
                                                : const Color(0xffff0000)))),
                                IconButton(
                                    onPressed: () {
                                      showReportTaskDialog(
                                        context,
                                        widget.uid,
                                        widget.subtitle,
                                      );
                                    },
                                    icon: const Icon(Icons.flag,
                                        color: Color(0xff6b7280)))
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(widget.title),
                            SizedBox(height: 1.h),
                            Text(widget.subtitle,
                                style:
                                    const TextStyle(color: Color(0xff6b7280))),
                            SizedBox(height: 1.5.h),
                            RichText(
                                text: TextSpan(
                                    text: "Time Left: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    children: [
                                  TextSpan(
                                      text: widget.timeLeft,
                                      style: const TextStyle(
                                          color: Color(0xffff6533)))
                                ])),
                            SizedBox(height: 1.h),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                      text: TextSpan(
                                          text: "₦${widget.pay}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xff22c55e)),
                                          children: [
                                        TextSpan(
                                          text: "  ${widget.clickPoints}points",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xff6b7280)),
                                        )
                                      ])),
                                  Container(
                                      width: 25.w,
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xfff4b5a1),
                                        borderRadius: BorderRadius.circular(
                                            30), // Optional rounded corners
                                      ),
                                      child: const Text("In Progress",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Color(0xffff6533)))),
                                ])
                          ]),
                    ),
                  )),
              SizedBox(height: 2.h),
              SizedBox(
                width: 90.w,
                child: Card(
                  elevation: 6, // adds shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Progress",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            Text("30%",
                                style: TextStyle(color: Color(0xff6b7280)))
                          ],
                        ),
                        SizedBox(height: 1.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            value: 0.25, // from 0.0 to 1.0
                            minHeight: 6,
                            backgroundColor: Color(0xffd9d9d9),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Started",
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xff6b7280))),
                              Text("In Progress",
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xff6b7280))),
                              Text("Review and Submit",
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xff6b7280))),
                            ])
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Link to Task",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 1.h),
                            TextButton(
                                onPressed: () {
                                  _launchURL(widget.link);
                                },
                                child: Text(widget.link,
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline)))
                          ]),
                    ),
                  )),
              SizedBox(height: 2.h),
              SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Task Description",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 1.h),
                            Text(
                                widget.description == ''
                                    ? "None"
                                    : widget.description,
                                style:
                                    const TextStyle(color: Color(0xff6b7280)))
                          ]),
                    ),
                  )),
              SizedBox(height: 2.h),
              SizedBox(
                  width: 90.w,
                  height: 7.h,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubmitTask(
                                    treasureID: widget.treasureID,
                                    taskID: widget.taskID,
                                    type: widget.type,
                                    earnings: widget.pay,
                                    points: widget.clickPoints,
                                  )),
                        );
                      },
                      child: const Text("Submit Task"))),
              SizedBox(height: 5.h),
            ],
          )),
        ));
  }
}

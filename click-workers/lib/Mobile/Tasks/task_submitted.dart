import 'package:click_workers/Mobile/Tasks/treasure_details.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskSubmitted extends StatefulWidget {
  const TaskSubmitted(
      {super.key,
      required this.earnings,
      required this.points,
      required this.type,
      required this.treasureID});
  final String earnings;
  final String points;
  final String type;
  final String treasureID;
  @override
  State<TaskSubmitted> createState() => _TaskSubmittedState();
}

class _TaskSubmittedState extends State<TaskSubmitted> {
  bool isTreasureFound = false;
  String quantityCompleted = "";
  String treasureName = "";
  String treasureStatus = "";
  String treasureImageUrl = "";
  Map treasureDetails = {};

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks(context);
    _fetchTreasureDetails();
  }

  //fetch num of completed tasks
  Future<void> fetchCompletedTasks(BuildContext context) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('completedTasks')) {
        final completedTasks = doc['completedTasks'].toString();

        setState(() {
          quantityCompleted = completedTasks;
        });
      }
    } catch (e) {
    if(context.mounted)  {ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching completedTasks: $e")),
      );}
    }
  }

  //fetch treasure details
  Future<void> _fetchTreasureDetails() async {
    if (widget.treasureID == "") return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("announcements")
          .doc("treasures")
          .collection("treasureDetails")
          .doc(widget.treasureID)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        setState(() {
          treasureName = data["name"] ?? "";
          treasureStatus = data["status"] ?? "";
          treasureImageUrl = data["imageUrl"] ?? "";
          treasureDetails = data["details"] ?? {};
          isTreasureFound = true;
        });
      }
    } catch (e) {
    if(mounted)  {ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching treasure: $e")),
      );}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffeeeeee),
        body: SingleChildScrollView(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: 4.h),
              Container(
                  padding: const EdgeInsets.all(20),
                  width: 90.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: 90.w,
                        decoration: BoxDecoration(
                            color: const Color(0xff092e57),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Center(
                          child: Text("Task Completed Successfully",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xff00d300),
                        child: Icon(Icons.check, color: Colors.white, size: 80),
                      ),
                      SizedBox(height: 1.h),
                    ],
                  )),
              SizedBox(height: 3.h),
              Container(
                  padding: const EdgeInsets.all(20),
                  width: 90.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                              text: "Potential Earning From this Task: ",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                text: "₦${widget.earnings}",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))
                          ])),
                      SizedBox(
                        height: 1.h,
                      ),
                      RichText(
                          text: TextSpan(
                              text: "Potential Point Earned: ",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                text: "${widget.points}CPS",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))
                          ])),
                      SizedBox(
                        height: 1.h,
                      ),
                      RichText(
                          text: TextSpan(
                              text: "Quantity of Task Completed: ",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                text: quantityCompleted,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))
                          ])),
                      SizedBox(
                        height: 1.h,
                      ),
                      RichText(
                          text: TextSpan(
                              text: "Task Type: ",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                text: widget.type,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))
                          ])),
                      SizedBox(
                        height: 1.h,
                      ),
                      RichText(
                          text: TextSpan(
                              text: "Treasure Found: ",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                                text: isTreasureFound
                                    ? "Congratulations you found a Treasure"
                                    : "None",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: isTreasureFound
                                        ? const Color(0xff007a3f)
                                        : Colors.red))
                          ])),
                      !isTreasureFound
                          ? const SizedBox(height: 0)
                          : SizedBox(height: 1.h),
                      !isTreasureFound
                          ? const SizedBox(
                              height: 0,
                            )
                          : treasureImageUrl.isNotEmpty
                              ? Center(
                                  child: SizedBox(
                                      height: 200,
                                      child: Image.network(treasureImageUrl,
                                          scale: 2.0, fit: BoxFit.cover)),
                                )
                              : const SizedBox.shrink(),
                      !isTreasureFound
                          ? const SizedBox(
                              height: 0,
                            )
                          : RichText(
                              text: const TextSpan(
                                  text: "Note: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xfffe6929)),
                                  children: [
                                  TextSpan(
                                    text:
                                        "this treasure can be found by more than 1 person. The Admin would give preference first to the Worker who performed the tasks first accessing the quality. You may be the first to perform this task, Goodluck!",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xfffe6929)),
                                  )
                                ])),
                      !isTreasureFound
                          ? const SizedBox(
                              height: 0,
                            )
                          : SizedBox(height: 2.h),
                      !isTreasureFound
                          ? const SizedBox(
                              height: 0,
                            )
                          : Center(
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TreasureDetails(
                                                status: treasureStatus,
                                                details: treasureDetails,
                                                name: treasureName,
                                                imageUrl: treasureImageUrl,
                                              )),
                                    );
                                  },
                                  child: const Text("View Treasure Details",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xff007a3f),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xff007a3f)))),
                            )
                    ],
                  )),
              SizedBox(height: 2.h),
              ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(40.w, 3.h), // width, height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // round corners
                    ),
                  ),
                  child: const Text("Back to Tasks")),
              SizedBox(height: 4.h),
            ]),
          ),
        ));
  }
}

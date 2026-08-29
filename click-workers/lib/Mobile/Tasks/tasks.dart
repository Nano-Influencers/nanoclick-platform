import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:click_workers/Mobile/Tasks/task_details.dart';

class Tasks extends StatefulWidget {
  const Tasks(
      {super.key,
      required this.otherFirestore,
      required this.isSelected,
      required this.payout,
      required this.urgency,
      required this.category});

  final FirebaseFirestore? otherFirestore;
  final String isSelected;
  final String payout;
  final String category;
  final String urgency;

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  late String isSelected;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  Stream<QuerySnapshot> filterTasks({
    String? category,
    String? payout,
    String? urgency,
  }) {
    Query query = widget.otherFirestore!.collection('tasks');

    // Filter by main category (single string match)
    if (category != null && category.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: category);
    }

    // Filter by sub category
    if (payout != null && payout == "High-Earning") {
      query = query.where('isHighEarning', isEqualTo: true);
    }

    // Filter by sub category
    if (payout != null && payout == "Low-Earning") {
      query = query.where('isHighEarning', isEqualTo: false);
    }

    if (urgency != null && urgency.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: urgency);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
          color: const Color(0xffeeeeee),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 30.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "All Tasks";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isSelected == "All Tasks"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "All Tasks"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child:
                        const Text("All Tasks", style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(width: 6.w),
                SizedBox(
                  width: 30.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Repeating";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isSelected == "Repeating"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "Repeating"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child:
                        const Text("Repeating", style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(width: 6.w),
                SizedBox(
                  width: 30.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "High-Earning";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isSelected == "High-Earning"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "High-Earning"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("High-Earning",
                        style: TextStyle(fontSize: 10)),
                  ),
                ),
                SizedBox(width: 4.w),
                SizedBox(
                  width: 30.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Non Repeating";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isSelected == "Non Repeating"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "Non Repeating"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("Non Repeating",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(width: 4.w),
                SizedBox(
                  width: 30.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "High-Points";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isSelected == "High-Points"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "High-Points"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("High-Points",
                        style: TextStyle(fontSize: 10)),
                  ),
                ),
                SizedBox(width: 4.w),
                SizedBox(
                  width: 30.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Simple";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isSelected == "Simple"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "Simple"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("Simple", style: TextStyle(fontSize: 10)),
                  ),
                ),
                SizedBox(width: 4.w),
                SizedBox(
                  width: 30.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Unpaid";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isSelected == "Unpaid"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "Unpaid"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("Unpaid", style: TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ),
        isSelected == "Unpaid"
            ? Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: StreamBuilder<QuerySnapshot>(
                    stream: widget.otherFirestore!
                        .collection('tasks')
                        .where('difficulty', isEqualTo: "Unpaid")
                        .where('commencement',
                            isLessThanOrEqualTo: DateTime.now())
                        .where('expiry', isGreaterThanOrEqualTo: DateTime.now())
                        .snapshots(),
                    builder: (context, snapshot) {
                      //  Loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        ));
                      }

                      //  Error state
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Success
                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return const Center(child: Text('No tasks yet.'));
                      }
                      //debugPrint("runs");
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: docs.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final title = data['title'] ?? 'Untitled';
                            final subtitle = data['subtext'] ?? '';
                            final difficulty = data['difficulty'] ?? 'Simple';
                            final clickPoints = data['clickPoints'] ?? '0';
                            final type = data['type'] ?? '';
                            final pay = data['pay'] ?? '0';
                            final uid = data['uid'] ?? '';
                            final taskID = data['taskID'] ?? '';
                            final link = data['link'] ?? '';
                            final description = data['description'] ?? '';
                            final treasureID = data['treasureID'] ?? '';
                            Timestamp expiry = data['expiry'] ?? '';
                            DateTime expiryDate = expiry.toDate();
                            final difference =
                                expiryDate.difference(DateTime.now());
                            final timeLeft =
                                "${difference.inDays}days ${difference.inHours % 24}hrs ${difference.inMinutes % 60}m";

                            return SizedBox(
                                width: 100.w,
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: difficulty == 'Simple'
                                                  ? 25.w
                                                  : 30.w,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: difficulty == 'Simple'
                                                    ? const Color(0xffb6e5c7)
                                                    : const Color(0xbdfb8282),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(difficulty,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color: difficulty ==
                                                              'Simple'
                                                          ? const Color(
                                                              0xff22C55E)
                                                          : const Color(
                                                              0xffff0000)))),
                                          SizedBox(height: 2.h),
                                          Text(title),
                                          SizedBox(height: 1.h),
                                          Text(subtitle,
                                              style: const TextStyle(
                                                  color: Color(0xff6b7280))),
                                          SizedBox(height: 4.h),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                RichText(
                                                    text: TextSpan(
                                                        text: "₦$pay",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xff22c55e)),
                                                        children: [
                                                      TextSpan(
                                                        text:
                                                            "  $clickPoints points",
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color: Color(
                                                                0xff6b7280)),
                                                      )
                                                    ])),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    TaskDetails(
                                                                      title:
                                                                          title,
                                                                      type:
                                                                          type,
                                                                      subtitle:
                                                                          subtitle,
                                                                      uid: uid,
                                                                      taskID:
                                                                          taskID,
                                                                      pay: pay,
                                                                      clickPoints:
                                                                          clickPoints,
                                                                      difficulty:
                                                                          difficulty,
                                                                      timeLeft:
                                                                          timeLeft,
                                                                      link:
                                                                          link,
                                                                      description:
                                                                          description,
                                                                      treasureID:
                                                                          treasureID,
                                                                    )),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      fixedSize: Size(22.w,
                                                          5.h), // width, height
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        // rounded corners
                                                      ),
                                                      padding: EdgeInsets
                                                          .zero, // optional
                                                    ),
                                                    child: const Text("Accept",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)))
                                              ])
                                        ]),
                                  ),
                                ));
                          });
                    }),
              )
            : isSelected == "Non Repeating"
                ? Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: widget.otherFirestore!
                            .collection('tasks')
                            .where('isRepeating', isEqualTo: false)
                            .where('commencement',
                                isLessThanOrEqualTo: DateTime.now())
                            .where('expiry',
                                isGreaterThanOrEqualTo: DateTime.now())
                            .snapshots(),
                        builder: (context, snapshot) {
                          //  Loading state
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                              color: Colors.black,
                            ));
                          }

                          //  Error state
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          // Success
                          final docs = snapshot.data?.docs ?? [];

                          if (docs.isEmpty) {
                            return const Center(child: Text('No tasks yet.'));
                          }
                          //debugPrint("runs");
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: docs.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final data =
                                    docs[index].data() as Map<String, dynamic>;
                                final title = data['title'] ?? 'Untitled';
                                final subtitle = data['subtext'] ?? '';
                                final difficulty =
                                    data['difficulty'] ?? 'Simple';
                                final clickPoints = data['clickPoints'] ?? '0';
                                final type = data['type'] ?? '';
                                final pay = data['pay'] ?? '0';
                                final uid = data['uid'] ?? '';
                                final taskID = data['taskID'] ?? '';
                                final link = data['link'] ?? '';
                                final description = data['description'] ?? '';
                                final treasureID = data['treasureID'] ?? '';
                                Timestamp expiry = data['expiry'] ?? '';
                                DateTime expiryDate = expiry.toDate();
                                final difference =
                                    expiryDate.difference(DateTime.now());
                                final timeLeft =
                                    "${difference.inDays}days ${difference.inHours % 24}hrs ${difference.inMinutes % 60}m";

                                return SizedBox(
                                    width: 100.w,
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: difficulty == 'Simple'
                                                      ? 25.w
                                                      : 30.w,
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        difficulty == 'Simple'
                                                            ? const Color(
                                                                0xffb6e5c7)
                                                            : const Color(
                                                                0xbdfb8282),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Text(difficulty,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: difficulty ==
                                                                  'Simple'
                                                              ? const Color(
                                                                  0xff22C55E)
                                                              : const Color(
                                                                  0xffff0000)))),
                                              SizedBox(height: 2.h),
                                              Text(title),
                                              SizedBox(height: 1.h),
                                              Text(subtitle,
                                                  style: const TextStyle(
                                                      color:
                                                          Color(0xff6b7280))),
                                              SizedBox(height: 4.h),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    RichText(
                                                        text: TextSpan(
                                                            text: "₦$pay",
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xff22c55e)),
                                                            children: [
                                                          TextSpan(
                                                            text:
                                                                "  $clickPoints points",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                color: Color(
                                                                    0xff6b7280)),
                                                          )
                                                        ])),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        TaskDetails(
                                                                          title:
                                                                              title,
                                                                          type:
                                                                              type,
                                                                          subtitle:
                                                                              subtitle,
                                                                          uid:
                                                                              uid,
                                                                          taskID:
                                                                              taskID,
                                                                          pay:
                                                                              pay,
                                                                          clickPoints:
                                                                              clickPoints,
                                                                          difficulty:
                                                                              difficulty,
                                                                          timeLeft:
                                                                              timeLeft,
                                                                          link:
                                                                              link,
                                                                          description:
                                                                              description,
                                                                          treasureID:
                                                                              treasureID,
                                                                        )),
                                                          );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          fixedSize: Size(22.w,
                                                              5.h), // width, height
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            // rounded corners
                                                          ),
                                                          padding: EdgeInsets
                                                              .zero, // optional
                                                        ),
                                                        child: const Text(
                                                            "Accept",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))
                                                  ])
                                            ]),
                                      ),
                                    ));
                              });
                        }),
                  )
                : isSelected == "High-Points"
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: widget.otherFirestore!
                                .collection('tasks')
                                .where('difficulty', isEqualTo: "High-Points")
                                .where('commencement',
                                    isLessThanOrEqualTo: DateTime.now())
                                .where('expiry',
                                    isGreaterThanOrEqualTo: DateTime.now())
                                .snapshots(),
                            builder: (context, snapshot) {
                              //  Loading state
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.black,
                                ));
                              }

                              //  Error state
                              if (snapshot.hasError) {
                                //debugPrint('Error: ${snapshot.error}');
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              // Success
                              final docs = snapshot.data?.docs ?? [];

                              if (docs.isEmpty) {
                                return const Center(
                                    child: Text('No tasks yet.'));
                              }
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: docs.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data()
                                        as Map<String, dynamic>;
                                    final title = data['title'] ?? 'Untitled';
                                    final subtitle = data['subtext'] ?? '';
                                    final difficulty =
                                        data['difficulty'] ?? 'Simple';
                                    final clickPoints =
                                        data['clickPoints'] ?? '0';
                                    final type = data['type'] ?? '';
                                    final pay = data['pay'] ?? '0';
                                    final uid = data['uid'] ?? '';
                                    final taskID = data['taskID'] ?? '';
                                    final link = data['link'] ?? '';
                                    final description =
                                        data['description'] ?? '';
                                    final treasureID = data['treasureID'] ?? '';
                                    Timestamp expiry = data['expiry'] ?? '';
                                    DateTime expiryDate = expiry.toDate();
                                    final difference =
                                        expiryDate.difference(DateTime.now());
                                    final timeLeft =
                                        "${difference.inDays}days ${difference.inHours % 24}hrs ${difference.inMinutes % 60}m";

                                    return SizedBox(
                                        width: 100.w,
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      width:
                                                          difficulty == 'Simple'
                                                              ? 25.w
                                                              : 30.w,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      decoration: BoxDecoration(
                                                        color: difficulty ==
                                                                'Simple'
                                                            ? const Color(
                                                                0xffb6e5c7)
                                                            : const Color(
                                                                0xbdfb8282),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      child: Text(difficulty,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                              color: difficulty ==
                                                                      'Simple'
                                                                  ? const Color(
                                                                      0xff22C55E)
                                                                  : const Color(
                                                                      0xffff0000)))),
                                                  SizedBox(height: 2.h),
                                                  Text(title),
                                                  SizedBox(height: 1.h),
                                                  Text(subtitle,
                                                      style: const TextStyle(
                                                          color: Color(
                                                              0xff6b7280))),
                                                  SizedBox(height: 4.h),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        RichText(
                                                            text: TextSpan(
                                                                text: "₦$pay",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xff22c55e)),
                                                                children: [
                                                              TextSpan(
                                                                text:
                                                                    "  $clickPoints points",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Color(
                                                                        0xff6b7280)),
                                                              )
                                                            ])),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            TaskDetails(
                                                                              title: title,
                                                                              type: type,
                                                                              subtitle: subtitle,
                                                                              uid: uid,
                                                                              taskID: taskID,
                                                                              pay: pay,
                                                                              clickPoints: clickPoints,
                                                                              difficulty: difficulty,
                                                                              timeLeft: timeLeft,
                                                                              link: link,
                                                                              description: description,
                                                                              treasureID: treasureID,
                                                                            )),
                                                              );
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              fixedSize: Size(
                                                                  22.w,
                                                                  5.h), // width, height
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                // rounded corners
                                                              ),
                                                              padding: EdgeInsets
                                                                  .zero, // optional
                                                            ),
                                                            child: const Text(
                                                                "Accept",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)))
                                                      ])
                                                ]),
                                          ),
                                        ));
                                  });
                            }),
                      )
                    : isSelected == "Simple"
                        ? Container(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                            child: StreamBuilder<QuerySnapshot>(
                                stream: widget.otherFirestore!
                                    .collection('tasks')
                                    .where('difficulty', isEqualTo: "Simple")
                                    .where('commencement',
                                        isLessThanOrEqualTo: DateTime.now())
                                    .where('expiry',
                                        isGreaterThanOrEqualTo: DateTime.now())
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  //  Loading state
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ));
                                  }

                                  //  Error state
                                  if (snapshot.hasError) {
                                    debugPrint('Error: ${snapshot.error}');
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  // Success
                                  final docs = snapshot.data?.docs ?? [];

                                  if (docs.isEmpty) {
                                    return const Center(
                                        child: Text('No tasks yet.'));
                                  }
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: docs.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final data = docs[index].data()
                                            as Map<String, dynamic>;
                                        final title =
                                            data['title'] ?? 'Untitled';
                                        final subtitle = data['subtext'] ?? '';
                                        final difficulty =
                                            data['difficulty'] ?? 'Simple';
                                        final clickPoints =
                                            data['clickPoints'] ?? '0';
                                        final type = data['type'] ?? '';
                                        final pay = data['pay'] ?? '0';
                                        final uid = data['uid'] ?? '';
                                        final taskID = data['taskID'] ?? '';
                                        final link = data['link'] ?? '';
                                        final description =
                                            data['description'] ?? '';
                                        final treasureID =
                                            data['treasureID'] ?? '';
                                        Timestamp expiry = data['expiry'] ?? '';
                                        DateTime expiryDate = expiry.toDate();
                                        final difference = expiryDate
                                            .difference(DateTime.now());
                                        final timeLeft =
                                            "${difference.inDays}days ${difference.inHours % 24}hrs ${difference.inMinutes % 60}m";

                                        return SizedBox(
                                            width: 100.w,
                                            child: Card(
                                              elevation: 6,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                          width: difficulty ==
                                                                  'Simple'
                                                              ? 25.w
                                                              : 30.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: difficulty ==
                                                                    'Simple'
                                                                ? const Color(
                                                                    0xffb6e5c7)
                                                                : const Color(
                                                                    0xbdfb8282),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                          child: Text(difficulty,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                  color: difficulty ==
                                                                          'Simple'
                                                                      ? const Color(
                                                                          0xff22C55E)
                                                                      : const Color(
                                                                          0xffff0000)))),
                                                      SizedBox(height: 2.h),
                                                      Text(title),
                                                      SizedBox(height: 1.h),
                                                      Text(subtitle,
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xff6b7280))),
                                                      SizedBox(height: 4.h),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "₦$pay",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Color(
                                                                            0xff22c55e)),
                                                                    children: [
                                                                  TextSpan(
                                                                    text:
                                                                        "  $clickPoints points",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xff6b7280)),
                                                                  )
                                                                ])),
                                                            ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            TaskDetails(
                                                                              title: title,
                                                                              type: type,
                                                                              subtitle: subtitle,
                                                                              uid: uid,
                                                                              taskID: taskID,
                                                                              pay: pay,
                                                                              clickPoints: clickPoints,
                                                                              difficulty: difficulty,
                                                                              timeLeft: timeLeft,
                                                                              link: link,
                                                                              description: description,
                                                                              treasureID: treasureID,
                                                                            )),
                                                                  );
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  fixedSize: Size(
                                                                      22.w,
                                                                      5.h), // width, height
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    // rounded corners
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero, // optional
                                                                ),
                                                                child: const Text(
                                                                    "Accept",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold)))
                                                          ])
                                                    ]),
                                              ),
                                            ));
                                      });
                                }),
                          )
                        : isSelected == "High-Earning"
                            ? Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 40),
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: widget.otherFirestore!
                                        .collection('tasks')
                                        .where('isHighEarning', isEqualTo: true)
                                        .where('commencement',
                                            isLessThanOrEqualTo: DateTime.now())
                                        .where('expiry',
                                            isGreaterThanOrEqualTo:
                                                DateTime.now())
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      //  Loading state
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.black,
                                        ));
                                      }

                                      //  Error state
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }

                                      // Success
                                      final docs = snapshot.data?.docs ?? [];

                                      if (docs.isEmpty) {
                                        return const Center(
                                            child: Text('No tasks yet.'));
                                      }
                                      return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: docs.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final data = docs[index].data()
                                                as Map<String, dynamic>;
                                            final title =
                                                data['title'] ?? 'Untitled';
                                            final subtitle =
                                                data['subtext'] ?? '';
                                            final difficulty =
                                                data['difficulty'] ?? 'Simple';
                                            final clickPoints =
                                                data['clickPoints'] ?? '0';
                                            final type = data['type'] ?? '';
                                            final pay = data['pay'] ?? '0';
                                            final uid = data['uid'] ?? '';
                                            final taskID = data['taskID'] ?? '';
                                            final link = data['link'] ?? '';
                                            final description =
                                                data['description'] ?? '';
                                            final treasureID =
                                                data['treasureID'] ?? '';
                                            Timestamp expiry =
                                                data['expiry'] ?? '';
                                            DateTime expiryDate =
                                                expiry.toDate();
                                            final difference = expiryDate
                                                .difference(DateTime.now());
                                            final timeLeft =
                                                "${difference.inDays}days ${difference.inHours % 24}hrs ${difference.inMinutes % 60}m";

                                            return SizedBox(
                                                width: 100.w,
                                                child: Card(
                                                  elevation: 6,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              width: difficulty ==
                                                                      'Simple'
                                                                  ? 25.w
                                                                  : 30.w,
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                      8.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: difficulty ==
                                                                        'Simple'
                                                                    ? const Color(
                                                                        0xffb6e5c7)
                                                                    : const Color(
                                                                        0xbdfb8282),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                              ),
                                                              child: Text(
                                                                  difficulty,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                      color: difficulty ==
                                                                              'Simple'
                                                                          ? const Color(
                                                                              0xff22C55E)
                                                                          : const Color(
                                                                              0xffff0000)))),
                                                          SizedBox(height: 2.h),
                                                          Text(title),
                                                          SizedBox(height: 1.h),
                                                          Text(subtitle,
                                                              style: const TextStyle(
                                                                  color: Color(
                                                                      0xff6b7280))),
                                                          SizedBox(height: 4.h),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                RichText(
                                                                    text: TextSpan(
                                                                        text:
                                                                            "₦$pay",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Color(0xff22c55e)),
                                                                        children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "  $clickPoints points",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                Color(0xff6b7280)),
                                                                      )
                                                                    ])),
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                TaskDetails(
                                                                                  title: title,
                                                                                  type: type,
                                                                                  subtitle: subtitle,
                                                                                  uid: uid,
                                                                                  taskID: taskID,
                                                                                  pay: pay,
                                                                                  clickPoints: clickPoints,
                                                                                  difficulty: difficulty,
                                                                                  timeLeft: timeLeft,
                                                                                  link: link,
                                                                                  description: description,
                                                                                  treasureID: treasureID,
                                                                                )),
                                                                      );
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      fixedSize: Size(
                                                                          22.w,
                                                                          5.h), // width, height
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        // rounded corners
                                                                      ),
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero, // optional
                                                                    ),
                                                                    child: const Text(
                                                                        "Accept",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.bold)))
                                                              ])
                                                        ]),
                                                  ),
                                                ));
                                          });
                                    }),
                              )
                            : isSelected == "Repeating"
                                ? Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 40),
                                    child: StreamBuilder<QuerySnapshot>(
                                        stream: widget.otherFirestore!
                                            .collection('tasks')
                                            .where('isRepeating',
                                                isEqualTo: true)
                                            .where('commencement',
                                                isLessThanOrEqualTo:
                                                    DateTime.now())
                                            .where('expiry',
                                                isGreaterThanOrEqualTo:
                                                    DateTime.now())
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          //  Loading state
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: Colors.black,
                                            ));
                                          }

                                          //  Error state
                                          if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          }

                                          // Success
                                          final docs =
                                              snapshot.data?.docs ?? [];

                                          if (docs.isEmpty) {
                                            return const Center(
                                                child: Text('No tasks yet.'));
                                          }
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: docs.length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                final data = docs[index].data()
                                                    as Map<String, dynamic>;
                                                final title =
                                                    data['title'] ?? 'Untitled';
                                                final subtitle =
                                                    data['subtext'] ?? '';
                                                final difficulty =
                                                    data['difficulty'] ??
                                                        'Simple';
                                                final clickPoints =
                                                    data['clickPoints'] ?? '0';
                                                final type = data['type'] ?? '';
                                                final pay = data['pay'] ?? '0';
                                                final link = data['link'] ?? '';
                                                final description =
                                                    data['description'] ?? '';
                                                final treasureID =
                                                    data['treasureID'] ?? '';
                                                final uid = data['uid'] ?? "";
                                                final taskID =
                                                    data['taskID'] ?? "";
                                                Timestamp expiry =
                                                    data['expiry'] ?? '';
                                                DateTime expiryDate =
                                                    expiry.toDate();
                                                final difference = expiryDate
                                                    .difference(DateTime.now());
                                                final timeLeft =
                                                    "${difference.inDays}days ${difference.inHours % 24}hrs ${difference.inMinutes % 60}m";

                                                return SizedBox(
                                                    width: 100.w,
                                                    child: Card(
                                                      elevation: 6,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                  width: difficulty ==
                                                                          'Simple'
                                                                      ? 25.w
                                                                      : 30.w,
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: difficulty ==
                                                                            'Simple'
                                                                        ? const Color(
                                                                            0xffb6e5c7)
                                                                        : const Color(
                                                                            0xbdfb8282),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  ),
                                                                  child: Text(
                                                                      difficulty,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              12,
                                                                          color: difficulty == 'Simple'
                                                                              ? const Color(0xff22C55E)
                                                                              : const Color(0xffff0000)))),
                                                              SizedBox(
                                                                  height: 2.h),
                                                              Text(title),
                                                              SizedBox(
                                                                  height: 1.h),
                                                              Text(subtitle,
                                                                  style: const TextStyle(
                                                                      color: Color(
                                                                          0xff6b7280))),
                                                              SizedBox(
                                                                  height: 4.h),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "₦$pay",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Color(0xff22c55e)),
                                                                            children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "  $clickPoints points",
                                                                            style:
                                                                                const TextStyle(fontSize: 10, color: Color(0xff6b7280)),
                                                                          )
                                                                        ])),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => TaskDetails(title: title, type: type, subtitle: subtitle, uid: uid, taskID: taskID, pay: pay, clickPoints: clickPoints, difficulty: difficulty, timeLeft: timeLeft, link: link, description: description, treasureID: treasureID)),
                                                                          );
                                                                        },
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          fixedSize: Size(
                                                                              22.w,
                                                                              5.h), // width, height
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            // rounded corners
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.zero, // optional
                                                                        ),
                                                                        child: const Text(
                                                                            "Accept",
                                                                            style:
                                                                                TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                                                                  ])
                                                            ]),
                                                      ),
                                                    ));
                                              });
                                        }),
                                  )
                                : Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 20, 20, 40),
                                    child: StreamBuilder<QuerySnapshot>(
                                        stream: widget.otherFirestore!
                                            .collection('tasks')
                                            .where('commencement',
                                                isLessThanOrEqualTo:
                                                    DateTime.now())
                                            .where('expiry',
                                                isGreaterThanOrEqualTo:
                                                    DateTime.now())
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          //  Loading state
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: Colors.black,
                                            ));
                                          }

                                          //  Error state
                                          if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          }

                                          // Success
                                          final docs =
                                              snapshot.data?.docs ?? [];

                                          if (docs.isEmpty) {
                                            return const Center(
                                                child: Text('No tasks yet.'));
                                          }
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: docs.length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                final data = docs[index].data()
                                                    as Map<String, dynamic>;
                                                final title =
                                                    data['title'] ?? 'Untitled';
                                                final subtitle =
                                                    data['subtext'] ?? '';
                                                final difficulty =
                                                    data['difficulty'] ??
                                                        'Simple';
                                                final clickPoints =
                                                    data['clickPoints'] ?? '0';
                                                final type = data['type'] ?? '';
                                                final pay = data['pay'] ?? '0';
                                                final link = data['link'] ?? '';
                                                final uid = data['uid'] ?? '';
                                                final taskID =
                                                    data['taskID'] ?? '';
                                                final description =
                                                    data['description'] ?? '';
                                                final treasureID =
                                                    data['treasureID'] ?? '';
                                                Timestamp expiry =
                                                    data['expiry'] ?? '';
                                                DateTime expiryDate =
                                                    expiry.toDate();
                                                final difference = expiryDate
                                                    .difference(DateTime.now());
                                                final timeLeft =
                                                    "${difference.inDays}days ${difference.inHours % 24}hrs ${difference.inMinutes % 60}m";

                                                return SizedBox(
                                                    width: 100.w,
                                                    child: Card(
                                                      elevation: 6,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15.0),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                  width: difficulty ==
                                                                          'Simple'
                                                                      ? 25.w
                                                                      : 30.w,
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: difficulty ==
                                                                            'Simple'
                                                                        ? const Color(
                                                                            0xffb6e5c7)
                                                                        : const Color(
                                                                            0xbdfb8282),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                  ),
                                                                  child: Text(
                                                                      difficulty,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              12,
                                                                          color: difficulty == 'Simple'
                                                                              ? const Color(0xff22C55E)
                                                                              : const Color(0xffff0000)))),
                                                              SizedBox(
                                                                  height: 2.h),
                                                              Text(title),
                                                              SizedBox(
                                                                  height: 1.h),
                                                              Text(subtitle,
                                                                  style: const TextStyle(
                                                                      color: Color(
                                                                          0xff6b7280))),
                                                              SizedBox(
                                                                  height: 4.h),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "₦$pay",
                                                                            style:
                                                                                const TextStyle(fontSize: 12, color: Color(0xff22c55e)),
                                                                            children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "  $clickPoints points",
                                                                            style:
                                                                                const TextStyle(fontSize: 10, color: Color(0xff6b7280)),
                                                                          )
                                                                        ])),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => TaskDetails(title: title, type: type, subtitle: subtitle, uid: uid, taskID: taskID, pay: pay, clickPoints: clickPoints, difficulty: difficulty, timeLeft: timeLeft, link: link, description: description, treasureID: treasureID)),
                                                                          );
                                                                        },
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          fixedSize: Size(
                                                                              22.w,
                                                                              5.h), // width, height
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            // rounded corners
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.zero, // optional
                                                                        ),
                                                                        child: const Text(
                                                                            "Accept",
                                                                            style:
                                                                                TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                                                                  ])
                                                            ]),
                                                      ),
                                                    ));
                                              });
                                        }),
                                  ),
      ]),
    );
  }
}

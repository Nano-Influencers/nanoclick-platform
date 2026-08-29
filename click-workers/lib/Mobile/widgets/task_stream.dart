import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../Tasks/task_details.dart';

class TaskStream extends StatelessWidget {
  /// Firestore instance for the *other* Firebase project.
  final FirebaseFirestore otherFirestore;
  final bool isVertical;
  final int limit;

  /// Optional callback when the Accept button is pressed.
  /// Parent can navigate or handle acceptance logic.
  final void Function(Map<String, dynamic> taskData)? onAccept;
  const TaskStream({
    super.key,
    required this.otherFirestore,
    required this.isVertical,
    required this.limit,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: otherFirestore
            .collection('tasks')
            .where('commencement', isLessThanOrEqualTo: DateTime.now())
            .where('expiry', isGreaterThanOrEqualTo: DateTime.now())
            .limit(limit)
            .snapshots(),
        builder: (context, snapshot) {
          //  Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
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
          return ListView.builder(
              shrinkWrap: true,
              scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
              itemCount: docs.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final title = data['title'] ?? 'Untitled';
                final subtitle = data['subtext'] ?? '';
                final pay = data['pay'] ?? '0';
                final uid = data['uid'] ?? '';
                final taskID = data['taskID'] ?? '';
                final difficulty = data['difficulty'] ?? 'Simple';
                final clickPoints = data['clickPoints'] ?? '0';
                final type = data['type'] ?? '';
                final treasureID = data['treasureID'] ?? '';
                Timestamp timestamp = data['timestamp'] ?? 'Few minutes ago';
                DateTime dateTime = timestamp.toDate();
                final difference = DateTime.now().difference(dateTime);
                String timeAgo;
                if (difference.inMinutes < 60) {
                  timeAgo = '${difference.inMinutes} minutes ago';
                } else if (difference.inHours < 24) {
                  timeAgo = '${difference.inHours} hours ago';
                } else {
                  timeAgo = '${difference.inDays} days ago';
                }
                final link = data['link'] ?? '';
                final description = data['description'] ?? '';
                Timestamp expiry = data['expiry'] ?? '';
                DateTime expiryDate = expiry.toDate();
                final expiring = expiryDate.difference(DateTime.now());
                final timeLeft =
                    "${expiring.inHours}hrs ${expiring.inMinutes % 60}m";
          
                return Container(
                    padding: isVertical
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(bottom: 20),
                    width: 85.w,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width: difficulty == 'Simple'
                                            ? 25.w
                                            : 30.w,
                                        padding: const EdgeInsets.all(8.0),
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: difficulty == 'Simple'
                                                    ? const Color(0xff22C55E)
                                                    : const Color(
                                                        0xffff0000)))),
                                    // IconButton(
                                    //     icon: const Icon(Icons.flag,
                                    //         color: Color(0xff6b7280)),
                                    //     onPressed: () {})
                                  ]),
                              SizedBox(height: 2.h),
                              Text(title),
                              SizedBox(height: 1.h),
                              Text(subtitle,
                                  style: const TextStyle(
                                      color: Color(0xff6b7280))),
                              SizedBox(height: 2.h),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                        text: TextSpan(
                                            text: "$clickPoints pts ",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff22c55e)),
                                            children: [
                                          TextSpan(
                                            text: timeAgo,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xff6b7280)),
                                          )
                                        ])),
                                    ElevatedButton(
                                        onPressed: () {
                                          if (onAccept != null) {
                                            if (isVertical) {
                                              Navigator.push(
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
                                                          clickPoints:
                                                              clickPoints,
                                                          difficulty:
                                                              difficulty,
                                                          timeLeft: timeLeft,
                                                          link: link,
                                                          description:
                                                              description,
                                                          treasureID:
                                                              treasureID,
                                                        )),
                                              );
                                            }
                                            onAccept!(data);
                                          } else {
                                            Navigator.push(
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
                                                        clickPoints:
                                                            clickPoints,
                                                        difficulty:
                                                            difficulty,
                                                        timeLeft: timeLeft,
                                                        link: link,
                                                        description:
                                                            description,
                                                        treasureID:
                                                            treasureID,
                                                      )),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: Size(
                                              22.w, 5.h), // width, height
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            // rounded corners
                                          ),
                                          padding:
                                              EdgeInsets.zero, // optional
                                        ),
                                        child: const Text("Accept",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)))
                                  ])
                            ]),
                      ),
                    ));
              });
        });
  }
}

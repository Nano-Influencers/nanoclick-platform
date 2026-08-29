import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String isSelected = "All";

  // final List<NotificationItem> notifications = [
  //   NotificationItem(
  //     icon: Icons.checklist,
  //     iconColor: Colors.grey,
  //     title: 'Task Completed Payment',
  //     message: 'You earned ₦3,000 from completing the review task.',
  //     action: 'Start Task',
  //     time: 'Just now',
  //   ),
  //   NotificationItem(
  //     icon: Icons.error,
  //     iconColor: Colors.red,
  //     title: 'Task Submission Rejected',
  //     message: 'A new website task submission has been rejected.',
  //     action: 'View Details',
  //     time: '3m ago',
  //   ),
  //   NotificationItem(
  //     icon: Icons.task_alt,
  //     iconColor: Colors.green,
  //     title: 'Withdrawal Successful',
  //     message: 'Your withdrawal request of ₦3,000 was successful.',
  //     action: '',
  //     time: '2m ago',
  //   ),
  //   NotificationItem(
  //     icon: Icons.attach_money,
  //     iconColor: Colors.green,
  //     title: 'Withdrawal Processed',
  //     message: 'Your withdrawal request of ₦3,000 was successful.',
  //     action: '',
  //     time: '2m ago',
  //   ),
  //   NotificationItem(
  //     icon: Icons.error,
  //     iconColor: Colors.red,
  //     title: 'Task Expiring Soon',
  //     message: 'A new website task is expiring, rewarded ₦3,000.',
  //     action: 'Open Task',
  //     time: '2m ago',
  //   ),
  //   NotificationItem(
  //     icon: Icons.checklist,
  //     iconColor: Colors.grey,
  //     title: 'New Task Available',
  //     message: 'A new website task is available, rewarded ₦3,000.',
  //     action: 'Start Task',
  //     time: 'Just now',
  //   ),
  //   NotificationItem(
  //     icon: Icons.access_time,
  //     iconColor: Colors.purple,
  //     title: 'Task Deadline Approaching',
  //     message: 'Finish your task to earn ₦3,000.',
  //     action: 'Continue Task',
  //     time: '30m ago',
  //   ),
  //   NotificationItem(
  //     icon: Icons.emoji_events,
  //     iconColor: Colors.purple,
  //     title: 'Leaderboard Update',
  //     message: 'You’ve moved up to #3!',
  //     action: '',
  //     time: '30m ago',
  //   ),
  //   NotificationItem(
  //     icon: Icons.task_alt,
  //     iconColor: Colors.green,
  //     title: 'Task Submission Successful',
  //     message: 'A new website task was submitted successfully.',
  //     action: 'View Details',
  //     time: '2m ago',
  //   ),
  // ];

  Future<void> deleteAllDocumentsInBatches({int batchSize = 500}) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notifications');

    while (true) {
      // Get a batch of documents
      final snapshot = await collectionRef.limit(batchSize).get();

      if (snapshot.docs.isEmpty) {
        break; // Done, no more docs
      }

      // Start a batch
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit batch
      await batch.commit();
    }
  }

  //clear notifications dialog
  void showClearNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Notifications"),
        content:
            const Text("Are you sure you want to clear all notifications?"),
        actions: [
          TextButton(
            child: const Text("No", style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.pop(context); // just close dialog
            },
          ),
          TextButton(
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context); // close dialog before deleting
              await deleteAllDocumentsInBatches();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All notifications cleared")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              showClearNotificationsDialog(context);
            },
            child: const Text(
              'clear all',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
            color: const Color(0xffeeeeee),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 27.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "All";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected == "All" ? Colors.black : Colors.white,
                        foregroundColor: isSelected == "All"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("All", style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 27.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Task";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected == "Task" ? Colors.black : Colors.white,
                        foregroundColor: isSelected == "Task"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child: const Text("Task", style: TextStyle(fontSize: 12)),
                  ),
                ),
                SizedBox(
                  width: 27.w,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSelected = "Earnings";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected == "Earnings"
                            ? Colors.black
                            : Colors.white,
                        foregroundColor: isSelected == "Earnings"
                            ? const Color(0xffff6533)
                            : Colors.black),
                    child:
                        const Text("Earnings", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          isSelected == "Earnings"
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('notifications')
                      .where('category', isEqualTo: 'earnings')
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
                      return const Center(child: Text('Nothing to see here.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final icon = data['type'] == "tasks" ? Icons.checklist :  data['type'] == "wallet" ? Icons.task_alt : data['type'] == "withdrawal" ? Icons.attach_money : Icons.leaderboard;
                        final color = data['color'] ?? 'grey';
                        final title = data['title'] ?? 'Untitled';
                        final message = data['message'] ?? 'No Message';
                        final action = data['action'] ?? '';
                        Timestamp time = data['time'] ?? 'Few minutes ago';
                        DateTime dateTime = time.toDate();
                        final difference = DateTime.now().difference(dateTime);
                        String timeAgo;
                        if (difference.inMinutes < 60) {
                          timeAgo = '${difference.inMinutes} minutes ago';
                        } else if (difference.inHours < 24) {
                          timeAgo = '${difference.inHours} hours ago';
                        } else {
                          timeAgo = '${difference.inDays} days ago';
                        }
                        return Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.05),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xffeeeeee),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(icon,
                                        color: Color(color),
                                        size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  // Text Section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          message,
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13),
                                        ),
                                        if (action != "")
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              action,
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Timestamp
                                  Text(
                                    timeAgo,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  })
              : isSelected == "Task"
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('notifications')
                          .where('category', isEqualTo: 'task')
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
                          return const Center(
                              child: Text('Nothing to see here.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final icon = data['type'] == "tasks" ? Icons.checklist :  data['type'] == "wallet" ? Icons.task_alt : data['type'] == "withdrawal" ? Icons.attach_money : Icons.leaderboard;
                            final color = data['color'] ?? 'grey';
                            final title = data['title'] ?? 'Untitled';
                            final message = data['message'] ?? 'No Message';
                            final action = data['action'] ?? '';
                            Timestamp time = data['time'] ?? 'Few minutes ago';
                            DateTime dateTime = time.toDate();
                            final difference =
                                DateTime.now().difference(dateTime);
                            String timeAgo;
                            if (difference.inMinutes < 60) {
                              timeAgo = '${difference.inMinutes} minutes ago';
                            } else if (difference.inHours < 24) {
                              timeAgo = '${difference.inHours} hours ago';
                            } else {
                              timeAgo = '${difference.inDays} days ago';
                            }
                            return Container(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4,
                                        color: Colors.black.withOpacity(0.05),
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icon
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xffeeeeee),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(icon,
                                            color: Color(color),
                                            size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      // Text Section
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              message,
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 13),
                                            ),
                                            if (action != "")
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  action,
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Timestamp
                                      Text(
                                        timeAgo,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      })
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('notifications')
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
                          return const Center(
                              child: Text('Nothing to see here.'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final icon = data['type'] == "tasks" ? Icons.checklist :  data['type'] == "wallet" ? Icons.task_alt : data['type'] == "withdrawal" ? Icons.attach_money : Icons.leaderboard;
                            final color = data['color'] ?? 'grey';
                            final title = data['title'] ?? 'Untitled';
                            final message = data['message'] ?? 'No Message';
                            final action = data['action'] ?? '';
                            Timestamp time = data['time'] ?? 'Few minutes ago';
                            DateTime dateTime = time.toDate();
                            final difference =
                                DateTime.now().difference(dateTime);
                            String timeAgo;
                            if (difference.inMinutes < 60) {
                              timeAgo = '${difference.inMinutes} minutes ago';
                            } else if (difference.inHours < 24) {
                              timeAgo = '${difference.inHours} hours ago';
                            } else {
                              timeAgo = '${difference.inDays} days ago';
                            }
                            return Container(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4,
                                        color: Colors.black.withOpacity(0.05),
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icon
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xffeeeeee),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(icon,
                                            color: Color(color),
                                            size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      // Text Section
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              message,
                                              style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 13),
                                            ),
                                            if (action != "")
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  action,
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Timestamp
                                      Text(
                                        timeAgo,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
        ]),
      ),
    );
  }
}

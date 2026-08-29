import 'dart:typed_data';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;

class TreasureHistory extends StatefulWidget {
  const TreasureHistory({super.key});

  @override
  State<TreasureHistory> createState() => _TreasureHistoryState();
}

class _TreasureHistoryState extends State<TreasureHistory> {
  String selected = "Found";
  final Set<int> expandedIndexes = {};
  final ValueNotifier<Uint8List?> selectedFile =
      ValueNotifier<Uint8List?>(null);
  final ValueNotifier<bool> submit = ValueNotifier<bool>(true);
  final ValueNotifier<String> fileName = ValueNotifier<String>("");
  bool received = false;
  // cloudinary credentials
  final String cloudName = "dihpawfyc";
  final String uploadPreset = "click-uploads";
  TextEditingController linkEditingController = TextEditingController();

  //pick files
  Future<void> pickVideo(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true, // needed for web (gives bytes)
      );

      if (result == null) return;

      final pickedFile = result.files.single;

      // Check file size (limit: 10 MB)
      if (pickedFile.size > 10 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Video must be less than 10MB")),
          );
        }
        return;
      }

      selectedFile.value = pickedFile.bytes;
      fileName.value = pickedFile.name;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking video: $e")),
        );
      }
    }
  }

  //upload video and store in firestore
  Future<void> uploadVideoAndStoreData({
    required Uint8List fileBytes,
    required String fileName,
    required String cloudName,
    required String uploadPreset,
  }) async {
    try {
      //Upload to Cloudinary
      final uri =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/video/upload");

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          ),
        );

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception(
            "Cloudinary upload failed with status: ${response.statusCode}");
      }

      final resStr = await response.stream.bytesToString();
      final resJson = jsonDecode(resStr);
      final videoUrl = resJson['secure_url'];

      if (videoUrl == null) {
        throw Exception("Cloudinary did not return a secure_url");
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload Success")),
          );
        }
      }

      //  Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('appreciation')
          .add({
        'videoUrl': videoUrl,
        'linkToField': linkEditingController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      submit.value = !submit.value;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  //filter drawer
  void showTopDrawer(BuildContext context) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "TopDrawer",
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink(); // required, but we override it below
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.translate(
          offset: Offset(0, -200 + anim1.value * 200), // slide down
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 8,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                width: double.infinity,
                height: 38.h, // custo
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    )),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Filter",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          TextButton(
                              onPressed: () {},
                              child: const Text("Clear All",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black))),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      const Text("Category",
                          style: TextStyle(
                              fontSize: 12, color: Color(0xff6b7280))),
                      SizedBox(height: 0.5.h),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField(
                          items: ['All', 'Content', 'Survey', 'Promo']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          value: 'All',
                          onChanged: (val) {},
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(children: [
                        const Text("Payout",
                            style: TextStyle(
                              color: Color(0xff6b7280),
                              fontSize: 12,
                            )),
                        SizedBox(width: 52.w),
                        const Text("Urgency",
                            style: TextStyle(
                                color: Color(0xff6b7280), fontSize: 12))
                      ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 30.w,
                              child: DropdownButtonFormField(
                                items: ['All', 'Content', 'Survey', 'Promo']
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                value: 'All',
                                onChanged: (val) {},
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                              ),
                            ),
                            SizedBox(
                              width: 30.w,
                              child: DropdownButtonFormField(
                                items: ['All', 'Content', 'Survey', 'Promo']
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                value: 'All',
                                onChanged: (val) {},
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                              ),
                            ),
                          ])
                    ]),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadLinkField = TextFormField(
      controller: linkEditingController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

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
            child: Text('Treasure History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          // actions: [
          //   InkWell(
          //       onTap: () {
          //         showTopDrawer(context);
          //       },
          //       child: Image.asset("assets/icons/filter_funnel.png"))
          // ],
          backgroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xffeeeeee),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(
            height: 3.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    setState(() {
                      selected = "Found";
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 28.w,
                      decoration: BoxDecoration(
                        color:
                            selected == "Found" ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Found",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected == "Found"
                                ? const Color(0xfffe6929)
                                : Colors.black),
                      ))),
              InkWell(
                  onTap: () {
                    setState(() {
                      selected = "Rejected";
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 28.w,
                      decoration: BoxDecoration(
                        color: selected == "Rejected"
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Rejected",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected == "Rejected"
                                ? const Color(0xfffe6929)
                                : Colors.black),
                      ))),
              InkWell(
                  onTap: () {
                    setState(() {
                      selected = "Approved";
                    });
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 28.w,
                      decoration: BoxDecoration(
                        color: selected == "Approved"
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Approved",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected == "Approved"
                                ? const Color(0xfffe6929)
                                : Colors.black),
                      )))
            ],
          ),
          SizedBox(
            height: 3.h,
          ),
          selected == "Found"
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('treasures')
                      .snapshots(),
                  builder: (context, treasureSnapshot) {
                    if (treasureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!treasureSnapshot.hasData ||
                        treasureSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No treasures found"));
                    }

                    // first treasures docId
                    final treasureDocId = treasureSnapshot.data!.docs.first.id;

                    // its subcollection
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('treasures')
                          .doc(treasureDocId)
                          .collection('treasureHistory')
                          .doc('found')
                          .snapshots(),
                      builder: (context, foundSnapshot) {
                        if (foundSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!foundSnapshot.hasData ||
                            !foundSnapshot.data!.exists) {
                          return const Center(child: Text("No history found"));
                        }

                        final data =
                            foundSnapshot.data!.data() as Map<String, dynamic>;

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (data['date'] as List).length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 2.h),
                          itemBuilder: (context, index) {
                            final date = (data['date'] as List)[index];
                            final Map details =
                                (data['details'] as List)[index];
                            final imageUrl = (data['imageUrls'] as List)[index];
                            final status = (data['status'] as List)[index];
                            bool isExpanded = false;
                            return StatefulBuilder(
                                builder: (context, setInnerState) {
                              return Container(
                                width: 100.w,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      width: 85.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black87,
                                            spreadRadius: 2,
                                            offset: Offset(2, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                                text: TextSpan(
                                                    text: "Status: ",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    children: [
                                                  TextSpan(
                                                      text: status,
                                                      style: TextStyle(
                                                          color: status ==
                                                                  "Approved by Admin"
                                                              ? const Color(
                                                                  0xff007a3f)
                                                              : status ==
                                                                      "Declined"
                                                                  ? const Color(
                                                                      0xffe70e17)
                                                                  : const Color(
                                                                      0xfffe6929)))
                                                ])),
                                            Image.network(imageUrl ?? "",
                                                fit: BoxFit.contain),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                    onPressed: () {
                                                      setInnerState(() {
                                                        isExpanded =
                                                            !isExpanded;
                                                      });
                                                    },
                                                    child: Text(
                                                        isExpanded
                                                            ? "See Less"
                                                            : "See More",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xff007a3f),
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor: Color(
                                                                0xff007a3f)))),
                                                SizedBox(width: 3.w),
                                                Text(date,
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10))
                                              ],
                                            )
                                          ]),
                                    ),
                                    SizedBox(height: 4.h),
                                    isExpanded
                                        ? Container(
                                            padding: const EdgeInsets.all(15),
                                            width: 85.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black87,
                                                  spreadRadius: 2,
                                                  offset: Offset(2, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Center(
                                                      child: Text(
                                                    "Details of the Item",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  )),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                                  Text(details['Name'],
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xfffe6929),
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(
                                                    height: 2.h,
                                                  ),
                                                  ...details.entries
                                                      .where((entry) =>
                                                          entry.key !=
                                                          'Name') // skips the "name" field
                                                      .map((entry) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        2.0),
                                                            child: RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "${entry.key}: ",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    children: [
                                                                  TextSpan(
                                                                    text:
                                                                        "${entry.value}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  )
                                                                ])),
                                                          )),
                                                ]))
                                        : const SizedBox(height: 0),
                                    SizedBox(height: 4.h),
                                  ],
                                ),
                              );
                            });
                          },
                        );
                      },
                    );
                  },
                )
              : selected == "Rejected"
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('treasures')
                          .snapshots(),
                      builder: (context, treasureSnapshot) {
                        if (treasureSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!treasureSnapshot.hasData ||
                            treasureSnapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text("No treasures found"));
                        }

                        // first treasures docId
                        final treasureDocId =
                            treasureSnapshot.data!.docs.first.id;

                        // its subcollection
                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('treasures')
                              .doc(treasureDocId)
                              .collection('treasureHistory')
                              .doc('rejected')
                              .snapshots(),
                          builder: (context, foundSnapshot) {
                            if (foundSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!foundSnapshot.hasData ||
                                !foundSnapshot.data!.exists) {
                              return const Center(
                                  child: Text("No history found"));
                            }

                            final data = foundSnapshot.data!.data()
                                as Map<String, dynamic>;

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (data['date'] as List).length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 2.h),
                              itemBuilder: (context, index) {
                                final date = (data['date'] as List)[index];
                                final Map details =
                                    (data['details'] as List)[index];
                                final imageUrl =
                                    (data['imageUrls'] as List)[index];
                                final reason = (data['reason'] as List)[index];
                                bool isExpanded = false;
                                return StatefulBuilder(
                                    builder: (context, setInnerState) {
                                  return Container(
                                    width: 100.w,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: const EdgeInsets.all(15),
                                          width: 85.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black87,
                                                spreadRadius: 2,
                                                offset: Offset(2, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                    text: const TextSpan(
                                                        text: "Status: ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        children: [
                                                      TextSpan(
                                                          text: "Declined",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffe70e17)))
                                                    ])),
                                                Image.network(imageUrl ?? "",
                                                    fit: BoxFit.contain),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          setInnerState(() {
                                                            isExpanded =
                                                                !isExpanded;
                                                          });
                                                        },
                                                        child: Text(
                                                            isExpanded
                                                                ? "See Less"
                                                                : "See More",
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xff007a3f),
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationColor:
                                                                    Color(
                                                                        0xff007a3f)))),
                                                    SizedBox(width: 3.w),
                                                    Text(date,
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10))
                                                  ],
                                                )
                                              ]),
                                        ),
                                        SizedBox(height: 4.h),
                                        isExpanded
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                width: 85.w,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black87,
                                                      spreadRadius: 2,
                                                      offset: Offset(2, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Center(
                                                          child: Text(
                                                        "Details of the Item",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      )),
                                                      SizedBox(
                                                        height: 2.h,
                                                      ),
                                                      Text(details['Name'],
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xfffe6929),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      SizedBox(
                                                        height: 2.h,
                                                      ),
                                                      ...details.entries
                                                          .where((entry) =>
                                                              entry.key !=
                                                              'Name') // skips the "name" field
                                                          .map(
                                                              (entry) =>
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        vertical:
                                                                            2.0),
                                                                    child:
                                                                        RichText(
                                                                            text: TextSpan(
                                                                                text: "${entry.key}: ",
                                                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                                                children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "${entry.value}",
                                                                            style:
                                                                                const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                                                                          )
                                                                        ])),
                                                                  )),
                                                    ]))
                                            : const SizedBox(height: 0),
                                        isExpanded
                                            ? SizedBox(height: 4.h)
                                            : const SizedBox(height: 0),
                                        SizedBox(
                                            width: 85.w,
                                            child: Column(children: [
                                              Text("Notice: $reason",
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red)),
                                              const Text(
                                                  "Approval Policy\n  ● Order of review: Submissions are evaluated by timestamp.\n  ● First-qualifying wins: The earliest submission that meets quality standards is approved.\n  ● Quality fallback: If the first submission fails quality, the next submission in timestamp order is reviewed",
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red)),
                                            ])),
                                        SizedBox(
                                          height: 3.h,
                                        )
                                      ],
                                    ),
                                  );
                                });
                              },
                            );
                          },
                        );
                      },
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          width: 100.w,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      received = false;
                                    });
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: received
                                            ? Colors.grey
                                            : const Color(0xfffe6929),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "Not Received",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ))),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      received = true;
                                    });
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 28.w,
                                      decoration: BoxDecoration(
                                        color: received
                                            ? const Color(0xff092e57)
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "Received",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ))),
                            ],
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('treasures')
                              .snapshots(),
                          builder: (context, treasureSnapshot) {
                            if (treasureSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!treasureSnapshot.hasData ||
                                treasureSnapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text("No treasures found"));
                            }

                            // first treasures docId
                            final treasureDocId =
                                treasureSnapshot.data!.docs.first.id;

                            // its subcollection
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('treasures')
                                  .doc(treasureDocId)
                                  .collection('treasureHistory')
                                  .doc('approved')
                                  .snapshots(),
                              builder: (context, foundSnapshot) {
                                if (foundSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!foundSnapshot.hasData ||
                                    !foundSnapshot.data!.exists) {
                                  return const Center(
                                      child: Text("No history found"));
                                }

                                final data = foundSnapshot.data!.data()
                                    as Map<String, dynamic>;

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: (data['date'] as List).length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 2.h),
                                  itemBuilder: (context, index) {
                                    final date = (data['date'] as List)[index];
                                    final Map details =
                                        (data['details'] as List)[index];
                                    final imageUrl =
                                        (data['imageUrls'] as List)[index];
                                    final rewardID =
                                        (data['rewardID'] as List)[index];
                                    bool isExpanded = false;
                                    return StatefulBuilder(
                                        builder: (context, setInnerState) {
                                      return Container(
                                        width: 100.w,
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            SizedBox(height: 4.h),
                                            Container(
                                              padding: const EdgeInsets.all(15),
                                              width: 85.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black87,
                                                    spreadRadius: 2,
                                                    offset: Offset(2, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                        text: const TextSpan(
                                                            text: "Status: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            children: [
                                                          TextSpan(
                                                              text:
                                                                  "Approved by the Admin",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff007a3f)))
                                                        ])),
                                                    SizedBox(height: 1.h),
                                                    RichText(
                                                        text: TextSpan(
                                                            text: "Reward ID: ",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey),
                                                            children: [
                                                          TextSpan(
                                                            text: rewardID,
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .grey),
                                                          )
                                                        ])),
                                                    Image.network(
                                                        imageUrl ?? "",
                                                        fit: BoxFit.contain),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                            onPressed: () {
                                                              setInnerState(() {
                                                                isExpanded =
                                                                    !isExpanded;
                                                              });
                                                            },
                                                            child: Text(
                                                                isExpanded
                                                                    ? "See Less"
                                                                    : "See More",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xff007a3f),
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    decorationColor:
                                                                        Color(
                                                                            0xff007a3f)))),
                                                        SizedBox(width: 3.w),
                                                        Text(date,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10))
                                                      ],
                                                    )
                                                  ]),
                                            ),
                                            SizedBox(height: 4.h),
                                            isExpanded
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    width: 85.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Colors.black87,
                                                          spreadRadius: 2,
                                                          offset: Offset(2, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Center(
                                                              child: Text(
                                                            "Details of the Item",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                          )),
                                                          SizedBox(
                                                            height: 2.h,
                                                          ),
                                                          Text(details['Name'],
                                                              style: const TextStyle(
                                                                  color: Color(
                                                                      0xfffe6929),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(
                                                            height: 2.h,
                                                          ),
                                                          ...details.entries
                                                              .where((entry) =>
                                                                  entry.key !=
                                                                  'Name') // skips the "name" field
                                                              .map(
                                                                  (entry) =>
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: RichText(
                                                                            text: TextSpan(text: "${entry.key}: ", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "${entry.value}",
                                                                            style:
                                                                                const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                                                                          )
                                                                        ])),
                                                                      )),
                                                        ]))
                                                : const SizedBox(height: 0),
                                            SizedBox(height: 4.h),
                                            received
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    width: 85.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Colors.black87,
                                                          spreadRadius: 2,
                                                          offset: Offset(2, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            "Upload Appreciation Post or Video",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2.h,
                                                          ),
                                                          const Text(
                                                              "Upload Video",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xfffe6929),
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      Color(
                                                                          0xfffe6929),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(
                                                            height: 2.h,
                                                          ),
                                                          ValueListenableBuilder<
                                                                  Uint8List?>(
                                                              valueListenable:
                                                                  selectedFile,
                                                              builder: (context,
                                                                  file, child) {
                                                                if (file ==
                                                                    null) {
                                                                  return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        pickVideo(
                                                                            context);
                                                                      },
                                                                      child: const Icon(
                                                                          Icons
                                                                              .cloud_upload_sharp,
                                                                          size:
                                                                              48,
                                                                          color:
                                                                              Colors.black));
                                                                } else {
                                                                  return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        pickVideo(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            200,
                                                                        width:
                                                                            300,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.black12,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons.play_circle_fill,
                                                                            size:
                                                                                64,
                                                                            color:
                                                                                Colors.black54,
                                                                          ),
                                                                        ),
                                                                      ));
                                                                }
                                                              }),
                                                          SizedBox(
                                                            height: 2.h,
                                                          ),
                                                          const Text(
                                                              "Upload Link to appreciation post Here:",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xfffe6929),
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      Color(
                                                                          0xfffe6929),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(height: 1.h),
                                                          SizedBox(
                                                              height: 50,
                                                              child:
                                                                  uploadLinkField),
                                                        ]))
                                                : const SizedBox(height: 0),
                                            received
                                                ? SizedBox(height: 4.h)
                                                : const SizedBox(height: 0),
                                            received
                                                ? ValueListenableBuilder<bool>(
                                                    valueListenable: submit,
                                                    builder: (context, value,
                                                        child) {
                                                      return ElevatedButton(
                                                        onPressed: !value
                                                            ? null
                                                            : () {
                                                                submit.value =
                                                                    !submit
                                                                        .value;
                                                                uploadVideoAndStoreData(
                                                                    fileBytes:
                                                                        selectedFile
                                                                            .value!,
                                                                    fileName:
                                                                        fileName
                                                                            .value,
                                                                    cloudName:
                                                                        cloudName,
                                                                    uploadPreset:
                                                                        uploadPreset);
                                                              },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                          backgroundColor:
                                                              const Color(
                                                                  0xff092e57),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                            "Submit Appreciation",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white)),
                                                      );
                                                    })
                                                : const SizedBox(height: 0),
                                            received
                                                ? SizedBox(height: 3.h)
                                                : const SizedBox(height: 0),
                                            !received
                                                ? Container(
                                                    width: 85.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                              "Delivery Notice (Approved but Item Not Received)",
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white)),
                                                          RichText(
                                                            text: const TextSpan(
                                                                text:
                                                                    "Status: ",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .white),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        "Your task was approved and your prize is being prepared for shipping.",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ]),
                                                          ),
                                                          SizedBox(height: 2.h),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                SizedBox(
                                                                    width: 3.w),
                                                                const Text("●",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white)),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                RichText(
                                                                  text: const TextSpan(
                                                                      text: "Dispatch Window: ",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Items are typically sent within\n7 days of approval.",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        )
                                                                      ]),
                                                                )
                                                              ]),
                                                          SizedBox(height: 1.h),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                SizedBox(
                                                                    width: 3.w),
                                                                const Text("●",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white)),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                RichText(
                                                                  text: const TextSpan(
                                                                      text: "Before 7 days: ",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              " No action needed. Please allow\nthe full dispatch window.",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        )
                                                                      ]),
                                                                )
                                                              ]),
                                                          SizedBox(height: 1.h),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                SizedBox(
                                                                    width: 3.w),
                                                                const Text("●",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white)),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                RichText(
                                                                  text: const TextSpan(
                                                                      text: "After 7 days (Day 8): ",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "If your item is not marked\n“Sent”, Click on Send Compliant →would land\non an email complaint@nanoinfluencer.com\nand include your reward ID.",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        )
                                                                      ]),
                                                                )
                                                              ]),
                                                          SizedBox(height: 2.h),
                                                          RichText(
                                                            text: const TextSpan(
                                                                text: "How we’ll contact you: ",
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        "We’ll use the email and phone number on your CW profile to confirm your delivery location. Keep them up to date. If we can’t reach you within 48 hours, the prize may go to a backup winner.",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                                  )
                                                                ]),
                                                          )
                                                        ]))
                                                : Container(
                                                    width: 85.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                              "Appreciation Requirement",
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      Colors
                                                                          .white,
                                                                  color: Colors
                                                                      .white)),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                SizedBox(
                                                                    width: 3.w),
                                                                const Text("●",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white)),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                const Text(
                                                                    "Share a short thank-you video (preferred) or\nphoto post with the item.",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .white,
                                                                    ))
                                                              ]),
                                                          SizedBox(height: 1.h),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                SizedBox(
                                                                    width: 3.w),
                                                                const Text("●",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white)),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                const Text(
                                                                    "Tag @ClickWorkers in the post.",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .white,
                                                                    ))
                                                              ]),
                                                          SizedBox(height: 1.h),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                SizedBox(
                                                                    width: 3.w),
                                                                const Text("●",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white)),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                const Text(
                                                                    "Make it clear, well-lit, and presentable.",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .white,
                                                                    ))
                                                              ]),
                                                          SizedBox(height: 1.h),
                                                          Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                SizedBox(
                                                                    width: 3.w),
                                                                const Text("●",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            8,
                                                                        color: Colors
                                                                            .white)),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                const Text(
                                                                    "If you don’t share appreciation, you won’t be\neligible for the next Treasure Hunt.",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .white,
                                                                    ))
                                                              ]),
                                                        ])),
                                            SizedBox(height: 3.h),
                                            received
                                                ? Container(
                                                    width: 85.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xffbb0000),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: const Text(
                                                        "If you haven’t received your item but it already appears in the ‘Received’ section, click on ‘Send Complaint’ to quickly send an email. Make sure you have your Reward ID handy, as it will be required to file and process the issue.",
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.white,
                                                        )))
                                                : const SizedBox(height: 0),
                                            received
                                                ? SizedBox(height: 3.h)
                                                : const SizedBox(height: 0),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final Uri emailUri = Uri(
                                                  scheme: 'mailto',
                                                  path:
                                                      'complaint@nano-influencers.com',
                                                  query:
                                                      'subject=Treasure Complaint&body=I wanted to reach out to complain about', // optional
                                                );

                                                if (await canLaunchUrl(
                                                    emailUri)) {
                                                  await launchUrl(emailUri);
                                                } else {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Could not open Email App")),
                                                    );
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                backgroundColor:
                                                    const Color(0xffbb0000),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                  "Send a Complaint",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                            SizedBox(height: 3.h),
                                          ],
                                        ),
                                      );
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
        ])));
  }
}

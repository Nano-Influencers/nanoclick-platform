import 'package:click_workers/Mobile/KYC/supporting_documents.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
//import 'package:flutter/cupertino.dart';

class SMCheck extends StatefulWidget {
  const SMCheck({super.key});

  @override
  State<SMCheck> createState() => _SMCheckState();
}

class _SMCheckState extends State<SMCheck> {
  bool isChecked = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  bool isChecked6 = false;
  bool isChecked7 = false;
  bool isChecked8 = false;
  bool isChecked9 = false;
  bool isChecked10 = false;
  bool isChecked11 = false;
  bool isChecked12 = false;
  bool isChecked13 = false;
  bool isChecked14 = false;
  bool isChecked15 = false;
  bool isChecked16 = false;
  bool isChecked17 = false;
  bool isChecked18 = false;
  bool isChecked19 = false;
  bool isChecked20 = false;
  bool isChecked21 = false;
  bool isChecked22 = false;
  bool isChecked23 = false;
  bool isChecked24 = false;
  bool isChecked25 = false;
  bool isChecked26 = false;
  bool isChecked27 = false;
  bool isChecked28 = false;
  String verifyVal = "0";
  String profileVal = "0";
  String changeVal = "0";
  String pictureVal = "0";
  String nameVal = "0";
  String selectedValue = "Select first most active platform";
  String selectedValue2 = "Select second most active platform";
  List contentsInteractedWith = [];
  List contentsPosted = [];

  List<String> platforms1 = [
    "Select first most active platform",
    'Instagram',
    'TikTok',
    'Twitter (X)',
    'Facebook',
    'YouTube',
    'LinkedIn',
    'Snapchat',
    'Threads',
  ];

  List<String> platforms2 = [
    "Select second most active platform",
    'Instagram',
    'TikTok',
    'Twitter (X)',
    'Facebook',
    'YouTube',
    'LinkedIn',
    'Snapchat',
    'Threads',
  ];

  Future<void> updateKycProgress(double value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("No user logged in");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.set(
      {
        "kycProgress": value,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> createSmCheck(
      List contentsInteractedWith, List contentsPosted) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('kyc').doc(uid).set({
        "smCheck": {
          "chatsWithAccount": verifyVal, // String
          "contentsInteractedWith": contentsInteractedWith, // int
          "contentsPosted": contentsPosted, // DateTime
          "profilePicture": profileVal, // String
          "changedDpIn3Months": changeVal, // String
          "realNameOnProfile": nameVal, // bool
          "realPicOnProfile": pictureVal,
          "firstMostActivePlatform": selectedValue,
          "secondMostActivePlatform": selectedValue2,
        }
      }, SetOptions(merge: true));
    } catch (e) {
    if(mounted) { ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating KYC document: $e"),
          duration: const Duration(seconds: 2), // how long it shows
        ),
      );}
    }
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
            child: Text('Kyc Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xffeeeeee),
        body: SingleChildScrollView(
            child: Center(
                child: SizedBox(
                    width: 90.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 2.h,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    width: 30.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color(0xffd1d5db)),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.account_circle,
                                            color: Color(0xff6b7280)),
                                        Text("Personal",
                                            style: TextStyle(
                                                color: Color(0xff6b7280),
                                                fontSize: 12))
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    width: 30.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color(0xffd1d5db)),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.chat,
                                            color: Color(0xff6b7280), size: 22),
                                        Text("Social Media",
                                            style: TextStyle(
                                                color: Color(0xff6b7280),
                                                fontSize: 12))
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    width: 30.w,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffff6533),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.chat,
                                            color: Colors.white, size: 22),
                                        Text("SM Check",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12))
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    width: 30.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color(0xffd1d5db)),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.chat,
                                            color: Color(0xff6b7280), size: 22),
                                        Text("Verify Docs",
                                            style: TextStyle(
                                                color: Color(0xff6b7280),
                                                fontSize: 12))
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                            width: 90.w,
                            child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                color: Colors.white,
                                child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Social Media Check",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 3.h),
                                        const Text(
                                            "Do You Currently Chat With This Account?",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 2.h),
                                        Row(children: [
                                          Radio(
                                              value: "Yes",
                                              groupValue: verifyVal,
                                              activeColor: Colors.black,
                                              onChanged: (val) {
                                                setState(() {
                                                  verifyVal = "Yes";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("Yes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8.w),
                                          Radio(
                                              value: "No",
                                              activeColor: Colors.black,
                                              groupValue: verifyVal,
                                              onChanged: (val) {
                                                setState(() {
                                                  verifyVal = "No";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("No",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                        SizedBox(height: 2.h),
                                        const Text(
                                            "What Type of Content Do You Like to Interact With?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 2.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked = newValue!;
                                                      if (isChecked == true) {
                                                        contentsInteractedWith
                                                            .add("Food");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove("Food");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Food",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                                width: 38.w,
                                                child: Row(children: [
                                                  Checkbox(
                                                    activeColor: Colors.black,
                                                    value: isChecked2,
                                                    onChanged:
                                                        (bool? newValue) {
                                                      setState(() {
                                                        isChecked2 = newValue!;
                                                        if (isChecked2 ==
                                                            true) {
                                                          contentsInteractedWith
                                                              .add(
                                                                  "Construction");
                                                        } else {
                                                          contentsInteractedWith
                                                              .remove(
                                                                  "Construction");
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  const Text("Construction",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ])),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked3,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked3 = newValue!;
                                                      if (isChecked == true) {
                                                        contentsInteractedWith
                                                            .add("Beauty");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove("Beauty");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Beauty",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked4,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked4 = newValue!;
                                                      if (isChecked4 == true) {
                                                        contentsInteractedWith
                                                            .add("Technology");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Technology");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Technology",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked5,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked5 = newValue!;
                                                      if (isChecked5 == true) {
                                                        contentsInteractedWith
                                                            .add("Finance");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove("Finance");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Finance",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked6,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked6 = newValue!;
                                                      if (isChecked6 == true) {
                                                        contentsInteractedWith
                                                            .add("Healthcare");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Healthcare");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Healthcare",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked7,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked7 = newValue!;
                                                      if (isChecked7 == true) {
                                                        contentsInteractedWith
                                                            .add("Lifestyle");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Lifestyle");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Lifestyle",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked8,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked8 = newValue!;
                                                      if (isChecked8 == true) {
                                                        contentsInteractedWith
                                                            .add(
                                                                "Entertainment");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Entertainment");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Entertainment",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked11,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked11 = newValue!;
                                                      if (isChecked11 == true) {
                                                        contentsInteractedWith
                                                            .add(
                                                                "Social Impact");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Social Impact");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Social Impact",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked12,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked12 = newValue!;
                                                      if (isChecked12 == true) {
                                                        contentsInteractedWith
                                                            .add("Real Estate");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Real Estate");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Real Estate",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked13,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked13 = newValue!;
                                                      if (isChecked13 == true) {
                                                        contentsInteractedWith.add(
                                                            "Professional Services");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Professional Services");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text(
                                                    "Professional\nServices",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked14,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked14 = newValue!;
                                                      if (isChecked14 == true) {
                                                        contentsInteractedWith.add(
                                                            "Media & Publishing");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove(
                                                                "Media & Publishing");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text(
                                                    "Media &\nPublishing",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked15,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked15 = newValue!;
                                                      if (isChecked15 == true) {
                                                        contentsInteractedWith
                                                            .add("Fashion");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove("Fashion");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Fashion",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked16,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked16 = newValue!;
                                                      if (isChecked16 == true) {
                                                        contentsInteractedWith
                                                            .add("Personal");
                                                      } else {
                                                        contentsInteractedWith
                                                            .remove("Personal");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Personal",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        const Text(
                                            "What Type of Content Do You Post?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 2.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked9,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked9 = newValue!;
                                                      if (isChecked9 == true) {
                                                        contentsPosted
                                                            .add("Food");
                                                      } else {
                                                        contentsPosted
                                                            .remove("Food");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Food",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                                width: 38.w,
                                                child: Row(children: [
                                                  Checkbox(
                                                    activeColor: Colors.black,
                                                    value: isChecked10,
                                                    onChanged:
                                                        (bool? newValue) {
                                                      setState(() {
                                                        isChecked10 = newValue!;
                                                        if (isChecked10 ==
                                                            true) {
                                                          contentsPosted.add(
                                                              "Construction");
                                                        } else {
                                                          contentsPosted.remove(
                                                              "Construction");
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  const Text("Construction",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ])),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked17,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked17 = newValue!;
                                                      if (isChecked17 == true) {
                                                        contentsPosted
                                                            .add("Beauty");
                                                      } else {
                                                        contentsPosted
                                                            .remove("Beauty");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Beauty",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked18,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked18 = newValue!;
                                                      if (isChecked18 == true) {
                                                        contentsPosted
                                                            .add("Technology");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Technology");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Technology",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked19,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked19 = newValue!;
                                                      if (isChecked19 == true) {
                                                        contentsPosted
                                                            .add("Finance");
                                                      } else {
                                                        contentsPosted
                                                            .remove("Finance");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Finance",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked20,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked20 = newValue!;
                                                      if (isChecked20 == true) {
                                                        contentsPosted
                                                            .add("Healthcare");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Healthcare");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Healthcare",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked21,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked21 = newValue!;
                                                      if (isChecked21 == true) {
                                                        contentsPosted
                                                            .add("Lifestyle");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Lifestyle");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Lifestyle",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked22,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked22 = newValue!;
                                                      if (isChecked22 == true) {
                                                        contentsPosted.add(
                                                            "Entertainment");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Entertainment");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Entertainment",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked23,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked23 = newValue!;
                                                      if (isChecked23 == true) {
                                                        contentsPosted.add(
                                                            "Social Impact");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Social Impact");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Social Impact",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked24,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked24 = newValue!;
                                                      if (isChecked24 == true) {
                                                        contentsPosted
                                                            .add("Real Estate");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Real Estate");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Real Estate",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked25,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked25 = newValue!;
                                                      if (isChecked25 == true) {
                                                        contentsPosted.add(
                                                            "Professional Services");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Professinal Services");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text(
                                                    "Professional\nServices",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked26,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked26 = newValue!;
                                                      if (isChecked26 == true) {
                                                        contentsPosted.add(
                                                            "Media & Publishing");
                                                      } else {
                                                        contentsPosted.remove(
                                                            "Media & Publishing");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text(
                                                    "Media &\nPublishing",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked27,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked27 = newValue!;
                                                      if (isChecked27 == true) {
                                                        contentsPosted
                                                            .add("Fashion");
                                                      } else {
                                                        contentsPosted
                                                            .remove("Fashion");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Fashion",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                            SizedBox(
                                              width: 38.w,
                                              child: Row(children: [
                                                Checkbox(
                                                  activeColor: Colors.black,
                                                  value: isChecked16,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      isChecked16 = newValue!;
                                                      if (isChecked9 == true) {
                                                        contentsPosted
                                                            .add("Personal");
                                                      } else {
                                                        contentsPosted
                                                            .remove("Personal");
                                                      }
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 1.w),
                                                const Text("Personal",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3.h),
                                        const Text(
                                            "Does Your Account Have a Profile Picture?",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        Row(children: [
                                          Radio(
                                              value: "Yes",
                                              groupValue: profileVal,
                                              activeColor: Colors.black,
                                              onChanged: (val) {
                                                setState(() {
                                                  profileVal = "Yes";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("Yes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8.w),
                                          Radio(
                                              value: "No",
                                              activeColor: Colors.black,
                                              groupValue: profileVal,
                                              onChanged: (val) {
                                                setState(() {
                                                  profileVal = "No";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("No",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                        SizedBox(height: 2.h),
                                        const Text(
                                            "Have You Changed Your Profile Picture in the Last 3 Months?",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        Row(children: [
                                          Radio(
                                              value: "Yes",
                                              groupValue: changeVal,
                                              activeColor: Colors.black,
                                              onChanged: (val) {
                                                setState(() {
                                                  changeVal = "Yes";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("Yes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8.w),
                                          Radio(
                                              value: "No",
                                              activeColor: Colors.black,
                                              groupValue: changeVal,
                                              onChanged: (val) {
                                                setState(() {
                                                  changeVal = "No";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("No",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                        SizedBox(height: 2.h),
                                        const Text(
                                            "Do You Use Your Real Name on Your Profile?",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        Row(children: [
                                          Radio(
                                              value: "Yes",
                                              groupValue: nameVal,
                                              activeColor: Colors.black,
                                              onChanged: (val) {
                                                setState(() {
                                                  nameVal = "Yes";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("Yes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8.w),
                                          Radio(
                                              value: "No",
                                              activeColor: Colors.black,
                                              groupValue: nameVal,
                                              onChanged: (val) {
                                                setState(() {
                                                  nameVal = "No";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("No",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                        SizedBox(height: 2.h),
                                        const Text(
                                            "Do You Use Your Real Picture on Your Profile?",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        Row(children: [
                                          Radio(
                                              value: "Yes",
                                              groupValue: pictureVal,
                                              activeColor: Colors.black,
                                              onChanged: (val) {
                                                setState(() {
                                                  pictureVal = "Yes";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("Yes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8.w),
                                          Radio(
                                              value: "No",
                                              activeColor: Colors.black,
                                              groupValue: pictureVal,
                                              onChanged: (val) {
                                                setState(() {
                                                  pictureVal = "No";
                                                });
                                              }),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          const Text("No",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ]),
                                        SizedBox(height: 4.h),
                                        const Text(
                                            "Which of the platforms selected are your 2 most active social media accounts?",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            )),
                                        SizedBox(height: 0.5.h),
                                        SizedBox(
                                          height: 8.h,
                                          width: 90.w,
                                          child: DropdownButtonFormField(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 2),
                                              ),
                                            ),
                                            value: selectedValue,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down),
                                            items: platforms1
                                                .map((option) =>
                                                    DropdownMenuItem(
                                                      value: option,
                                                      child: Text(option,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xff6b7280))),
                                                    ))
                                                .toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedValue = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        SizedBox(
                                          height: 8.h,
                                          width: 90.w,
                                          child: DropdownButtonFormField(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 2),
                                              ),
                                            ),
                                            value: selectedValue2,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down),
                                            items: platforms2
                                                .map((option) =>
                                                    DropdownMenuItem(
                                                      value: option,
                                                      child: Text(option,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xff6b7280))),
                                                    ))
                                                .toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedValue2 = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                      ],
                                    )))),
                        SizedBox(height: 2.h),
                        SizedBox(
                            width: 90.w,
                            height: 8.h,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  if (isChecked ||
                                      isChecked2 ||
                                      isChecked3 ||
                                      isChecked4 ||
                                      isChecked5 ||
                                      isChecked6 ||
                                      isChecked7 ||
                                      isChecked8 ||
                                      isChecked11 ||
                                      isChecked12 ||
                                      isChecked13 ||
                                      isChecked14 ||
                                      isChecked15 ||
                                      isChecked16) {
                                    if (isChecked9 ||
                                        isChecked10 ||
                                        isChecked17 ||
                                        isChecked18 ||
                                        isChecked19 ||
                                        isChecked20 ||
                                        isChecked21 ||
                                        isChecked22 ||
                                        isChecked23 ||
                                        isChecked24 ||
                                        isChecked25 ||
                                        isChecked26 ||
                                        isChecked27 ||
                                        isChecked28) {
                                      if (verifyVal != "0" &&
                                          nameVal != "0" &&
                                          profileVal != "0" &&
                                          pictureVal != "0" &&
                                          changeVal != "0") {
                                        if (selectedValue !=
                                                "Select first most active platform" &&
                                            selectedValue2 !=
                                                "Select second most active platform") {
                                          await createSmCheck(
                                              contentsInteractedWith,
                                              contentsPosted);
                                          await updateKycProgress(0.7);
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SupportingDocuments()),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Please answer all questions"),
                                              duration: Duration(
                                                  seconds:
                                                      2), // how long it shows
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Please answer all questions"),
                                            duration: Duration(
                                                seconds:
                                                    2), // how long it shows
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Please select contents you post"),
                                          duration: Duration(
                                              seconds: 2), // how long it shows
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please select contents you interact with "),
                                        duration: Duration(
                                            seconds: 2), // how long it shows
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Continue"))),
                        SizedBox(height: 3.h),
                      ],
                    )))));
  }
}

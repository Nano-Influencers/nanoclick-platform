import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_check.dart';
//import 'package:flutter/cupertino.dart';

class SMAccountVerification extends StatefulWidget {
  const SMAccountVerification({super.key});

  @override
  State<SMAccountVerification> createState() => _SMAccountVerificationState();
}

class _SMAccountVerificationState extends State<SMAccountVerification> {
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
  String selectedValue = "Select Option";
  String selectedValue2 = "Select Option";
  String selectedValue3 = "Select Option";
  String selectedValue4 = "Select Option";
  String selectedValue5 = "Select Option";
  String selectedValue6 = "Select Option";
  String selectedValue7 = "Select Option";
  String selectedValue8 = "Select Option";
  String selectedValue9 = "Select Option";
  String selectedValue10 = "Select Option";
  String selectedValue11 = "Select Option";
  String selectedValue12 = "Select Option";
  String selectedValue13 = "Select Option";
  String selectedValue14 = "Select Option";
  String verifyVal = "0";
  List platforms = [];
  List categories = [];

  TextEditingController otherEditingController = TextEditingController();
  TextEditingController whatsAppEditingController = TextEditingController();
  TextEditingController instagramEditingController = TextEditingController();
  final dateEditingController = TextEditingController(
      text:
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}");

  // form key
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepOrange, // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // OK & Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      setState(() {
        dateEditingController.text = formattedDate;
      });
    }
  }

  List<String> duration = [
    "Select Option",
    'Less than 1 month',
    '1–3 months',
    '4–6 months',
    '7–12 months',
    '1–2 years',
    'Over 2 years',
  ];

  List<String> frequency = [
    "Select Option",
    'Daily',
    'Weekly',
    'Bi-weekly',
    'Monthly',
    'Occasionally',
    'Rarely',
  ];

  List<String> quantity = [
    "Select Option",
    'None',
    '1–2',
    '3–5',
    '6–10',
    '11–20',
    'More than 20',
  ];

  List<String> engagement = [
    "Select Option",
    'Less than 100',
    '100 – 500',
    '501 – 1,000',
    '1,001 – 5,000',
    '5,001 – 10,000',
    'Over 10,000',
  ];

  List<String> followerCategories = [
    "Select Option",
    'Friends & Family',
    'General Audience',
    'Niche Community',
    'Professionals',
    'Local Followers',
    'International Audience',
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

  Future<void> createKycSmDetails(List categories, List platforms) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('kyc').doc(uid).set({
        "smDetails": {
          "socialPlatforms": platforms, // String
          "otherPlatform": otherEditingController.text, // int
          "whatsAppLink": whatsAppEditingController.text, // DateTime
          "whatsAppAge": selectedValue, // String
          "whatsAppPostFrequency": selectedValue2, // String
          "whatsAppGroupsNum": selectedValue3, // bool
          "whatsAppContactNum": selectedValue4,
          "whatsAppGroupsActive": selectedValue5,
          "whatsAppAverageStatusViews": selectedValue6,
          "instagramAge": selectedValue7,
          "instagramPostFrequency": selectedValue8,
          "instagramPostCount": selectedValue9,
          "instagramLastPost": dateEditingController.text,
          "instagramFollowerCount": selectedValue10,
          "instagramFollowingCount": selectedValue11,
          "instagramHighestEngagement": selectedValue12,
          "instagramVerfied": verifyVal,
          "instagramFollowerCategory": selectedValue13,
          "instagramFollowerIndustryCategory":
              categories, // Firestore timestamp
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
  void dispose() {
    dateEditingController.dispose();
    otherEditingController.dispose();
    whatsAppEditingController.dispose();
    instagramEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherField = TextFormField(
      controller: otherEditingController,
      decoration: InputDecoration(
        hintText: 'Others (Specify)',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xff6b7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Fully rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );

    final whatsAppField = SizedBox(
      width: 66.w,
      child: TextFormField(
        controller: whatsAppEditingController,
        validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
        decoration: InputDecoration(
          hintText: 'WhatsApp Link',
          hintStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xff6b7280),
              fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Fully rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );

    final instagramField = SizedBox(
      width: 66.w,
      child: TextFormField(
        controller: instagramEditingController,
        validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
        decoration: InputDecoration(
          hintText: 'Instagram Profile Link',
          hintStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xff6b7280),
              fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Fully rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );

    final dateField = GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: dateEditingController,
          validator: (val) => val!.isEmpty ? 'Fill out this field' : null,
          readOnly: true, // prevent manua
          decoration: InputDecoration(
            suffix: const Icon(Icons.calendar_today, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
          child: Text('Kyc Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xffeeeeee),
      body: SingleChildScrollView(
          child: Center(
        child: Form(
          key: _formKey,
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: 30.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xffd1d5db)),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.account_circle,
                                    color: Color(0xff6b7280)),
                                Text("Personal",
                                    style: TextStyle(
                                        color: Color(0xff6b7280), fontSize: 12))
                              ],
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: 30.w,
                            decoration: BoxDecoration(
                                color: const Color(0xffff6533),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.chat, color: Colors.white, size: 22),
                                Text("Social Media",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12))
                              ],
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: 30.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xffd1d5db)),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.chat,
                                    color: Color(0xff6b7280), size: 22),
                                Text("SM Check",
                                    style: TextStyle(
                                        color: Color(0xff6b7280), fontSize: 12))
                              ],
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: 30.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xffd1d5db)),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.chat,
                                    color: Color(0xff6b7280), size: 22),
                                Text("Verify Docs",
                                    style: TextStyle(
                                        color: Color(0xff6b7280), fontSize: 12))
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
                        elevation: 6, // adds shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Social Media Account Verification",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 3.h),
                                const Text("Social Media Platforms You Use",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
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
                                                platforms.add("Facebook");
                                              } else {
                                                platforms.remove("Facebook");
                                              }
                                            });
                                          },
                                        ),
                                        Image.asset("assets/Facebook.png",
                                            color: Colors.blue[900],
                                            scale: 1.2),
                                        SizedBox(width: 1.w),
                                        const Text("Facebook",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
                                      ]),
                                    ),
                                    SizedBox(
                                        width: 38.w,
                                        child: Row(children: [
                                          Checkbox(
                                            activeColor: Colors.black,
                                            value: isChecked2,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                if (isChecked2 == true) {
                                                  platforms.add("X");
                                                } else {
                                                  platforms.remove("X");
                                                }
                                                isChecked2 = newValue!;
                                              });
                                            },
                                          ),
                                          Image.asset("assets/X.png",
                                              color: Colors.black, scale: 1.2),
                                          SizedBox(width: 1.w),
                                          const Text("Twitter",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
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
                                              if (isChecked3 == true) {
                                                platforms.add("Instagram");
                                              } else {
                                                platforms.remove("Instagram");
                                              }
                                            });
                                          },
                                        ),
                                        Image.asset("assets/insta.png",
                                            scale: 1.5),
                                        SizedBox(width: 1.w),
                                        const Text("Instagram",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
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
                                                platforms.add("TikTok");
                                              } else {
                                                platforms.remove("TikTok");
                                              }
                                            });
                                          },
                                        ),
                                        Image.asset("assets/tiktok.png",
                                            color: Colors.black, scale: 1.2),
                                        SizedBox(width: 1.w),
                                        const Text("Tik Tok",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
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
                                                platforms.add("WhatsApp");
                                              } else {
                                                platforms.remove("WhatsApp");
                                              }
                                            });
                                          },
                                        ),
                                        Image.asset("assets/whatsapp.png",
                                            scale: 1.5),
                                        SizedBox(width: 1.w),
                                        const Text("WhatsApp",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
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
                                                platforms.add("LinkedIn");
                                              } else {
                                                platforms.remove("LinkedIn");
                                              }
                                            });
                                          },
                                        ),
                                        Image.asset("assets/LinkedIn.png",
                                            color: Colors.blue[600],
                                            scale: 1.2),
                                        SizedBox(width: 1.w),
                                        const Text("LinkedIn",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
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
                                                platforms.add("YouTube");
                                              } else {
                                                platforms.remove("YouTube");
                                              }
                                            });
                                          },
                                        ),
                                        Image.asset("assets/Youtube.png",
                                            color: Colors.red[600], scale: 1.2),
                                        SizedBox(width: 1.w),
                                        const Text("YouTube",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
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
                                                platforms.add("Telegram");
                                              } else {
                                                platforms.remove("Telegram");
                                              }
                                            });
                                          },
                                        ),
                                        Image.asset("assets/telegram.png",
                                            scale: 1.5),
                                        SizedBox(width: 1.w),
                                        const Text("Telegram",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))
                                      ]),
                                    ),
                                  ],
                                ),
                                Row(children: [
                                  Checkbox(
                                    activeColor: Colors.black,
                                    value: isChecked9,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked9 = newValue!;
                                        if (isChecked9 == true) {
                                          platforms.add("Snapchat");
                                        } else {
                                          platforms.remove("Snapchat");
                                        }
                                      });
                                    },
                                  ),
                                  Image.asset("assets/snap.png", scale: 1.1),
                                  SizedBox(width: 1.w),
                                  const Text("Snapchat",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
                                ]),
                                SizedBox(height: 2.h),
                                otherField,
                                SizedBox(height: 2.h),
                                const Text(
                                    "Provide Links to Your Social Media Accounts (Minimum required: 2, WhatsApp is compulsory with at least 1 others)",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                SizedBox(height: 2.h),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: const Color(0x6fa7eac1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Image.asset(
                                            "assets/whatsapp.png",
                                            scale: 1.5),
                                      ),
                                      SizedBox(width: 1.w),
                                      whatsAppField,
                                    ]),
                                SizedBox(height: 2.h),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: const Color(0x74f4c1ba),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Image.asset("assets/insta.png",
                                            scale: 1.5),
                                      ),
                                      SizedBox(width: 2.w),
                                      instagramField,
                                    ]),
                              ],
                            )))),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("WhatsApp Details",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 3.h),
                                  const Text(
                                      "How Old Is Your WhatsApp Account?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: duration
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "How Often Do You Post Status Updates?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue2,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: frequency
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
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
                                  const Text(
                                      "How Many WhatsApp Groups Are You In?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue3,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: quantity
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue3 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text("How Many Contacts Do You Have?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue4,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: quantity
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue4 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "How Many Groups Are You Active In?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue5,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: quantity
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue5 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "How Many People View Your Status On Average?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue6,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: quantity
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue6 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ])))),
                SizedBox(height: 2.h),
                SizedBox(
                    width: 90.w,
                    child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Instagram Details",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 3.h),
                                  const Text(
                                      "How Old Is Your Instagram Account?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue7,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: duration
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue7 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "How Often Do You Post on Instagram?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue8,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: frequency
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue8 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "How Many Posts Do You Currently Have on Your Account?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue9,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: quantity
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue9 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text("When Was Your Last Post?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      )),
                                  SizedBox(height: 0.5.h),
                                  dateField,
                                  SizedBox(height: 2.h),
                                  const Text("How Many Followers Do You Have?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue10,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: quantity
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue10 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "How Many People Are You Following?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue11,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: quantity
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue11 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "What Is Your Highest Engagement on Your Best Performing Post?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue12,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: engagement
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue12 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "Is Your Account Verified on Instagram?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      )),
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
                                      "How Would You Categorize Your Followers?",
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
                                              color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      value: selectedValue13,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: followerCategories
                                          .map((option) => DropdownMenuItem(
                                                value: option,
                                                child: Text(option,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xff6b7280))),
                                              ))
                                          .toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedValue13 = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  const Text(
                                      "How Would You Categorize Your Followers in Terms of the Industry They Belong?",
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
                                            value: isChecked10,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                isChecked10 = newValue!;
                                                if (isChecked10 == true) {
                                                  categories
                                                      .add("Construction");
                                                } else {
                                                  categories
                                                      .remove("Construction");
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 1.w),
                                          const Text("Construction",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                      ),
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
                                                    categories.add("Food");
                                                  } else {
                                                    categories.remove("Food");
                                                  }
                                                });
                                              },
                                            ),
                                            SizedBox(width: 1.w),
                                            const Text("Food",
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
                                            value: isChecked12,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                isChecked12 = newValue!;
                                                if (isChecked12 == true) {
                                                  categories.add("Beauty");
                                                } else {
                                                  categories.remove("Beauty");
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 1.w),
                                          const Text("Beauty",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                      ),
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
                                                  categories.add("Technology");
                                                } else {
                                                  categories
                                                      .remove("Technology");
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 1.w),
                                          const Text("Technology",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
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
                                            value: isChecked14,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                isChecked14 = newValue!;
                                                if (isChecked14 == true) {
                                                  categories.add("Finance");
                                                } else {
                                                  categories.remove("Finance");
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 1.w),
                                          const Text("Finance",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                      ),
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
                                                  categories.add("Healthcare");
                                                } else {
                                                  categories
                                                      .remove("Healthcare");
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 1.w),
                                          const Text("Healthcare",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
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
                                            value: isChecked16,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                isChecked16 = newValue!;
                                                if (isChecked16 == true) {
                                                  categories.add("Lifestyle");
                                                } else {
                                                  categories
                                                      .remove("Lifestyle");
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 1.w),
                                          const Text("Lifestyle",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                      ),
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
                                                  categories
                                                      .add("Entertainment");
                                                } else {
                                                  categories
                                                      .remove("Entertainment");
                                                }
                                              });
                                            },
                                          ),
                                          SizedBox(width: 1.w),
                                          const Text("Entertainment",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ]),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                ])))),
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
                          if (_formKey.currentState!.validate()) {
                            if (isChecked ||
                                isChecked2 ||
                                isChecked3 ||
                                isChecked4 ||
                                isChecked5 ||
                                isChecked6 ||
                                isChecked7 ||
                                isChecked8 ||
                                isChecked9) {
                              if (selectedValue != "Select Option" &&
                                  selectedValue2 != "Select Option" &&
                                  selectedValue3 != "Select Option" &&
                                  selectedValue4 != "Select Option" &&
                                  selectedValue5 != "Select Option" &&
                                  selectedValue6 != "Select Option" &&
                                  selectedValue7 != "Select Option" &&
                                  selectedValue8 != "Select Option" &&
                                  selectedValue9 != "Select Option" &&
                                  selectedValue10 != "Select Option" &&
                                  selectedValue11 != "Select Option" &&
                                  selectedValue12 != "Select Option" &&
                                  selectedValue13 != "Select Option") {
                                if (verifyVal != "0") {
                                  if (isChecked10 ||
                                      isChecked11 ||
                                      isChecked12 ||
                                      isChecked13 ||
                                      isChecked14 ||
                                      isChecked15 ||
                                      isChecked16 ||
                                      isChecked17) {
                                    await createKycSmDetails(
                                        categories, platforms);
                                    await updateKycProgress(0.5);
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SMCheck()),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please select follower categories"),
                                        duration: Duration(
                                            seconds: 2), // how long it shows
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Please indicate if account is verified"),
                                      duration: Duration(
                                          seconds: 2), // how long it shows
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Please fill all Social Media Details"),
                                    duration: Duration(
                                        seconds: 2), // how long it shows
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please select  Social Platforms"),
                                  duration:
                                      Duration(seconds: 2), // how long it shows
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Continue"))),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

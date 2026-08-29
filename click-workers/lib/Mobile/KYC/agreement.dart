import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Agreement extends StatefulWidget {
  const Agreement({super.key});

  @override
  State<Agreement> createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  bool isChecked = false;

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

  Future<void> updateKycStatus({
    required bool kycCompleted,
    required String status,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("No user logged in");
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.set(
      {
        "kycCompleted": kycCompleted,
        "status": status,
      },
      SetOptions(merge: true),
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
                      SizedBox(height: 3.h),
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
                                const Text("Agreement & Submission",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(height: 2.h),
                                Container(
                                    width: 90.w,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffeeeeee),
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                            "By submitting this form, I confirm that all the information provided is accurate. I understand that providing false information may result in disqualification from the ClickWorkers platform.",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff6b7280))),
                                        SizedBox(height: 2.h),
                                        InkWell(
                                          onTap: () {},
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Terms and Conditions",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Color(0xffff6533))),
                                              Icon(Icons.keyboard_arrow_down,
                                                  color: Color(0xffff6533))
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        InkWell(
                                          onTap: () {},
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Privacy Policy",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Color(0xffff6533))),
                                              Icon(Icons.keyboard_arrow_down,
                                                  color: Color(0xffff6533))
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      activeColor: Colors.black,
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isChecked = !isChecked;
                                        });
                                      },
                                    ),
                                    const Text(
                                        "I have read and agree to the Terms and\nConditions and Privacy Policy. I confirm\nthat all information provided is accurate\nand complete.",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xff6b7280)))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
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
                              onPressed: !isChecked
                                  ? null
                                  : () async {
                                      await updateKycProgress(1);
                                      await updateKycStatus(
                                          kycCompleted: true,
                                          status: "Verified");
                                      if (context.mounted) {
                                        Navigator.popUntil(
                                            context, (route) => route.isFirst);
                                      }
                                    },
                              child: const Text("Submit Application"))),
                      SizedBox(height: 3.h),
                    ],
                  )))),
    );
  }
}

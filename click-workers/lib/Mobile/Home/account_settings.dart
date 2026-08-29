import 'package:click_workers/Mobile/Home/sign_out.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/Home/change_profile_picture.dart';
import 'package:click_workers/Mobile/Home/edit_profile.dart';
import 'package:click_workers/Mobile/Home/upgrade.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:click_workers/Mobile/Home/delete_account.dart';
import 'package:click_workers/Mobile/Home/change_password.dart';
import 'package:click_workers/Mobile/Home/preferred_language.dart';
import 'package:click_workers/Mobile/Home/preferred_currency.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import '../KYC/account_check.dart';
import '../KYC/account_verification.dart';
import '../KYC/agreement.dart';
import '../KYC/kyc_personal.dart';
import '../KYC/supporting_documents.dart';
import '../KYC/user_agreement.dart';
import '../authentication/utils/profile_photo_state.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key, required this.status, required this.id});

  final String id;
  final String status;

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  Map userDoc = {};

  @override
  void initState() {
    super.initState();

    fetchUser();
  }

  Future<Map<String, dynamic>?> getUserDoc(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void fetchUser() async {
    final userData =
        await getUserDoc(fire.FirebaseAuth.instance.currentUser!.uid);
    if (userData != null) {
      setState(() {
        userDoc = userData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new), // or any custom icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Account Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h),
            SizedBox(
              width: 90.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Account Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "ID: #${widget.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: 90.w,
              child: Card(
                elevation: 6, // adds shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            fire.FirebaseAuth.instance.currentUser!.photoURL ==
                                    null
                                ? CircleAvatar(
                                    radius: 15,
                                    backgroundColor: const Color(0xffeeeeee),
                                    child: Center(
                                        child: Text(
                                            fire.FirebaseAuth.instance
                                                .currentUser!.displayName![0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))))
                                : ValueListenableBuilder<String?>(
                                    valueListenable: ProfilePhotoState.photoUrl,
                                    builder: (context, photoUrl, _) {
                                      return CircleAvatar(
                                        radius: 15,
                                        backgroundImage: photoUrl != null &&
                                                photoUrl.isNotEmpty
                                            ? NetworkImage(
                                                fire.FirebaseAuth.instance
                                                    .currentUser!.photoURL
                                                    .toString(),
                                              )
                                            : null,
                                        child: photoUrl == null ||
                                                photoUrl.isEmpty
                                            ? Center(
                                                child: Text(
                                                    fire
                                                        .FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .displayName![0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight
                                                            .bold))) // placeholder icon
                                            : null,
                                      );
                                    }),
                            SizedBox(width: 2.w),
                            Text("${widget.status} User",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ]),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // <-- Adjust the radius
                              ),
                            ),
                            child: const Text("Basic",
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      const Text("Current Level",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 1.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: widget.status == "Non Verified"
                              ? 0.35
                              : widget.status == "Verified"
                                  ? 0.7
                                  : 1.0, // from 0.0 to 1.0
                          minHeight: 6,
                          backgroundColor: const Color(0xffd9d9d9),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Non Verified",
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xff6b7280))),
                            Text("Verified",
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xff6b7280))),
                            Text("Pro",
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xff6b7280))),
                          ])
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: 90.w,
              height: 350,
              child: Card(
                elevation: 6, // adds shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                    child: ListView(children: [
                      ListTile(
                          dense: true,
                          title: const Text("Complete Kyc Verification",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          onTap: () {
                            if (userDoc["kycCompleted"] != true) {
                              if (userDoc["kycProgress"] != 0.1) {
                                if (userDoc["kycProgress"] != 0.3) {
                                  if (userDoc["kycProgress"] != 0.5) {
                                    if (userDoc["kycProgress"] != 0.7) {
                                      if (userDoc["kycProgress"] != 0.9) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const UserAgreement()),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Agreement()),
                                        );
                                      }
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SupportingDocuments()),
                                      );
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SMAccountVerification()),
                                    );
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SMCheck()),
                                  );
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const KycPersonal()),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("KYC Already Completed"),
                                  duration:
                                      Duration(seconds: 2), // how long it shows
                                ),
                              );
                            }
                          }),
                      ListTile(
                          dense: true,
                          title: const Text("Edit profile",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditProfile()),
                            );
                          }),
                      ListTile(
                          dense: true,
                          title: const Text("Change password",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChangePassword()),
                            );
                          }),
                      ListTile(
                          dense: true,
                          title: const Text("Change profile picture",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChangeDP()),
                            );
                          }),
                      ListTile(
                          dense: true,
                          title: const Text("Preferred language",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PreferredLanguage()),
                            );
                          },
                          trailing: const Text("English (UK)",
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff6b7280)))),
                      ListTile(
                          dense: true,
                          title: const Text("Choose preferred currency",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PreferredCurrency()),
                            );
                          },
                          trailing: const Text("NGN",
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff6b7280)))),
                      ListTile(
                          dense: true,
                          title: const Text("Sign Out",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffff0004))),
                          onTap: () async {
                            showSignOutDialog(context);
                          }),
                      ListTile(
                          dense: true,
                          title: const Text("Delete Account",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffff0004))),
                          onTap: () async {
                            await showDeleteDialog(context);
                          }),
                    ])),
              ),
            ),
            SizedBox(height: 3.h),
            const Text("Account Level Benefits",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 2.h),
            SizedBox(
              width: 90.w,
              child: Card(
                elevation: 6, // adds shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: const Color(0xff4b5563),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 100.w,
                        decoration: BoxDecoration(
                            color: const Color(0xff6b7280),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Non Verified",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                  padding: const EdgeInsets.all(8),
                                  width: 20.w,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Center(
                                    child: Text("Current",
                                        style: TextStyle(
                                            color: Color(0xffff6533),
                                            fontWeight: FontWeight.bold)),
                                  ))
                            ]),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 100.w,
                        decoration: BoxDecoration(
                            color: const Color(0xff6b7280),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Limited task access",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 1.h),
                              const Text("₦5k minimum withdrawal Limit",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  )),
                              SizedBox(height: 1.h),
                              const Text("Basic features only",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ))
                            ]),
                      ),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                color: const Color(0xff4b5563),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 100.w,
                        decoration: BoxDecoration(
                            color: const Color(0xff6b7280),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Verified",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                  padding: const EdgeInsets.all(8),
                                  width: 20.w,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Center(
                                    child: Text("Next",
                                        style: TextStyle(
                                            color: Color(0xffff6533),
                                            fontWeight: FontWeight.bold)),
                                  ))
                            ]),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 100.w,
                        decoration: BoxDecoration(
                            color: const Color(0xff6b7280),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Full task access",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 1.h),
                              const Text("Standard Rewards",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 1.h),
                              const Text("5% referral commission",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  )),
                              SizedBox(height: 1.h),
                              const Text("₦1k withdrawal Limit",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  )),
                              SizedBox(height: 1.h),
                              const Text("All verified features",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ))
                            ]),
                      ),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9E4529),
                        Color(0xFF4C2920), // dark brownish center glow
                        Color(0xFF16171A),
                      ],
                      stops: [0.0, 0.1, 1.0],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: 100.w,
                          decoration: BoxDecoration(
                              color: const Color(0x87535863),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Pro",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                    padding: const EdgeInsets.all(8),
                                    width: 20.w,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text("Premium",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xffff6533),
                                              fontWeight: FontWeight.bold)),
                                    ))
                              ]),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: 100.w,
                          decoration: BoxDecoration(
                              color: const Color(0x87535863),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Higher points per task access",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 1.h),
                                const Text("Unlimited withdrawal Limit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 1.h),
                                const Text("10% referral commission",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    )),
                                SizedBox(height: 1.h),
                                const Text("2 Daily free spin",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    )),
                                SizedBox(height: 1.h),
                                const Text("Pro badge display",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ))
                              ]),
                        ),
                        SizedBox(height: 3.h),
                        SizedBox(
                          width: 90.w,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Upgrade()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Upgrade to Pro")),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        )),
      ),
    );
  }
}

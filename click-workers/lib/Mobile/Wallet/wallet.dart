import 'package:click_workers/Mobile/KYC/user_agreement.dart';
import 'package:click_workers/Mobile/Wallet/wallet_notifications.dart';
import 'package:click_workers/Mobile/Wallet/withdraw_funds.dart';
import 'package:click_workers/Mobile/Wallet/withdrawal_history.dart';
import 'package:click_workers/Mobile/widgets/arrow_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;

class Wallet extends StatefulWidget {
  const Wallet({
    super.key,
    required this.controller,
    required this.kycCompleted,
  });

  final PageController controller;
  final bool kycCompleted;
  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  ValueNotifier<bool> seeMore = ValueNotifier(true);
  ValueNotifier<String> pendingToday = ValueNotifier("0");
  ValueNotifier<String> withdrawnToday = ValueNotifier("0");
  ValueNotifier<String> earnedToday = ValueNotifier("0");
  ValueNotifier<String> availableCpsToday = ValueNotifier("0");
  ValueNotifier<String> pendingCpsToday = ValueNotifier("0");
  ValueNotifier<String> totalCpsToday = ValueNotifier("0");
  ValueNotifier<String> usedCpsToday = ValueNotifier("0");
  ValueNotifier<String> referralsToday = ValueNotifier("0");
  ValueNotifier<String> monetaryRedeemedValue = ValueNotifier("");
  ValueNotifier<String> numberPending = ValueNotifier("");
  ValueNotifier<String> numberRedeemed = ValueNotifier("");
  ValueNotifier<String> noOfItems = ValueNotifier("");
  ValueNotifier<String> cashRedeemedValue = ValueNotifier("");
  ValueNotifier<String> cashWithdrawn = ValueNotifier("");
  ValueNotifier<String> cashPending = ValueNotifier("");
  ValueNotifier<String> totalCash = ValueNotifier("");
  ValueNotifier<String> cpsRedeemedValue = ValueNotifier("");
  ValueNotifier<String> totalTreasurePointsWithdrawn = ValueNotifier("");
  ValueNotifier<String> totalTreasurePointsPending = ValueNotifier("");
  ValueNotifier<String> totalTreasurePoints = ValueNotifier("");
  ValueNotifier<String> spinToWinPointsToday = ValueNotifier("0");
  ValueNotifier<String> spinToWinCashToday = ValueNotifier("0");
  ValueNotifier<String> checkinCpsToday = ValueNotifier("0");
  ValueNotifier<Map<String, String>> oneOffSingle = ValueNotifier({});
  ValueNotifier<Map<String, String>> oneOffSingleToday = ValueNotifier({});
  ValueNotifier<Map<String, String>> repeatingSingle = ValueNotifier({});
  ValueNotifier<Map<String, String>> repeatingSingleToday = ValueNotifier({});
  ValueNotifier<Map<String, String>> oneOffGrouped = ValueNotifier({});
  ValueNotifier<Map<String, String>> oneOffGroupedToday = ValueNotifier({});
  ValueNotifier<Map<String, String>> unpaid = ValueNotifier({});
  ValueNotifier<Map<String, String>> unpaidToday = ValueNotifier({});
  ValueNotifier<Map<String, String>> timeOrSkillBased = ValueNotifier({});
  ValueNotifier<Map<String, String>> timeOrSkillBasedToday = ValueNotifier({});
  ValueNotifier<Map<String, String>> trendPush = ValueNotifier({});
  ValueNotifier<Map<String, String>> trendPushToday = ValueNotifier({});
  ValueNotifier<Map<String, String>> repeatingGrouped = ValueNotifier({});
  ValueNotifier<Map<String, String>> repeatingGroupedToday = ValueNotifier({});
  ValueNotifier<int> pointChange = ValueNotifier(0);

  Future<void> getPointsChange() async {
    final uid = fire.FirebaseAuth.instance.currentUser!.uid;

    final firestore = FirebaseFirestore.instance;

    // Fetch both docs
    final todayDoc = await firestore
        .collection('wallets')
        .doc(uid)
        .collection('walletSnapshots')
        .doc("today")
        .get();

    final yesterdayDoc = await firestore
        .collection('wallets')
        .doc(uid)
        .collection('walletSnapshots')
        .doc("yesterday")
        .get();

    final todayPoints =
        int.parse(todayDoc.data()!['totalPoints'].replaceAll(',', ''));
    final yesterdayPoints =
        int.parse(yesterdayDoc.data()!['totalPoints'].replaceAll(',', ''));

    final change = ((todayPoints - yesterdayPoints) / yesterdayPoints) * 100;

    pointChange.value = change.round();
    // could be negative or positive
  }

  Future<void> fetchTaskEarnings() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      final walletRef =
          FirebaseFirestore.instance.collection("wallets").doc(userId);

      // 7 subcollection names
      final subcollections = [
        "oneOffGrouped",
        "oneOffSingle",
        "repeatingGrouped",
        "repeatingSingle",
        "unpaid",
        "timeOrSkillBased",
        "trendPush",
      ];

      // Loops through subcollections
      for (int i = 0; i < subcollections.length; i++) {
        final col = subcollections[i];
        final colRef = walletRef.collection(col);

        // Fetches "today"
        final todaySnap = await colRef.doc("today").get();
        if (todaySnap.exists) {
          final data = todaySnap.data()!;

          if (i == 0) {
            oneOffGroupedToday.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 1) {
            oneOffSingleToday.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 2) {
            repeatingGroupedToday.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 3) {
            repeatingSingleToday.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 4) {
            unpaidToday.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 5) {
            timeOrSkillBasedToday.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 6) {
            trendPushToday.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
        }

        // Fetch "total"
        final totalSnap = await colRef.doc("total").get();
        if (totalSnap.exists) {
          final data = totalSnap.data()!;

          if (i == 0) {
            oneOffGrouped.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 1) {
            oneOffSingle.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 2) {
            repeatingGrouped.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 3) {
            repeatingSingle.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 4) {
            unpaid.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 5) {
            timeOrSkillBased.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
          if (i == 6) {
            trendPush.value = {
              "cash": data["cash"]?.toString() ?? "0",
              "points": data["points"]?.toString() ?? "0",
            };
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching wallet data: $e")),
        );
      }
    }
  }

  void getTodayWalletSnapshot() async {
    final uid = fire.FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('wallets')
        .doc(uid)
        .collection('walletSnapshots')
        .doc('today')
        .get();

    if (doc.exists) {
      pendingToday.value = doc["pendingEarnings"] ?? "0";
      withdrawnToday.value = doc["withdrawnEarnings"] ?? "0";
      earnedToday.value = doc["totalEarnings"] ?? "0";
      availableCpsToday.value = doc["availableClickPoints"] ?? "0";
      pendingCpsToday.value = doc["pendingClickPoints"] ?? "0";
      totalCpsToday.value = doc["totalPoints"] ?? "0";
      usedCpsToday.value = doc["usedClickPoints"] ?? "0";
      referralsToday.value = doc["referrals"] ?? "0";
      spinToWinPointsToday.value = doc["spinToWinPoints"] ?? "0";
      spinToWinCashToday.value = doc["spinToWinCash"] ?? "0";
      checkinCpsToday.value = doc["dailyCheckinCps"] ?? "0";
    }
  }

  Future<void> fetchTreasureHuntWalletData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      final ref = FirebaseFirestore.instance
          .collection("wallets")
          .doc(userId)
          .collection("treasureHunt");

      // get the only document in the collection
      final snapshot = await ref.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        monetaryRedeemedValue.value = data["monetaryRedeemedValue"] ?? "";
        numberPending.value = data["numberPending"] ?? "";
        numberRedeemed.value = data["numberRedeemed"] ?? "";
        noOfItems.value = data["noOfItems"] ?? "";
        cashRedeemedValue.value = data["cashRedeemedValue"] ?? "";
        cashWithdrawn.value = data["cashWithdrawn"] ?? "";
        cashPending.value = data["cashPending"] ?? "";
        totalCash.value = data["totalCash"] ?? "";
        cpsRedeemedValue.value = data["cpsRedeemedValue"] ?? "";
        totalTreasurePointsWithdrawn.value =
            data["totalTreasurePointsWithdrawn"] ?? "";
        totalTreasurePointsPending.value =
            data["totalTreasurePointsPending"] ?? "";
        totalTreasurePoints.value = data["totalTreasurePoints"] ?? "";
      } else {
        // no document found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No treasure hunt data found.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    getTodayWalletSnapshot();
    getPointsChange();
    fetchTreasureHuntWalletData();
    fetchTaskEarnings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('wallets')
                    .doc(fire.FirebaseAuth.instance.currentUser!.uid)
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
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text("No data"));
                  }

                  final data = snapshot.data as DocumentSnapshot;
                  // ✅ THEN convert safely
                  final doc = data.data() as Map<String, dynamic>? ?? {};

                  final String availableEarnings =
                      doc['availableEarnings'] ?? "";
                  final String availablePoints = doc['availablePoints'] ?? "";
                  final String pendingEarnings = doc["pendingEarnings"] ?? "";
                  final String withdrawnEarnings =
                      doc["withdrawnEarnings"] ?? "";
                  final String totalEarnings = doc['totalEarnings'] ?? "";
                  final String totalPoints = doc['totalPoints'] ?? "";
                  final String usedPoints = doc['usedPoints'] ?? "";
                  final String pendingPoints = doc['pendingPoints'] ?? "";
                  final String kycStatus = doc['kycStatus'] ?? "";
                  final String workerStatus = doc['workerStatus'] ?? "";
                  final String withdrawalStatus = doc['withdrawalStatus'] ?? "";
                  final String minimumWithdrawal =
                      doc['minimumWithdrawal'] ?? "";
                  final String availableReferralPoints =
                      doc['availableReferralPoints'] ?? "";
                  final String totalReferralPoints =
                      doc['totalReferralPoints'] ?? "";
                  final String usedReferralPoints =
                      doc['usedReferralPoints'] ?? "";
                  final String availableReferralEarnings =
                      doc['availableReferralEarnings'] ?? "";
                  final String totalReferralEarnings =
                      doc['totalReferralEarnings'] ?? "";
                  final String usedReferralEarnings =
                      doc['usedReferralEarnings'] ?? "";
                  final int referrals = doc['referrals'] ?? 0;
                  final String spinToWinPoints = doc['spinToWinPoints'] ?? "";
                  final String spinToWinCash = doc['spinToWinCash'] ?? "";
                  final String dailyCheckinTotalCps =
                      doc['dailyCheckinTotalCps'] ?? "";

                  final int gritEarnings = doc['gritEarnings'] ?? 0;
                  final int gratisEarnings = doc['gratisEarnings'] ?? 0;
                  final int taskEarnings = doc['taskEarnings'] ?? 0;
                  final int weeklyTaskEarnings = doc['weeklyTaskEarnings'] ?? 0;
                  final int monthlyTaskEarnings =
                      doc['monthlyTaskEarnings'] ?? 0;
                  final int rpsEarnings = doc['rpsEarnings'] ?? 0;
                  final int weeklyRpsEarnings = doc['weeklyRpsEarnings'] ?? 0;
                  final int monthlyRpsEarnings = doc['monthlyRpsEarnings'] ?? 0;
                  final int cpsEarnings = doc['cpsEarnings'] ?? 0;
                  final int weeklyCpsEarnings = doc['weeklyCpsEarnings'] ?? 0;
                  final int monthlyCpsEarnings = doc['monthlyCpsEarnings'] ?? 0;
                  final int streakEarnings = doc['streakEarnings'] ?? 0;
                  final int weeklyStreakEarnings =
                      doc['weeklyStreakEarnings'] ?? 0;
                  final int monthlyStreakEarnings =
                      doc['monthlyStreakEarnings'] ?? 0;

                  return ValueListenableBuilder<bool>(
                      valueListenable: seeMore,
                      builder: (_, val, __) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: 90.w,
                              child: const Text("General Overview",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xfffa6332))),
                            ),
                            SizedBox(
                              width: 90.w,
                              child: Card(
                                elevation: 6, // adds shadow
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.black,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Earnings Overview",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 100.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff6b7280),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Available Balance",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                "₦$availableEarnings",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 100.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff6b7280),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Pending Earnings",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                "₦$pendingEarnings",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              ValueListenableBuilder<String>(
                                                  valueListenable: pendingToday,
                                                  builder: (_, val, __) {
                                                    return Text(
                                                        "₦$val Pending Today",
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff22c55e),
                                                            fontSize: 12));
                                                  })
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 100.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff6b7280),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Withdrawn Earnings",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                "₦$withdrawnEarnings",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              ValueListenableBuilder(
                                                  valueListenable:
                                                      withdrawnToday,
                                                  builder: (_, val, __) {
                                                    return Text(
                                                        "₦$val Withdrawn Today",
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff22c55e),
                                                            fontSize: 12));
                                                  })
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 100.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff6b7280),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Total Earnings",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.5.h),
                                              Text(
                                                "₦$totalEarnings",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              ValueListenableBuilder<String>(
                                                  valueListenable: earnedToday,
                                                  builder: (_, val, __) {
                                                    return Text(
                                                        "₦$val Earned Today",
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff22c55e),
                                                            fontSize: 12));
                                                  })
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        SizedBox(
                                            width: 90.w,
                                            height: 7.h,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => WithdrawFunds(
                                                            balance:
                                                                availableEarnings,
                                                            kycCompleted: widget
                                                                .kycCompleted)),
                                                  );
                                                },
                                                child: const Text(
                                                    "Withdraw Funds"))),
                                        SizedBox(height: 2.h),
                                      ]),
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletNotifs(
                                                isSelected: "Earnings",
                                                mainCategories: ["All"])),
                                  );
                                },
                                child: const Text("View Earning Log",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black))),
                            SizedBox(
                              height: 2.h,
                            ),
                            SizedBox(
                              width: 90.w,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 90.w,
                                    child: const Text("Points Overview",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: 42.w,
                                            child: Card(
                                                elevation: 6, // adds shadow
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                color: const Color(0xff370606),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                              "Available ClickPoints",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 11,
                                                                  color: Color(
                                                                      0xffbab7b7))),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          Text(
                                                              "${availablePoints}CPs",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16)),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          ValueListenableBuilder(
                                                              valueListenable:
                                                                  availableCpsToday,
                                                              builder:
                                                                  (_, val, __) {
                                                                return Text(
                                                                    "+${val}CPs today",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xffbab7b7)));
                                                              })
                                                        ])))),
                                        SizedBox(
                                            width: 42.w,
                                            child: Card(
                                                elevation: 6, // adds shadow
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                color: const Color(0xff572525),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                              "Total ClickPoints",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xffbab7b7))),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          Text(
                                                              "${totalPoints}CPs",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16)),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          ValueListenableBuilder<
                                                                  int>(
                                                              valueListenable:
                                                                  pointChange,
                                                              builder:
                                                                  (_, val, __) {
                                                                return Text(
                                                                    "$val% increase Today",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xffbab7b7)));
                                                              })
                                                        ])))),
                                      ]),
                                  SizedBox(height: 2.h),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: 42.w,
                                            child: Card(
                                                elevation: 6, // adds shadow
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                color: const Color(0xff700c0c),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                              "Pending ClickPoints",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xffbab7b7))),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          Text(
                                                              "${pendingPoints}CPs",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16)),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          ValueListenableBuilder<
                                                                  String>(
                                                              valueListenable:
                                                                  pendingCpsToday,
                                                              builder:
                                                                  (_, val, __) {
                                                                return Text(
                                                                    "+${val}CPs Pending today",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xffbab7b7)));
                                                              })
                                                        ])))),
                                        SizedBox(
                                            width: 42.w,
                                            child: Card(
                                                elevation: 6, // adds shadow
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                color: const Color(0xffaa1313),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                              "Used Points",
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xffbab7b7))),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          Text(
                                                              "${usedPoints}CPs",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16)),
                                                          SizedBox(
                                                              height: 0.5.h),
                                                          ValueListenableBuilder<
                                                              String>(
                                                            valueListenable:
                                                                usedCpsToday,
                                                            builder:
                                                                (_, val, __) {
                                                              return Text(
                                                                  "+${val}CPs used today",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Color(
                                                                          0xffbab7b7)));
                                                            },
                                                          )
                                                        ])))),
                                      ]),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const WalletNotifs(
                                          isSelected: "Points",
                                          mainCategories: ["All"])),
                                );
                              },
                              child: const Text("View Point Log",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 10,
                                    decorationColor: Colors.black,
                                    color: Colors.black,
                                  )),
                            ),
                            Container(
                              width: 100.w,
                              height: 2.h,
                              color: const Color(0xffeeeeee),
                            ),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: 90.w,
                              child: const Text("Category Breakdown",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xfffa6332))),
                            ),
                            SizedBox(height: 1.h),
                            SizedBox(
                              width: 90.w,
                              child: Card(
                                elevation: 6, // adds shadow
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.black,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Referral Earnings Overview",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 100.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff6b7280),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Available Referral Points/Earnings",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                "₦$availableReferralEarnings + ${availableReferralPoints}RPs",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              ValueListenableBuilder(
                                                  valueListenable:
                                                      referralsToday,
                                                  builder: (_, val, __) {
                                                    return Text(
                                                        "$val Referrals Today",
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff22c55e),
                                                            fontSize: 12));
                                                  })
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 100.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff6b7280),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Total Referral Points/Earnings",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                "₦$totalReferralEarnings + ${totalReferralPoints}RPs",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                  "$referrals Referrals So far",
                                                  style: const TextStyle(
                                                      color: Color(0xff22c55e),
                                                      fontSize: 12))
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 100.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xff6b7280),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Used Referral Points/Earnings",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                "₦$usedReferralEarnings + ${usedReferralPoints}RPs",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                      ]),
                                ),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletNotifs(
                                                isSelected: "Filtered",
                                                mainCategories: ["Referral"])),
                                  );
                                },
                                child: const Text("View Referral Log/History",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black))),
                            SizedBox(
                              height: 2.h,
                            ),
                            const Divider(
                                thickness: 2.0, color: Color(0xff6b7380)),
                            SizedBox(height: 3.h),
                            SizedBox(
                              width: 90.w,
                              child:
                                  const Text("Treasure Hunt Earnings Summary",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                            ),
                            SizedBox(height: 1.h),
                            SizedBox(
                              width: 90.w,
                              child: Card(
                                elevation: 6, // adds shadow
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: const Color(0xff370606),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 20, 20, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    "Monetary Value of Redeemed Items",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                //SizedBox(height: 1.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    monetaryRedeemedValue,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      " ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            SizedBox(
                                                                height: 2.h),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    numberRedeemed,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Items Redeemed: ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    numberPending,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Items Pending:  ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    noOfItems,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Items so far:  ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                          ]),
                                                      Column(
                                                        children: [
                                                          SizedBox(height: 2.h),
                                                          Image.asset(
                                                              'assets/wallets/treasure_box.png',
                                                              scale: 5,
                                                              alignment: Alignment
                                                                  .bottomRight),
                                                        ],
                                                      )
                                                    ]),
                                              ])),
                                      const Divider(
                                          thickness: 1,
                                          color: Color(0xff6b7380)),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    "Cash Value Redeemed",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                SizedBox(height: 1.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    cashRedeemedValue,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      " ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            SizedBox(
                                                                height: 1.h),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    cashWithdrawn,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Cash Withdrawn:  ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    cashPending,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Cash Pending:  ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    totalCash,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Cash so far:  ₦${val.isEmpty ? 0 : val}",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                          ]),
                                                      Column(
                                                        children: [
                                                          Image.asset(
                                                              'assets/wallets/cash.png',
                                                              scale: 5.5,
                                                              alignment: Alignment
                                                                  .bottomRight),
                                                        ],
                                                      )
                                                    ]),
                                                SizedBox(
                                                  height: 2.h,
                                                ),
                                              ])),
                                      const Divider(
                                          thickness: 1,
                                          color: Color(0xff6b7380)),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    "Click Points Value Redeemed",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                SizedBox(height: 1.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    cpsRedeemedValue,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      " ${val.isEmpty ? 0 : val}CPs",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            SizedBox(
                                                                height: 1.h),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    totalTreasurePointsWithdrawn,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Points Withdrawn:  ${val.isEmpty ? 0 : val}CPs",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            9,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    totalTreasurePointsPending,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Points Pending:  ${val.isEmpty ? 0 : val}CPs",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            9,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                            ValueListenableBuilder(
                                                                valueListenable:
                                                                    totalCash,
                                                                builder: (_,
                                                                    val, __) {
                                                                  return Text(
                                                                      "Total Treasure Points so far:  ${val.isEmpty ? 0 : val}CPs",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            9,
                                                                        color: Colors
                                                                            .white,
                                                                      ));
                                                                }),
                                                          ]),
                                                      Column(
                                                        children: [
                                                          Image.asset(
                                                              'assets/wallets/coins.png',
                                                              scale: 6,
                                                              alignment:
                                                                  Alignment
                                                                      .topRight),
                                                        ],
                                                      )
                                                    ]),
                                                SizedBox(
                                                  height: 3.h,
                                                ),
                                              ])),
                                    ]),
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletNotifs(
                                                isSelected: "Filtered",
                                                mainCategories: ["Referral"])),
                                  );
                                },
                                child: const Text("View Treasure Details",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff7a0000),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xff7a0000),
                                    ))),
                            SizedBox(
                              height: 2.h,
                            ),
                            const Divider(
                                thickness: 2.0, color: Color(0xff6b7380)),
                            SizedBox(
                              height: 2.h,
                            ),
                            SizedBox(
                              width: 90.w,
                              child: const Text("Spin to Win Earning Summary",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 1.h),
                            SizedBox(
                              width: 90.w,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                        width: 42.w,
                                        child: Card(
                                            elevation: 6, // adds shadow
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            color: const Color(0xff9f2b00),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                          "Total Points Earned",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .white)),
                                                      SizedBox(height: 0.5.h),
                                                      Text(
                                                          "${spinToWinPoints}CPs",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16)),
                                                      SizedBox(height: 0.5.h),
                                                      const Text(
                                                          "Points Earned Today",
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors
                                                                  .white)),
                                                      ValueListenableBuilder(
                                                          valueListenable:
                                                              spinToWinPointsToday,
                                                          builder:
                                                              (_, val, __) {
                                                            return Text(
                                                                "+${val}CPs",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white));
                                                          }),
                                                    ])))),
                                    SizedBox(
                                        width: 42.w,
                                        child: Card(
                                            elevation: 6, // adds shadow
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            color: const Color(0xff9f2b00),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                          "Total Cash Earned",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                      SizedBox(height: 0.5.h),
                                                      Text("₦$spinToWinCash",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16)),
                                                      SizedBox(height: 0.5.h),
                                                      const Text(
                                                          "Cash Earned Today:",
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors
                                                                  .white)),
                                                      ValueListenableBuilder(
                                                          valueListenable:
                                                              spinToWinCashToday,
                                                          builder:
                                                              (_, val, __) {
                                                            return Text("₦$val",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white));
                                                          }),
                                                    ])))),
                                  ]),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletNotifs(
                                                isSelected: "Filtered",
                                                mainCategories: [
                                                  "Spin To Win"
                                                ])),
                                  );
                                },
                                child: const Text(
                                    "View Spin to Win Earning Details",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xff7a0000),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xff7a0000),
                                    ))),
                            SizedBox(height: 2.h),
                            const Divider(
                                thickness: 2.0, color: Color(0xff6b7380)),
                            SizedBox(
                              height: 2.h,
                            ),
                            SizedBox(
                              width: 90.w,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Tasks Earning Overview",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const WalletNotifs(
                                                      isSelected: "Filtered",
                                                      mainCategories: [
                                                        "Tasks"
                                                      ])),
                                        );
                                      },
                                      child: const Text("View Task Earning Log",
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.black,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.black,
                                          ))),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            ValueListenableBuilder<Map<String, String>>(
                                valueListenable: oneOffSingle,
                                builder: (_, total, __) {
                                  return ValueListenableBuilder<
                                          Map<String, String>>(
                                      valueListenable: oneOffSingleToday,
                                      builder: (_, today, __) {
                                        return Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.grey, width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(children: [
                                              CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      const Color(0xffff6533),
                                                  child: Center(
                                                      child: Image.asset(
                                                          "assets/wallets/task1.png",
                                                          scale: 4))),
                                              SizedBox(width: 5.w),
                                              SizedBox(
                                                width: 64.w,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "One-off Single",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const Text(
                                                              "Action",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                                height: 0.5.h),
                                                            const Text(
                                                              "Today's Earnings",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Text(
                                                              "₦${today['cash'] ?? 0} & ${today['points'] ?? 0}CPs",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ]),
                                                      Column(children: [
                                                        const Text(
                                                            "Total Earnings",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                        SizedBox(height: 0.5.h),
                                                        Container(
                                                            width: 25.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16)),
                                                            child: Center(
                                                                child: Text(
                                                                    "₦${total['cash'] ?? 0}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        SizedBox(height: 1.h),
                                                        Container(
                                                            width: 25.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xfffe6929),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16)),
                                                            child: Center(
                                                                child: Text(
                                                                    "${total['points'] ?? 0}CPs",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                      ]),
                                                    ]),
                                              )
                                            ]));
                                      });
                                }),
                            SizedBox(height: 2.h),
                            ValueListenableBuilder<Map<String, String>>(
                                valueListenable: oneOffGrouped,
                                builder: (_, total, __) {
                                  return ValueListenableBuilder<
                                          Map<String, String>>(
                                      valueListenable: oneOffGroupedToday,
                                      builder: (_, today, __) {
                                        return Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  color: Colors.grey, width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(children: [
                                              CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      const Color(0xffff6533),
                                                  child: Center(
                                                      child: Image.asset(
                                                          "assets/wallets/task2.png",
                                                          scale: 4))),
                                              SizedBox(width: 5.w),
                                              SizedBox(
                                                width: 64.w,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "One-off Grouped",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const Text(
                                                              "Actions",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                                height: 0.5.h),
                                                            const Text(
                                                              "Today's Earnings",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Text(
                                                              "₦${today['cash'] ?? 0} & ${today['points'] ?? 0}CPs",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ]),
                                                      Column(children: [
                                                        const Text(
                                                            "Total Earnings",
                                                            style: TextStyle(
                                                                fontSize: 12)),
                                                        SizedBox(height: 0.5.h),
                                                        Container(
                                                            width: 25.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16)),
                                                            child: Center(
                                                                child: Text(
                                                                    "₦${total['cash'] ?? 0}",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        SizedBox(height: 1.h),
                                                        Container(
                                                            width: 25.w,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xfffe6929),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16)),
                                                            child: Center(
                                                                child: Text(
                                                                    "${total['points'] ?? 0}CPs",
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                      ]),
                                                    ]),
                                              )
                                            ]));
                                      });
                                }),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : SizedBox(height: 2.h),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : ValueListenableBuilder<Map<String, String>>(
                                    valueListenable: repeatingGrouped,
                                    builder: (_, total, __) {
                                      return ValueListenableBuilder<
                                              Map<String, String>>(
                                          valueListenable:
                                              repeatingGroupedToday,
                                          builder: (_, today, __) {
                                            return Container(
                                                width: 90.w,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(children: [
                                                  CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor:
                                                          const Color(
                                                              0xffff6533),
                                                      child: Center(
                                                          child: Image.asset(
                                                              "assets/wallets/task3.png",
                                                              scale: 4))),
                                                  SizedBox(width: 5.w),
                                                  SizedBox(
                                                    width: 64.w,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  "Repeating Grouped",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const Text(
                                                                  "Action",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        0.5.h),
                                                                const Text(
                                                                  "Today's Earnings",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "₦${today['cash'] ?? 0} & ${today['points'] ?? 0}CPs",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ]),
                                                          Column(children: [
                                                            const Text(
                                                                "Total Earnings",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12)),
                                                            SizedBox(
                                                                height: 0.5.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "₦${total['cash'] ?? 0}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xfffe6929),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "${total['points'] ?? 0}CPs",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                          ]),
                                                        ]),
                                                  )
                                                ]));
                                          });
                                    }),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : SizedBox(height: 2.h),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : ValueListenableBuilder<Map<String, String>>(
                                    valueListenable: repeatingSingle,
                                    builder: (_, total, __) {
                                      return ValueListenableBuilder<
                                              Map<String, String>>(
                                          valueListenable: repeatingSingleToday,
                                          builder: (_, today, __) {
                                            return Container(
                                                width: 90.w,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(children: [
                                                  CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor:
                                                          const Color(
                                                              0xffff6533),
                                                      child: Center(
                                                          child: Image.asset(
                                                              "assets/wallets/task4.png",
                                                              scale: 4))),
                                                  SizedBox(width: 5.w),
                                                  SizedBox(
                                                    width: 64.w,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  "Repeating Single",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const Text(
                                                                  "Action",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        0.5.h),
                                                                const Text(
                                                                  "Today's Earnings",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "₦${today['cash'] ?? 0} & ${today['points'] ?? 0}CPs",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ]),
                                                          Column(children: [
                                                            const Text(
                                                                "Total Earnings",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12)),
                                                            SizedBox(
                                                                height: 0.5.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "₦${total['cash'] ?? 0}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xfffe6929),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "${total['points'] ?? 0}CPs",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                          ]),
                                                        ]),
                                                  )
                                                ]));
                                          });
                                    }),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : SizedBox(height: 2.h),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : ValueListenableBuilder<Map<String, String>>(
                                    valueListenable: trendPush,
                                    builder: (_, total, __) {
                                      return ValueListenableBuilder<
                                              Map<String, String>>(
                                          valueListenable: trendPushToday,
                                          builder: (_, today, __) {
                                            return Container(
                                                width: 90.w,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(children: [
                                                  CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor:
                                                          const Color(
                                                              0xffff6533),
                                                      child: Center(
                                                          child: Image.asset(
                                                              "assets/wallets/task5.png",
                                                              scale: 4))),
                                                  SizedBox(width: 5.w),
                                                  SizedBox(
                                                    width: 64.w,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  "Trend Push",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        0.5.h),
                                                                const Text(
                                                                  "Today's Earnings",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "₦${today['cash'] ?? 0} & ${today['points'] ?? 0}CPs",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ]),
                                                          Column(children: [
                                                            const Text(
                                                                "Total Earnings",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12)),
                                                            SizedBox(
                                                                height: 0.5.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "₦${total['cash'] ?? 0}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xfffe6929),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "${total['points'] ?? 0}CPs",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                          ]),
                                                        ]),
                                                  )
                                                ]));
                                          });
                                    }),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : SizedBox(height: 2.h),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : ValueListenableBuilder<Map<String, String>>(
                                    valueListenable: timeOrSkillBased,
                                    builder: (_, total, __) {
                                      return ValueListenableBuilder<
                                              Map<String, String>>(
                                          valueListenable:
                                              timeOrSkillBasedToday,
                                          builder: (_, today, __) {
                                            return Container(
                                                width: 90.w,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(children: [
                                                  CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor:
                                                          const Color(
                                                              0xffff6533),
                                                      child: Center(
                                                          child: Image.asset(
                                                              "assets/wallets/task6.png",
                                                              scale: 4))),
                                                  SizedBox(width: 5.w),
                                                  SizedBox(
                                                    width: 64.w,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  "Time/Skill Based",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const Text(
                                                                  "Social Action",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        0.5.h),
                                                                const Text(
                                                                  "Today's Earnings",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "₦${today['cash'] ?? 0} & ${today['points'] ?? 0}CPs",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ]),
                                                          Column(children: [
                                                            const Text(
                                                                "Total Earnings",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12)),
                                                            SizedBox(
                                                                height: 0.5.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "₦${total['cash'] ?? 0}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xfffe6929),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "${total['points'] ?? 0}CPs",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                          ]),
                                                        ]),
                                                  )
                                                ]));
                                          });
                                    }),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : SizedBox(height: 2.h),
                            seeMore.value
                                ? const SizedBox(height: 0)
                                : ValueListenableBuilder<Map<String, String>>(
                                    valueListenable: unpaid,
                                    builder: (_, total, __) {
                                      return ValueListenableBuilder<
                                              Map<String, String>>(
                                          valueListenable: unpaidToday,
                                          builder: (_, today, __) {
                                            return Container(
                                                width: 90.w,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(children: [
                                                  CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor:
                                                          const Color(
                                                              0xffff6533),
                                                      child: Center(
                                                          child: Image.asset(
                                                              "assets/wallets/task7.png",
                                                              scale: 4))),
                                                  SizedBox(width: 5.w),
                                                  SizedBox(
                                                    width: 64.w,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  "Unpaid",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                const Text(
                                                                  "Tasks/Actions",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        0.5.h),
                                                                const Text(
                                                                  "Today's Earnings",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "₦${today['cash'] ?? 0} & ${today['points'] ?? 0}CPs",
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ]),
                                                          Column(children: [
                                                            const Text(
                                                                "Total Earnings",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12)),
                                                            SizedBox(
                                                                height: 0.5.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "₦${total['cash'] ?? 0}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                            SizedBox(
                                                                height: 1.h),
                                                            Container(
                                                                width: 25.w,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xfffe6929),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16)),
                                                                child: Center(
                                                                    child: Text(
                                                                        "${total['points'] ?? 0}CPs",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)))),
                                                          ]),
                                                        ]),
                                                  )
                                                ]));
                                          });
                                    }),
                            SizedBox(
                              height: 1.h,
                            ),
                            SizedBox(
                              width: 90.w,
                              child: Row(children: [
                                const SizedBox(
                                    width: 40,
                                    child: ArrowCircleAnimation(
                                        borderColor: Colors.black)),
                                SizedBox(width: 2.w),
                                ValueListenableBuilder(
                                    valueListenable: seeMore,
                                    builder: (_, val, __) {
                                      return SizedBox(
                                          width: 22.w,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xffaa1313),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                seeMore.value = !seeMore.value;
                                              },
                                              child: Text(
                                                  val ? "See More" : "See Less",
                                                  style: const TextStyle(
                                                      fontSize: 12))));
                                    }),
                                ValueListenableBuilder(
                                    valueListenable: seeMore,
                                    builder: (_, val, __) {
                                      return Icon(
                                          val
                                              ? Icons.arrow_drop_down
                                              : Icons.arrow_drop_up,
                                          size: 45,
                                          color: const Color(0xff700c0c));
                                    })
                              ]),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            const Divider(
                                thickness: 2.0, color: Color(0xff6b7380)),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: 90.w,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Daily Check-in Earnings",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const WalletNotifs(
                                                      isSelected: "Filtered",
                                                      mainCategories: [
                                                        "Check-in"
                                                      ])),
                                        );
                                      },
                                      child: const Text(
                                          "View Check-in Earning Log",
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.black,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.black,
                                          ))),
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
                                color: const Color(0xff572525),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 2.h),
                                        const Center(
                                            child: Text("Total Points Earned: ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Center(
                                            child: Text(
                                                "${dailyCheckinTotalCps}CPs",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        SizedBox(height: 2.h),
                                        Container(
                                            width: 32.w,
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                      "Points Earned Today: ",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xffbab7b7))),
                                                  SizedBox(height: 1.h),
                                                  ValueListenableBuilder(
                                                      valueListenable:
                                                          checkinCpsToday,
                                                      builder: (_, val, __) {
                                                        return Text("${val}CPs",
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xffbab7b7)));
                                                      }),
                                                ])),
                                        SizedBox(height: 2.h)
                                      ]),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            const Divider(
                                thickness: 2.0, color: Color(0xff6b7380)),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: 90.w,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Achievements Earnings",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const WalletNotifs(
                                                      isSelected: "Filtered",
                                                      mainCategories: [
                                                        "Acheivements"
                                                      ])),
                                        );
                                      },
                                      child: const Text(
                                          "View Acheivements Earning",
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.black,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.black,
                                          ))),
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
                                color: const Color(0xff363637),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                                "Grit Earnings: ₦$gritEarnings",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        SizedBox(height: 2.h),
                                        Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                                "Gratis Earnings: ₦$gratisEarnings",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ]),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            const Divider(
                                thickness: 2.0, color: Color(0xff6b7380)),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: 90.w,
                              child: const Text("Leaderboard Ranking Earnings",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: 90.w,
                              child: Card(
                                elevation: 6, // adds shadow
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: const Color(0xff9f2b00),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              children: [
                                                const Center(
                                                  child: Text(
                                                      "Task Performance Earnings:",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Center(
                                                  child: Text("₦$taskEarnings",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                SizedBox(height: 1.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Week:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$weeklyTaskEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Month:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$monthlyTaskEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                    ])
                                              ],
                                            )),
                                        SizedBox(height: 2.h),
                                        Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              children: [
                                                const Center(
                                                  child: Text(
                                                      "Click Points Earnings:",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Center(
                                                  child: Text("₦$cpsEarnings",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                SizedBox(height: 1.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Week:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$weeklyCpsEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Month:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$monthlyCpsEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                    ])
                                              ],
                                            )),
                                        SizedBox(height: 2.h),
                                        Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              children: [
                                                const Center(
                                                  child: Text(
                                                      "Referral Points Earnings:",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Center(
                                                  child: Text("₦$rpsEarnings",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                SizedBox(height: 1.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Week:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$weeklyRpsEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Month:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$monthlyRpsEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                    ])
                                              ],
                                            )),
                                        SizedBox(height: 2.h),
                                        Container(
                                            width: 90.w,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              children: [
                                                const Center(
                                                  child: Text(
                                                      "Streak Earnings:",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Center(
                                                  child: Text(
                                                      "₦$streakEarnings",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                SizedBox(height: 1.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Week:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$weeklyStreakEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                      Container(
                                                          width: 32.w,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                    "Earnings This Month:",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                Text(
                                                                    "₦$monthlyStreakEarnings",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ])),
                                                    ])
                                              ],
                                            )),
                                        SizedBox(height: 2.h),
                                      ]),
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletNotifs(
                                                isSelected: "Filtered",
                                                mainCategories: [
                                                  "Leaderboard"
                                                ])),
                                  );
                                },
                                child:
                                    const Text("View Leaderboard Earning Log",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.black,
                                        ))),
                            SizedBox(
                              height: 4.h,
                            ),
                            const Divider(
                                thickness: 2.0, color: Color(0xff6b7380)),
                            SizedBox(height: 2.h),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('wallets')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('withdrawalHistory')
                                    .where('amount', isNotEqualTo: "")
                                    .limit(2)
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
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  // Success
                                  final docs = snapshot.data?.docs ?? [];

                                  if (docs.isEmpty) {
                                    return const SizedBox(height: 0);
                                  }
                                  return SizedBox(
                                      width: 90.w,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Withdrawal History",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const WithdrawHistoryScreen()),
                                                    );
                                                  },
                                                  child: const Text(
                                                      "View all Withdrawal History",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Colors.black,
                                                          color: Colors.black)))
                                            ],
                                          ),
                                          SizedBox(height: 2.h),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      DateFormat(
                                                              "MMMM d 'at' h:mm a")
                                                          .format(docs[0]
                                                                  ['date']
                                                              .toDate()),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: docs[0][
                                                                    'status'] ==
                                                                "Completed"
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.1)
                                                            : docs[0]['status'] ==
                                                                    "Pending"
                                                                ? Colors.orange
                                                                    .withOpacity(
                                                                        0.1)
                                                                : Colors.red
                                                                    .withOpacity(
                                                                        0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        docs[0]['status'] ?? "",
                                                        style: TextStyle(
                                                          color: docs[0][
                                                                      'status'] ==
                                                                  "Completed"
                                                              ? Colors.green
                                                              : docs[0]['status'] ==
                                                                      "Pending"
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "₦${docs[0]['amount']}",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text("${docs[0]['txDetails']}",
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                Text("${docs[0]['ref']}",
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      DateFormat(
                                                              "MMMM d 'at' h:mm a")
                                                          .format(docs[1]
                                                                  ['date']
                                                              .toDate()),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: docs[1][
                                                                    'status'] ==
                                                                "Completed"
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.1)
                                                            : docs[1]['status'] ==
                                                                    "Pending"
                                                                ? Colors.orange
                                                                    .withOpacity(
                                                                        0.1)
                                                                : Colors.red
                                                                    .withOpacity(
                                                                        0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        docs[1]['status'] ?? "",
                                                        style: TextStyle(
                                                          color: docs[1][
                                                                      'status'] ==
                                                                  "Completed"
                                                              ? Colors.green
                                                              : docs[1]['status'] ==
                                                                      "Pending"
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "₦${docs[1]['amount']}",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text("${docs[1]['txDetails']}",
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                Text("${docs[1]['ref']}",
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Center(
                                            child: SizedBox(
                                                width: 70.w,
                                                height: 6.h,
                                                child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                WithdrawFunds(
                                                                    balance:
                                                                        availableEarnings,
                                                                    kycCompleted:
                                                                        widget
                                                                            .kycCompleted)),
                                                      );
                                                    },
                                                    child: const Text(
                                                        "Withdraw Funds"))),
                                          ),
                                          SizedBox(height: 4.h),
                                        ],
                                      ));
                                }),
                            // SizedBox(height: 4.h),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.h, vertical: 2.w),
                                width: 100.w,
                                color: const Color(0xffeeeeee),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 2.h),
                                      const Text("Profile Overview",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 2.h),
                                      Container(
                                          width: 90.w,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: RichText(
                                              text: TextSpan(
                                                  text: "Kyc Status: ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                TextSpan(
                                                    text: kycStatus,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: kycStatus ==
                                                                "InProgress"
                                                            ? const Color(
                                                                0xffb59720)
                                                            : kycStatus ==
                                                                    "Not Started"
                                                                ? const Color(
                                                                    0xff7a0000)
                                                                : const Color(
                                                                    0xff007a3f)))
                                              ]))),
                                      SizedBox(height: 2.h),
                                      Container(
                                          width: 90.w,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: RichText(
                                              text: TextSpan(
                                                  text: "ClickWorker Status: ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                TextSpan(
                                                    text: workerStatus,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black))
                                              ]))),
                                      SizedBox(height: 2.h),
                                      Container(
                                          width: 90.w,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: RichText(
                                              text: TextSpan(
                                                  text:
                                                      "Current Minimum Withdrawal: ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  children: [
                                                TextSpan(
                                                    text: minimumWithdrawal,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black))
                                              ]))),
                                      SizedBox(height: 2.h),
                                      Container(
                                          width: 90.w,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Withdrawal Status: ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (withdrawalStatus ==
                                                      "Ineligible, Complete Kyc") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const UserAgreement()),
                                                    );
                                                  }
                                                },
                                                child: Text(withdrawalStatus,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: withdrawalStatus ==
                                                                "Ineligible, Complete Kyc"
                                                            ? const Color(
                                                                0xffaa1313)
                                                            : const Color(
                                                                0xff007a3f))),
                                              )
                                            ],
                                          )),
                                      SizedBox(height: 2.h),
                                    ])),
                            SizedBox(height: 2.h),
                            SizedBox(
                                width: 90.w,
                                child: Card(
                                    elevation: 6, // adds shadow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: const Color(0xff6b7280),
                                    child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: const Color(
                                                          0xffff6533)),
                                                  child: const Icon(Icons.error,
                                                      color: Colors.white)),
                                              // SizedBox(width: 0.5.w),
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                        "Important Notice",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffff6533),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18)),
                                                    SizedBox(height: 1.h),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(
                                                              width: 0.5.w),
                                                          RichText(
                                                              text: const TextSpan(
                                                                  text: "Minimum Withdrawal:₦1000 ",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "is the lowest amount\nyou can withdraw or subscribe to ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: "Pro ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "to reduce\nto ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: "₦500.",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ])),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(
                                                              width: 0.5.w),
                                                          RichText(
                                                              text: const TextSpan(
                                                                  text: "External Deposits: ",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Deposits are not allowed. All\nearnings must come from completed tasks, treasures\nand earnings within the platform.",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                ),
                                                              ])),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(
                                                              width: 0.5.w),
                                                          RichText(
                                                              text: const TextSpan(
                                                                  text: "Kyc Requirements: ",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Withdrawals are locked until kyc\nis successfully completed or updated.",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                ),
                                                              ])),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(
                                                              width: 0.5.w),
                                                          RichText(
                                                              text: const TextSpan(
                                                                  text: "Withdrawal Processing Time: ",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Withdrawals are\ninstant and reflect immediately in your bank account",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                ),
                                                              ])),
                                                        ]),
                                                    SizedBox(height: 2.h),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .baseline,
                                                        textBaseline:
                                                            TextBaseline
                                                                .alphabetic,
                                                        children: [
                                                          const Text("●",
                                                              style: TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(
                                                              width: 0.5.w),
                                                          RichText(
                                                              text: const TextSpan(
                                                                  text: "Dispute Window: ",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "If payment is not received after\n24hrs, you can raise a complaint through support\nusing support@nanoinfluencers.com",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                  ),
                                                                ),
                                                              ])),
                                                        ]),
                                                  ])
                                            ])))),
                            SizedBox(height: 4.h),
                            Center(
                              child: SizedBox(
                                  width: 70.w,
                                  height: 6.h,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: () {
                                        Future.delayed(Duration.zero, () {
                                          widget.controller.jumpToPage(1);
                                        });
                                      },
                                      child: const Text("Go to Tasks"))),
                            ),
                            SizedBox(height: 4.h),
                          ],
                        );
                      });
                }),
          ),
        ));
  }
}

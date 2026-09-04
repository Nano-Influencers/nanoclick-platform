import 'package:click_workers/Mobile/KYC/user_agreement.dart';
import 'package:click_workers/Mobile/Wallet/wallet_notifications.dart';
import 'package:click_workers/Mobile/Wallet/withdraw_funds.dart';
import 'package:click_workers/Mobile/Wallet/withdrawal_history.dart';
import 'package:click_workers/Mobile/widgets/arrow_animation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/services/api_client.dart';

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

  // Backs the FutureBuilder that replaced the old wallet-doc Firestore
  // stream. Combines wallet balance + referral stats + KYC status into
  // one map (prefixed keys _referralCount/_referralEarningsKobo/
  // _kycStatus) since the old single Firestore doc bundled all of these
  // together too.
  late Future<Map<String, dynamic>> _walletFuture;

  Future<Map<String, dynamic>> _loadWalletBundle() async {
    final wallet = await ApiClient.instance.getWalletBalance();
    final referral = await ApiClient.instance.referralStats();
    final kycStatus = await ApiClient.instance.kycStatus();
    return {
      ...wallet,
      '_referralCount': referral['referral_count'],
      '_referralEarningsKobo': referral['total_referral_earnings_kobo'],
      '_kycStatus': kycStatus,
    };
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _walletFuture = _loadWalletBundle();
    });
  }

  Future<void> getPointsChange() async {
    // No historical daily-snapshot data is retained server-side (the
    // backend only tracks the *current* daily_reset_at-scoped counters,
    // not a "yesterday" snapshot to diff against) — a real day-over-day
    // percentage isn't computable from what exists. Left at its default
    // (0) rather than fabricating a number.
    pointChange.value = 0;
  }

  Future<void> fetchTaskEarnings() async {
    try {
      final wallet = await ApiClient.instance.getWalletBalance();
      Map<String, String> pair(String kobo, String cps) => {
            "cash": (((wallet[kobo] as num?) ?? 0) / 100).toStringAsFixed(0),
            "points": ((wallet[cps] as num?) ?? 0).toString(),
          };
      oneOffGroupedToday.value = pair('daily_one_off_grouped_kobo', 'daily_one_off_grouped_cps');
      oneOffGrouped.value = pair('total_one_off_grouped_kobo', 'daily_one_off_grouped_cps');
      oneOffSingleToday.value = pair('daily_one_off_single_kobo', 'daily_one_off_single_cps');
      oneOffSingle.value = pair('total_one_off_single_kobo', 'daily_one_off_single_cps');
      repeatingGroupedToday.value = pair('daily_repeating_grouped_kobo', 'daily_repeating_grouped_cps');
      repeatingGrouped.value = pair('total_repeating_grouped_kobo', 'daily_repeating_grouped_cps');
      repeatingSingleToday.value = pair('daily_repeating_single_kobo', 'daily_repeating_single_cps');
      repeatingSingle.value = pair('total_repeating_single_kobo', 'daily_repeating_single_cps');
      unpaidToday.value = pair('daily_unpaid_kobo', 'daily_unpaid_cps');
      unpaid.value = pair('total_unpaid_kobo', 'daily_unpaid_cps');
      timeOrSkillBasedToday.value = pair('daily_skill_based_kobo', 'daily_skill_based_cps');
      timeOrSkillBased.value = pair('total_skill_based_kobo', 'daily_skill_based_cps');
      trendPushToday.value = pair('daily_trend_push_kobo', 'daily_trend_push_cps');
      trendPush.value = pair('total_trend_push_kobo', 'daily_trend_push_cps');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching wallet data: $e")),
        );
      }
    }
  }

  void getTodayWalletSnapshot() async {
    try {
      final wallet = await ApiClient.instance.getWalletBalance();
      final referral = await ApiClient.instance.referralStats();
      pendingToday.value = "0"; // no per-day pending-earnings breakdown exists server-side
      withdrawnToday.value = ((wallet['total_withdrawn_kobo'] as num? ?? 0) / 100).toStringAsFixed(0);
      earnedToday.value = ((wallet['total_earned_kobo'] as num? ?? 0) / 100).toStringAsFixed(0);
      availableCpsToday.value = (wallet['click_points'] as num? ?? 0).toString();
      pendingCpsToday.value = "0";
      totalCpsToday.value = (wallet['click_points'] as num? ?? 0).toString();
      usedCpsToday.value = "0";
      referralsToday.value = (referral['referral_count'] as num? ?? 0).toString();
      spinToWinPointsToday.value = "0";
      spinToWinCashToday.value = "0";
      checkinCpsToday.value = "0";
    } catch (_) {
      // Leave defaults — a transient failure here shouldn't block the rest
      // of the wallet screen from rendering.
    }
  }

  // Treasure Hunt has no backend model or endpoint at all (see
  // docs/architecture.md — it's one of the gamification subsystems that
  // was purely client-side Firestore state with no server authority).
  // fetchTreasureHuntWalletData() previously populated its ValueNotifiers
  // from a Firestore 'treasureHunt' subcollection; removed rather than
  // left calling nonexistent data. The associated notifiers keep their
  // default empty-string values, which the UI already treats as "no data".

  @override
  void initState() {
    _walletFuture = _loadWalletBundle();
    getTodayWalletSnapshot();
    getPointsChange();
    fetchTaskEarnings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: FutureBuilder<Map<String, dynamic>>(
                future: _walletFuture,
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
                  if (!snapshot.hasData) {
                    return const Center(child: Text("No data"));
                  }

                  final doc = snapshot.data!;
                  // Every field below maps to a real WalletResponse field
                  // (app/schemas/wallet.py) except the granular
                  // grit/gratis/rps/cps/streak sub-breakdowns further down,
                  // which were never modeled server-side (no per-source
                  // earnings ledger breakdown exists beyond the 7 task
                  // categories tracked in daily_*/total_* — see
                  // fetchTaskEarnings above) — those are left at their
                  // honest zero/default rather than a fabricated number.
                  final String availableEarnings =
                      (((doc['balance_kobo'] as num?) ?? 0) / 100).toStringAsFixed(0);
                  final String availablePoints =
                      ((doc['click_points'] as num?) ?? 0).toString();
                  final String pendingEarnings = "0"; // no pending-vs-available split exists server-side
                  final String withdrawnEarnings =
                      (((doc['total_withdrawn_kobo'] as num?) ?? 0) / 100).toStringAsFixed(0);
                  final String totalEarnings =
                      (((doc['total_earned_kobo'] as num?) ?? 0) / 100).toStringAsFixed(0);
                  final String totalPoints =
                      ((doc['click_points'] as num?) ?? 0).toString();
                  final String usedPoints = "0"; // no used/available split tracked separately
                  final String pendingPoints = "0";
                  final String kycStatus = doc['_kycStatus'] ?? "";
                  final String workerStatus = ""; // no separate "worker status" concept server-side
                  final String withdrawalStatus = "";
                  final String minimumWithdrawal = "500"; // matches the real POST /wallet/withdraw validation
                  final String availableReferralPoints = "0";
                  final String totalReferralPoints = "0";
                  final String usedReferralPoints = "0";
                  final String availableReferralEarnings =
                      (((doc['_referralEarningsKobo'] as num?) ?? 0) / 100).toStringAsFixed(0);
                  final String totalReferralEarnings =
                      (((doc['_referralEarningsKobo'] as num?) ?? 0) / 100).toStringAsFixed(0);
                  final String usedReferralEarnings = "0";
                  final int referrals = (doc['_referralCount'] as int?) ?? 0;
                  final String spinToWinPoints = "0";
                  final String spinToWinCash = "0";
                  final String dailyCheckinTotalCps = "0";

                  // No per-source earnings breakdown (grit/gratis/rps/cps/
                  // streak, each with weekly/monthly variants) is modeled
                  // server-side beyond the 7 task categories already
                  // covered by fetchTaskEarnings above — left at an honest
                  // zero rather than a fabricated number.
                  final int gritEarnings = 0;
                  final int gratisEarnings = 0;
                  final int taskEarnings = ((doc['total_earned_kobo'] as num?) ?? 0) ~/ 100;
                  final int weeklyTaskEarnings = 0;
                  final int monthlyTaskEarnings = 0;
                  final int rpsEarnings = 0;
                  final int weeklyRpsEarnings = 0;
                  final int monthlyRpsEarnings = 0;
                  final int cpsEarnings = 0;
                  final int weeklyCpsEarnings = 0;
                  final int monthlyCpsEarnings = 0;
                  final int streakEarnings = 0;
                  final int weeklyStreakEarnings = 0;
                  final int monthlyStreakEarnings = 0;

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
                            FutureBuilder<List<dynamic>>(
                                future: ApiClient.instance.getTransactions().then(
                                    (txs) => txs.where((t) => t['type'] == 'withdrawal').take(2).toList()),
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
                                  final docs = snapshot.data ?? [];

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
                                                          .format(DateTime.parse(docs[0]['created_at'])),
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
                                                                "completed"
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.1)
                                                            : docs[0]['status'] ==
                                                                    "pending"
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
                                                                  "completed"
                                                              ? Colors.green
                                                              : docs[0]['status'] ==
                                                                      "pending"
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
                                                  "₦${docs[0]['amount_ngn']}",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text("${docs[0]['description'] ?? ''}",
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                Text("${(docs[0]['id'] as String).substring(0, 8)}",
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
                                                          .format(DateTime.parse(docs[1]['created_at'])),
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
                                                                "completed"
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.1)
                                                            : docs[1]['status'] ==
                                                                    "pending"
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
                                                                  "completed"
                                                              ? Colors.green
                                                              : docs[1]['status'] ==
                                                                      "pending"
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
                                                  "₦${docs[1]['amount_ngn']}",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text("${docs[1]['description'] ?? ''}",
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                Text("${(docs[1]['id'] as String).substring(0, 8)}",
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

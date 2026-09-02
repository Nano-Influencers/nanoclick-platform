import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../KYC/user_agreement.dart';
import '../widgets/task_stream.dart';
import 'package:click_workers/services/dashboard_stream.dart';

/// Was backed by three combined Firestore streams (wallet doc, user doc,
/// leaderboard query — see the deleted wallet_stream.dart) plus direct
/// FirebaseAuth.instance.currentUser reads scattered through the widget
/// tree. Now backed by DashboardData, a typed bundle polled from the
/// backend (see lib/services/dashboard_stream.dart) — no
/// FirebaseFirestore/FirebaseAuth left anywhere in this file.
class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.controller,
  });

  final PageController controller;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late YoutubePlayerController _controller;
  bool isLinkClicked = false;

  @override
  initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'OHz0xIR8uwI',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: true,
      ),
    );
  }

  String _formatMoney(num n) {
    return n.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffeeeeee),
        body: StreamBuilder<DashboardData>(
            stream: dashboardStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.black));
              }

              final d = snapshot.data!;
              final user = d.user;
              final wallet = d.wallet;
              final kycVerified = user.kycVerified;
              // No partial-progress concept exists server-side (KYC is a
              // single all-or-nothing submission, not a multi-step wizard
              // with a real percentage) — this maps the four real statuses
              // onto a progress bar as a reasonable approximation rather
              // than an invented precise number.
              final kycProgressValue = switch (d.kycStatus) {
                'approved' => 1.0,
                'pending' => 0.5,
                _ => 0.0,
              };
              final kycButtonLabel = switch (d.kycStatus) {
                'approved' => 'Completed',
                'pending' => 'Pending Review',
                'rejected' => 'Resubmit KYC',
                _ => 'Complete Kyc',
              };
              final initial = user.fullName.isNotEmpty
                  ? user.fullName.trim()[0].toUpperCase()
                  : '?';
              final displayName = user.fullName
                  .split(" ")
                  .where((w) => w.isNotEmpty)
                  .map((w) => w[0].toUpperCase() + w.substring(1))
                  .join(" ");
              final leaderboard = d.leaderboardTop;

              return SingleChildScrollView(
                  child: Center(
                      child: Column(children: [
                SizedBox(height: 3.h),
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
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // No backend field/endpoint for a profile
                              // picture exists yet (see AppUser.photoURL) —
                              // always show an initials avatar.
                              CircleAvatar(
                                  radius: 40,
                                  backgroundColor: const Color(0xffeeeeee),
                                  child: Center(
                                      child: Text(initial,
                                          style: const TextStyle(
                                              fontSize: 40,
                                              color: Colors.black,
                                              fontWeight:
                                                  FontWeight.bold)))),
                              SizedBox(width: 3.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    kycVerified ? "  verified" : "  Non verified",
                                    style: TextStyle(
                                        color: kycVerified
                                            ? Colors.white
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              SizedBox(width: 1.w),
                              kycVerified
                                  ? const Icon(Icons.check_circle,
                                      color: Color(0xff22c55e), size: 22)
                                  : const SizedBox(
                                      height: 0,
                                    )
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(children: [
                                  const Text("Total click Points",
                                      style:
                                          TextStyle(color: Color(0xffd1d5db))),
                                  Text(
                                      _formatMoney(
                                          (wallet['click_points'] as num?) ?? 0),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ]),
                                Column(children: [
                                  const Text("Current Rank",
                                      style:
                                          TextStyle(color: Color(0xffd1d5db))),
                                  Text("Grit Lv. ${d.gritLevel}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))
                                ]),
                              ])
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                SizedBox(
                    width: 90.w,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(15),
                              width: 40.w,
                              decoration: BoxDecoration(
                                  color: const Color(0xffb0b2b7),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(children: [
                                const Text("Total Earnings",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff6b7280),
                                    )),
                                SizedBox(height: 1.h),
                                Text(
                                    "₦${_formatMoney(((wallet['total_earned_kobo'] as num?) ?? 0) / 100)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ])),
                          Container(
                              padding: const EdgeInsets.all(15),
                              width: 40.w,
                              decoration: BoxDecoration(
                                  color: const Color(0xffb0b2b7),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(children: [
                                const Text("Available Balance",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff6b7280),
                                    )),
                                SizedBox(height: 1.h),
                                Text(
                                    "₦${_formatMoney(((wallet['balance_kobo'] as num?) ?? 0) / 100)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ])),
                        ])),
                SizedBox(
                  height: 3.h,
                ),
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
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const CircleAvatar(
                                  radius: 15,
                                  child: Icon(Icons.account_circle,
                                      color: Colors.black),
                                ),
                                SizedBox(width: 2.w),
                                const Text("Kyc Status",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ]),
                              ElevatedButton(
                                onPressed: () {
                                  if (d.kycStatus == 'approved' ||
                                      d.kycStatus == 'pending') {
                                    // Nothing to do — already submitted or
                                    // approved.
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserAgreement()),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(kycButtonLabel,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Progress",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Text(
                                    '${(kycProgressValue * 100).round()}%',
                                    style: const TextStyle(
                                        color: Color(0xff6b7280),
                                        fontSize: 12)),
                              ]),
                          SizedBox(height: 1.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: kycProgressValue,
                              minHeight: 6,
                              backgroundColor: const Color(0xffd9d9d9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: const Text("Task Summary",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: Card(
                    elevation: 6, // adds shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Ongoing Task",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(d.ongoingTasks.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          const Divider(color: Color(0xffd1d5db), thickness: 2),
                          SizedBox(height: 1.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Completed Task",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(d.completedTasks.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff22c55e))),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          const Divider(color: Color(0xffd1d5db), thickness: 2),
                          SizedBox(height: 1.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Missed Task",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(d.missedTasks.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffff0000))),
                            ],
                          ),
                          SizedBox(height: 1.h),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: 90.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Trending Tasks",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {
                            widget.controller.jumpToPage(1);
                          },
                          child: const Text("see more",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6b7280))))
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: const TaskStream(
                    isVertical: true,
                    limit: 2,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 90.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Leader Board",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () {
                            widget.controller.jumpToPage(2);
                          },
                          child: const Text("View All",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff6b7280))))
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                if (leaderboard.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: const Text("No leaderboard data yet",
                        style: TextStyle(color: Color(0xff6b7280))),
                  )
                else
                  ...List.generate(leaderboard.length, (i) {
                    final entry = leaderboard[i];
                    final rankColors = [
                      const Color(0xffffb33a),
                      const Color(0xffd9d9d9),
                      const Color(0xffa67629)
                    ];
                    final initials =
                        entry.fullName.isNotEmpty ? entry.fullName[0].toUpperCase() : '?';
                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: SizedBox(
                        width: 90.w,
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: Row(children: [
                                CircleAvatar(
                                    radius: 22,
                                    backgroundColor: rankColors[i],
                                    child: Text("${i + 1}")),
                                SizedBox(width: 2.w),
                                CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xffeeeeee),
                                    child: Text(initials,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                                SizedBox(width: 3.w),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.fullName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          "${_formatMoney(entry.score)} points",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ])
                              ])),
                        ),
                      ),
                    );
                  }),
                SizedBox(height: 2.h),
                SizedBox(
                  width: 90.w,
                  child: const Text("Achievements",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                    width: 90.w,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Level Progress (Grit)",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Text("Level ${d.gritLevel}",
                                    style: const TextStyle(
                                        color: Color(0xff6b7280),
                                        fontSize: 12)),
                              ]),
                          SizedBox(height: 1.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: d.gritLevel >= 10
                                  ? 1.0
                                  : 1 - (d.gritTasksToNextLevel / 20),
                              minHeight: 6,
                              backgroundColor: const Color(0xffd9d9d9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                              d.gritLevel >= 10
                                  ? "Max level reached!"
                                  : "${d.gritTasksToNextLevel} difficult tasks to next level",
                              style: const TextStyle(
                                  color: Color(0xff6b7280), fontSize: 12)),
                        ])),
                SizedBox(height: 2.h),
                 SizedBox(height: 2.h),
                  Center(
                  child: Container(
                      width: 85.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffd9d9d9),
                        borderRadius:
                            BorderRadius.circular(16), // 👈 Rounded corners
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: YoutubePlayer(
                          controller: _controller,
                          aspectRatio: 16 / 9,
                        ),
                      )),
                ),
                SizedBox(height: 4.h),
                Container(
                    width: 85.w,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xfffe6929),
                          Color(0xfff45e2a),
                          Color(0xffc23707),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Refer & Earn 5% Extra",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 2.h),
                          const Text(
                              "Invite your friends to join ClickWorkers and earn 5% of their earnings for life. The more friends you refer, the more you earn",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          SizedBox(height: 3.h),
                          const Text("Your Referral Link",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 2.h),
                          Container(
                              padding: const EdgeInsets.only(right: 1.0),
                              width: 80.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width: 58.w,
                                        height: 8.h,
                                        decoration: const BoxDecoration(
                                          color: Color(0xfffe6929),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(30.0),
                                            topLeft: Radius.circular(30.0),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                              "https://click-workers.com/${user.referralCode}",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        )),
                                    InkWell(
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text:
                                                  "https://click-workers.com/${user.referralCode}"));
                                          setState(() {
                                            isLinkClicked = true;
                                          });
                                        },
                                        child: Container(
                                            width: 50,
                                            padding: const EdgeInsets.all(5),
                                            child: isLinkClicked
                                                ? const Icon(Icons.check,
                                                    color: Color(0xfffe6929),
                                                    size: 12)
                                                : const Text(" Copy",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xfffe6929),
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                  ])),
                          SizedBox(height: 2.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Referrals:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                Text(
                                    "${d.referralCount} person(s)",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ]),
                          SizedBox(height: 1.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Earnings from Referrals:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                Text("₦${_formatMoney(d.totalReferralEarningsKobo / 100)}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ]),
                        ])),
                SizedBox(height: 3.h),
              ])));
            }));
  }
}

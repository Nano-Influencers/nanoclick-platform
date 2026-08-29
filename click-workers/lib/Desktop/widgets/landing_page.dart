import 'dart:async';

import 'package:click_workers/Desktop/home/home.dart';
import 'package:click_workers/Desktop/rewards/leaderboard.dart';
import 'package:click_workers/Desktop/widgets/desktop_footer.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  FirebaseFirestore? otherFirestore;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _subscribeController = TextEditingController();
  Timer? timer;
  late YoutubePlayerController _controller2;
  late YoutubePlayerController _controller;
  PageController? _innerController;
  int _currentInnerPage = 0;
  Timer? _innerTimer;
  bool dropdown1 = false;
  bool dropdown2 = false;
  bool dropdown3 = false;
  bool dropdown4 = false;
  bool dropdown5 = false;

  // int _currentPage2 = 0;

  //initialize other firestore
  Future<void> readFromOtherFirestore() async {
    final otherApp = await Firebase.initializeApp(
        name: "Nano Influencers",
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCgGNNEtmU5ZDZFsNbGMpRO5TSY_fL8wmU',
          appId: '1:881328477265:web:ddd3979fd0d79742101470',
          messagingSenderId: '881328477265',
          projectId: 'nano-influencers',
          authDomain: 'nano-influencers.firebaseapp.com',
          storageBucket: 'nano-influencers.appspot.com',
        ));

    setState(() {
      otherFirestore = FirebaseFirestore.instanceFor(app: otherApp);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'OHz0xIR8uwI',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: true,
      ),
    );
    _controller2 = YoutubePlayerController.fromVideoId(
      videoId: 'OHz0xIR8uwI',
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: false),
    );
    _controller.loadVideoById(videoId: 'OHz0xIR8uwI');
    _controller2.loadVideoById(videoId: 'OHz0xIR8uwI');
    readFromOtherFirestore();
    _innerController = PageController(
      viewportFraction: 0.85, // 👈
    );

    _innerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_innerController == null) return;
      if (!_innerController!.hasClients) return;

      _currentInnerPage++;

      if (_currentInnerPage >= 2) {
        _currentInnerPage = 0;
      }

      _innerController!.animateToPage(
        _currentInnerPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _innerTimer?.cancel();
    _innerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xffff6533),
          elevation: 0,
          centerTitle: false,
          title: Image.asset(
            "assets/logo.png",
            height: 6.h,
            width: 15.w,
            fit: BoxFit.contain,
          ),
          actions: [
            const Text(
                textAlign: TextAlign.center,
                'Home',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              width: 2.w,
            ),
            const Text(
                textAlign: TextAlign.center,
                'How it Works',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              width: 2.w,
            ),
            const Text(
                textAlign: TextAlign.center,
                'Tasks',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              width: 2.w,
            ),
            const Text(
                textAlign: TextAlign.center,
                'Rewards',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              width: 2.w,
            ),
            const Text(
                textAlign: TextAlign.center,
                'Leaderboard',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              width: 20.w,
            ),
            _button(
              onTap: () {},
              height: 35,
              width: 80,
              text: 'Login',
              isBorderSide: true,
            ),
            SizedBox(
              width: 1.w,
            ),
            _button(
              onTap: () {},
              height: 35,
              width: 80,
              text: 'Sign up',
              isBorderSide: false,
            ),
            SizedBox(
              width: 3.w,
            ),
          ],
        ),
        body: otherFirestore == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('leaderboard')
                    .orderBy('clickPoints', descending: true)
                    .limit(6)
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

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 460,
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.start,
                                        text: const TextSpan(
                                            text: "Advertise/promote ",
                                            style: TextStyle(
                                                fontSize: 28,
                                                color: Color(0xffff6533),
                                                fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      "for brands,\nperform simple tasks, earn\nmoney & win gifts no skill\nrequired",
                                                  style: TextStyle(
                                                      fontSize: 28,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ]),
                                      ),
                                      SizedBox(height: 2.h),
                                      const Text(
                                        "Get paid to advertise, complete easy tasks, and represent top brands. It’s simple,\nfun, and free to start — no experience required!",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 3.h),
                                      Row(
                                        children: [
                                          _button(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const DesktopHomeScreen(),
                                                  ));
                                            },
                                            height: 35,
                                            width: 95,
                                           text: 'Get Started',
                                            isBorderSide: false,
                                          ),
                                          SizedBox(
                                            width: 1.w,
                                          ),
                                          _button(
                                            onTap: () {},
                                            height: 35,
                                            width: 95,
                                            text: 'Explore Tasks',
                                            isBorderSide: true,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    'assets/social_media.gif',
                                    height: 400,
                                    width: 400,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        const Text(
                          textAlign: TextAlign.center,
                          'How it Works',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          textAlign: TextAlign.center,
                          'Join thousands of people who earn money and win prizes by completing simple tasks in their free time.',
                          style: TextStyle(
                              color: Color(0xff33393E),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        Wrap(
                          spacing: 1.5.w,
                          runSpacing: 1.5.w,
                          children: [
                            howItWorksCard(
                              image: "assets/profile_plus.png",
                              title: 'Free Sign Up & Verification',
                              description:
                                  'Register and complete KYC to unlock all features.',
                            ),
                            howItWorksCard(
                              image: "assets/choose.png",
                              title: 'Choose Tasks',
                              description:
                                  'Browse Ads task, complete them, and submit proof.',
                            ),
                            howItWorksCard(
                              image: "assets/earn.png",
                              title: 'Earn Money & Points',
                              description:
                                  'Get paid for publishing ads for brands or promoting brands, climb the leaderboard and win cash prizes, and unlock massive cash and item rewards',
                            ),
                            howItWorksCard(
                              image: "assets/atm_card.png",
                              title: 'Withdraw Earnings',
                              description:
                                  'Cash out via secure payment options',
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                textAlign: TextAlign.center,
                                'Featured Tasks',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              const Text(
                                textAlign: TextAlign.center,
                                'Easy gigs. Your next reward is one task away. Start earning now!',
                                style: TextStyle(
                                    color: Color(0xff33393E),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(children: [
                                  taskCard(
                                      text: 'All Task', isBorderSide: true),
                                  taskCard(
                                    text: 'Repeating',
                                  ),
                                  taskCard(
                                    text: 'High-Earning Task',
                                  ),
                                  taskCard(
                                    text: 'High-Point ',
                                  ),
                                  taskCard(
                                    text: 'Simple Task',
                                  ),
                                  taskCard(
                                    text: 'Reward Task',
                                  ),
                                ]),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Wrap(
                                spacing: 1.5.w,
                                runSpacing: 1.5.w,
                                children: [
                                  trendingTaskCard(
                                    "Like 10 Posts",
                                    "Browse through community posts and like 10 relevant post",
                                    '100 pts',
                                    const Color(0xff22C55E),
                                    const Color(0xff22C55E),
                                    'Simple',
                                  ),
                                  trendingTaskCard(
                                      'Marketing Campaign',
                                      "Create a viral marketing campaign for our upcoming product launch",
                                      'N100,000 pts ',
                                      const Color(0xffFF0000),
                                      const Color(0xffFF0000),
                                      'Urgent Contest'),
                                  trendingTaskCard(
                                      'Marketing Campaign',
                                      "Create a viral marketing campaign for our upcoming product launch",
                                      'N100,000 pts ',
                                      const Color(0xffFF0000),
                                      const Color(0xffFF0000),
                                      'Urgent Contest'),
                                  trendingTaskCard(
                                    "Like 10 Posts",
                                    "Browse through community posts and like 10 relevant post",
                                    '100 pts',
                                    const Color(0xff22C55E),
                                    const Color(0xff22C55E),
                                    'Simple',
                                  ),
                                  trendingTaskCard(
                                      'Marketing Campaign',
                                      "Create a viral marketing campaign for our upcoming product launch",
                                      'N100,000 pts ',
                                      const Color(0xffFF0000),
                                      const Color(0xffFF0000),
                                      'Urgent Contest'),
                                  trendingTaskCard(
                                      'Marketing Campaign',
                                      "Create a viral marketing campaign for our upcoming product launch",
                                      'N100,000 pts ',
                                      const Color(0xffFF0000),
                                      const Color(0xffFF0000),
                                      'Urgent Contest'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        const Text(
                          textAlign: TextAlign.center,
                          'Featured Tasks',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        const Text(
                          textAlign: TextAlign.center,
                          'Easy gigs. Your next reward is one task away. Start earning now!',
                          style: TextStyle(
                              color: Color(0xff33393E),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Wrap(
                          spacing: 1.5.w,
                          runSpacing: 1.5.w,
                          children: [
                            leaderBoardCard(
                              circleColor: const Color(0xFF9CA3AF),
                              color: const Color(0xffF5F6F8),
                              boardNum: '2',
                              image: docs[1]['dp'] != ''
                                  ? NetworkImage(docs[1]['dp'])
                                  : const NetworkImage(
                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1752572842/1d05d59e2312732dd6546e4a1b3357770704b778_1_ojexwk.png"),
                              referral: docs[1]['referrals']
                                  .toString()
                                  .replaceAllMapped(
                                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                      (match) => ','),
                              clickPoints:
                                  "${docs[1]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                              performanceScore: docs[0]['performanceScore']
                                  .toString()
                                  .replaceAllMapped(
                                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                      (match) => ','),
                              approvalScore:
                                  "₦${docs[1]['approvalScore'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                            ),
                            leaderBoardCard(
                              color: const Color(0xfffefad1),
                              boardOne: true,
                              circleColor: const Color(0xFFEAB308),
                              boardNum: '1',
                              image: docs[0]['dp'] != ''
                                  ? NetworkImage(docs[0]['dp'])
                                  : const NetworkImage(
                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png"),
                              referral: docs[0]['referrals']
                                  .toString()
                                  .replaceAllMapped(
                                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                      (match) => ','),
                              clickPoints:
                                  "${docs[0]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                              performanceScore: docs[0]['performanceScore']
                                  .toString()
                                  .replaceAllMapped(
                                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                      (match) => ','),
                              approvalScore:
                                  "₦${docs[0]['approvalScore'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                            ),
                            leaderBoardCard(
                              circleColor: const Color(0xFFF97316),
                              color: const Color(0xffFFF1DE),
                              boardNum: '3',
                              image: docs[2]['dp'] != ''
                                  ? NetworkImage(docs[2]['dp'])
                                  : const NetworkImage(
                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1752572843/d20f43a765e6ed6ac3bdea39b6be2ea6b6b1193c_o9xsf1.png"),
                              referral: docs[2]['referrals']
                                  .toString()
                                  .replaceAllMapped(
                                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                      (match) => ','),
                              clickPoints:
                                  "${docs[2]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                              performanceScore: docs[2]['performanceScore']
                                  .toString()
                                  .replaceAllMapped(
                                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                      (match) => ','),
                              approvalScore:
                                  "₦${docs[2]['approvalScore'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                            )
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        ...List.generate(
                          performance.take(3).length,
                          (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: performanceItem(performance[index]),
                            );
                          },
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignIn()),
                              );
                            },
                            child: const Text("View full leaderboard ↗")),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(1.5.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 1.h,
                              ),
                              const Text("Why Choose ClickWorkers?",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              SizedBox(height: 2.h),
                              const Text(
                                  textAlign: TextAlign.center,
                                  "Join thousands of Nigerians who are earning money through our platform",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xff33393e))),
                              SizedBox(height: 7.h),
                              Wrap(
                                runSpacing: 1.5.w,
                                spacing: 1.5.w,
                                children: [
                                  clickWorkersCard(
                                    isIcon: true,
                                    icon: Icons.schedule,
                                    title: 'Flexible Work',
                                    description:
                                        "Work anytime, anywhere with absolutely no skills required. Perfect for students, stay-at-home parents, or anyone looking for extra income.",
                                  ),
                                  clickWorkersCard(
                                    image: 'chart',
                                    title: "No Investment Required",
                                    description:
                                        "Start earning immediately without funding your wallet or paying any fees. We believe in providing opportunities, not taking your money.",
                                  ),
                                  clickWorkersCard(
                                    image: 'game',
                                    title: "Gamified Experience",
                                    description:
                                        "Earn rewards through leaderboards, treasure hunts, and spins. Win cash prizes from ₦50,000 to ₦2.5M, gadgets, event tickets, and more",
                                  ),
                                  clickWorkersCard(
                                    image: 'atm_card',
                                    title: "Fast Payouts",
                                    description:
                                        "Withdraw your earnings without delays. Our efficient payment system ensures you get your money when you need it.",
                                  ),
                                  clickWorkersCard(
                                    isIcon: true,
                                    icon: Icons.workspace_premium_sharp,
                                    title: "No. 1 in Africa",
                                    description:
                                        "We partner with numerous advertising companies, task platforms, and gift-sharing services to ensure you always have opportunities to earn.",
                                  ),
                                  clickWorkersCard(
                                    isIcon: true,
                                    icon: Icons.verified_user_sharp,
                                    title: "Secure & Trusted",
                                    description:
                                        "Join thousands of satisfied users who trust ClickWorkers for reliable income. Our platform is secure, transparent, and user-friendly",
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(
                                                  10))),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignIn()),
                                    );
                                  },
                                  child: const Text("Join Now"))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        const Text("Why Choose ClickWorkers?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 2.h),
                        const Text(
                            textAlign: TextAlign.center,
                            "Join thousands of Nigerians who are earning money through our platform",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xff33393e))),
                        SizedBox(height: 5.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                          child: Wrap(
                            runSpacing: 1.5.w,
                            spacing: 1.5.w,
                            children: [
                              clickWorksCards(
                                image:
                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584324/dfd70265b6c97dc2786bd118f98dfa0858e4ecaf_1_wpnljm.png",
                                title: '"Theresa Webb"',
                                subTitle: "Entrepreneur, Lagos",
                                priFixText: "⭐️⭐️⭐️⭐️⭐️",
                                priFixSubText:
                                    "Won a MacBook Air worth ₦750,000",
                                description:
                                    '"I was skeptical at first, but ClickWorkers has been a game-changer for me. As a student, I′ve been able to earn enough to cover my expenses and even save some money. The tasks are simple and the payment is always on time!"',
                              ),
                              clickWorksCards(
                                image:
                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584323/0c26d887ed060b47018885c4c6847048f8a83758_ktjqvs.png",
                                title: '""Esther Howards""',
                                subTitle: "Entreprenuer, Lagos",
                                priFixText: "⭐️⭐️⭐️⭐️⭐️",
                                priFixSubText: "Earned ₦480,000 in 6 months",
                                description:
                                    '"I won a brand new laptop through the treasure hunt feature! I couldn′t believe it at first. The platform is not just about completing tasks - the gamification makes it fun and rewarding. Now I recommend it to everyone I know."',
                              ),
                              clickWorksCards(
                                image:
                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584325/83ab462a89a08fdba266b544d03bce6d41e497cd_qcylbx.png",
                                title: "Ralph Edwards",
                                subTitle: "Student, Lagos",
                                priFixText: "⭐️⭐️⭐️⭐️⭐️",
                                priFixSubText: "Earned ₦303,200 in 3 months",
                                description:
                                    '"As a stay-at-home mom, I needed a flexible way to contribute to our family income. ClickWorkers has been perfect! I complete tasks during my free time and have earned enough to pay for my children′s school fees. The platform is so easy to use!"',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.5.w),
                          child: SizedBox(
                            width: double.infinity,
                            height: 260,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 300,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffd9d9d9),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: YoutubePlayer(
                                              controller: _controller2,
                                              aspectRatio: 19 / 9,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2.w,
                                        ),

                                        /// ================= TEXT PAGE =================
                                        Container(
                                          padding: EdgeInsets.all(1.5.w),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: const Color(0xffa0aab2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '"How I Earned ₦500,000 in One Month"',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              const Text(
                                                "Blessing Adekunle shares her journey from struggling to pay bills to becoming a top earner on ClickWorkers.",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xffa0aab2),
                                                ),
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 25,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584325/9265f6e3e22a4d011fdf9bee1bc447fd54300962_riqkfc.png",
                                                    ),
                                                  ),
                                                  SizedBox(width: 3.w),
                                                  const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Blessing Adekunle",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Student, Lagos",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Color(0xffa0aab2),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 2.h),
                                const Text("How it Works",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                SizedBox(height: 2.h),
                                const Text(
                                    textAlign: TextAlign.center,
                                    "Join thousands of people who earn money and win prizes by completing simple tasks in their free time.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xff33393e))),
                                SizedBox(height: 3.h),
                                Wrap(
                                  runSpacing: 1.5.w,
                                  spacing: 1.5.w,
                                  children: [
                                    howItWorkItems(
                                      title: "Treasure Hunt",
                                      description:
                                          "Find hidden rewards in ads and tasks. Discover treasure boxes worth up to ₦50,000 in cash and points.",
                                      image: "assets/treasure.png",
                                    ),
                                    howItWorkItems(
                                      title: "Spin & Win",
                                      description:
                                          "Exchange earnings for bonus points to climb the leaderboard and win millions in cash and item rewards.",
                                      image: "assets/spin.png",
                                    ),
                                    howItWorkItems(
                                        title: "Achievements & Badges",
                                        description:
                                            "Get recognized for completing milestones. Earn exclusive badges and unlock special rewards.",
                                        isIcon: true)
                                  ],
                                )
                              ],
                            )),
                        SizedBox(
                          height: 3.h,
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 6.5.w),
                            padding: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              color: const Color(0xffEEEEEE),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(children: [
                              SizedBox(height: 2.h),
                              const Text("Video Walkthrough/Demo"),
                              SizedBox(height: 2.h),
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.5.w),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                              width: double.infinity,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: const Color(0xffd9d9d9),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        16), // 👈 Rounded corners
                                              ),
                                              child: YoutubePlayer(
                                                controller: _controller,
                                                aspectRatio: 16 / 9,
                                              )),
                                          SizedBox(height: 4.h),
                                          Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(25),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30), // 👈 rounded corners
                                                border: Border.all(
                                                  color:
                                                      const Color(0xffa0aab2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(children: [
                                                const Text(
                                                    textAlign: TextAlign.center,
                                                    'How to Earn Money online with Click Workers',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(height: 2.h),
                                                const Text(
                                                    textAlign: TextAlign.center,
                                                    "A 30-60 second video explaining how Click Workers works.",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xffa0aab2))),
                                              ])),
                                        ]),
                                  ),
                                ),
                              ),
                            ])),
                        SizedBox(height: 3.h),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Live Activity Feed",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      elevation: 6, // adds shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      color: const Color(0xffced7f8),
                                      child: Padding(
                                          padding: EdgeInsets.all(1.5.w),
                                          child: Row(children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: const BoxDecoration(
                                                  color: Color(
                                                      0xff8ba3fb), // light peach circle
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                    Icons.checklist_outlined,
                                                    color: Color(0xff2756ff))),
                                            SizedBox(width: 4.w),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                      text: const TextSpan(
                                                          text:
                                                              "Adebayo from Lagos just completed a Twitter task and earned ",
                                                          children: [
                                                        TextSpan(
                                                            text: "₦500!",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff2756FF)))
                                                      ])),
                                                  SizedBox(height: 1.h),
                                                  const Text("2 Minutes ago",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xff6b7280))),
                                                ])
                                          ])),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      elevation: 6, // adds shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      color: const Color(0xfff6d6cb),
                                      child: Padding(
                                          padding: EdgeInsets.all(1.5.w),
                                          child: Row(children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: const BoxDecoration(
                                                  color: Color(
                                                      0xfff88f6b), // light peach circle
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Image.asset(
                                                    "assets/treasure.png",
                                                    scale: 1.5)),
                                            SizedBox(width: 4.w),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                      text: const TextSpan(
                                                          text:
                                                              "Ngozi unlocked a treasure box worth ",
                                                          children: [
                                                        TextSpan(
                                                            text: "100 Points!",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffff6533)))
                                                      ])),
                                                  SizedBox(height: 1.h),
                                                  const Text("5 Minutes ago",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xff6b7280))),
                                                ])
                                          ])),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      elevation: 6, // adds shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      color: const Color(0xfff1d2fd),
                                      child: Padding(
                                          padding: EdgeInsets.all(1.5.w),
                                          child: Row(children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: const BoxDecoration(
                                                  color: Color(
                                                      0xffd779f9), // light peach circle
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                    Icons
                                                        .workspace_premium_sharp,
                                                    color: Color(0xffc830ff))),
                                            SizedBox(width: 4.w),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                      text: const TextSpan(
                                                          text:
                                                              "Emeka ranked up to ",
                                                          children: [
                                                        TextSpan(
                                                            text: "Pro User ",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffc830ff))),
                                                        TextSpan(
                                                          text: "this week!",
                                                        ),
                                                      ])),
                                                  SizedBox(height: 1.h),
                                                  const Text("10 Minutes ago",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xff6b7280))),
                                                ])
                                          ])),
                                    ),
                                  ),
                                ])),
                        Container(
                            color: const Color(0xffeeeeee),
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 2.h),
                                          const Text("FAQs",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          SizedBox(height: 2.h),
                                          RichText(
                                              text: const TextSpan(
                                                  text:
                                                      "Find answers to common\nquestions about",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                  children: [
                                                TextSpan(
                                                    text: " ClickWorkers",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xffff6533)))
                                              ])),
                                          SizedBox(height: 2.h),
                                          const Text("Still have questions?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                          const Text("Contact our support team",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                      Center(
                                        child: SizedBox(
                                          width: 350,
                                          child: Card(
                                            elevation: 6, // adds shadow
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            color: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Divider(
                                                        thickness: 2,
                                                        color: Colors.black),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                              " How do I start earning?",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          IconButton(
                                                              icon: dropdown1
                                                                  ? const Icon(Icons
                                                                      .keyboard_arrow_up)
                                                                  : const Icon(Icons
                                                                      .keyboard_arrow_down),
                                                              onPressed: () {
                                                                setState(() {
                                                                  dropdown1 =
                                                                      !dropdown1;
                                                                });
                                                              })
                                                        ]),
                                                    dropdown1
                                                        ? const Text(
                                                            "This is a random body of text, a placeholder, it is to be changed")
                                                        : const SizedBox(
                                                            height: 0),
                                                    dropdown1
                                                        ? SizedBox(height: 1.h)
                                                        : const SizedBox(
                                                            height: 0),
                                                    const Divider(
                                                        thickness: 2,
                                                        color: Colors.black),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                              " What type of ads and social\n tasks are available?",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          IconButton(
                                                              icon: dropdown2
                                                                  ? const Icon(Icons
                                                                      .keyboard_arrow_up)
                                                                  : const Icon(Icons
                                                                      .keyboard_arrow_down),
                                                              onPressed: () {
                                                                setState(() {
                                                                  dropdown2 =
                                                                      !dropdown2;
                                                                });
                                                              })
                                                        ]),
                                                    dropdown2
                                                        ? const Text(
                                                            "This is a random body of text, a placeholder, it is to be changed")
                                                        : const SizedBox(
                                                            height: 0),
                                                    dropdown2
                                                        ? SizedBox(height: 1.h)
                                                        : const SizedBox(
                                                            height: 0),
                                                    const Divider(
                                                        thickness: 2,
                                                        color: Colors.black),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                              " How does withdrawal work?",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          IconButton(
                                                              icon: const Icon(Icons
                                                                  .keyboard_arrow_down),
                                                              onPressed: () {
                                                                setState(() {
                                                                  dropdown3 =
                                                                      !dropdown3;
                                                                });
                                                              })
                                                        ]),
                                                    dropdown3
                                                        ? const Text(
                                                            "This is a random body of text, a placeholder, it is to be changed")
                                                        : const SizedBox(
                                                            height: 0),
                                                    dropdown3
                                                        ? SizedBox(height: 1.h)
                                                        : const SizedBox(
                                                            height: 0),
                                                    const Divider(
                                                        thickness: 2,
                                                        color: Colors.black),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                              " What happens if my task\n submission is rejected?",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          IconButton(
                                                              icon: const Icon(Icons
                                                                  .keyboard_arrow_down),
                                                              onPressed: () {
                                                                setState(() {
                                                                  dropdown4 =
                                                                      !dropdown4;
                                                                });
                                                              })
                                                        ]),
                                                    dropdown4
                                                        ? const Text(
                                                            "This is a random body of text, a placeholder, it is to be changed")
                                                        : const SizedBox(
                                                            height: 0),
                                                    dropdown4
                                                        ? SizedBox(height: 1.h)
                                                        : const SizedBox(
                                                            height: 0),
                                                    const Divider(
                                                        thickness: 2,
                                                        color: Colors.black),
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                              " Is ClickWorkers available in my\n country?",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          IconButton(
                                                              icon: dropdown5
                                                                  ? const Icon(Icons
                                                                      .keyboard_arrow_up)
                                                                  : dropdown5
                                                                      ? const Icon(
                                                                          Icons
                                                                              .keyboard_arrow_up)
                                                                      : const Icon(
                                                                          Icons
                                                                              .keyboard_arrow_down),
                                                              onPressed: () {
                                                                setState(() {
                                                                  dropdown5 =
                                                                      !dropdown5;
                                                                });
                                                              })
                                                        ]),
                                                    dropdown5
                                                        ? const Text(
                                                            "This is a random body of text, a placeholder, it is to be changed")
                                                        : const SizedBox(
                                                            height: 0),
                                                    dropdown5
                                                        ? SizedBox(height: 1.h)
                                                        : const SizedBox(
                                                            height: 0),
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]))),
                        Container(
                            color: Colors.white,
                            width: double.infinity,
                            child: Padding(
                                padding: EdgeInsets.all(6.w),
                                child: Column(children: [
                                  Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            Color(0xfffe6929),
                                            Color(0xfff45e2a),
                                            Color(0xffc23707),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(children: [
                                        const Text("Join ClickWorkers Today!",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        SizedBox(height: 3.h),
                                        const Text(
                                            textAlign: TextAlign.center,
                                            "Start earning money, winning prizes, and building your future with Africa's #1 earning platform.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        SizedBox(height: 3.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    fixedSize:
                                                        const Size(160, 35)),
                                                onPressed: () {},
                                                child: const Text("Sign Up Now",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                            0xffff6533)))),
                                            SizedBox(width: 2.w),
                                            OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  fixedSize:
                                                      const Size(310, 35),
                                                  backgroundColor:
                                                      const Color(0x00000000),
                                                  side: const BorderSide(
                                                      color: Colors.white,
                                                      width: 2),
                                                ),
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const SignIn()),
                                                  );
                                                },
                                                child: const Text(
                                                    "Already a member? Login",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white)))
                                          ],
                                        )
                                      ])),
                                  SizedBox(height: 4.h),
                                  Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            Color(0xfffe6929),
                                            Color(0xfff45e2a),
                                            Color(0xffc23707),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("250,000+",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                Text("Active Users",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                            SizedBox(width: 3.w),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("8.2M+",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                Text("Tasks Completed",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                            SizedBox(width: 3.w),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("₦209.5M+",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                Text("Paid to Users",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                            SizedBox(width: 3.w),
                                            const Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("65,000+",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                Text("Prizes Awarded",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            )
                                          ]))
                                ]))),
                        Container(
                            width: double.infinity,
                            color: const Color(0xffeeeeee),
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(children: [
                                  const Text("Subscribe to our newsletter",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 3.h),
                                  const Text(
                                      textAlign: TextAlign.center,
                                      "Stay up to date with ClickWorkers for the latest updates, tips, and news",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 3.h),
                                  Container(
                                      padding:
                                          const EdgeInsets.only(right: 1.0),
                                      width: 450,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          color: Colors.white,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                width: 340,
                                                height: 40,
                                                padding: const EdgeInsets.only(
                                                    left: 20),
                                                decoration: const BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(30.0),
                                                    topLeft:
                                                        Radius.circular(30.0),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: TextField(
                                                    controller:
                                                        _subscribeController,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 1.2.h),
                                                      border: InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      hintText: 'Your Email',
                                                    ),
                                                  ),
                                                )),
                                            Container(
                                                width: 100,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xffff6533),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(30.0),
                                                    topRight:
                                                        Radius.circular(30.0),
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Center(
                                                  child: Text(" Subscribe",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          height: 0.5,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )),
                                          ])),
                                ]))),
                        DesktopFooter(scrollController: _scrollController),
                      ],
                    ),
                  );
                }));
  }

  _button({
    required double height,
    required double width,
    required String text,
    bool isBorderSide = false,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: width,
          height: height,
          alignment: AlignmentGeometry.center,
          padding: EdgeInsets.all(0.4.w),
          decoration: BoxDecoration(
            color: isBorderSide ? Colors.white : const Color(0xffFF6533),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: isBorderSide ? 0 : 2,
                color: isBorderSide
                    ? const Color(0xffFF6533)
                    : const Color(0xffFF6533)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            textAlign: TextAlign.center,
            text,
            style: TextStyle(
                color: isBorderSide ? const Color(0xffFF6533) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal),
          )),
    );
  }

  howItWorksCard(
      {required String image,
      required String title,
      required String description}) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
          width: 350,
          height: 250,
          padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEDE4), // light peach circle
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  image,
                  height: 25,
                  width: 25,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xffa0aab2),
                ),
              ),
            ],
          )),
    );
  }

  taskCard({required String text, bool isBorderSide = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            color: isBorderSide ? const Color(0xffff6533) : Colors.white,
            border: Border.all(
                color: isBorderSide
                    ? const Color(0xffff6533)
                    : const Color(0xffa0aab2),
                width: isBorderSide ? 0 : 1),
            borderRadius: BorderRadius.circular(30), // Optional rounded corners
          ),
          child: Text(text,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
    );
  }

  trendingTaskCard(String title, String description, String points,
      Color conatinerColor, Color containerTextColor, String containerTextC) {
    return Card(
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 350,
        height: 180,
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: conatinerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                      textAlign: TextAlign.center,
                      containerTextC,
                      style:
                          TextStyle(fontSize: 10, color: containerTextColor)),
                ),
                const Spacer(),
                Image.asset(
                  "assets/icons/flag.png",
                  height: 11,
                  width: 11,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 1.h),
            Text(description,
                style: const TextStyle(color: Color(0xff6B7280), fontSize: 12)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Text(points,
                    style: const TextStyle(color: Colors.green, fontSize: 12)),
                SizedBox(width: 2.w),
                const Text('10mins ago',
                    style: TextStyle(color: Color(0xff6B7280), fontSize: 11)),
                const Spacer(),
                SizedBox(
                  width: 50,
                  height: 25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Accept",
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  leaderBoardCard({
    bool boardOne = false,
    required String boardNum,
    required ImageProvider image,
    required String referral,
    required String clickPoints,
    required String performanceScore,
    required String approvalScore,
    required Color color,
    required Color circleColor,
  }) {
    return SizedBox(
      width: 350,
      child: Card(
        elevation: 6, // adds shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: color,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              boardOne
                  ? Image.asset("assets/first_place.png")
                  : const SizedBox.shrink(),
              SizedBox(height: 2.h),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: circleColor, // light peach circle
                  shape: BoxShape.circle,
                ),
                child: Text(boardNum,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              SizedBox(height: 2.h),
              CircleAvatar(
                radius: 50,
                backgroundImage: image,
              ),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(children: [
                  const Text("  Total Referral",
                      style: TextStyle(fontSize: 12, color: Color(0xff6b7280))),
                  Text(referral,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))
                ]),
                Column(children: [
                  const Text("Total Points",
                      style: TextStyle(fontSize: 12, color: Color(0xff6b7280))),
                  Text(clickPoints,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))
                ]),
              ]),
              SizedBox(height: 2.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(children: [
                  const Text("Performance Score",
                      style: TextStyle(fontSize: 12, color: Color(0xff6b7280))),
                  Text(performanceScore,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))
                ]),
                Column(children: [
                  const Text("Approval Score",
                      style: TextStyle(fontSize: 12, color: Color(0xff6b7280))),
                  Text(approvalScore,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))
                ]),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget performanceItem(Performance performance) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Card(
        elevation: 6,
        clipBehavior: Clip.hardEdge,
        color: Colors.white,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xffFFB33A),
                  child: Text(performance.firstAvatar,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                SizedBox(width: 0.5.w),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(performance.secondAvatar),
                ),
                SizedBox(
                  width: 0.5.w,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performance.name,
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Image.asset(performance.spark),
                        SizedBox(
                          width: 0.2.w,
                        ),
                        Text(
                          'Task Speed Score',
                          style: TextStyle(
                              fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 0.5.w),
                        Text(performance.speed,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey))
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Image.asset(performance.star),
                        SizedBox(
                          width: 0.2.w,
                        ),
                        Text(
                          'Client/Advertiser Rating',
                          style: TextStyle(
                              fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 0.5.w),
                        Text(performance.rating,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffff6533)))
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 12),
                        const Text(" Approval Rate Score",
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        SizedBox(width: 0.5.w),
                        Text(performance.approval,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey))
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ID: 20x1HP',
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.normal),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: const Color(0xffd4d5d7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Task Quantity Score: ',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xff6B7280),
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 0.5.h,
                                  ),
                                  Text(performance.quantity,
                                      style: TextStyle(
                                        color: const Color(0xffff6533),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Task Diversity Score: ',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xff6B7280),
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 0.5.h,
                                  ),
                                  Text(performance.diversity,
                                      style: TextStyle(
                                        color: const Color(0xffff6533),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 1.5.w,
                        ),
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: const Color(0xffd4d5d7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Task performance score',
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xff6B7280),
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 0.5.h,
                              ),
                              Text(performance.taskPerformance,
                                  style: TextStyle(
                                    color: const Color(0xffff6533),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }

  clickWorkersCard(
      {IconData? icon,
      String? image,
      required String title,
      bool isIcon = false,
      required String description}) {
    return SizedBox(
      width: 350,
      height: 240,
      child: Card(
        elevation: 6, // adds shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(1.5.w),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xfff8ac92),
                    child: isIcon
                        ? Icon(icon, color: const Color(0xffff6533), size: 35)
                        : Image.asset("assets/$image.png", scale: 1.5)),
                SizedBox(height: 4.h),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4.h),
                Text(description,
                    style: const TextStyle(
                        color: Color(0xffa0aab2), fontSize: 12)),
              ]),
        ),
      ),
    );
  }

  Widget clickWorksCards(
      {required String image,
      required String title,
      required String subTitle,
      required String priFixText,
      required String priFixSubText,
      required String description}) {
    return SizedBox(
      width: 360,
      height: 320,
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
                CircleAvatar(radius: 25, backgroundImage: NetworkImage(image)),
                SizedBox(height: 4.h),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subTitle,
                    style: const TextStyle(
                        color: Color(0xff6b7280), fontSize: 14)),
                SizedBox(height: 4.h),
                Text(description,
                    style: const TextStyle(
                        color: Color(0xffa0aab2), fontSize: 12)),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(priFixText),
                    SizedBox(width: 1.w),
                    Text(priFixSubText,
                        style: const TextStyle(
                            color: Color(0xff6b7280), fontSize: 12))
                  ],
                ),
              ]),
        ),
      ),
    );
  }

  howItWorkItems(
      {required String title,
      required String description,
      bool isIcon = false,
      String? image}) {
    return Container(
        width: 350,
        padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xffa0aab2),
            width: 1,
          ),
        ),
        child: Column(children: [
          CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xfff8ac92),
              child: isIcon
                  ? const Icon(Icons.workspace_premium_sharp,
                      color: Color(0xffff6533))
                  : Image.asset(image ?? '', scale: 1.5)),
          SizedBox(height: 4.h),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4.h),
          Text(
              textAlign: TextAlign.center,
              description,
              style: const TextStyle(color: Color(0xffa0aab2), fontSize: 13)),
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
              },
              child: RichText(
                  text: const TextSpan(
                      text: "Learn More",
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xffff6533),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xffff6533)))))
        ]));
  }
}

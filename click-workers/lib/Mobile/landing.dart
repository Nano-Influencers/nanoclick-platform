import 'package:click_workers/Mobile/authentication/sign_up.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/widgets/task_stream.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:click_workers/Mobile/widgets/footer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// Stub implementations for YouTube player (web compatibility issue)
class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  late YoutubePlayerController _controller;
  late YoutubePlayerController _controller2;
  final PageController _pageController = PageController();
  final PageController _pageController2 = PageController();
  final PageController _pageController3 = PageController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentPage = 0;
  // int _currentPage2 = 0;
  int _currentPage3 = 0;
  FirebaseFirestore? otherFirestore;

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

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 4;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    // Timer.periodic(const Duration(seconds: 5), (timer) {
    //   if (_pageController2.hasClients) {
    //     _currentPage2 = (_currentPage2 + 1) % 6;
    //     _pageController2.animateToPage(
    //       _currentPage2,
    //       duration: const Duration(milliseconds: 500),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController3.hasClients) {
        _currentPage3 = (_currentPage3 + 1) % 6;
        _pageController3.animateToPage(
          _currentPage3,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    readFromOtherFirestore();
  }

  bool isValidEmail(String email) {
    return RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    ).hasMatch(email);
  }

  Future<bool> subscribeUser(String email) async {
    try {
      final safeEmail = email.toLowerCase().trim().replaceAll('.', '_');

      final docRef =
          _firestore.collection('newsletter_subscribers').doc(safeEmail);

      final doc = await docRef.get();

      if (doc.exists) {
        return false; // already subscribed
      }

      await docRef.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final GlobalKey section0Key = GlobalKey();
  final GlobalKey section1Key = GlobalKey();
  final GlobalKey section2Key = GlobalKey();
  final GlobalKey section3Key = GlobalKey();
  final GlobalKey section4Key = GlobalKey();
  final GlobalKey section5Key = GlobalKey();
  final GlobalKey section6Key = GlobalKey();
  final GlobalKey section7Key = GlobalKey();
  final GlobalKey section8Key = GlobalKey();
  final GlobalKey section9Key = GlobalKey();
  final GlobalKey section10Key = GlobalKey();
  final GlobalKey section11Key = GlobalKey();
  final GlobalKey section12Key = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

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
                height: 110.w,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    )),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset("assets/logo.png"),
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.cancel, color: Colors.black))
                          ],
                        ),
                        SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section0Key);
                                },
                                title: const Text(
                                  'Home',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                       SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section1Key);
                                },
                                title: const Text(
                                  'How it Works',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section2Key);
                                },
                                title: const Text(
                                  'Featured Tasks',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section3Key);
                                },
                                title: const Text(
                                  'Leaderboard',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section4Key);
                                },
                                title: const Text(
                                  'Why Choose Clickworks',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section5Key);
                                },
                                title: const Text(
                                  'Testimonials',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section6Key);
                                },
                                title: const Text(
                                  'Gamification',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section7Key);
                                },
                                title: const Text(
                                  'Video Walkthrough/Demo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section8Key);
                                },
                                title: const Text(
                                  'Live Activity Feed',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section9Key);
                                },
                                title: const Text(
                                  'Refer & Earn',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section10Key);
                                },
                                title: const Text(
                                  'FAQs',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section11Key);
                                },
                                title: const Text(
                                  'Join Clickworkers',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                                 SizedBox(
                            height: 4.h,
                            child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  _scrollToSection(section12Key);
                                },
                                title: const Text(
                                  'Subscribe to Our Newsletter',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                ))),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                            child: SizedBox(
                                width: 88.w,
                                child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const SignIn()),
                                      );
                                    },
                                    child: const Text("Login")))),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: SizedBox(
                                width: 88.w,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const SignUp()),
                                      );
                                    },
                                    child: const Text("Sign Up"))))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset("assets/logo.png"),
          ),
          centerTitle: false,
          actions: [
            IconButton(
                onPressed: () {
                  showTopDrawer(context);
                },
                icon: const Icon(Icons.menu))
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xffff6533),
        ),
        backgroundColor: Colors.white,
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
                    controller: _scrollController,
                    child: Column(children: [
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              RichText(
                                key: section0Key,
                                text: const TextSpan(
                                    text: "Advertise/promote ",
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: Color(0xffff6533),
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                          text:
                                              "for brands, perform\nsimple tasks, earn money & win gifts no skill required",
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold))
                                    ]),
                              ),
                              SizedBox(height: 2.h),
                              const Text(
                                "Get paid to advertise, complete easy tasks, and represent top brands. It’s simple, fun, and free to start — no experience required!",
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 4.h),
                              Center(
                                  child: SizedBox(
                                      width: 88.w,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignUp()),
                                            );
                                          },
                                          child: const Text("Get Started")))),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                  child: SizedBox(
                                      width: 88.w,
                                      child: OutlinedButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignUp()),
                                            );
                                          },
                                          child: const Text("Explore Tasks")))),
                              Image.asset('assets/social_media.gif'),
                            ],
                          )),
                      Container(
                        key: section1Key,
                        color: const Color(0xffEEEEEE),
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                  SizedBox(height: 2.h),
                                  SizedBox(
                                    width: 85.w,
                                    height: 53.h,
                                    child: PageView(
                                        controller: _pageController,
                                        children: [
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(40),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Color(
                                                            0xFFFFEDE4), // light peach circle
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/profile_plus.png"),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Free Sign Up & Verification',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Register and complete KYC to unlock all features.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xffa0aab2),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(40),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Color(
                                                            0xFFFFEDE4), // light peach circle
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/choose.png"),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Choose Tasks',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Browse Ads task, complete them, and submit proof',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xffa0aab2),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(40),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Color(
                                                            0xFFFFEDE4), // light peach circle
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/earn.png"),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Earn Money & Points',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Get paid for publishing ads for brands or promoting brands, climb the leaderboard and win cash prizes, and unlock massive cash and item rewards.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xffa0aab2),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(38),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Color(
                                                            0xFFFFEDE4), // light peach circle
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.asset(
                                                          "assets/atm_card.png"),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Withdraw Earnings',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    const Text(
                                                      'Cash out via secure payment options',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xffa0aab2),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ])),
                      ),
                      Container(
                          key: section2Key,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 2.h),
                                    const Text("Featured Tasks",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(height: 2.h),
                                    const Text(
                                        textAlign: TextAlign.center,
                                        "Easy gigs. Your next reward is one task away. Start earning now!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xff33393e))),
                                    SizedBox(height: 5.h),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(children: [
                                        Container(
                                            width: 25.w,
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffff6533),
                                              borderRadius: BorderRadius.circular(
                                                  30), // Optional rounded corners
                                            ),
                                            child: const Text("All Task",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12))),
                                        SizedBox(width: 3.w),
                                        Container(
                                            width: 25.w,
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(
                                                    0xffd1d5db), // Border color
                                                width: 2, // Border width
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                  30), // Optional rounded corners
                                            ),
                                            child: const Text("Repeating",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12))),
                                        SizedBox(width: 3.w),
                                        Container(
                                            width: 30.w,
                                            padding: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(
                                                    0xffd1d5db), // Border color
                                                width: 2, // Border width
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                  30), // Optional rounded corners
                                            ),
                                            child: const Text("High Earning",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12))),
                                      ]),
                                    ),
                                    SizedBox(height: 5.h),
                                    SizedBox(
                                      width: 85.w,
                                      height: 38.h,
                                      child: PageView(
                                          controller: _pageController2,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            TaskStream(
                                                otherFirestore: otherFirestore!,
                                                isVertical: false,
                                                limit: 6,
                                                onAccept: (task) {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const SignIn()),
                                                  );
                                                })
                                          ]),
                                    ),
                                  ]))),
                      Container(
                        key: section3Key,
                        color: const Color(0xffEEEEEE),
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(children: [
                              SizedBox(height: 2.h),
                              const Text("Leaderboard",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              SizedBox(height: 2.h),
                              const Text(
                                  textAlign: TextAlign.center,
                                  "See who's earning the most and get inspired to climb the ranks",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xff33393e))),
                              SizedBox(height: 4.h),
                              SizedBox(
                                width: 85.w,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: const Color(0xfffefad1),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 20, 40, 40),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset("assets/first_place.png"),
                                        SizedBox(height: 2.h),
                                        Container(
                                          padding: const EdgeInsets.all(25),
                                          decoration: const BoxDecoration(
                                            color: Color(
                                                0xFFEAB308), // light peach circle
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Text("1",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        SizedBox(height: 2.h),
                                        CircleAvatar(
                                            radius: 50,
                                            backgroundImage: docs[0]['dp'] != ''
                                                ? NetworkImage(docs[0]['dp'])
                                                : const NetworkImage(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1755085552/character_default_p7m3r2.png")),
                                        SizedBox(height: 2.h),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(children: [
                                                const Text("  Total Referral",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    docs[0]['referrals']
                                                        .toString()
                                                        .replaceAllMapped(
                                                            RegExp(
                                                                r'\B(?=(\d{3})+(?!\d))'),
                                                            (match) => ','),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                              Column(children: [
                                                const Text("Total Points",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    "${docs[0]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ]),
                                        SizedBox(height: 2.h),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(children: [
                                                const Text("Performance Score",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    docs[0]['performanceScore']
                                                        .toString()
                                                        .replaceAllMapped(
                                                            RegExp(
                                                                r'\B(?=(\d{3})+(?!\d))'),
                                                            (match) => ','),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                              Column(children: [
                                                const Text("Approval Score",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    "₦${docs[0]['approvalScore'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              SizedBox(
                                width: 85.w,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: const Color(0xfff5f6f8),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 20, 40, 40),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(25),
                                          decoration: const BoxDecoration(
                                            color: Color(
                                                0xFF9CA3AF), // light peach circle
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Text("2",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        SizedBox(height: 2.h),
                                        CircleAvatar(
                                            radius: 50,
                                            backgroundImage: docs[1]['dp'] != ''
                                                ? NetworkImage(docs[1]['dp'])
                                                : const NetworkImage(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752572842/1d05d59e2312732dd6546e4a1b3357770704b778_1_ojexwk.png")),
                                        SizedBox(height: 2.h),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(children: [
                                                const Text("  Total Referral",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    docs[1]['referrals']
                                                        .toString()
                                                        .replaceAllMapped(
                                                            RegExp(
                                                                r'\B(?=(\d{3})+(?!\d))'),
                                                            (match) => ','),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                              Column(children: [
                                                const Text("Total Points",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    "${docs[1]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ]),
                                        SizedBox(height: 2.h),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(children: [
                                                const Text("Performance Score",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    docs[1]['performanceScore']
                                                        .toString()
                                                        .replaceAllMapped(
                                                            RegExp(
                                                                r'\B(?=(\d{3})+(?!\d))'),
                                                            (match) => ','),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                              Column(children: [
                                                const Text("Approval Score",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    "₦${docs[1]['approvalScore'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              SizedBox(
                                width: 85.w,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: const Color(0xfffff1de),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 20, 40, 40),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(25),
                                          decoration: const BoxDecoration(
                                            color: Color(
                                                0xFFF97316), // light peach circle
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Text("3",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        SizedBox(height: 2.h),
                                        CircleAvatar(
                                            radius: 50,
                                            backgroundImage: docs[2]['dp'] != ''
                                                ? NetworkImage(docs[2]['dp'])
                                                : const NetworkImage(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752572843/d20f43a765e6ed6ac3bdea39b6be2ea6b6b1193c_o9xsf1.png")),
                                        SizedBox(height: 2.h),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(children: [
                                                const Text("  Total Referral",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    docs[2]['referrals']
                                                        .toString()
                                                        .replaceAllMapped(
                                                            RegExp(
                                                                r'\B(?=(\d{3})+(?!\d))'),
                                                            (match) => ','),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                              Column(children: [
                                                const Text("Total Points",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    "${docs[2]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ]),
                                        SizedBox(height: 2.h),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(children: [
                                                const Text("Performance Score",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    docs[2]['performanceScore']
                                                        .toString()
                                                        .replaceAllMapped(
                                                            RegExp(
                                                                r'\B(?=(\d{3})+(?!\d))'),
                                                            (match) => ','),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                              Column(children: [
                                                const Text("Approval Score",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff6b7280))),
                                                Text(
                                                    "₦${docs[2]['approvalScore'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                              ]),
                                            ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 7.h),
                              SizedBox(
                                width: 85.w,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 20, 20),
                                      child: Row(children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                            color: Color(
                                                0xFFd1d5db), // light peach circle
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Text("4",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                        ),
                                        SizedBox(width: 2.w),
                                        CircleAvatar(
                                            radius: 20,
                                            backgroundImage: docs[3]['dp'] != ''
                                                ? NetworkImage(docs[3]['dp'])
                                                : const NetworkImage(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752572842/41bd7ba92e2f774b483e0863cf6a654b600c4ef2_aitwdw.png")),
                                        SizedBox(width: 2.w),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(docs[3]['name'].toString()),
                                              const Text("Total Points",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Color(0xff6b7280))),
                                              Text(
                                                  "${docs[3]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const Text("⭐️ 4.9",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])
                                      ])),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              SizedBox(
                                width: 85.w,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 20, 20),
                                      child: Row(children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                            color: Color(
                                                0xFFd1d5db), // light peach circle
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Text("5",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                        ),
                                        SizedBox(width: 2.w),
                                        CircleAvatar(
                                            radius: 20,
                                            backgroundImage: docs[4]['dp'] != ''
                                                ? NetworkImage(docs[4]['dp'])
                                                : const NetworkImage(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752572842/1d05d59e2312732dd6546e4a1b3357770704b778_1_ojexwk.png")),
                                        SizedBox(width: 2.w),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(docs[4]['name'].toString()),
                                              const Text("Total Points",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Color(0xff6b7280))),
                                              Text(
                                                  "${docs[4]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const Text("⭐️ 4.5",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])
                                      ])),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              SizedBox(
                                width: 85.w,
                                child: Card(
                                  elevation: 6, // adds shadow
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 20, 20),
                                      child: Row(children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: const BoxDecoration(
                                            color: Color(
                                                0xFFd1d5db), // light peach circle
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Text("6",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                        ),
                                        SizedBox(width: 2.w),
                                        CircleAvatar(
                                            radius: 20,
                                            backgroundImage: docs[5]['dp'] != ''
                                                ? NetworkImage(docs[5]['dp'])
                                                : const NetworkImage(
                                                    "https://res.cloudinary.com/dihpawfyc/image/upload/v1752572842/54aef3fee175e59f276c50cba2f035bd04800518_mfevfz.png")),
                                        SizedBox(width: 2.w),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(docs[5]['name'].toString()),
                                              const Text("Total Points",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Color(0xff6b7280))),
                                              Text(
                                                  "${docs[5]['clickPoints'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')} Pts",
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const Text("⭐️ 4.2",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])
                                      ])),
                                ),
                              ),
                              SizedBox(height: 7.h),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SignIn()),
                                    );
                                  },
                                  child: const Text("View full leaderboard ↗")),
                            ])),
                      ),
                      Container(
                        key: section4Key,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(children: [
                                SizedBox(height: 2.h),
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
                                SizedBox(
                                    width: 85.w,
                                    height: 50.h,
                                    child: PageView(
                                        controller: _pageController3,
                                        children: [
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              Color(0xfff8ac92),
                                                          child: Icon(
                                                              Icons.schedule,
                                                              color: Color(
                                                                  0xffff6533),
                                                              size: 35)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Flexible Work",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Work anytime, anywhere with absolutely no skills required. Perfect for students, stay-at-home parents, or anyone looking for extra income.",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffa0aab2),
                                                              fontSize: 13)),
                                                    ]),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              const Color(
                                                                  0xfff8ac92),
                                                          child: Image.asset(
                                                              "assets/chart.png",
                                                              scale: 1.5)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "No Investment Required",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Start earning immediately without funding your wallet or paying any fees. We believe in providing opportunities, not taking your money.",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffa0aab2),
                                                              fontSize: 13)),
                                                    ]),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              const Color(
                                                                  0xfff8ac92),
                                                          child: Image.asset(
                                                              "assets/game.png",
                                                              scale: 1.5)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Gamified Experience",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Earn rewards through leaderboards, treasure hunts, and spins. Win cash prizes from ₦50,000 to ₦2.5M, gadgets, event tickets, and more",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffa0aab2),
                                                              fontSize: 13)),
                                                    ]),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              const Color(
                                                                  0xfff8ac92),
                                                          child: Image.asset(
                                                              "assets/atm_card.png",
                                                              scale: 1.5)),
                                                      SizedBox(height: 4.h),
                                                      const Text("Fast Payouts",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Withdraw your earnings without delays. Our efficient payment system ensures you get your money when you need it.",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffa0aab2),
                                                              fontSize: 13)),
                                                    ]),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              Color(0xfff8ac92),
                                                          child: Icon(
                                                              Icons
                                                                  .workspace_premium_sharp,
                                                              color: Color(
                                                                  0xffff6533),
                                                              size: 35)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "No. 1 in Africa",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "We partner with numerous advertising companies, task platforms, and gift-sharing services to ensure you always have opportunities to earn.",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffa0aab2),
                                                              fontSize: 13)),
                                                    ]),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 85.w,
                                            child: Card(
                                              elevation: 6, // adds shadow
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              Color(0xfff8ac92),
                                                          child: Icon(
                                                              Icons
                                                                  .verified_user_sharp,
                                                              color: Color(
                                                                  0xffff6533),
                                                              size: 35)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Secure & Trusted",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                      SizedBox(height: 4.h),
                                                      const Text(
                                                          "Join thousands of satisfied users who trust ClickWorkers for reliable income. Our platform is secure, transparent, and user-friendly",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffa0aab2),
                                                              fontSize: 13)),
                                                    ]),
                                              ),
                                            ),
                                          ),
                                        ])),
                                SizedBox(height: 4.h),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignIn()),
                                      );
                                    },
                                    child: const Text("Join Now"))
                              ]))),
                      Container(
                        
                          color: const Color(0xffeeeeee),
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(children: [
                                SizedBox(height: 2.h),
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
                                SizedBox(height: 5.h),
                                SizedBox(
                                  width: 85.w,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: NetworkImage(
                                                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584324/dfd70265b6c97dc2786bd118f98dfa0858e4ecaf_1_wpnljm.png")),
                                                SizedBox(width: 3.w),
                                                const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text("Ugwu Shine",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                          "University student, Enugu",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff6b7280))),
                                                    ])
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            const Text(
                                                '"I was skeptical at first, but ClickWorkers has been a game-changer for me. As a student, I′ve been able to earn enough to cover my expenses and even save some money. The tasks are simple and the payment is always on time!"',
                                                style: TextStyle(
                                                    color: Color(0xffa0aab2),
                                                    fontSize: 13)),
                                            SizedBox(height: 2.h),
                                            const Text("⭐️⭐️⭐️⭐️⭐️"),
                                            //SizedBox(height: 1.h),
                                            const Text(
                                                "Won a MacBook Air worth ₦750,000",
                                                style: TextStyle(
                                                    color: Color(0xff6b7280))),
                                          ]),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                SizedBox(
                                  width: 85.w,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: NetworkImage(
                                                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584323/0c26d887ed060b47018885c4c6847048f8a83758_ktjqvs.png")),
                                                SizedBox(width: 3.w),
                                                const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text("Esther Howards",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                          "Entreprenuer, Lagos",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff6b7280))),
                                                    ])
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            const Text(
                                                '"I won a brand new laptop through the treasure hunt feature! I couldn′t believe it at first. The platform is not just about completing tasks - the gamification makes it fun and rewarding. Now I recommend it to everyone I know."',
                                                style: TextStyle(
                                                    color: Color(0xffa0aab2),
                                                    fontSize: 13)),
                                            SizedBox(height: 2.h),
                                            const Text("⭐️⭐️⭐️⭐️⭐️"),
                                            //SizedBox(height: 1.h),
                                            const Text(
                                                "Earned ₦480,000 in 6 months",
                                                style: TextStyle(
                                                    color: Color(0xff6b7280))),
                                          ]),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                SizedBox(
                                  width: 85.w,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: NetworkImage(
                                                        "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584325/83ab462a89a08fdba266b544d03bce6d41e497cd_qcylbx.png")),
                                                SizedBox(width: 3.w),
                                                const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text("Ralph Edwards",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text("Student, Lagos",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff6b7280))),
                                                    ])
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            const Text(
                                                '"As a stay-at-home mom, I needed a flexible way to contribute to our family income. ClickWorkers has been perfect! I complete tasks during my free time and have earned enough to pay for my children′s school fees. The platform is so easy to use!"',
                                                style: TextStyle(
                                                    color: Color(0xffa0aab2),
                                                    fontSize: 13)),
                                            SizedBox(height: 2.h),
                                            const Text("⭐️⭐️⭐️⭐️⭐️"),
                                            //SizedBox(height: 1.h),
                                            const Text(
                                                "Earned ₦303,200 in 3 months",
                                                style: TextStyle(
                                                    color: Color(0xff6b7280))),
                                          ]),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                SizedBox(
                                  width: 85.w,
                                  child: Card(
                                    key: section5Key,
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
                                            Container(
                                                width: 85.w,
                                                height: 30.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffd9d9d9),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: YoutubePlayer(
                                                    controller: _controller2,
                                                    aspectRatio: 16 / 9,
                                                  ),
                                                )),
                                            SizedBox(height: 4.h),
                                            Container(
                                                width: 85.w,
                                                padding:
                                                    const EdgeInsets.all(25),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20), // 👈 rounded corners
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xffa0aab2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Column(children: [
                                                  const Text(
                                                      '"How I Earned ₦500,000 in One Month"',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(height: 1.h),
                                                  const Text(
                                                      "Blessing Adekunle shares her journey from struggling to pay bills to becoming a top earner on ClickWorkers. Learn her strategies and tips for maximizing your earnings.",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xffa0aab2))),
                                                  SizedBox(height: 3.h),
                                                  Row(children: [
                                                    const CircleAvatar(
                                                        radius: 30,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                "https://res.cloudinary.com/dihpawfyc/image/upload/v1752584325/9265f6e3e22a4d011fdf9bee1bc447fd54300962_riqkfc.png")),
                                                    SizedBox(width: 3.w),
                                                    const Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              "Blessing\nAdekunle",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text("Student, Lagos",
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Color(
                                                                      0xffa0aab2)))
                                                        ])
                                                  ])
                                                ])),
                                          ]),
                                    ),
                                  ),
                                ),
                              ]))),
                      Container(
                        key: section6Key,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(children: [
                                SizedBox(height: 2.h),
                                const Text("Gamification",
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
                                Container(
                                    width: 77.w,
                                    padding: const EdgeInsets.fromLTRB(
                                        35, 20, 35, 20),
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
                                          backgroundColor:
                                              const Color(0xfff8ac92),
                                          child: Image.asset(
                                              "assets/treasure.png",
                                              scale: 1.5)),
                                      SizedBox(height: 4.h),
                                      const Text("Treasure Hunt",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      SizedBox(height: 4.h),
                                      const Text(
                                          textAlign: TextAlign.center,
                                          "Find hidden rewards in ads and tasks. Discover treasure boxes worth up to ₦50,000 in cash and points.",
                                          style: TextStyle(
                                              color: Color(0xffa0aab2),
                                              fontSize: 13)),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignIn()),
                                            );
                                          },
                                          child: RichText(
                                              text: const TextSpan(
                                                  text: "Learn More",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xffff6533),
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Color(0xffff6533)))))
                                    ])),
                                SizedBox(height: 3.h),
                                Container(
                                    width: 77.w,
                                    padding: const EdgeInsets.fromLTRB(
                                        33, 20, 33, 20),
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
                                          backgroundColor:
                                              const Color(0xfff8ac92),
                                          child: Image.asset("assets/spin.png",
                                              scale: 1.5)),
                                      SizedBox(height: 4.h),
                                      const Text("Spin & Win",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      SizedBox(height: 4.h),
                                      const Text(
                                          textAlign: TextAlign.center,
                                          "Exchange earnings for bonus points to climb the leaderboard and win millions in cash and item rewards.",
                                          style: TextStyle(
                                              color: Color(0xffa0aab2),
                                              fontSize: 13)),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignIn()),
                                            );
                                          },
                                          child: RichText(
                                              text: const TextSpan(
                                                  text: "Learn More",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xffff6533),
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Color(0xffff6533)))))
                                    ])),
                                SizedBox(height: 3.h),
                                Container(
                                    width: 77.w,
                                    padding: const EdgeInsets.fromLTRB(
                                        33, 20, 33, 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xffa0aab2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(children: [
                                      const CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xfff8ac92),
                                          child: Icon(
                                              Icons.workspace_premium_sharp,
                                              color: Color(0xffff6533))),
                                      SizedBox(height: 4.h),
                                      const Text("Achievements & Badges",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      SizedBox(height: 4.h),
                                      const Text(
                                          textAlign: TextAlign.center,
                                          "Get recognized for completing milestones. Earn exclusive badges and unlock special rewards.",
                                          style: TextStyle(
                                              color: Color(0xffa0aab2),
                                              fontSize: 13)),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignIn()),
                                            );
                                          },
                                          child: RichText(
                                              text: const TextSpan(
                                                  text: "Learn More",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xffff6533),
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Color(0xffff6533)))))
                                    ])),
                                SizedBox(height: 2.h),
                              ]))),
                      Container(
                        key: section7Key,
                          color: const Color(0xffEEEEEE),
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(children: [
                                SizedBox(height: 2.h),
                                const Text("Video Walkthrough/Demo"),
                                SizedBox(height: 2.h),
                                SizedBox(
                                  width: 85.w,
                                  child: Card(
                                    elevation: 6, // adds shadow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(25),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                                width: 85.w,
                                                height: 30.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffd9d9d9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16), // 👈 Rounded corners
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: YoutubePlayer(
                                                    controller: _controller,
                                                    aspectRatio: 16 / 9,
                                                  ),
                                                )),
                                            SizedBox(height: 4.h),
                                            Container(
                                                width: 85.w,
                                                padding:
                                                    const EdgeInsets.all(25),
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      'How to Earn Money online with Click Workers',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(height: 2.h),
                                                  const Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      "A 30-60 second video explaining how Click Workers works.",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xffa0aab2))),
                                                ])),
                                          ]),
                                    ),
                                  ),
                                ),
                              ]))),
                      Container(
                        key: section8Key,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
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
                                      width: 85.w,
                                      child: Card(
                                        elevation: 6, // adds shadow
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        color: const Color(0xffced7f8),
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 20, 20, 20),
                                            child: Row(children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(
                                                        0xff8ba3fb), // light peach circle
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                      Icons.checklist_outlined,
                                                      color:
                                                          Color(0xff2756ff))),
                                              SizedBox(width: 4.w),
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                        text: const TextSpan(
                                                            text:
                                                                "Adebayo from Lagos just\ncompleted a Twitter task\nand earned ",
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
                                      width: 85.w,
                                      child: Card(
                                        elevation: 6, // adds shadow
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        color: const Color(0xfff6d6cb),
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 20, 20, 20),
                                            child: Row(children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration:
                                                      const BoxDecoration(
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
                                                                "Ngozi unlocked a treasure\nbox worth ",
                                                            children: [
                                                          TextSpan(
                                                              text:
                                                                  "100 Points!",
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
                                      width: 85.w,
                                      child: Card(
                                        elevation: 6, // adds shadow
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        color: const Color(0xfff1d2fd),
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 20, 20, 20),
                                            child: Row(children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(
                                                        0xffd779f9), // light peach circle
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                      Icons
                                                          .workspace_premium_sharp,
                                                      color:
                                                          Color(0xffc830ff))),
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
                                                              text:
                                                                  "Pro\nUser ",
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
                                    SizedBox(height: 4.h),
                                    Container(
                                        key: section9Key,
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                  "Refer & Earn 5% Extra",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              SizedBox(height: 2.h),
                                              const Text(
                                                  "Invite your friends to join ClickWorkers and earn 5% of their earnings for life. The more friends you refer, the more you earn",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12)),
                                              SizedBox(height: 3.h),
                                              Center(
                                                child: Image.asset(
                                                  "assets/referral.png",
                                                ),
                                              )
                                            ]))
                                  ]))),
                      Container(
                         key: section10Key,
                          color: const Color(0xffeeeeee),
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                "Find answers to common questions about",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            children: [
                                          TextSpan(
                                              text: " ClickWorkers",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xffff6533)))
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
                                    SizedBox(height: 2.h),
                                    Center(
                                      child: SizedBox(
                                        width: 90.w,
                                        child: Card(
                                          
                                          elevation: 6, // adds shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          color: Colors.white,
                                          child: const Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Divider(
                                                      thickness: 1,
                                                      color: Colors.grey),
                                                  FAQItem(
                                                      question:
                                                          " How do I start earning?",
                                                      answer:
                                                          "This is a random body of text, a placeholder, it is to be changed"),
                                                  FAQItem(
                                                      question:
                                                          " What type of ads and social\n tasks are available?",
                                                      answer:
                                                          "This is a random body of text, a placeholder, it is to be changed"),
                                                  FAQItem(
                                                      question:
                                                          " How does withdrawal work?",
                                                      answer:
                                                          "This is a random body of text, a placeholder, it is to be changed"),
                                                  FAQItem(
                                                      question:
                                                          " How does withdrawal work?",
                                                      answer:
                                                          "This is a random body of text, a placeholder, it is to be changed"),
                                                  FAQItem(
                                                      question:
                                                          " What happens if my task\n submission is rejected?",
                                                      answer:
                                                          "This is a random body of text, a placeholder, it is to be changed"),
                                                  FAQItem(
                                                      question:
                                                          " Is ClickWorkers available in my\n country?",
                                                      answer:
                                                          "This is a random body of text, a placeholder, it is to be changed")
                                                ]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]))),
                      Container(
                        key: section11Key,
                          color: Colors.white,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(children: [
                                Container(
                                    width: 85.w,
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 20, 30, 20),
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
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              fixedSize: Size(55.w, 2.h)),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignUp()),
                                            );
                                          },
                                          child: const Text("Sign Up Now",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xffff6533)))),
                                      SizedBox(height: 2.h),
                                      OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            fixedSize: Size(55.w, 2.h),
                                            backgroundColor:
                                                const Color(0x00000000),
                                            side: const BorderSide(
                                                color: Colors.white, width: 2),
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
                                    ])),
                                SizedBox(height: 4.h),
                                Container(
                                    width: 85.w,
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 20, 30, 20),
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
                                    child: Column(children: [
                                      const Text("250,000+",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const Text("Active Users",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(height: 3.h),
                                      const Text("8.2M+",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const Text("Tasks Completed",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(height: 3.h),
                                      const Text("₦209.5M+",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const Text("Paid to Users",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(height: 3.h),
                                      const Text("65,000+",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const Text("Prizes Awarded",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ]))
                              ]))),
                      Container(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 3.h),
                                 SubscriberField(
                                    key: section12Key,
                                )
                              ]))),
                      Footer(scrollController: _scrollController),
                    ]),
                  );
                }));
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({super.key, required this.question, required this.answer});

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  textAlign: TextAlign.start,
                  widget.question,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              IconButton(
                icon: Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    isOpen = !isOpen;
                  });
                },
              )
            ],
          ),
        ),

        // Answer (expandable)
        if (isOpen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              textAlign: TextAlign.start,
              widget.answer,
              style: const TextStyle(fontSize: 15),
            ),
          ),

        const Divider(thickness: 1, color: Colors.grey),
      ],
    );
  }
}

class SubscriberField extends StatefulWidget {
  const SubscriberField({super.key});

  @override
  State<SubscriberField> createState() => _SubscriberFieldState();
}

class _SubscriberFieldState extends State<SubscriberField> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _subscribeController = TextEditingController();
  bool isSubscribed = false;
  bool emailExists = false;
  String? emailError;
  bool isLinkClicked = false;

  bool isValidEmail(String email) {
    return RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    ).hasMatch(email);
  }

  Future<bool> subscribeUser(String email) async {
    try {
      final safeEmail = email.toLowerCase().trim().replaceAll('.', '_');

      final docRef =
          _firestore.collection('newsletter_subscribers').doc(safeEmail);

      final doc = await docRef.get();

      if (doc.exists) {
        return false; // already subscribed
      }

      await docRef.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80.w,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _subscribeController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Your Email',
                        hintStyle:
                            TextStyle(color: Colors.black54, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                      ),
                      onFieldSubmitted: (_) {},
                    ),
                  ),
                ),
                InkWell(
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(30)),
                  onTap: isSubscribed
                      ? null
                      : () async {
                          final email =
                              _subscribeController.text.trim().toLowerCase();

                          // Reset error first
                          setState(() {
                            emailError = null;
                          });

                          // ✅ Validate empty
                          if (email.isEmpty) {
                            setState(() {
                              emailError = "Email is required";
                            });
                            return;
                          }

                          // ✅ Validate format
                          if (!isValidEmail(email)) {
                            setState(() {
                              emailError = "Enter a valid email";
                            });
                            return;
                          }

                          final success = await subscribeUser(email);

                          if (!mounted) return;

                          setState(() {
                            isSubscribed = success;
                            emailExists = !success;
                          });
                        },
                  child: Container(
                    height: 7.h,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xffff6533),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isSubscribed
                          ? 'Subscribed ✓'
                          : emailExists
                              ? 'Already Subscribed'
                              : 'Subscribe',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              emailError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

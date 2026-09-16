import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/authentication/sign_up.dart';
import 'package:click_workers/Mobile/widgets/footer.dart';
import 'package:click_workers/Mobile/widgets/task_stream.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final ScrollController _scrollController = ScrollController();
  late final YoutubePlayerController _controller;

  final Map<String, GlobalKey> _sectionKeys = {
    'home': GlobalKey(),
    'how': GlobalKey(),
    'tasks': GlobalKey(),
    'leaderboard': GlobalKey(),
    'why': GlobalKey(),
    'testimonials': GlobalKey(),
    'gamification': GlobalKey(),
    'video': GlobalKey(),
    'activity': GlobalKey(),
    'referral': GlobalKey(),
    'faqs': GlobalKey(),
  };

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
  }

  @override
  void dispose() {
    _controller.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _auth(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _goTo(String section) async {
    final key = _sectionKeys[section];
    if (key?.currentContext == null) return;
    await Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.04,
    );
  }

  void _openMenu() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (dialogContext) => Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  color: Color(0x33000000),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(7.w, 2.h, 7.w, 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/logo.png', width: 42.w),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black,
                            child: Icon(Icons.close, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    ...[
                      ['Home', 'home'],
                      ['How it Works', 'how'],
                      ['Featured Tasks', 'tasks'],
                      ['Leaderboard', 'leaderboard'],
                      ['Why Choose ClickWorkers', 'why'],
                      ['Testimonials', 'testimonials'],
                      ['Gamification', 'gamification'],
                      ['Video Walkthrough/Demo', 'video'],
                      ['Live Activity Feed', 'activity'],
                      ['Refer & Earn', 'referral'],
                      ['FAQs', 'faqs'],
                    ].map(
                      (item) => InkWell(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _goTo(item[1]);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.15.h),
                          child: Text(
                            item[0],
                            style: TextStyle(
                              fontSize: 16.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff292929),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Device.width > 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _header(isDesktop),
            _hero(isDesktop),
            _howItWorks(isDesktop),
            _featuredTasks(isDesktop),
            _leaderboard(isDesktop),
            _whyChoose(isDesktop),
            _testimonials(isDesktop),
            _gamification(isDesktop),
            _video(isDesktop),
            _activityFeed(isDesktop),
            _referral(isDesktop),
            _faqs(isDesktop),
            Footer(scrollController: _scrollController),
          ],
        ),
      ),
    );
  }

  Widget _header(bool isDesktop) {
    return Container(
      key: _sectionKeys['home'],
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 5.w : 5.w,
            vertical: 1.8.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logo.png',
                width: isDesktop ? 180 : 42.w,
                fit: BoxFit.contain,
              ),
              if (isDesktop)
                Row(
                  children: [
                    _navButton('Home', 'home'),
                    _navButton('How it Works', 'how'),
                    _navButton('Featured Tasks', 'tasks'),
                    _navButton('Leaderboard', 'leaderboard'),
                    _navButton('FAQs', 'faqs'),
                    SizedBox(width: 1.w),
                    OutlinedButton(
                      onPressed: () => _auth(context, const SignIn()),
                      child: const Text('Sign in'),
                    ),
                    SizedBox(width: 0.8.w),
                    ElevatedButton(
                      onPressed: () => _auth(context, const SignUp()),
                      child: const Text('Get Started'),
                    ),
                  ],
                )
              else
                IconButton(
                  onPressed: _openMenu,
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xffff6533),
                    size: 34,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton(String label, String section) {
    return TextButton(
      onPressed: () => _goTo(section),
      child: Text(label),
    );
  }

  Widget _hero(bool isDesktop) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 8.w : 5.w,
        vertical: isDesktop ? 7.h : 3.h,
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _heroCopy()),
                SizedBox(width: 4.w),
                Expanded(child: _heroImage()),
              ],
            )
          : Column(
              children: [
                _heroCopy(),
                SizedBox(height: 2.h),
                _heroImage(),
              ],
            ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: Device.width > 1024 ? 30.sp : 28.sp,
              height: 1.16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
            children: const [
              TextSpan(
                text: 'Advertise/promote ',
                style: TextStyle(color: Color(0xffff6533)),
              ),
              TextSpan(text: 'for brands, perform simple tasks, earn money & win gifts no skill required'),
            ],
          ),
        ),
        SizedBox(height: 2.4.h),
        Text(
          'Get paid to advertise, complete easy tasks, and represent top brands. It’s simple, fun, and free to start — no experience required!',
          style: TextStyle(
            fontSize: Device.width > 1024 ? 14.5.sp : 15.5.sp,
            height: 1.55,
            color: const Color(0xff353535),
          ),
        ),
        SizedBox(height: 3.h),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: Device.width > 1024 ? 190 : double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _auth(context, const SignUp()),
                child: const Text('Get Started'),
              ),
            ),
            SizedBox(
              width: Device.width > 1024 ? 190 : double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => _goTo('tasks'),
                child: const Text('Explore Tasks'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroImage() {
    return Image.asset(
      'assets/social_media.gif',
      width: Device.width > 1024 ? 500 : 88.w,
      height: Device.width > 1024 ? 500 : 70.w,
      fit: BoxFit.contain,
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle, {
    Color background = Colors.white,
    bool center = true,
    required String keyName,
  }) {
    return Container(
      key: _sectionKeys[keyName],
      width: double.infinity,
      color: background,
      padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 3.h),
      child: Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: center ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: Device.width > 1024 ? 21.sp : 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xff242424),
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            subtitle,
            textAlign: center ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: 14.5.sp,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xff4b4b4b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _howItWorks(bool isDesktop) {
    final steps = [
      ('1', 'Create Account', 'Sign up free and create your worker profile.'),
      ('2', 'KYC Verification', 'Complete verification when a task or feature requires it.'),
      ('3', 'Choose Tasks', 'Browse available tasks, check the requirements and accept one.'),
      ('4', 'Submit Proof', 'Complete the task and submit the requested proof for review.'),
    ];

    return Container(
      color: const Color(0xffeeeeee),
      child: Column(
        children: [
          _sectionTitle(
            'How it Works',
            'Join thousands of people who earn money and win prizes by completing simple tasks in their free time.',
            background: const Color(0xffeeeeee),
            keyName: 'how',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
            child: isDesktop
                ? Row(
                    children: steps
                        .map((s) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.7.w),
                                child: _stepCard(s.$1, s.$2, s.$3),
                              ),
                            ))
                        .toList(),
                  )
                : Column(
                    children: steps
                        .map((s) => Padding(
                              padding: EdgeInsets.only(bottom: 1.5.h),
                              child: _stepCard(s.$1, s.$2, s.$3),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(String number, String title, String body) {
    final icon = {
          '1': 'assets/profile_plus.png',
          '2': 'assets/choose.png',
          '3': 'assets/icons/task.png',
          '4': 'assets/earn.png',
        }[number] ??
        'assets/choose.png';

    return Container(
      constraints: const BoxConstraints(minHeight: 205),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xffffe5dc),
                child: Image.asset(icon, width: 30, height: 30),
              ),
              const Spacer(),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xffff6533),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xff242424),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5.sp,
              height: 1.45,
              color: const Color(0xff555555),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredTasks(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          _sectionTitle(
            'Featured Tasks',
            'Explore current opportunities. You can review requirements before accepting a task.',
            keyName: 'tasks',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
            child: SizedBox(
              height: isDesktop ? 390 : 42.h,
              child: TaskStream(
                isVertical: !isDesktop,
                limit: isDesktop ? 8 : 6,
                onAccept: (_) => _auth(context, const SignIn()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaderboard(bool isDesktop) {
    final rows = [
      ('1', 'Top Worker', '1,245 pts'),
      ('2', 'Task Champion', '1,080 pts'),
      ('3', 'Rising Star', '940 pts'),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xffeeeeee),
      child: Column(
        children: [
          _sectionTitle(
            'Leaderboard',
            'See how active workers are progressing and keep building your own streak.',
            background: const Color(0xffeeeeee),
            keyName: 'leaderboard',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: rows
                    .map(
                      (row) => Container(
                        margin: EdgeInsets.only(bottom: 1.2.h),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xffffe5dc),
                              child: Text(
                                row.$1,
                                style: const TextStyle(
                                  color: Color(0xffff6533),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                row.$2,
                                style: TextStyle(
                                  fontSize: 15.5.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              row.$3,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xffff6533),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whyChoose(bool isDesktop) {
    final items = [
      ('Simple Tasks', 'Choose from eligible digital tasks with clear instructions.'),
      ('Flexible', 'Work when you have time and browse tasks that fit your availability.'),
      ('Rewards', 'Approved task earnings and eligible rewards are tracked in your worker account.'),
      ('Secure', 'Identity and financial workflows are handled through the NanoClick backend.'),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          _sectionTitle(
            'Why Choose ClickWorkers',
            'A straightforward way to discover tasks, build activity, and manage your worker journey.',
            keyName: 'why',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
            child: isDesktop
                ? Row(
                    children: items
                        .map((item) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.7.w),
                                child: _infoCard(item.$1, item.$2),
                              ),
                            ))
                        .toList(),
                  )
                : Column(
                    children: items
                        .map((item) => Padding(
                              padding: EdgeInsets.only(bottom: 1.5.h),
                              child: _infoCard(item.$1, item.$2),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String body) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xfff7f7f7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffededed)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xffffe5dc),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xffff6533)),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 1.h),
          Text(
            body,
            style: TextStyle(fontSize: 13.5.sp, height: 1.45, color: const Color(0xff555555)),
          ),
        ],
      ),
    );
  }

  Widget _testimonials(bool isDesktop) {
    final testimonials = [
      ('Amaka', 'The task instructions are easy to follow and I like being able to choose what I want to work on.'),
      ('Daniel', 'I enjoy the activity, rewards and progress features. It makes completing tasks feel engaging.'),
      ('Zainab', 'The worker dashboard gives me a clear place to track tasks and my account activity.'),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xffeeeeee),
      child: Column(
        children: [
          _sectionTitle(
            'What Workers Say',
            'Examples of the kind of worker experience ClickWorkers is designed to support.',
            background: const Color(0xffeeeeee),
            keyName: 'testimonials',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
            child: isDesktop
                ? Row(
                    children: testimonials
                        .map((item) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0.7.w),
                                child: _testimonialCard(item.$1, item.$2),
                              ),
                            ))
                        .toList(),
                  )
                : Column(
                    children: testimonials
                        .map((item) => Padding(
                              padding: EdgeInsets.only(bottom: 1.5.h),
                              child: _testimonialCard(item.$1, item.$2),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _testimonialCard(String name, String body) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Color(0xffff6533), size: 30),
          SizedBox(height: 1.h),
          Text(
            body,
            style: TextStyle(fontSize: 14.sp, height: 1.5, color: const Color(0xff444444)),
          ),
          SizedBox(height: 2.h),
          Text(name, style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w800)),
          const Text('ClickWorker'),
        ],
      ),
    );
  }

  Widget _gamification(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          _sectionTitle(
            'Gamification & Rewards',
            'Stay active, build streaks, unlock achievements and take part in reward experiences available to eligible workers.',
            keyName: 'gamification',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(child: _rewardCard('Task Streaks', 'Keep completing tasks consistently and build your activity streak.')),
                      SizedBox(width: 1.5.w),
                      Expanded(child: _rewardCard('Achievements', 'Reach milestones and collect achievements as you progress.')),
                      SizedBox(width: 1.5.w),
                      Expanded(child: _rewardCard('Treasure Hunts', 'Participate in eligible treasure and reward activities when available.')),
                    ],
                  )
                : Column(
                    children: [
                      _rewardCard('Task Streaks', 'Keep completing tasks consistently and build your activity streak.'),
                      SizedBox(height: 1.5.h),
                      _rewardCard('Achievements', 'Reach milestones and collect achievements as you progress.'),
                      SizedBox(height: 1.5.h),
                      _rewardCard('Treasure Hunts', 'Participate in eligible treasure and reward activities when available.'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(String title, String body) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xfffff7f3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffffe5dc)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.emoji_events_outlined, color: Color(0xffff6533), size: 36),
          SizedBox(height: 2.h),
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 1.h),
          Text(body, style: TextStyle(fontSize: 13.5.sp, height: 1.45, color: const Color(0xff555555))),
        ],
      ),
    );
  }

  Widget _video(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: const Color(0xffeeeeee),
      child: Column(
        children: [
          _sectionTitle(
            'Video Walkthrough / Demo',
            'Watch a quick overview of the worker experience and how tasks are completed.',
            background: const Color(0xffeeeeee),
            keyName: 'video',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 6.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: YoutubePlayer(controller: _controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityFeed(bool isDesktop) {
    final activities = [
      ('Chinedu', 'completed a social engagement task'),
      ('Mariam', 'submitted proof for review'),
      ('Ibrahim', 'earned an approved task reward'),
      ('Grace', 'joined ClickWorkers'),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          _sectionTitle(
            'Live Activity Feed',
            'A sample of the activity workers can see as tasks and account events move through the platform.',
            keyName: 'activity',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 5.h),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: activities
                    .map(
                      (activity) => Container(
                        margin: EdgeInsets.only(bottom: 1.2.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: const Color(0xfff7f7f7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xffffe5dc),
                              child: Icon(Icons.bolt, color: Color(0xffff6533)),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 13.8.sp, color: const Color(0xff333333)),
                                  children: [
                                    TextSpan(text: activity.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    TextSpan(text: ' ${activity.$2}.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _referral(bool isDesktop) {
    return Container(
      key: _sectionKeys['referral'],
      width: double.infinity,
      color: const Color(0xffff6533),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6.h),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _referralCopy()),
                SizedBox(width: 4.w),
                Expanded(
                  child: Image.asset(
                    'assets/referral.png',
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _referralCopy(),
                SizedBox(height: 3.h),
                Image.asset('assets/referral.png', height: 220, fit: BoxFit.contain),
              ],
            ),
    );
  }

  Widget _referralCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Refer & Earn',
          style: TextStyle(
            color: Colors.white,
            fontSize: Device.width > 1024 ? 24.sp : 22.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Invite eligible friends to join ClickWorkers. Referral rewards and conditions are subject to the current programme rules.',
          style: TextStyle(color: Colors.white, fontSize: 14.5.sp, height: 1.5),
        ),
        SizedBox(height: 2.5.h),
        SizedBox(
          width: 190,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xffff6533),
            ),
            onPressed: () => _auth(context, const SignUp()),
            child: const Text('Get Started'),
          ),
        ),
      ],
    );
  }

  Widget _faqs(bool isDesktop) {
    final faqs = [
      ('Do I need experience?', 'No. Tasks explain the required actions and proof. Eligibility varies by task.'),
      ('When do I get paid?', 'Approved earnings are credited according to the NanoClick backend payout and task-approval rules.'),
      ('Why is KYC required?', 'Some tasks or features require identity verification before they can be used.'),
      ('Can I choose my tasks?', 'You can browse available eligible tasks and review their requirements before accepting one.'),
      ('Where can I get help?', 'Use the support channels available inside the worker application for account-specific assistance.'),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xffeeeeee),
      child: Column(
        children: [
          _sectionTitle(
            'FAQs',
            'Quick answers to common questions about getting started as a ClickWorker.',
            background: const Color(0xffeeeeee),
            keyName: 'faqs',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 6.h),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: faqs
                    .map(
                      (faq) => Card(
                        margin: EdgeInsets.only(bottom: 1.h),
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ExpansionTile(
                          title: Text(faq.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                          childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(faq.$2, style: const TextStyle(color: Color(0xff555555), height: 1.45)),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

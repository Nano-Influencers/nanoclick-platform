import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/authentication/sign_in.dart';
import 'package:click_workers/Mobile/authentication/sign_up.dart';
import 'package:click_workers/Mobile/widgets/footer.dart';
import 'package:click_workers/Mobile/widgets/task_stream.dart';

const _orange = Color(0xffff6533);
const _soft = Color(0xffffaa91);
const _light = Color(0xffeeeeee);
const _muted = Color(0xff777777);

class Landing extends StatefulWidget {
  const Landing({super.key});
  @override State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final _scroll = ScrollController();
  void _auth(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(children: [
          _header(), _hero(), _howItWorks(), _featuredTasks(), _leaderboard(),
          _whyChoose(), _testimonials(), _gamification(), _videoDemo(), _activity(),
          _referral(), _faqs(), _joinToday(), _stats(), _newsletter(),
          Footer(scrollController: _scroll),
        ]),
      ),
    );
  }

  Widget _header() => SafeArea(
    bottom: false,
    child: Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Image.asset('assets/logo.png', width: 42.w),
        IconButton(onPressed: _menu, icon: const Icon(Icons.menu, color: _orange, size: 34)),
      ]),
    ),
  );

  void _menu() {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final item in ['Home','About Us','How it works','Tasks','Rewards','Testimonials','Support','FAQs','Contact Us'])
            ListTile(title: Text(item, style: const TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(context); _auth(const SignIn()); }, child: const Text('Sign in'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(context); _auth(const SignUp()); }, child: const Text('Get Started'))),
          ]),
        ]),
      )),
    );
  }

  Widget _hero() => Container(
    color: Colors.white, padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Advertise/promote for brands, perform simple tasks, earn money & win gifts no skill required',
        style: TextStyle(fontSize: 28.sp, height: 1.15, fontWeight: FontWeight.w800)),
      SizedBox(height: 2.5.h),
      Text('Get paid to advertise, complete easy tasks, and represent top brands. It’s simple, fun, and free to start — no experience required!',
        style: TextStyle(fontSize: 15.5.sp, height: 1.55, color: const Color(0xff333333))),
      SizedBox(height: 3.h),
      SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => _auth(const SignUp()), child: const Text('Get Started'))),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, height: 52, child: OutlinedButton(onPressed: () {}, child: const Text('Explore Tasks'))),
      SizedBox(height: 3.h),
      Image.asset('assets/social_media.gif', width: double.infinity, height: 68.w, fit: BoxFit.contain),
    ]),
  );

  Widget _section(String title, String subtitle, {Color bg = Colors.white}) => Container(
    color: bg, padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 3.h), width: double.infinity,
    child: Column(children: [
      Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800)),
      SizedBox(height: 1.4.h),
      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5.sp, height: 1.5, fontWeight: FontWeight.w600, color: const Color(0xff3f3f3f))),
    ]),
  );

  Widget _howItWorks() => Container(color: _light, child: Column(children: [
    _section('How it Works', 'Join thousands of people who earn money and win prizes by completing simple tasks in their free time.', bg: _light),
    _featureCard(Icons.work_outline, 'Earn Money & Points', 'Get paid for publishing ads for brands or promoting brands, climb the leaderboard and win cash prizes, and unlock massive cash and item rewards.'),
    _featureCard(Icons.task_alt, 'Choose Simple Tasks', 'Choose simple tasks that match your time and eligibility, then submit the requested proof.'),
    _featureCard(Icons.verified, 'Submit & Get Paid', 'Complete your task, submit proof for review, and receive approved earnings through the platform.'),
  ]);

  Widget _featureCard(IconData icon, String title, String body) => Container(
    margin: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h), padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6.h),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5))]),
    child: Column(children: [
      Container(width: 110, height: 110, decoration: const BoxDecoration(color: Color(0xffffeee9), shape: BoxShape.circle), child: Icon(icon, size: 52, color: _orange)),
      SizedBox(height: 3.h), Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500)),
      SizedBox(height: 2.h), Text(body, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5.sp, height: 1.55, color: _muted)),
    ]),
  );

  Widget _featuredTasks() => Column(children: [
    _section('Featured Tasks', 'Easy gigs. Your next reward is one task away. Start earning now!'),
    Padding(padding: EdgeInsets.symmetric(horizontal: 7.w), child: Row(children: [
      _chip('All Task', true), const SizedBox(width: 12), _chip('Repeating', false), const SizedBox(width: 12), _chip('High Earning', false),
    ])),
    SizedBox(height: 2.5.h),
    SizedBox(height: 390, child: TaskStream(isVertical: false, limit: 6, onAccept: (_) => _auth(const SignIn()))),
    SizedBox(height: 3.h),
  ]);

  Widget _chip(String label, bool active) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14), alignment: Alignment.center,
    decoration: BoxDecoration(color: active ? _orange : Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: active ? _orange : const Color(0xffbfc1c4), width: 2)),
    child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: active ? Colors.white : Colors.black)),
  ));

  Widget _leaderboard() => Container(color: _light, child: Column(children: [
    _section('Leaderboard', 'See who’s earning the most and get inspired to climb the ranks', bg: _light),
    _leaderCard('1', 'assets/icons/leadboard_avatar1.png', '50,000 Pts', '60', '₦6', const Color(0xfffffbd4), const Color(0xffb68b00)),
    _leaderCard('2', 'assets/icons/leadboard_avatar2.png', '10,000 Pts', '58', '₦5', Colors.white, const Color(0xff727785)),
    _leaderCard('3', 'assets/icons/leadboard_avatar3.png', '5,000 Pts', '52', '₦5', Colors.white, const Color(0xffdf733e)),
    TextButton(onPressed: () {}, child: const Text('View full leaderboard ↗', style: TextStyle(color: _orange, fontSize: 16))),
    SizedBox(height: 3.h),
  ]));

  Widget _leaderCard(String rank, String asset, String points, String perf, String approval, Color bg, Color rankColor) => Container(
    margin: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h), padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5))]),
    child: Column(children: [
      Icon(Icons.workspace_premium, size: 46, color: rankColor), SizedBox(height: 1.h),
      CircleAvatar(radius: 62, backgroundColor: rankColor, child: Text(rank, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
      SizedBox(height: 2.h), CircleAvatar(radius: 53, backgroundImage: AssetImage(asset)), SizedBox(height: 3.h),
      Row(children: [Expanded(child: _metric('Total Referral', '0')), Expanded(child: _metric('Total Points', points))]),
      SizedBox(height: 2.h), Row(children: [Expanded(child: _metric('Performance Score', perf)), Expanded(child: _metric('Approval Score', approval))]),
    ]),
  );

  Widget _metric(String label, String value) => Column(children: [Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: const Color(0xff5c6070))), SizedBox(height: .5.h), Text(value, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800))]);

  Widget _whyChoose() => Container(color: Colors.white, child: Column(children: [
    _section('Why Choose ClickWorkers?', 'Join thousands of Nigerians who are earning money through our platform'),
    _whyCard(Icons.access_time, 'Flexible Work', 'Work anytime, anywhere with absolutely no skills required. Perfect for students, stay-at-home parents, or anyone looking for extra income.'),
    _whyCard(Icons.account_balance_wallet_outlined, 'Fast Payouts', 'Get paid quickly for completed and approved tasks through secure payment options.'),
    _whyCard(Icons.sports_esports_outlined, 'Gamified Experience', 'Earn rewards through leaderboards, treasure hunts, and spins. Win cash prizes from ₦50,000 to ₦2.5M, gadgets, event tickets, and more.'),
    _whyCard(Icons.public, 'Opportunities in Africa', 'Partner with numerous advertising companies, task platforms, and gift-sharing services to ensure you always have opportunities to earn.'),
    _whyCard(Icons.verified_user_outlined, 'Secure & Trusted', 'Join the ClickWorkers community and use a secure platform built around clear tasks and rewards.'),
    SizedBox(height: 1.h), ElevatedButton(onPressed: () => _auth(const SignUp()), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12), child: Text('Join Now'))),
    SizedBox(height: 5.h),
  ]));

  Widget _whyCard(IconData icon, String title, String body) => Container(
    margin: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h), padding: EdgeInsets.fromLTRB(5.w, 4.h, 5.w, 5.h),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xffeeeeee)), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 100, height: 100, decoration: const BoxDecoration(color: _soft, shape: BoxShape.circle), child: Icon(icon, size: 48, color: _orange)),
      SizedBox(height: 3.h), Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)), SizedBox(height: 2.h), Text(body, style: TextStyle(fontSize: 14.5.sp, height: 1.55, color: _muted)),
    ]),
  );

  Widget _testimonials() => Container(color: _light, child: Column(children: [
    _section('Testimonials', 'What workers say about their experience', bg: _light),
    _testimonial('Ugwu Shine', 'University student, Enugu', 'assets/icons/leadboard_avatar1.png', '“I was skeptical at first, but ClickWorkers has been a game-changer for me. As a student, I\'ve been able to earn enough to cover my expenses and even save some money. The tasks are simple and the payment is always on time!”', 'Won a MacBook Air worth ₦750,000'),
    _testimonial('Esther Howards', 'Entrepreneur, Lagos', 'assets/icons/leadboard_avatar2.png', '“I won a brand new laptop through the treasure hunt feature! I couldn\'t believe it at first. The platform is not just about completing tasks - the gamification makes it fun and rewarding.”', 'Won a brand new laptop'),
    _testimonial('Ralph Edwards', 'Student, Lagos', 'assets/icons/leadboard_avatar3.png', '“The platform is easy to use and I can complete tasks around my schedule.”', 'Earned ₦303,200 in 3 months'),
    _testimonial('Adekunle', 'Student, Lagos', 'assets/icons/leadboard_avatar1.png', '“I enjoy the rewards and simple tasks. It is easy to follow my progress.”', 'Free Video Intros'),
    SizedBox(height: 4.h),
  ]));

  Widget _testimonial(String name, String role, String avatar, String quote, String reward) => Container(
    margin: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h), padding: EdgeInsets.all(5.w),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(radius: 34, backgroundImage: AssetImage(avatar)), SizedBox(width: 3.w), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)), SizedBox(height: .5.h), Text(role, style: TextStyle(fontSize: 14.sp, color: _muted))]))]),
      SizedBox(height: 3.h), Text(quote, style: TextStyle(fontSize: 14.5.sp, height: 1.55, color: _muted)), SizedBox(height: 2.h), const Text('★★★★★', style: TextStyle(color: Color(0xffffc400), fontSize: 23, letterSpacing: 2)), SizedBox(height: 1.h), Text(reward, style: TextStyle(fontSize: 14.5.sp, color: const Color(0xff3f444b))),
    ]),
  );

  Widget _gamification() => Container(color: Colors.white, child: Column(children: [
    _section('Gamification', 'Join thousands of people who earn money and win prizes by completing simple tasks in their free time.'),
    _gameCard(Icons.card_giftcard, 'Treasure Hunt', 'Find hidden rewards in ads and tasks. Discover treasure boxes worth up to ₦50,000 in cash and points.'),
    _gameCard(Icons.casino, 'Spin & Win', 'Exchange earnings for bonus points to climb the leaderboard and win millions in cash and item rewards.'),
    _gameCard(Icons.workspace_premium, 'Achievements & Badges', 'Get recognized for completing milestones. Earn exclusive badges and unlock special rewards.'),
    SizedBox(height: 3.h),
  ]));

  Widget _gameCard(IconData icon, String title, String body) => Container(
    margin: EdgeInsets.fromLTRB(7.w, 0, 7.w, 2.h), padding: EdgeInsets.fromLTRB(7.w, 5.h, 7.w, 5.h),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xff6f7379)), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))]),
    child: Column(children: [Container(width: 100, height: 100, decoration: const BoxDecoration(color: _soft, shape: BoxShape.circle), child: Icon(icon, size: 44, color: _orange)), SizedBox(height: 3.h), Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)), SizedBox(height: 3.h), Text(body, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5.sp, height: 1.55, color: _muted)), SizedBox(height: 2.h), const Text('Learn More', style: TextStyle(color: _orange, fontSize: 16, decoration: TextDecoration.underline))]),
  );

  Widget _videoDemo() => Container(color: _light, padding: EdgeInsets.fromLTRB(2.5.w, 3.h, 2.5.w, 3.h), child: Container(
    color: _light, padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 5.h), child: Column(children: [
      Text('Video Walkthrough/Demo', style: TextStyle(fontSize: 20.sp)), SizedBox(height: 3.h),
      Container(padding: EdgeInsets.all(5.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5))]), child: Column(children: [
        AspectRatio(aspectRatio: 16/9, child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)), child: Center(child: Container(width: 90, height: 64, decoration: BoxDecoration(color: const Color(0xffd0002b), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.play_arrow, color: Colors.white, size: 42))))),
        SizedBox(height: 5.h), Container(padding: EdgeInsets.all(5.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xff55595e))), child: Column(children: [Text('How to Earn Money online with Click Workers', textAlign: TextAlign.center, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)), SizedBox(height: 2.h), Text('A 30-60 second video explaining how Click Workers works.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5.sp, height: 1.5, color: _muted))])),
      ])),
    ]),
  ));

  Widget _activity() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: EdgeInsets.fromLTRB(7.w, 4.h, 7.w, 2.h), child: Text('Live Activity Feed', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800))),
    _activityCard(const Color(0xffcdd0ff), Icons.checklist, 'Adebayo from Lagos just completed a Twitter task and earned ₦500!', '2 Minutes ago', const Color(0xff3552c9)),
    _activityCard(const Color(0xffffd3c7), Icons.card_giftcard, 'Ngozi unlocked a treasure box worth 100 Points!', '5 Minutes ago', _orange),
    _activityCard(const Color(0xffdba9e9), Icons.workspace_premium, 'Emeka ranked up to Pro User this week!', '10 Minutes ago', const Color(0xff8b1cc0)),
    SizedBox(height: 2.h),
  ]);

  Widget _activityCard(Color bg, IconData icon, String text, String time, Color accent) => Container(
    margin: EdgeInsets.fromLTRB(7.w, 0, 7.w, 2.h), padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 9, offset: Offset(0, 5))]),
    child: Row(children: [Container(width: 70, height: 70, decoration: BoxDecoration(color: accent.withOpacity(.45), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 35)), SizedBox(width: 4.w), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(text, style: TextStyle(fontSize: 15.sp, height: 1.35)), SizedBox(height: 1.h), Text(time, style: TextStyle(fontSize: 13.5.sp, color: _muted))]))]),
  );

  Widget _referral() => Container(margin: EdgeInsets.fromLTRB(7.w, 0, 7.w, 2.h), padding: EdgeInsets.all(5.w), decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(28)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Refer & Earn 5% Extra', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white)), SizedBox(height: 1.5.h),
    Text('Invite your friends to join ClickWorkers and earn 5% of their task earnings.', style: TextStyle(fontSize: 14.5.sp, height: 1.5, color: Colors.white)), SizedBox(height: 2.h),
    SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _orange), onPressed: () => _auth(const SignUp()), child: const Text('Invite Friends'))),
  ]));

  Widget _faqs() => Container(color: _light, padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 4.h), child: Column(children: [
    Text('FAQs', style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800)), SizedBox(height: 1.h), Text('Find answers to common questions about ClickWorkers.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5.sp, color: _muted)), SizedBox(height: 2.h),
    _faq('Do I need experience?', 'No specialist experience is required for suitable beginner tasks.'),
    _faq('What type of ads and tasks can I perform?', 'Tasks can include social media promotion, advertising, engagement and other simple digital activities.'),
    _faq('How can I withdraw?', 'This is a random body of text, a placeholder, it is to be changed'),
    _faq('What happens if my task submission is rejected?', 'This is a random body of text, a placeholder, it is to be changed'),
    _faq('Is ClickWorkers available in my country?', 'Availability depends on task and platform eligibility in your location.'),
    SizedBox(height: 2.h), Text('Still have questions?', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800)), SizedBox(height: 1.h), Text('Contact our support team', style: TextStyle(fontSize: 14.5.sp, color: _muted)),
  ]));

  Widget _faq(String q, String a) => Card(color: Colors.white, elevation: 0, margin: EdgeInsets.only(bottom: 1.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ExpansionTile(title: Text(q, style: const TextStyle(fontWeight: FontWeight.w700)), childrenPadding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 2.h), children: [Text(a, style: TextStyle(fontSize: 14.5.sp, height: 1.5))]));

  Widget _joinToday() => Container(margin: EdgeInsets.fromLTRB(7.w, 3.h, 7.w, 2.h), padding: EdgeInsets.fromLTRB(5.w, 4.h, 5.w, 5.h), decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(28)), child: Column(children: [
    Text('Join ClickWorkers Today!', textAlign: TextAlign.center, style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800, color: Colors.white)), SizedBox(height: 2.h),
    Text("Start earning money, winning prizes, and building your future with Africa's #1 earning platform.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, height: 1.5, fontWeight: FontWeight.w700, color: Colors.white)), SizedBox(height: 3.h),
    SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _orange), onPressed: () => _auth(const SignUp()), child: const Text('Sign Up Now'))), SizedBox(height: 1.5.h),
    SizedBox(width: double.infinity, height: 52, child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 2)), onPressed: () => _auth(const SignIn()), child: const Text('Already a member? Login'))),
  ]));

  Widget _stats() => Container(margin: EdgeInsets.fromLTRB(7.w, 0, 7.w, 3.h), padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h), decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(28)), child: Column(children: [
    _stat('250,000+', 'Active Users'), _stat('8.2M+', 'Tasks Completed'), _stat('₦209.5M+', 'Paid to Users'), _stat('65,000+', 'Prizes Awarded'),
  ]));
  Widget _stat(String value, String label) => Padding(padding: EdgeInsets.symmetric(vertical: 1.5.h), child: Column(children: [Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white)), SizedBox(height: .5.h), Text(label, style: TextStyle(fontSize: 15.sp, color: Colors.white))]));

  Widget _newsletter() => Container(padding: EdgeInsets.fromLTRB(7.w, 3.h, 7.w, 5.h), child: Column(children: [
    Text('Subscribe to our newsletter', style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800)), SizedBox(height: 2.h),
    Text('Stay up to date with ClickWorkers for the latest updates, tips, and news', textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp, height: 1.5, fontWeight: FontWeight.w700)), SizedBox(height: 3.h),
    Container(height: 58, decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white, width: 2)), child: Row(children: [Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: Text('Your Email', style: TextStyle(fontSize: 15.sp, color: _muted)))), Container(width: 150, height: double.infinity, decoration: const BoxDecoration(color: _orange, borderRadius: BorderRadius.horizontal(right: Radius.circular(32))), alignment: Alignment.center, child: const Text('Subscribe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))])),
  ]));
}

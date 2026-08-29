import 'package:click_workers/Desktop/home/dashboard.dart';
import 'package:click_workers/Desktop/rewards/leaderboard.dart';
import 'package:click_workers/Desktop/widgets/desktop.dart';
import 'package:click_workers/Desktop/rewards/reward.dart';
import 'package:click_workers/Desktop/settings/change_password.dart';
import 'package:click_workers/Desktop/settings/change_profile.dart';
import 'package:click_workers/Desktop/settings/edit_profile.dart';
import 'package:click_workers/Desktop/settings/preferred_currency.dart';
import 'package:click_workers/Desktop/settings/preferred_language.dart';
import 'package:click_workers/Desktop/settings/settings.dart';
import 'package:click_workers/Desktop/settings/upgrade_plan.dart';
import 'package:click_workers/Desktop/task/task.dart';
import 'package:click_workers/Desktop/task/task_details.dart';
import 'package:click_workers/Desktop/task/task_submission.dart';
import 'package:click_workers/Desktop/wallet/wallet.dart';
import 'package:click_workers/Desktop/wallet/withdraw_funds.dart';
import 'package:click_workers/Desktop/wallet/withdraw_history.dart';
import 'package:click_workers/Desktop/widgets/dashboard_top_header.dart';
import 'package:click_workers/Desktop/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  late final Map<DesktopPage, DeskTopHeader> screens;

  final List<DesktopPage> _pageStack = [DesktopPage.dashboard];
  DesktopPage get _currentPage => _pageStack.last;

  final List<DesktopPage> sidebarPages = [
    DesktopPage.dashboard,
    DesktopPage.tasks,
    DesktopPage.ranking,
    DesktopPage.rewards,
    DesktopPage.wallet,
    DesktopPage.settings,
  ];
  @override
  void initState() {
    super.initState();

    screens = {
      DesktopPage.dashboard: const DesktopDashboard(),
      DesktopPage.tasks: TaskScreen(
        onNavigate: _navigateTo,
      ),
      DesktopPage.ranking: const LeaderboardScreen(),
      DesktopPage.rewards: const DesktopRewards(),
      DesktopPage.wallet: DeskTopWallet(
        onNavigate: _navigateTo,
      ),
      DesktopPage.settings: DesktopSettings(onNavigate: _navigateTo),
      DesktopPage.withdrawHistory: const WithdrawHistoryScreen(),
      DesktopPage.withdrawFunds: WithdrawFundsScreen(
        onNavigate: _navigateTo,
      ),
      DesktopPage.preferredCurrency: const PreferredCurrencyScreen(),
      DesktopPage.changePassword: const ChangePasswordScreen(),
      DesktopPage.taskDetails: TaskDetailsScreen(
        onNavigate: _navigateTo,
      ),
      DesktopPage.editProfile: EditProfileScreen(
        onNavigate: _navigateTo,
      ),
      DesktopPage.upgradePlan: UpgradePlanScreen(
        onNavigate: _navigateTo,
      ),
      DesktopPage.changeProfilePics: ChangeProfileScreen(
        onNavigate: _navigateTo,
      ),
      DesktopPage.preferredLanguage: PreferredLanguageScreen(
        onNavigate: _navigateTo,
      ),
      DesktopPage.taskSubmission: const TaskSubmissionScreen(),
    };
  }

  void _navigateTo(DesktopPage page) {
    setState(() {
      _pageStack.add(page);
    });
  }

  void _goBack() {
    if (_pageStack.length > 1) {
      setState(() {
        _pageStack.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = screens[_currentPage]!;
    String title = currentScreen.title;
    String? subtitle = currentScreen.subtitle;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Row(
          children: [
            DesktopSidebar(
              selectedIndex: sidebarPages.indexOf(_pageStack.first),
              onItemSelected: (index) {
                final selectedPage = sidebarPages[index];

                setState(() {
                  _pageStack
                    ..clear()
                    ..add(selectedPage); // Reset stack
                });
              },
            ),
            Expanded(
              child: Column(
                children: [
                  DashboardTopHeader(
                    leading: Row(
                      children: [
                        if (_pageStack.length > 1)
                          GestureDetector(
                            onTap: _goBack,
                            child: Image.asset(
                              'assets/icons/back_arrow.png',
                              height: 25,
                              width: 25,
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            if (subtitle != null)
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff6B7280),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(_currentPage),
                      padding: EdgeInsets.all(2.w),
                      child: currentScreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

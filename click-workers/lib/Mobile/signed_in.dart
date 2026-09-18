import 'package:click_workers/Mobile/Home/account_settings.dart';
import 'package:click_workers/Mobile/Home/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';
import 'package:click_workers/Mobile/Home/home.dart';
import 'package:click_workers/Mobile/Ranking/ranking.dart';
import 'package:click_workers/Mobile/Rewards/rewards.dart';
import 'package:click_workers/Mobile/Tasks/tasks.dart';
import 'package:click_workers/Mobile/Wallet/wallet.dart';
import 'Wallet/wallet_notifications.dart';
import 'authentication/utils/profile_photo_state.dart';

class SignedIn extends StatefulWidget {
  const SignedIn({super.key});

  @override
  State<SignedIn> createState() => _SignedInState();
}

class _SignedInState extends State<SignedIn> {
  String firstName = "";
  String fullName = "";
  String lastName = "";
  String selectedValue1 = "Simple";
  String selectedValue2 = "Low-Earning";
  String selectedValue3 = "Urgent";
  String isSelected = "All Tasks";
  final ValueNotifier<Map<String, dynamic>> filterNotifier =
      ValueNotifier<Map<String, dynamic>>({});

  final PageController controller = PageController();

  int _selectedIndex = 0;
  Map userDoc = {};

  @override
  void initState() {
    super.initState();
    getFirstName();
    fetchUser();
    initProfilePhoto();
  }

  void getFirstName() async {
    final user = AuthProvider().currentUser;
    if (user != null && user.fullName.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        final parts = user.fullName.split(' ');
        firstName = parts.first;
        lastName = parts.last;
        fullName = user.fullName;
      });
    } else if (mounted) {
      setState(() => firstName = 'Guest');
    }
  }

  void initProfilePhoto() {
    ProfilePhotoState.photoUrl.value = AuthProvider().currentUser?.photoURL;
  }

  void _openTryForFree() {
    setState(() => isSelected = 'Unpaid');
    controller.jumpToPage(1);
  }

  void fetchUser() {
    final user = AuthProvider().currentUser;
    if (user != null && mounted) {
      setState(() {
        userDoc = {'kycCompleted': user.kycVerified};
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    filterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tree = [
      Dashboard(controller: controller),
      Tasks(
        isSelected: isSelected,
        category: selectedValue1,
        payout: selectedValue2,
        urgency: selectedValue3,
      ),
      const Ranking(),
      Rewards(
        controller: controller,
        kycCompleted: userDoc['kycCompleted'] ?? false,
        onTryForFree: _openTryForFree,
      ),
      Wallet(
        controller: controller,
        kycCompleted: userDoc['kycCompleted'] ?? false,
      ),
    ];

    return Scaffold(
      appBar: _selectedIndex == 4
          ? AppBar(
              backgroundColor: Colors.white,
              centerTitle: false,
              title: const Text(
                "Wallet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletNotifs(
                          isSelected: "All",
                          mainCategories: ["All"],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.bell_fill),
                )
              ],
            )
          : _selectedIndex == 3
              ? AppBar(
                  backgroundColor: Colors.white,
                  centerTitle: false,
                  title: const Text(
                    "Rewards",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : _selectedIndex == 2
                  ? AppBar(
                      backgroundColor: Colors.white,
                      centerTitle: false,
                      title: const Text(
                        "Leaderboard",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : _selectedIndex == 1
                      ? AppBar(
                          backgroundColor: Colors.white,
                          centerTitle: false,
                          title: const Text(
                            "Tasks",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : AppBar(
                          backgroundColor: Colors.white,
                          title: RichText(
                            text: TextSpan(
                              text: "  Click Workers",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: "\n   Hi $firstName",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff6b7280),
                                  ),
                                )
                              ],
                            ),
                          ),
                          actions: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountSettings(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Notifications(),
                                  ),
                                );
                              },
                              icon: const Icon(CupertinoIcons.bell_fill),
                            ),
                          ],
                        ),
      backgroundColor: const Color(0xffd9d9d9),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: filterNotifier,
        builder: (context, filter, _) {
          return PageView(
            controller: controller,
            children: tree,
            onPageChanged: (index) {
              if (mounted) setState(() => _selectedIndex = index);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xffff6533),
        unselectedItemColor: const Color(0xff6b7280),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        currentIndex: _selectedIndex,
        onTap: (index) {
          controller.jumpToPage(index);
          setState(() => _selectedIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/home.png",
              color: _selectedIndex == 0
                  ? const Color(0xffff6533)
                  : const Color(0xff6b7280),
            ),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/choose.png",
              color: _selectedIndex == 1
                  ? const Color(0xffff6533)
                  : const Color(0xff6b7280),
              height: 24,
              width: 20,
            ),
            label: "Task",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/reward.png",
              color: _selectedIndex == 3
                  ? const Color(0xffff6533)
                  : const Color(0xff6b7280),
            ),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/icons/wallet.png",
              color: _selectedIndex == 4
                  ? const Color(0xffff6533)
                  : const Color(0xff6b7280),
            ),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}

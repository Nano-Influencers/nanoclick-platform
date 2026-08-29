import 'package:click_workers/Mobile/Home/account_settings.dart';
import 'package:click_workers/Mobile/Home/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:click_workers/Mobile/Home/home.dart';
import 'package:click_workers/Mobile/Ranking/ranking.dart';
import 'package:click_workers/Mobile/Rewards/rewards.dart';
import 'package:click_workers/Mobile/Tasks/tasks.dart';
//import 'package:responsive_sizer/responsive_sizer.dart';
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

  final PageController controller =
      PageController(); //initialize controller for pageview

  int _selectedIndex = 0;
  Map userDoc = {};

  FirebaseFirestore? otherFirestore;

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
    getFirstName();
    readFromOtherFirestore();
    fetchUser();
    initProfilePhoto();
  }

  // void showTopDrawer(BuildContext context) {
  //   showGeneralDialog(
  //     barrierDismissible: true,
  //     barrierLabel: "TopDrawer",
  //     barrierColor: Colors.black.withOpacity(0.3),
  //     transitionDuration: const Duration(milliseconds: 300),
  //     context: context,
  //     pageBuilder: (context, anim1, anim2) {
  //       return const SizedBox.shrink(); // required, but we override it below
  //     },
  //     transitionBuilder: (context, anim1, anim2, child) {
  //       return Transform.translate(
  //         offset: Offset(0, -200 + anim1.value * 200), // slide down
  //         child: Align(
  //           alignment: Alignment.topCenter,
  //           child: Material(
  //             elevation: 8,
  //             borderRadius: const BorderRadius.only(
  //               bottomLeft: Radius.circular(30),
  //               bottomRight: Radius.circular(30),
  //             ),
  //             child: StatefulBuilder(builder: (context, localSetState) {
  //               return Container(
  //                 width: double.infinity,
  //                 height: 38.h, // custo
  //                 padding: const EdgeInsets.all(20),
  //                 decoration: const BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.only(
  //                       bottomLeft: Radius.circular(24),
  //                       bottomRight: Radius.circular(24),
  //                     )),
  //                 child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           const Text("Filter Tasks",
  //                               style: TextStyle(
  //                                   fontSize: 14, fontWeight: FontWeight.bold)),
  //                           TextButton(
  //                               onPressed: () {
  //                                 setState(() {
  //                                   isSelected = "Filtered";
  //                                 });
  //                                 filterNotifier.value = {};
  //                                 Navigator.pop(context);
  //                               },
  //                               child: const Text("Done",
  //                                   style: TextStyle(
  //                                       fontSize: 14,
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.black))),
  //                         ],
  //                       ),
  //                       SizedBox(height: 2.h),
  //                       const Text("Main Category",
  //                           style: TextStyle(
  //                               fontSize: 12, color: Color(0xff6b7280))),
  //                       SizedBox(height: 0.5.h),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: DropdownButtonFormField(
  //                           items: ['High-Points', 'Simple', 'Non Repeating']
  //                               .map((e) =>
  //                                   DropdownMenuItem(value: e, child: Text(e)))
  //                               .toList(),
  //                           value: 'Simple',
  //                           onChanged: (val) {
  //                             localSetState(() {
  //                               selectedValue1 = val!;
  //                             });
  //                           },
  //                           decoration: const InputDecoration(
  //                               border: OutlineInputBorder()),
  //                         ),
  //                       ),
  //                       SizedBox(height: 2.h),
  //                       Row(children: [
  //                         const Text("Payout",
  //                             style: TextStyle(
  //                               color: Color(0xff6b7280),
  //                               fontSize: 12,
  //                             )),
  //                         SizedBox(width: 40.w),
  //                         const Text("Urgency",
  //                             style: TextStyle(
  //                                 color: Color(0xff6b7280), fontSize: 12))
  //                       ]),
  //                       Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             SizedBox(
  //                               width: 40.w,
  //                               child: DropdownButtonFormField(
  //                                 items: ['High-Earning', 'Low-Earning']
  //                                     .map((e) => DropdownMenuItem(
  //                                         value: e, child: Text(e)))
  //                                     .toList(),
  //                                 value: 'High-Earning',
  //                                 onChanged: (val) {
  //                                   localSetState(() {
  //                                     selectedValue2 = val!;
  //                                   });
  //                                 },
  //                                 decoration: const InputDecoration(
  //                                     border: OutlineInputBorder()),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               width: 40.w,
  //                               child: DropdownButtonFormField(
  //                                 items: ['Night Tasks', 'Urgent', 'Short-Time']
  //                                     .map((e) => DropdownMenuItem(
  //                                         value: e, child: Text(e)))
  //                                     .toList(),
  //                                 value: 'Urgent',
  //                                 onChanged: (val) {
  //                                   localSetState(() {
  //                                     selectedValue3 = val!;
  //                                   });
  //                                 },
  //                                 decoration: const InputDecoration(
  //                                     border: OutlineInputBorder()),
  //                               ),
  //                             ),
  //                           ])
  //                     ]),
  //               );
  //             }),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void getFirstName() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user!.reload();
    if (user.displayName != null) {
      setState(() {
        firstName = user.displayName!.split(' ').first;
        lastName = user.displayName!.split(' ').last;
        fullName = user.displayName!;
      });
    } else {
      setState(() {
        firstName = 'Guest';
      });
    }
  }

  void initProfilePhoto() {
    final user = FirebaseAuth.instance.currentUser;
    ProfilePhotoState.photoUrl.value = user?.photoURL;
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
    final userData = await getUserDoc(FirebaseAuth.instance.currentUser!.uid);
    if (userData != null) {
      setState(() {
        userDoc = userData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tree = [
      Dashboard(controller: controller, otherFirestore: otherFirestore),
      Tasks(
          otherFirestore: otherFirestore,
          isSelected: isSelected,
          category: selectedValue1,
          payout: selectedValue2,
          urgency: selectedValue3),
      const Ranking(),
      Rewards(
          controller: controller,
          kycCompleted: userDoc['kycCompleted'] ?? false),
      Wallet(
          controller: controller,
          kycCompleted: userDoc['kycCompleted'] ?? false),
    ];

    return Scaffold(
      appBar: _selectedIndex == 4
          ? AppBar(
              backgroundColor: Colors.white,
              centerTitle: false,
              title: const Text("Wallet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WalletNotifs(
                                isSelected: "All", mainCategories: ["All"])),
                      );
                    },
                    icon: const Icon(CupertinoIcons.bell_fill))
              ],
            )
          : _selectedIndex == 3
              ? AppBar(
                  backgroundColor: Colors.white,
                  centerTitle: false,
                  title: const Text("Rewards",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
              : _selectedIndex == 2
                  ? AppBar(
                      backgroundColor: Colors.white,
                      centerTitle: false,
                      title: const Text("Leaderboard",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)))
                  : _selectedIndex == 1
                      ? AppBar(
                          backgroundColor: Colors.white,
                          centerTitle: false,
                          title: const Text("Tasks",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          // actions: [
                          //   // InkWell(
                          //   //     onTap: () {
                          //   //       showTopDrawer(context);
                          //   //     },
                          //   //     child: Image.asset(
                          //   //         "assets/icons/filter_funnel.png"))
                          // ],
                        )
                      : AppBar(
                          backgroundColor: Colors.white,
                          title: RichText(
                              text: TextSpan(
                                  text: "  Click Workers",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                TextSpan(
                                    text: "\n   Hi $firstName",
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xff6b7280)))
                              ])),
                          actions: [
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AccountSettings(
                                            status: userDoc['status'],
                                            id: userDoc['refID'])),
                                  );
                                },
                                icon: const Icon(Icons.settings)),
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Notifications()),
                                  );
                                },
                                icon: const Icon(CupertinoIcons.bell_fill)),
                          ],
                        ),
      backgroundColor: const Color(0xffd9d9d9),
      body: otherFirestore == null
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: filterNotifier,
              builder: (context, filter, _) {
                return PageView(
                    controller: controller,
                    children: tree,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;

                        /// Switching bottom tabs
                      });
                    });
              }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xffff6533),
        unselectedItemColor: const Color(0xff6b7280),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12), // for selected tab
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        currentIndex: _selectedIndex,
        onTap: (index) {
          controller.jumpToPage(index);

          /// Switching the PageView tabs
          setState(() {
            _selectedIndex = index;
          });
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
              label: "Task"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Ranking'),
          BottomNavigationBarItem(
              icon: Image.asset(
                "assets/icons/reward.png",
                color: _selectedIndex == 3
                    ? const Color(0xffff6533)
                    : const Color(0xff6b7280),
              ),
              label: 'Rewards'),
          BottomNavigationBarItem(
              icon: Image.asset(
                "assets/icons/wallet.png",
                color: _selectedIndex == 4
                    ? const Color(0xffff6533)
                    : const Color(0xff6b7280),
              ),
              label: 'Wallet')
        ],
      ),
    );
  }
}

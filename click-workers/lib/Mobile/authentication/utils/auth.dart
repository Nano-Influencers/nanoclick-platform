import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:click_workers/Mobile/authentication/utils/user.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => auth.currentUser;
  bool refreshFav = false;

  Stream<User?> get user_ => auth.authStateChanges();

  void updateVar() {
    refreshFav = true;

    notifyListeners();
  }

  String generateRandomId({int length = 20}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

//reset password
  Future forgotPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(
        email: email,
        // actionCodeSettings: ActionCodeSettings(
        //   url: 'https://nano-influencers.com', // 👈 your domain ONLY
        //   handleCodeInApp: true,
        // ),
      );
      
    } on FirebaseAuthException catch (e) {
      return e.toString();
    }
  }

//confirm password reset
  
  Future<String?> confirmPasswordReset(
      String oobCode, String newPassword) async {
    try {
      await auth.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong";
    }
  }

  String generateReferralCode(String uid) {
    //creates a checksum from uid
    int sum = uid.codeUnits.fold(0, (a, b) => a + b);

    //reverses uid checksum (base36) for randomness
    String mixed = uid.split('').reversed.join() + sum.toRadixString(36);

    //returns first 6 characters (uppercase)
    return mixed.substring(0, 6).toUpperCase();
  }

//reload page
  reload() async {
    return auth.currentUser?.reload();
  }

  late ConfirmationResult confirmationResult;
  int? updateToken = 0;

//create user in firestore
  Future createUserInFirestore(
    String username,
    String password,
  ) async {
    DocumentSnapshot doc =
        await firestore.collection('users').doc(currentUser!.uid).get();

    if (!doc.exists) {
      String refID = generateReferralCode(currentUser!.uid);
      firestore.collection('users').doc(currentUser!.uid).set({
        'username': "@${username.replaceAll(' ', '').toLowerCase()}",
        'birthday': "2000-01-01",
        'referrals': 0,
        'lastHintUsed': null,
        'longestStreak': 0,
        'refID': refID,
        'kycProgress': 0.0,
        'kycCompleted': false,
        'gritLevel': "1",
        'gratisLevel': "1",
        'ongoingTasks': 0,
        'missedTasks': 0,
        'dp': '',
        'completedTasks': 0,
        'phoneNumber': "",
        'streakRank': "Rookie",
        'status': "non-verified",
        'email': currentUser!.email,
        'password': password,
        'createdOn': DateTime.now(),
      }).onError((error, stackTrace) => debugPrint(error.toString()));
      createUserWallet();
      setupUserData(currentUser!.uid);
      setupWalletData(currentUser!.uid);
      setupLeaderboardEntry(currentUser!.uid, refID);
    }
  }

  //create user object based on firebase user
  UserId? _userFromFirebaseUser(User? user) {
    return user != null ? UserId() : null;
  }

//sign in with email and password
 Future<String?> signInWithEmailAndPassword(
  String email,
  String password,
) async {
  try {
    final result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user == null) {
      return "User not found";
    }

    if (!user.emailVerified) {
      await user.sendEmailVerification();
      return "Please verify your email first";
    }

    return null; // ✅ SUCCESS
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        return "No account found for this email";
      case 'wrong-password':
        return "Incorrect password";
      case 'invalid-email':
        return "Invalid email format";
      case 'user-disabled':
        return "This account has been disabled";
      default:
        return e.message ?? "Login failed";
    }
  } catch (e) {
    return "Something went wrong";
  }
}

//fetch sign in methods for email
  // Future<List> fetchSignInMethodsForEmail(String email) async {
  //   List signInMethods = await auth.fetchSignInMethodsForEmail(email);
  //   return signInMethods;
  // }

//sign up with email and password
  Future registerWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      await user.updateDisplayName(fullName);
      await user.reload();

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      String error = e.message.toString();
      return error;
    }
  }

//create user wallet
  Future createUserWallet() async {
    DocumentSnapshot doc =
        await firestore.collection('wallets').doc(currentUser!.uid).get();

    if (!doc.exists) {
      firestore.collection('wallets').doc(currentUser!.uid).set({
        'totalPoints': "0",
        'totalEarnings': "0",
        'availablePoints': "0",
        'availableEarnings': "0",
        'availableReferralPoints': "0",
        'availableReferralEarnings': "0",
        'currentRank': "Platinum",
        'dailyCheckinTotalCps': "0",
        'kycStatus': "Not Started",
        'minimumWithdrawal': "0",
        'pendingEarnings': "0",
        'pendingPoints': "0",
        'referrals': 0,
        'spinToWinCash': "0",
        'spinToWinPoints': "0",
        'totalReferralEarnings': "0",
        'totalReferralPoints': "0",
        'usedReferralEarnings': "0",
        'usedReferralPoints': "0",
        'usedPoints': "0",
        'workerStatus': "Basic",
        'withdrawalStatus': "Ineligible, Complete Kyc",
        'withdrawnEarnings': "0",
        'gritEarnings': 0,
        'gratisEarnings': 0,
        'taskEarnings': 0,
        'weeklyTaskEarnings': 0,
        'monthlyTaskEarnings': 0,
        'cpsEarnings': 0,
        'weeklyCpsEarnings': 0,
        'monthlyCpsEarnings': 0,
        'rpsEarnings': 0,
        'weeklyRpsEarnings': 0,
        'monthlyRpsEarnings': 0,
        'streakEarnings': 0,
        'weeklyStreakEarnings': 0,
        'monthlyStreakEarnings': 0,
      }).onError((error, stackTrace) => debugPrint(error.toString()));
    }
  }

//update resend token
  void updateResendToken(int? resendToken) {
    updateToken = resendToken;
    notifyListeners();
  }

  //verify user phoneNumber
  verifyUserPhoneNumber(String userNumber) async {
    try {
      // Wait for the user to complete the reCAPTCHA & for an SMS code to be sent.
      ConfirmationResult result =
          await auth.signInWithPhoneNumber('+234$userNumber');
      return result;
    } on FirebaseAuthException catch (e) {
      String error = e.message.toString();
      debugPrint(e.message);
      return error;
    }
  }

  //setUp User Data
  Future<void> setupUserData(String userId) async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    // 1. Ensure main user doc exists
    await userRef.set({
      "createdAt": FieldValue.serverTimestamp(),
      "emailVerified": false,
    }, SetOptions(merge: true));

    // 2. Subcollection: treasures/{userId}
    final treasureDoc = userRef.collection("treasures").doc(userId);
    final treasureSnap = await treasureDoc.get();

    if (!treasureSnap.exists) {
      await treasureDoc.set({
        "found": 0,
        "hintUsed": 0,
        "huntedDown": 0,
        "itemsWon": [],
        "participated": 0,
        "spentEarnings": "",
        "spentPoints": "",
        "weeklyStatus": "Participating",
      });
    }

    // 3. Sub-subcollection: treasureHistory/{approved|rejected|found}
    final treasureHistoryRef = treasureDoc.collection("treasureHistory");

    final historyDocs = {
      "approved": {
        "details": [],
        "date": [],
        "hintLeadUsed": [],
        "imageUrls": [],
        "rewardID": []
      },
      "rejected": {"details": [], "date": [], "reason": [], "imageUrls": []},
      "found": {"details": [], "date": [], "imageUrls": [], "status": []},
    };

    for (final entry in historyDocs.entries) {
      final docRef = treasureHistoryRef.doc(entry.key);
      final snap = await docRef.get();
      if (!snap.exists) {
        await docRef.set(entry.value);
      }
    }

    // 4. Subcollection: walletSnapshots/{today|yesterday}
    final walletRef = userRef.collection("walletSnapshots");

    final walletDocs = {
      "today": {
        "availableEarnings": "0",
        "availablePoints": "0",
        "dateString": "0",
        "referralEarnings": "0",
        "totalEarnings": "0",
        "totalPoints": "0",
        "date": null,
      },
      "yesterday": {
        "balance": 0,
        "availableEarnings": "0",
        "availablePoints": "0",
        "dateString": "0",
        "referralEarnings": "0",
        "totalEarnings": "0",
        "totalPoints": "0",
        "date": null,
      },
    };

    for (final entry in walletDocs.entries) {
      final docRef = walletRef.doc(entry.key);
      final snap = await docRef.get();
      if (!snap.exists) {
        await docRef.set(entry.value);
      }
    }
  }

  //set leaderboard for user
  Future<void> setupLeaderboardEntry(String userId, String refID) async {
    final leaderboardRef =
        FirebaseFirestore.instance.collection("leaderboard").doc(userId);

    await leaderboardRef.set({
      "ID": refID,
      "approvalScore": "0",
      "createdAt": FieldValue.serverTimestamp(),
      "diversityScore": "0",
      "performanceScore": 0,
      "quantityScore": "0",
      "rating": "0",
      "speedScore": "0",
      "streak": 0,
      "uid": currentUser!.uid,
      "weeklyApprovalScore": "0",
      "weeklyClickPoints": 0,
      "weeklyDiversityScore": "0",
      "weeklyPerformanceScore": 0,
      "weeklyQuantityScore": "0",
      "weeklyRating": "0",
      "weeklyReferrals": 0,
      "weeklySpeedScore": "0",
      "dp": "",
      "clickPoints": 0,
      "referrals": 0,
      "weeklyStreak": 1,
      "name": currentUser!.displayName,
    }, SetOptions(merge: true));
  }

  //set up user wallet
  Future<void> setupWalletData(String userId) async {
    final walletRef =
        FirebaseFirestore.instance.collection("wallets").doc(userId);

    // 1. Ensure wallet doc exists
    await walletRef.set({
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Subcollection: walletSnapshots/{today|yesterday}
    final Map<String, Map<String, Map<String, dynamic>>> subCollections = {
      "walletSnapshots": {
        "today": {
          "availableEarnings": "0",
          "availableClickPoints": "0",
          "dailyCheckinCps": "0",
          "dateString": "0",
          "pendingClickPoints": "0",
          "pendingEarnings": "0",
          "referralEarnings": "0",
          "referrals": "0",
          "spinToWinCash": "0",
          "spinToWinPoints": "0",
          "totalEarnings": "0",
          "totalPoints": "0",
          "usedClickPoints": "0",
          "withdrawnEarnings": "0",
          "date": null,
        },
        "yesterday": {
          "balance": 0,
          "availableEarnings": "0",
          "availablePoints": "0",
          "dateString": "0",
          "referralEarnings": "0",
          "totalEarnings": "0",
          "totalPoints": "0",
          "date": null,
        },
      },
      "oneOffGrouped": {
        "today": {
          "cash": "0",
          "points": "0",
        },
        "total": {
          "cash": 0,
          "points": "0",
        },
      },
      "oneOffSingle": {
        "today": {
          "cash": "0",
          "points": "0",
        },
        "total": {
          "cash": 0,
          "points": "0",
        },
      },
      "repeatingGrouped": {
        "today": {
          "cash": "0",
          "points": "0",
        },
        "total": {
          "cash": 0,
          "points": "0",
        },
      },
      "repeatingSingle": {
        "today": {
          "cash": "0",
          "points": "0",
        },
        "total": {
          "cash": 0,
          "points": "0",
        },
      },
      "timeOrSkillBased": {
        "today": {
          "cash": "0",
          "points": "0",
        },
        "total": {
          "cash": 0,
          "points": "0",
        },
      },
      "trendPush": {
        "today": {
          "cash": "0",
          "points": "0",
        },
        "total": {
          "cash": 0,
          "points": "0",
        },
      },
      "unpaid": {
        "today": {
          "cash": "0",
          "points": "0",
        },
        "total": {
          "cash": 0,
          "points": "0",
        },
      },
      "treasureHunt": {
        generateRandomId(): {
          "cashPending": "0",
          "cashRedeemedValue": "0",
          "cashWithdrawn": "0",
          "cpsRedeemedValue": "0",
          "monetaryRedeemedValue": "0",
          "noOfItems": "0",
          "numberPending": "0",
          "numberRedeemed": "0",
          "totalCash": "0",
          "totalTreasurePoints": "0",
          "totalTreasurePointsPending": "0",
          "totalTreasurePointsWithdrawn": "0",
        },
      },
    };

    // 3. Loop through and create docs if missing
    for (final entry in subCollections.entries) {
      final subName = entry.key;
      final docs = entry.value;

      final subRef = walletRef.collection(subName);

      // If docs are predefined
      if (docs.isNotEmpty) {
        for (final docEntry in docs.entries) {
          final docRef = subRef.doc(docEntry.key);
          final snap = await docRef.get();
          if (!snap.exists) {
            await docRef.set(docEntry.value);
          }
        }
      } else {
        // If docs are random IDs (like transactions/activities), do nothing.
        // Collection will be created automatically when adding first doc.
      }
    }
  }

  //verify otpCode
  Future verifyOTPCode(
      ConfirmationResult confirmationResult, String otpCode) async {
    try {
      await confirmationResult.confirm(otpCode);
    } on FirebaseAuthException catch (e) {
      String error = e.message.toString();
      return error;
    }
  }

//sign out
  Future signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      return null;
    }
  }

  //attempt password change
  Future<String?> attemptPasswordChange({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "User not logged in";

    // Check if the user has email/password as one of their providers
    bool isEmailLinked =
        user.providerData.any((provider) => provider.providerId == 'password');

    if (!isEmailLinked) {
      return "No email linked. Add and verify your email to change password.";
    }

    try {
      // Re-authenticate before updating password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return ""; // ✅ Success
    } on FirebaseAuthException catch (e) {
      return e.message; // ⚠️ Return the error for the UI to show
    } catch (e) {
      return "Something went wrong. Try again later.";
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';

Stream<List<dynamic>> multiDataStream() {
  final walletStream = FirebaseFirestore.instance
      .collection('wallets')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots(); // ONE doc only

  final userStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  final leaderboardStream = FirebaseFirestore.instance
      .collection('leaderboard')
      .orderBy('clickPoints', descending: true)
      .limit(10)
      .snapshots();

  return Rx.combineLatest3<DocumentSnapshot, DocumentSnapshot, QuerySnapshot,
      List<dynamic>>(
    walletStream,
    userStream,
    leaderboardStream,
    (wallet, user, leaderboard) => [wallet, user, leaderboard],
  );
}

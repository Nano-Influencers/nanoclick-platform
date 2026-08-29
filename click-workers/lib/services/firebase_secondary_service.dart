import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSecondaryService {
  static final FirebaseSecondaryService _instance = FirebaseSecondaryService._internal();
  factory FirebaseSecondaryService() => _instance;
  FirebaseSecondaryService._internal();

  FirebaseApp? _secondaryApp;
  FirebaseFirestore? _firestore;

  Future<void> init() async {
    if (_secondaryApp == null) {
      _secondaryApp = await Firebase.initializeApp(
        name: 'NanoInfluencers',
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCgGNNEtmU5ZDZFsNbGMpRO5TSY_fL8wmU',
          appId: '1:881328477265:web:ddd3979fd0d79742101470',
          messagingSenderId: '881328477265',
          projectId: 'nano-influencers',
          authDomain: 'nano-influencers.firebaseapp.com',
          storageBucket: 'nano-influencers.appspot.com',
        ),
      );

      _firestore = FirebaseFirestore.instanceFor(app: _secondaryApp!);
    }
  }

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Secondary Firebase not initialized. Call init() first.');
    }
    return _firestore!;
  }
}

//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInWithFacebook {
  static Future signInWithFacebook() async {
    // Create a new provider
  FacebookAuthProvider facebookProvider = FacebookAuthProvider();
   // FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
  facebookProvider.addScope('email');
  facebookProvider.addScope('public_profile');
  facebookProvider.setCustomParameters({
    'display': 'popup',
  });
  
  // Once signed in, return the UserCredential
  final UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(facebookProvider);
      debugPrint(userCredential.user.toString());
        user = userCredential.user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        //handle the error here
        return e.code;
      }

      if (e.code == 'invalid-credential') {
        //hanle the error here
        return e.code;
      }
    } catch (e) {
      //handle the error here
      debugPrint(e.toString());
      return null;
    }

    return user;
  }
}

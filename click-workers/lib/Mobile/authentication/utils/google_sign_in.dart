//import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SignInWithGoogle{

static  Future<User?> signInWithGoogle() async {  
  // Create a new provider
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  User? user;

  googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
  googleProvider.setCustomParameters({
    'login_hint': 'user@example.com'
  });

  // Once signed in, return the UserCredential
  try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
          return null;
        } else if (e.code == 'invalid-credential') {
          // handle the error here
          return null;
        }
      } catch (e) {
        // handle the error here
        return null;
      }
  return user;

  // Or use signInWithRedirect
  // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
}

 static Future disconnect() {
    return GoogleSignIn().disconnect();
  }

}
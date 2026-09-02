import 'dart:html' as html;
import 'package:click_workers/services/api_client.dart';

/// Replaces FirebaseAuth's signInWithPopup(FacebookAuthProvider()) with a
/// full-page redirect to the backend's own Facebook OAuth flow — see
/// google_sign_in.dart for the equivalent Google flow and why a redirect
/// rather than a popup is used.
class SignInWithFacebook {
  static Future<void> signInWithFacebook() async {
    html.window.location.href = ApiClient.instance.oauthUrl('facebook');
  }
}

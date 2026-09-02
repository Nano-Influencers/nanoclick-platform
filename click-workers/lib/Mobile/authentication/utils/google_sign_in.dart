import 'dart:html' as html;
import 'package:click_workers/services/api_client.dart';

/// Replaces FirebaseAuth's signInWithPopup(GoogleAuthProvider()) with a
/// full-page redirect to the backend's own Google OAuth flow (which does
/// the actual token exchange server-side — see app/routers/auth.py). The
/// browser leaves this app entirely and comes back to the same URL with
/// access_token/refresh_token in the query string once Google approves the
/// login, at which point main.dart's startup check picks them up (the same
/// pattern the old Firebase password-reset oobCode flow used).
class SignInWithGoogle {
  static Future<void> signInWithGoogle() async {
    html.window.location.href = ApiClient.instance.oauthUrl('google');
  }

  // Kept as a no-op for call-site compatibility — Firebase's GoogleSignIn
  // package is no longer used at all (the app only ever called
  // signInWithPopup, not the native google_sign_in SDK), so there's
  // nothing to disconnect from client-side; signing out of the account
  // itself is handled by AuthProvider.signOut().
  static Future<void> disconnect() async {}
}

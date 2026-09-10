import 'dart:html' as html;

import 'package:click_workers/services/api_client.dart';

class SignInWithGoogle {
  static Future<void> signInWithGoogle() async {
    html.window.location.href = ApiClient.instance.oauthUrl('google', platform: 'web');
  }

  static Future<void> disconnect() async {}
}

import 'dart:html' as html;

import 'package:click_workers/services/api_client.dart';

class SignInWithFacebook {
  static Future<void> signInWithFacebook() async {
    html.window.location.href = ApiClient.instance.oauthUrl('facebook', platform: 'web');
  }
}

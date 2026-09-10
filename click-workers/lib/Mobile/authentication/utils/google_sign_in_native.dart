import 'package:url_launcher/url_launcher.dart';

import 'package:click_workers/services/api_client.dart';

class SignInWithGoogle {
  static Future<void> signInWithGoogle() async {
    final uri = Uri.parse(ApiClient.instance.oauthUrl('google', platform: 'app'));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Unable to open Google sign-in');
    }
  }

  static Future<void> disconnect() async {}
}

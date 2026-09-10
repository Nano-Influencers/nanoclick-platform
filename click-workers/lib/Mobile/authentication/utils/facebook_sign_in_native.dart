import 'package:url_launcher/url_launcher.dart';

import 'package:click_workers/services/api_client.dart';

class SignInWithFacebook {
  static Future<void> signInWithFacebook() async {
    final uri = Uri.parse(ApiClient.instance.oauthUrl('facebook', platform: 'app'));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Unable to open Facebook sign-in');
    }
  }
}

import 'dart:async';

import 'package:app_links/app_links.dart';

import 'api_client.dart';

Future<void> initializeNativeOAuthDeepLinks() async {
  final appLinks = AppLinks();

  Future<void> handle(Uri uri) async {
    if (uri.scheme != 'nanoclick' || uri.host != 'oauth') return;
    final code = uri.queryParameters['oauth_code'];
    if (code == null || code.isEmpty) return;
    try {
      await ApiClient.instance.exchangeOAuthCode(code);
    } catch (_) {
      // Invalid/expired codes leave the app unauthenticated.
    }
  }

  final initial = await appLinks.getInitialLink();
  if (initial != null) {
    await handle(initial);
  }

  appLinks.uriLinkStream.listen(handle, onError: (_) {});
}

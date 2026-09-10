import 'package:app_links/app_links.dart';

import 'api_client.dart';

Future<void> initializeNativeOAuthDeepLinks({
  Future<void> Function()? onAuthenticated,
}) async {
  final appLinks = AppLinks();

  Future<void> handle(Uri uri) async {
    if (uri.scheme != 'nanoclick' || uri.host != 'oauth') return;
    try {
      final code = uri.queryParameters['oauth_code'];
      if (code == null || code.isEmpty) return;
      await ApiClient.instance.exchangeOAuthCode(code);
      await onAuthenticated?.call();
    } catch (_) {
      // Invalid/expired callbacks leave the app unauthenticated.
    }
  }

  final initial = await appLinks.getInitialLink();
  if (initial != null) {
    await handle(initial);
  }

  appLinks.uriLinkStream.listen(handle, onError: (_) {});
}

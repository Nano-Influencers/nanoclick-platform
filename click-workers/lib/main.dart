import 'dart:async';

import 'package:click_workers/Desktop/home/desktop_home.dart';
import 'package:click_workers/Mobile/authentication/forgotPassword/new_password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/mobile_home.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';
import 'package:click_workers/services/app_user.dart';
import 'package:click_workers/services/api_client.dart';
import 'package:click_workers/services/oauth_deep_link_stub.dart'
    if (dart.library.io) 'package:click_workers/services/oauth_deep_link_io.dart';
import 'package:click_workers/services/token_storage_stub.dart'
    if (dart.library.html) 'package:click_workers/services/token_storage_web.dart'
    if (dart.library.io) 'package:click_workers/services/token_storage_io.dart' as storage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final uri = Uri.base;
  final authProvider = AuthProvider();

  // Never block Flutter's first frame on API/session restoration. A failed
  // refresh or unavailable backend must not leave the web app as a blank page.
  runApp(MyApp(initialUri: uri, authProvider: authProvider));

  unawaited(_bootstrap(authProvider, uri));
}

Future<void> _bootstrap(AuthProvider authProvider, Uri uri) async {
  try {
    await ApiClient.instance.initialize();

    final oauthCode = uri.queryParameters['oauth_code'];
    if (oauthCode != null && oauthCode.isNotEmpty) {
      try {
        await ApiClient.instance.exchangeOAuthCode(oauthCode, platform: 'web');
        await authProvider.refreshSessionSilently();
      } catch (_) {
        // Invalid/expired codes fall through to the normal sign-in screen.
      } finally {
        // OAuth codes are short-lived bearer credentials. Remove them from
        // the browser URL even when exchange fails.
        storage.replaceBrowserUrl('/');
      }
    } else {
      // AuthProvider performs an initial restore itself. This second refresh
      // makes the post-initialize state deterministic when a web session was
      // restored by ApiClient during bootstrap.
      await authProvider.refreshSessionSilently();
    }
  } catch (_) {
    // Startup must remain usable when the API is unavailable or CORS/session
    // restoration fails. The landing page is still rendered by MyApp.
  }

  await initializeNativeOAuthDeepLinks(
    onAuthenticated: authProvider.refreshSessionSilently,
  );
}

class MyApp extends StatelessWidget {
  final Uri initialUri;
  final AuthProvider authProvider;

  const MyApp({super.key, required this.initialUri, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    final oobCode = initialUri.queryParameters['oobCode'];
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [],
        title: 'Click Workers',
        theme: ThemeData(
          fontFamily: 'Roboto',
          primarySwatch: Colors.deepOrange,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xffff6533),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              disabledForegroundColor: const Color(0xffff6533),
              disabledBackgroundColor: Colors.white,
              foregroundColor: const Color(0xffff6533),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xffff6533)),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xffff6533),
            ),
          ),
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 14)),
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.black),
          ),
        ),
        home: oobCode != null
            ? NewPassword(oobCode: oobCode)
            : StreamProvider<AppUser?>.value(
                value: authProvider.user_,
                initialData: authProvider.currentUser,
                child: Device.width > 1024 ? const DesktopHome() : const MobileHome(),
              ),
      );
    });
  }
}
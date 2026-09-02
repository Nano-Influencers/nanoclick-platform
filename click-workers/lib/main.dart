import 'package:click_workers/Desktop/home/desktop_home.dart';
import 'package:click_workers/Mobile/authentication/forgotPassword/new_password.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/mobile_home.dart';
import 'package:click_workers/Mobile/authentication/utils/auth.dart';
import 'package:click_workers/services/app_user.dart';
import 'package:click_workers/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final uri = Uri.base;

  // See assets/env_temp.txt — kept only until withdraw_funds.dart's direct
  // dotenv.env[...] reads are rewired to the backend, at which point this
  // load() call (and flutter_dotenv entirely) can go away.
  await dotenv.load(fileName: "assets/env_temp.txt");

  // Firebase.initializeApp() removed — this app no longer uses any
  // Firebase product. Auth state now comes from AuthProvider (backed by
  // the NanoClick backend), constructed once below and shared via
  // Provider so every screen sees the same instance.
  runApp(MyApp(
    initialUri: uri,
    authProvider: AuthProvider(),
  ));
}

class MyApp extends StatelessWidget {
  final Uri initialUri;
  final AuthProvider authProvider;
  const MyApp({super.key, required this.initialUri, required this.authProvider});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Two distinct "the browser just came back from somewhere else" cases
    // land here as query params on this app's own root URL, since this app
    // has no client-side router — see AuthProvider/api_client.dart for how
    // each is produced:
    //   1. oobCode: the password-reset flow (this app's own naming,
    //      inherited from Firebase's terminology, now carrying the
    //      backend's plain reset token instead of a Firebase oobCode).
    //   2. access_token/refresh_token: a completed Google/Facebook OAuth
    //      login (?platform=web redirect — see ApiClient.oauthUrl).
    final oobCode = initialUri.queryParameters['oobCode'];
    final oauthAccessToken = initialUri.queryParameters['access_token'];
    final oauthRefreshToken = initialUri.queryParameters['refresh_token'];

    if (oauthAccessToken != null && oauthRefreshToken != null) {
      ApiClient.instance.setTokens(access: oauthAccessToken, refresh: oauthRefreshToken);
      // Re-check the auth session now that tokens are stored, so the
      // StreamProvider below picks up the logged-in user without needing
      // a manual refresh. Errors are swallowed here deliberately: if this
      // somehow fails, the user just lands on the sign-in screen instead
      // of a crash, and can try again normally.
      authProvider.refreshSessionSilently();
    }

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
                  backgroundColor: const Color(0xffff6533)),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
              disabledForegroundColor: const Color(0xffff6533),
              disabledBackgroundColor: Colors.white,
              foregroundColor: const Color(0xffff6533),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xffff6533)),
            )),
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
                  child: Device.width > 1024
                      ? const DesktopHome()
                      : const MobileHome(),
                ));
    });
  }
}

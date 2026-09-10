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
import 'package:click_workers/services/oauth_deep_link_stub.dart'
    if (dart.library.io) 'package:click_workers/services/oauth_deep_link_io.dart';
import 'package:click_workers/services/token_storage_stub.dart'
    if (dart.library.html) 'package:click_workers/services/token_storage_web.dart'
    if (dart.library.io) 'package:click_workers/services/token_storage_io.dart' as storage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final uri = Uri.base;
  await dotenv.load(fileName: 'assets/env_temp.txt');
  await ApiClient.instance.initialize();

  final authProvider = AuthProvider();
  final oauthCode = uri.queryParameters['oauth_code'];
  if (oauthCode != null && oauthCode.isNotEmpty) {
    try {
      await ApiClient.instance.exchangeOAuthCode(oauthCode);
      storage.replaceBrowserUrl('/');
      await authProvider.refreshSessionSilently();
    } catch (_) {
      // Invalid/expired codes fall through to the normal sign-in screen.
    }
  }

  await initializeNativeOAuthDeepLinks(
    onAuthenticated: authProvider.refreshSessionSilently,
  );

  runApp(MyApp(initialUri: uri, authProvider: authProvider));
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

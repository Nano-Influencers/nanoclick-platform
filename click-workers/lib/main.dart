import 'package:click_workers/Desktop/home/desktop_home.dart';
import 'package:click_workers/Mobile/authentication/forgotPassword/new_password.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:click_workers/Mobile/mobile_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final uri = Uri.base;
  await dotenv.load(fileName: "assets/env_temp.txt");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(
    initialUri: uri,
  ));
}

class MyApp extends StatelessWidget {
  final Uri initialUri;
  const MyApp({super.key, required this.initialUri});

  // This widget is the root of your application.
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
    : 
    StreamProvider<User?>.value(
        value: FirebaseAuth.instance.authStateChanges(),
        initialData: null,
        child: Device.width > 1024
            ? const DesktopHome()
            : const MobileHome(),
      ),);
    });
  }
}

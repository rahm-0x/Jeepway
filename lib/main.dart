import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // 👈 Added

// Screens
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/role_selection_page.dart';
import 'screens/driver_verification_page.dart';
import 'screens/driver_registration_page.dart';
import 'screens/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 👈 Updated to use firebase_options.dart
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    host: 'firestore.googleapis.com',
    sslEnabled: true,
    webExperimentalForceLongPolling: true, // 👈 Prevents 400 error on web
  );

  runApp(const JeepwayApp());
}

class JeepwayApp extends StatelessWidget {
  const JeepwayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeepway',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const JeepwayHomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/role': (context) => const RoleSelectionPage(),
        '/driver-verification': (context) => const DriverVerificationPage(),
        '/driver-registration': (context) => const DriverRegistrationPage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('404: Page not found')),
        ),
      ),
    );
  }
}

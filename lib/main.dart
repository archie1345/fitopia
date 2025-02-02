import 'package:firebase_core/firebase_core.dart';
import 'package:fitopia/page/getStarted.dart';
import 'package:fitopia/page/recipe.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fitopia/page/home.dart';
import 'package:fitopia/page/login.dart';
import 'package:fitopia/splashScreen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the Stripe publishable key
  Stripe.publishableKey =
      "pk_test_51Qcc97R3km1Wsl68keogSvTUekALbQcaXXjY8QVC75dhNHJCuvMSqWQLoNZGBi8jlDELII3oxc1sPu6nqsvUhhGT008qoGjA7b";

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCYEmD_YN8CmsWH8wNmfu8tHu9InagrMS4",
        appId: "1:218297721418:web:c8ce12a52deab12f6b7cb3",
        messagingSenderId: "218297721418",
        projectId: "fitopia-42331",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Start the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: gfonts.GoogleFonts.leagueSpartanTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Fitopia',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/getStarted': (context) => GetStarted(),
        '/home': (context) => const HomePage(),
        '/recipe': (context) => const RecipeListPage(),
      },
    );
  }
}

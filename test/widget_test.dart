import 'package:fitopia/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fitopia/page/home.dart';
import 'package:flutter/material.dart';
import 'package:fitopia/widget/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import '../firebase_auth_implementation/firebase_auth_services.dart';

class TestSignInPage extends StatefulWidget {
  const TestSignInPage({super.key});

  @override
  State<TestSignInPage> createState() => _TestSignInPageState();
}

class _TestSignInPageState extends State<TestSignInPage> {
  // Instance of the FirebaseAuthService to handle sign-in logic.
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'TEST SIGN-IN',
              style: gfonts.GoogleFonts.getFont(
                'Montserrat',
                color: const Color(0xFF656839),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 7,
              ),
            ),
            const SizedBox(height: 50),
            // The button that triggers the Google Sign-in flow.
            GestureDetector(
              onTap: () async {
                showToast(message: "Attempting Google Sign-in...");
                await _auth.signInWithGoogle(context);
              },
              child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(81, 75, 35, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

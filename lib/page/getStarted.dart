import 'package:fitopia/page/genderSelection.dart';
import 'package:fitopia/page/login.dart';
import 'package:fitopia/classes/userRegistrationData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'
    as gfonts; // Use a prefix for google_fonts

class GetStarted extends StatelessWidget {
  final UserRegistrationData userData = UserRegistrationData();

  GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Set background color
        body: SingleChildScrollView(
          // Allow scrolling if content is too long
          child: Padding(
            padding: const EdgeInsets.only(bottom: 62),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *
                      0.5, // Set height to 50% of screen height
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage("https://via.placeholder.com/393x463"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Consistency Is \nthe Key To Progress.\nDon't Give Up!",
                    textAlign: TextAlign.center,
                    style: gfonts.GoogleFonts.getFont(
                      'Poppins',
                      color: Color(0xFF514B23),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      height: 1.20,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 90,
                  decoration: const BoxDecoration(color: Color(0xFFCBC9AD)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: 325,
                    child: Text(
                      'Get ready to transform your fitness journey with us. Whether youre a beginner or a pro, were here to guide, motivate, and celebrate every milestone with you.',
                      textAlign: TextAlign.center,
                      style: gfonts.GoogleFonts.getFont(
                        'League Spartan',
                        color: Color(0xFF514B23),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GenderSelectionScreen(userData: userData),
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 4),
                          blurRadius: 2,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Next',
                        textAlign: TextAlign.center,
                        style: gfonts.GoogleFonts.getFont(
                          'Poppins',
                          color: Color(0xFF514B23),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Have an account? ',
                        style: gfonts.GoogleFonts.getFont(
                          'Montserrat',
                          color: Color(0xFF514B23),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.07,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Login",
                          style: gfonts.GoogleFonts.getFont(
                            'Montserrat',
                            color: Color(0xFF514B23),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.07,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

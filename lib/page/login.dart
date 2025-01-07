import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/page/forgotPass.dart';
import 'package:fitopia/page/home.dart';
import 'package:flutter/material.dart';
import 'package:fitopia/page/getStarted.dart';
import 'package:fitopia/widget/form_container_widget.dart';
import 'package:fitopia/widget/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import '../../firebase_auth_implementation/firebase_auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Prevent keyboard-related overflow
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, top: 30),
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'LOGIN',
                        textAlign: TextAlign.center,
                        style: gfonts.GoogleFonts.getFont(
                          'Montserrat',
                          color: const Color(0xFF656839),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 0.88,
                          letterSpacing: 7,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, top: 30),
                    child: Text(
                      'WELCOME',
                      textAlign: TextAlign.center,
                      style: gfonts.GoogleFonts.getFont(
                        'Montserrat',
                        color: const Color(0xFF656839),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 0.88,
                        letterSpacing: 7,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      textAlign: TextAlign.center,
                      style: gfonts.GoogleFonts.getFont(
                        'League Spartan',
                        color: const Color(0xFF656839),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1,
                        letterSpacing: 7,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40,
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF514B23),
                          fontSize: 15,
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.w500,
                          height: 0.83,
                        ),
                      ),
                    ),
                  ),
                  FormContainerWidget(
                    controller: _usernameController,
                    hintText: "Email",
                    isPasswordField: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40,
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        'Password',
                        style: TextStyle(
                          color: Color(0xFF514B23),
                          fontSize: 15,
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.w500,
                          height: 0.83,
                        ),
                      ),
                    ),
                  ),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: "Password",
                    isPasswordField: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()),
                          );
                        },
                        child: const Text(
                          'FORGOT PASSWORD?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF514B23),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            height: 1.07,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _signIn,
                    child: Center(
                      child: _isSigning
                          ? const CircularProgressIndicator(
                              strokeCap: StrokeCap.round,
                              color: Color.fromRGBO(81, 75, 35, 1),
                            )
                          : Container(
                              alignment: Alignment.center,
                              width: 125,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(217, 217, 217, 1),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Color.fromRGBO(81, 75, 35, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Doesn’t have an account? ',
                        style: TextStyle(
                          color: Color(0xFF514B23),
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          height: 1.07,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  GetStarted()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF514B23),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            height: 1.07,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'or sign up with',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF514B23),
                      fontSize: 14,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      FirebaseAuthService().signInWithGoogle(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(81, 75, 35, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(username, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      showToast(message: "User is successfully signed in");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      showToast(message: "Some error occurred");
    }
  }
}

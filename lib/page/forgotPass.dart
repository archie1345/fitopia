import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Firebase Auth instance
    final FirebaseAuth auth = FirebaseAuth.instance;

    void handleSubmit() async {
      if (formKey.currentState!.validate()) {
        try {
          await auth.sendPasswordResetEmail(email: emailController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Password reset email sent to ${emailController.text}')),
          );
        } catch (e) {
          String message = 'An error occurred';
          if (e is FirebaseAuthException) {
            if (e.code == 'user-not-found') {
              message = 'No user found for this email.';
            } else if (e.code == 'invalid-email') {
              message = 'Invalid email address.';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'FORGOT PASSWORD',
                  style: TextStyle(
                    color: Color(0xFF514B23),
                    fontSize: 17,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 7,
                  ),
                ),
                SizedBox(height: 60),
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF514B23),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Please enter your email address below to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter your email address',
                    style: TextStyle(
                      color: Color(0xFF232222),
                      fontSize: 18,
                      fontFamily: 'League Spartan',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFECE6F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Color(0xFF514B23),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
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

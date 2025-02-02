import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/classes/userRegistrationData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class FillProfile extends StatefulWidget {
  final UserRegistrationData userData;

  const FillProfile({super.key, required this.userData});

  @override
  State<FillProfile> createState() => _FillProfileState();
}

class _FillProfileState extends State<FillProfile> {
  // Controllers for form fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isSigningUp = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
            context, "/getStarted", (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          leading: IconButton(
            iconSize: 18,
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/getStarted", (route) => false);
            },
          ),
          title: Text(
            'Back',
            style: gfonts.GoogleFonts.getFont(
              'League Spartan',
              color: const Color(0xFF656839),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 54),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Fill Your Profile',
                    style: gfonts.GoogleFonts.getFont(
                      'League Spartan',
                      color: const Color(0xFF656839),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tell us a bit more about yourself to unlock a fully personalized fitness experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF514B23),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField('Username', usernameController,
                      hintText: 'Enter username'),
                  _buildInputField('Email', emailController,
                      isEmail: true, hintText: 'Enter email'),
                  _buildInputField('Password', passwordController,
                      isPassword: true, hintText: 'Enter password'),
                  _buildInputField(
                      'Confirm Password', confirmPasswordController,
                      isPassword: true, hintText: 'Confirm password'),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      _register();
                    },
                    child: Container(
                      width: 150,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(203, 201, 173, 1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: isSigningUp
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/login");
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0xFF514B23),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Registration Logic
  void _register() async {
    setState(() {
      isSigningUp = true;
    });

    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    // Validate fields
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Please fill all fields.');
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Validate email
    if (!_validateField(email, 'email')) {
      _showErrorSnackbar('Enter a valid email address.');
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Validate password
    if (!_validateField(password, 'password')) {
      _showErrorSnackbar(
          'Password must be at least 8 characters long and include an uppercase letter, a number, and a special character.');
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      _showErrorSnackbar('Passwords do not match!');
      setState(() {
        isSigningUp = false;
      });
      return;
    }

    try {
      // Register the user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Store additional details in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'height': widget.userData.height,
          'weight': widget.userData.weight,
          'gender': widget.userData.gender,
          'age': widget.userData.age,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')));
        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      _showErrorSnackbar('Registration failed: $e');
    } finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }

  /// Helper for validation
  bool _validateField(String value, String type) {
    if (type == 'email') {
      final emailRegEx = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
      return RegExp(emailRegEx).hasMatch(value);
    } else if (type == 'password') {
      final passwordRegEx =
          r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&_])[A-Za-z\d@$!%*?&_]{8,}$';
      return RegExp(passwordRegEx).hasMatch(value);
    }
    return value.isNotEmpty;
  }

  /// Helper to show error messages
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Input Field Builder
  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false, bool isEmail = false, String hintText = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFF514B23),
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType:
                !isEmail ? TextInputType.text : TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: hintText,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

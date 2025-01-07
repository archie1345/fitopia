import 'package:fitopia/page/height.dart';
import 'package:fitopia/page/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fitopia/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FillProfile extends StatefulWidget {
  const FillProfile({super.key});

  @override
  State<FillProfile> createState() => _FillProfileState();
}

class _FillProfileState extends State<FillProfile> {
  // Controllers for form fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final picker = ImagePicker();

  final FirebaseAuthService _auth = FirebaseAuthService();

  bool isSigningUp = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HeightSelector()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          leading: IconButton(
            iconSize: 18,
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HeightSelector()),
                (route) => false,
              );
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
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                    'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
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
                        color: Color.fromRGBO(203, 201, 173, 1),
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (route) => false,
                          );
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

void _register() async {
  setState(() {
    isSigningUp = true;
  });

  String username = usernameController.text.trim();
  String email = emailController.text.trim();
  String mobileNumber = mobileController.text.trim();
  String password = passwordController.text;
  String confirmPassword = confirmPasswordController.text;

  // Validate fields
  if (username.isEmpty || email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields.')),
    );
    print("Validation failed: One or more fields are empty.");
    setState(() {
      isSigningUp = false;
    });
    return;
  }

  // Validate email format
  if (!validateField(email, 'email')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter a valid email address.')),
    );
    print("Validation failed: Invalid email format.");
    setState(() {
      isSigningUp = false;
    });
    return;
  }

  // Validate password constraints
  if (!validateField(password, 'password')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password must be at least 8 characters long and include an uppercase letter, a number, and a special character.',
        ),
      ),
    );
    print("Validation failed: Password does not meet requirements.");
    setState(() {
      isSigningUp = false;
    });
    return;
  }

  // Check if passwords match
  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passwords do not match!')),
    );
    print("Validation failed: Passwords do not match.");
    setState(() {
      isSigningUp = false;
    });
    return;
  }

  try {
    // Attempt Firebase registration
    User? user = await _auth.signUpWithEmailAndPassword(email, password, username);

    if (user != null) {
      print("User registered successfully: ${user.uid}");
      try {
        // Add user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'mobileNumber': mobileNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });

        showToast(message: "User is successfully created");
        Navigator.pushNamed(context, "/home");
      } catch (e) {
        print("Error storing user data in Firestore: $e");
        showToast(message: "Error storing user data: $e");
      }
    } else {
      print("Registration failed: User is null.");
      showToast(message: "Some error happened during registration.");
    }
  } catch (e) {
    print("Error during Firebase registration: $e");
    showToast(message: "Registration failed: $e");
  }

  setState(() {
    isSigningUp = false;
  });
}


  // Helper function to validate fields
  bool validateField(String value, String type) {
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

  // Helper to create input fields
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType:
                !isEmail ? TextInputType.text : TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

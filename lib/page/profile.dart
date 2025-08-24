import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:fitopia/widget/toast.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _age = 0;
  String _email = 'N/A';
  double _bmi = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _calculateBMI() {
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double height = double.tryParse(_heightController.text) ?? 0.0;
    if (weight > 0 && height > 0) {
      height = height / 100; // Convert height to meters
      setState(() {
        _bmi = weight / (height * height);
      });
    } else {
      setState(() {
        _bmi = 0.0;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          // Prioritize Firestore email, fallback to Firebase Auth email
          _email = userDoc['email'] ?? user.email ?? 'N/A';
          _nameController.text = userDoc['username'] ?? user.displayName ?? '';
          _weightController.text = userDoc['weight']?.toString() ?? '0';
          _heightController.text = userDoc['height']?.toString() ?? '0';
          _birthdateController.text = userDoc['birthdate'] ?? '';
          _age = _birthdateController.text.isNotEmpty
              ? _calculateAge(_birthdateController.text)
              : 0;
          _calculateBMI(); // Calculate BMI after loading
        });

        // Update Firestore if email is missing
        if (_email == 'N/A' || !userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email ?? 'N/A',
          }, SetOptions(merge: true));
        }
      } catch (e) {
        showToast(message: "Error loading profile: $e");
      }
    } else {
      showToast(message: "No user is logged in.");
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      showToast(message: "Name cannot be empty.");
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': _nameController.text,
          'weight': int.tryParse(_weightController.text),
          'height': int.tryParse(_heightController.text),
          'birthdate': _birthdateController.text.isNotEmpty
              ? _birthdateController.text
              : null,
          'email': _email, // Ensure email is saved to Firestore
        }, SetOptions(merge: true));

        setState(() {
          _age = _birthdateController.text.isNotEmpty
              ? _calculateAge(_birthdateController.text)
              : 0;
          _calculateBMI(); // Recalculate BMI after update
        });
        showToast(message: "Profile updated successfully");
      }
    } catch (e) {
      showToast(message: "Error updating profile: $e");
    }
  }

  int _calculateAge(String birthdate) {
    if (birthdate.isEmpty) return 0;
    try {
      DateTime birthDate = DateTime.parse(birthdate);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildMetricTile(String value, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.isEmpty ? 'N/A' : value,
            style: gfonts.GoogleFonts.poppins(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: gfonts.GoogleFonts.poppins(
              color: const Color.fromARGB(137, 255, 255, 255),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isNumber = false, bool isDate = false, String hintText = ''}) {
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
          TextFormField(
            controller: controller,
            keyboardType: isNumber
                ? TextInputType.number
                : isDate
                    ? TextInputType.datetime
                    : TextInputType.text,
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

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          iconSize: 18,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 125,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(81, 75, 35, 1),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _nameController.text.isEmpty
                          ? 'N/A'
                          : _nameController.text,
                      style: gfonts.GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'BMI: ${_bmi.toStringAsFixed(1)}',
                      style: gfonts.GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Email: $_email',
                      textAlign: TextAlign.center,
                      style: gfonts.GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Birthday: ${_birthdateController.text.isEmpty ? 'N/A' : _birthdateController.text}',
                      textAlign: TextAlign.center,
                      style: gfonts.GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(203, 201, 173, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricTile('${_weightController.text} KG',
                              'Weight'),
                          _buildMetricTile('$_age', 'Years Old'),
                          _buildMetricTile('${_heightController.text} CM',
                              'Height'),
                        ],
                      ),
                    ),
                  ),
                  _buildInputField('Username', _nameController,
                      hintText: 'Enter Username'),
                  _buildInputField('Weight', _weightController,
                      hintText: 'Enter weight (kg)', isNumber: true),
                  _buildInputField('Height', _heightController,
                      hintText: 'Enter height (cm)', isNumber: true),
                  _buildInputField('Birthdate', _birthdateController,
                      hintText: 'Enter birthdate (YYYY-MM-DD)', isDate: true),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _updateProfile,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(81, 75, 35, 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Update Profile",
                          style: gfonts.GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

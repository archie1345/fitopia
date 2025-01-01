import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitopia/toast.dart';

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

  File? _image;
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _age = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['username'];
          _weightController.text = userDoc['weight'].toString();
          _heightController.text = userDoc['height'].toString();
          _birthdateController.text = userDoc['birthdate'];
          _age = _calculateAge(userDoc['birthdate']);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _birthdateController.text.isEmpty) {
      showToast(message: "Please fill all the fields.");
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'username': _nameController.text,
          'weight': int.parse(_weightController.text),
          'height': int.parse(_heightController.text),
          'birthdate': _birthdateController.text,
        });

        setState(() {
          _age = _calculateAge(_birthdateController.text);
        });

        showToast(message: "Profile updated successfully");
      }
    } catch (e) {
      showToast(message: "Error updating profile: $e");
    }
  }

  int _calculateAge(String birthdate) {
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
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(81, 75, 35,1),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _image == null
                            ? const NetworkImage('https://via.placeholder.com/125')
                            : FileImage(_image!) as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Madison Smith'
                          : _nameController.text,
                      style: gfonts.GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'madison@example.com\nBirthday: ${_birthdateController.text}',
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(203, 201, 173, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricTile('${_weightController.text} KG', 'Weight'),
                          _buildMetricTile('$_age', 'Years Old'),
                          _buildMetricTile('${_heightController.text} CM', 'Height'),
                        ],
                      ),
                    ),
                  ),
                  _buildInputField('Full name', _nameController,
                      hintText: 'Enter full name'),
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
                        color: const Color(0xFF8E8CF3),
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

  Widget _buildMetricTile(String value, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
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
}

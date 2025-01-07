import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/page/height.dart';
import 'package:fitopia/classes/userRegistrationData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class Weight extends StatefulWidget {
  final UserRegistrationData userData;

  const Weight({super.key, required this.userData});

  @override
  State<Weight> createState() => _WeightState();
}

class _WeightState extends State<Weight> {
  final FixedExtentScrollController _controller = FixedExtentScrollController(initialItem: 74);

  int selectedWeight = 74;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveWeightToFirestore(int weight) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'weight': weight,
        });
        print("Weight updated successfully: $weight kg");
      } else {
        print("No user logged in.");
      }
    } catch (e) {
      print("Error updating weight: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
        body: Padding(
          padding: const EdgeInsets.only(bottom: 54),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'What Is Your Weight?',
                  style: gfonts.GoogleFonts.getFont(
                    'League Spartan',
                    color: const Color(0xFF656839),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 323,
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    textAlign: TextAlign.center,
                    style: gfonts.GoogleFonts.getFont(
                      'League Spartan',
                      color: const Color(0xFF656839),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Container(
                width: 250,
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '${selectedWeight + 1} KG',
                  style: TextStyle(
                    color: Color(0xFF514B23),
                    fontSize: 70,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  width: 46,
                  height: 32,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFCBC9AD),
                    shape: StarBorder.polygon(
                      sides: 3,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100, // Adjust height as needed
                child: RotatedBox(
                  quarterTurns: 1,
                  child: ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: 60, // Each item width
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedWeight = index;
                        widget.userData.weight = selectedWeight + 1;
                      });
                    },
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        return RotatedBox(
                          quarterTurns: -1,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(
                                  milliseconds: 150), // Smooth animation
                              curve: Curves.easeInOut, // Animation curve
                              style: TextStyle(
                                color: const Color(0xFF514B23),
                                fontSize: index == selectedWeight
                                    ? 50
                                    : 25, // Bold size for selected
                                fontFamily: 'Poppins',
                                fontWeight: index == selectedWeight
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              child: Text('${index + 1}'),
                            ),
                          ),
                        );
                      },
                      childCount: 100, // Weight range 1-100
                    ),
                  ),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _saveWeightToFirestore(selectedWeight + 1);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HeightSelector(userData: widget.userData),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Continue',
                  style: gfonts.GoogleFonts.getFont(
                    'Poppins',
                    color: const Color(0xFF656839),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

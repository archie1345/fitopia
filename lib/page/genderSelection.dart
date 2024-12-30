import 'package:fitopia/page/age.dart';
import 'package:fitopia/page/getStarted.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts; // Use a prefix for google_fonts

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  _GenderSelectionScreenState createState() =>
      _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => GetStarted()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            iconSize: 18,
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => GetStarted()), (route) => false);
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 54),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'What\'s Your Gender',
                    style: gfonts.GoogleFonts.getFont(
                      'League Spartan',
                      color: const Color(0xFF656839),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  textAlign: TextAlign.center,
                  style: gfonts.GoogleFonts.getFont(
                    'League Spartan',
                    color: const Color(0xFF656839),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMaleSelected = !_isMaleSelected;
                      _isFemaleSelected = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isMaleSelected ? const Color.fromRGBO(203, 201, 173, 1) : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.male,
                      size: 100,
                      color: Color.fromRGBO(101, 104, 57, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Male',
                  style: gfonts.GoogleFonts.getFont(
                    'League Spartan',
                    color: const Color(0xFF656839),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFemaleSelected = !_isFemaleSelected;
                      _isMaleSelected = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isFemaleSelected ? const Color.fromRGBO(203, 201, 173, 1) : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.female,
                      size: 100,
                      color: Color.fromRGBO(101, 104, 57, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Female',
                  style: gfonts.GoogleFonts.getFont(
                    'League Spartan',
                    color: const Color(0xFF656839),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Handle Continue action
                    print('Continue pressed');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Age()),
                      (route) => false,
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
      ),
    );
  }
}
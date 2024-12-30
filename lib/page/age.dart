import 'package:fitopia/page/genderSelection.dart';
import 'package:fitopia/page/weight.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts; // Use a prefix for google_fonts

class Age extends StatefulWidget {
  const Age({super.key});

  @override
  State<Age> createState() => _AgeState();
}

class _AgeState extends State<Age> {
  final FixedExtentScrollController _controller = FixedExtentScrollController(initialItem: 28);

  int selectedAge = 28;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => GenderSelectionScreen()),
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
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => GenderSelectionScreen()), (route) => false);
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
                            'How Old Are You?',
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
                        SizedBox(
                          height: 300, // Fixed height for the view
                          child: ListWheelScrollView.useDelegate(
                            controller: _controller,
                            itemExtent: 64, // Each item height
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedAge = index;
                              });
                            },
                            physics: const FixedExtentScrollPhysics(),
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                // Wrap with Center to ensure alignment
                                return Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 150), // Smooth animation
                                    curve: Curves.easeInOut, // Animation curve
                                    style: TextStyle(
                                      color: const Color(0xFF514B23),
                                      fontSize: index == selectedAge ? 60 : 30, // Bold size for selected
                                      fontFamily: 'Poppins',
                                      fontWeight: index == selectedAge
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    child: Text('${index + 1}'),
                                  ),
                                );
                              },
                              childCount: 100, // Age range 0-99
                            ),
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                    onPressed: () {
                      // Handle Continue action
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Weight()),
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

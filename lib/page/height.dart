import 'package:fitopia/page/register.dart';
import 'package:fitopia/page/weight.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class HeightSelector extends StatefulWidget {
  const HeightSelector({super.key});

  @override
  State<HeightSelector> createState() => _HeightSelectorState();
}

class _HeightSelectorState extends State<HeightSelector> {
  int selectedHeight = 165;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: selectedHeight - 100);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          appBar: AppBar(
          surfaceTintColor: Colors.white,
          leading: IconButton(
            iconSize: 18,
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Weight()),
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
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 54),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'What Is Your Height?',
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '$selectedHeight CM',
                        style: gfonts.GoogleFonts.getFont(
                        'Poppins',
                        color: const Color(0xFF656839),
                        fontSize: 70,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            selectedHeight -= (details.delta.dy * 0.5).toInt();
                            selectedHeight = selectedHeight.clamp(100, 200);
                            _scrollController.jumpToItem(selectedHeight - 100);
                          });
                        },
                        child: Container(
                          height: 300,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(203, 201, 173,1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ListWheelScrollView.useDelegate(
                            controller: _scrollController,
                            itemExtent: 60,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedHeight = 100 + index;
                              });
                            },
                            physics: const FixedExtentScrollPhysics(),
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                int height = 100 + index;
                                return Center(
                                  child: Text(
                                    '$height',
                                    style: gfonts.GoogleFonts.getFont(
                                      'Poppins',
                                      fontSize: height == selectedHeight ? 50 : 25,
                                      fontWeight: height == selectedHeight
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: height == selectedHeight
                                          ? const Color.fromRGBO(81, 75, 35,1)
                                          : Colors.white,
                                    ),
                                  ),
                                );
                              },
                              childCount: 101,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Handle Continue action
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => FillProfile()),
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
          )),
    );
  }
}

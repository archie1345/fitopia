import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/page/home.dart';
import 'package:fitopia/page/settings.dart';
import 'package:fitopia/widget/exerciseDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:fitopia/widget/floatingNavBar.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:cloud_firestore/cloud_firestore.dart';

class LowerBody extends StatefulWidget {
  const LowerBody({super.key});

  @override
  State<LowerBody> createState() => _LowerBodyState();
}

class _LowerBodyState extends State<LowerBody> {
  String selectedDifficulty = 'BEGINNER';
  bool isPremium = false; // Store user's premium status

  final Map<String, List<Map<String, dynamic>>> workouts = {
    'BEGINNER': [
      {
        'name': 'Push-Ups',
        'image':
            'https://img.freepik.com/free-photo/man-doing-push-ups-listening-music_23-2148375908.jpg',
        'steps': [
          'Start in a plank position with hands shoulder-width apart.',
          'Lower your body until your chest is just above the ground.',
          'Push back to the starting position.',
          'Keep your body in a straight line throughout the movement.',
        ],
        'challenges': [
          'Do 3 sets of 10–12 reps.',
          'Rest for 1–2 minutes between sets.',
        ],
      },
      // Add more BEGINNER workouts here...
    ],
    'INTERMEDIATE': [
      // Add INTERMEDIATE workouts here...
    ],
    'ADVANCE': [
      // Add ADVANCE workouts here...
    ],
  };

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(userId)
            .get();
        if (doc.exists && doc.data()?['isPremium'] == true) {
          setState(() {
            isPremium = true;
          });
        }
      }
    } catch (e) {
      print('Error checking premium status: $e');
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
              Navigator.pushNamed(context, '/home');
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: FloatingNavigationBar(
            onHomePressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            ),
            onSettingsPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingPage()),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              // Difficulty Selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDifficultyButton('BEGINNER'),
                    if (isPremium) _buildDifficultyButton('INTERMEDIATE'),
                    if (isPremium) _buildDifficultyButton('ADVANCE'),
                  ],
                ),
              ),
              // Workout List
              Expanded(
                child: workouts[selectedDifficulty]?.isNotEmpty == true
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: workouts[selectedDifficulty]!.length,
                        itemBuilder: (context, index) {
                          var workout = workouts[selectedDifficulty]![index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseDetailPage(
                                  name: workout['name'],
                                  image: workout['image'],
                                  steps: workout['steps'] ?? [],
                                  challenges: workout['challenges'] ?? [],
                                ),
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      workout['image'],
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    workout['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No workouts available for $selectedDifficulty',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selectedDifficulty == difficulty
              ? const Color.fromRGBO(101, 104, 57, 1)
              : const Color.fromRGBO(217, 217, 217, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          difficulty,
          style: TextStyle(
            color: selectedDifficulty == difficulty
                ? const Color.fromRGBO(217, 217, 217, 1)
                : const Color.fromRGBO(101, 104, 57, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

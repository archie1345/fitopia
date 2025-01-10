import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/page/home.dart';
import 'package:fitopia/page/settings.dart';
import 'package:fitopia/widget/exerciseDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:fitopia/widget/floatingNavBar.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:cloud_firestore/cloud_firestore.dart';

class UpperBody extends StatefulWidget {
  const UpperBody({super.key});

  @override
  State<UpperBody> createState() => _UpperBodyState();
}

class _UpperBodyState extends State<UpperBody> {
  String selectedDifficulty = 'BEGINNER';
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  /// Check if the user has a premium subscription
  Future<void> _checkPremiumStatus() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();

      if (doc.exists && doc.data()?['isPremium'] == true) {
        setState(() {
          isPremium = true;
        });
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
              MaterialPageRoute(builder: (context) => HomePage()),
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
                child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('workouts')
                      .where('category', isEqualTo: 'UpperBody')
                      .where('difficulty', isEqualTo: selectedDifficulty)
                      .get(),
                  builder: (context, snapshot) {
                    // Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Error state
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'An error occurred: ${snapshot.error}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }

                    // Empty data state
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No workouts available for $selectedDifficulty',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    // Data available state
                    final workouts = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout =
                            workouts[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseDetailPage(
                                exerciseId: workouts[index].id,
                              ),
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    workout['image'] ?? '',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.image_not_supported,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout['name'] ?? 'Unnamed Workout',
                                        style: gfonts.GoogleFonts.leagueSpartan(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF656839),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workout['time'] ?? 'Unknown Time'} | ${workout['calories'] ?? 'Unknown Calories'}',
                                        style: gfonts.GoogleFonts.leagueSpartan(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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

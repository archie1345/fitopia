import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitopia/widget/workoutCard.dart';
import 'package:flutter/material.dart';
import 'package:fitopia/page/premium.dart';
import 'package:fitopia/page/profile.dart';
import 'package:fitopia/page/recipe.dart';
import 'package:fitopia/page/settings.dart';
import 'package:fitopia/page/workout/core.dart';
import 'package:fitopia/page/workout/lowerBody.dart';
import 'package:fitopia/page/workout/upperBody.dart';
import 'package:fitopia/widget/floatingNavBar.dart';
import 'package:fitopia/widget/weeklyChallenge.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical:32), // Space for the navigation bar
        child: SingleChildScrollView(
          child: Column(
            children: [
              // User Greeting Section
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.displayName ?? "User"}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(81, 75, 35, 1),
                          ),
                        ),
                        const Text(
                          "It's time to challenge your limits.",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle, size: 50, color: Colors.black87),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Navigation Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecipeListPage()),
                      );
                    },
                    child: Column(
                      children: const [Icon(Icons.restaurant), Text('Nutrition')],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PremiumPage()),
                      );
                    },
                    child: Column(
                      children: const [Icon(Icons.card_membership), Text('Premium')],
                    ),
                  ),
                ],
              ),
              // Workout Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Workout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      WorkoutCard(
                        title: 'Upper Body',
                        imageUrl: 'https://images.pexels.com/photos/29575475/pexels-photo-29575475/free-photo-of-muscular-man-exercising-with-gym-equipment.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                        duration: '1-2 mins',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UpperBody()),
                        ),
                      ),
                      WorkoutCard(
                        title: 'Core',
                        imageUrl: 'https://example.com', // Replace with a valid URL
                        duration: '1-2 mins',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Core()),
                        ),
                      ),
                      WorkoutCard(
                        title: 'Lower Body',
                        imageUrl: 'https://example.com', // Replace with a valid URL
                        duration: '1-2 mins',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LowerBody()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Weekly Challenge Section
              WeeklyChallenge(
                title: 'Weekly Challenge',
                description: 'Plank With Hip Twist',
                imageUrl: 'https://example.com/challenge', // Replace with a valid URL
                onTap: () => _launchURL('https://example.com/challenge'),
              ),
              // Articles & Tips Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Articles & Tips',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _launchURL('https://example.com/daily-routines'),
                      child: _buildArticleCard(context, 'Daily Routines', 'https://via.placeholder.com/250x150'),
                    ),
                    GestureDetector(
                      onTap: () => _launchURL('https://example.com/supplement-guide'),
                      child: _buildArticleCard(context, 'Supplement Guide', 'https://via.placeholder.com/250x150'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 54),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
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
      
    );
  }

  Widget _buildArticleCard(BuildContext context, String title, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.height * 0.20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              title,
              style: gfonts.GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          
        ],
      ),
    );
  }
}

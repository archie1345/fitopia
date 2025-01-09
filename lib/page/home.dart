import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<String> _getUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          return data?['username'] ?? (user.displayName ?? 'User');
        } else {
          // Fallback to Google display name if no document exists
          return user.displayName ?? 'User';
        }
      } catch (e) {
        print('Error fetching username: $e');
      }
    }
    return 'User';
  }

  Future<void> _checkSubscriptionStatus(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PremiumPage(userId: ''),
        ),
      );
      return;
    }

    try {
      DocumentSnapshot subscriptionSnapshot = await FirebaseFirestore.instance
          .collection('payment')
          .doc(user.uid)
          .get();

      if (subscriptionSnapshot.exists) {
        Map<String, dynamic> data =
            subscriptionSnapshot.data() as Map<String, dynamic>;

        if (data['status'] != 'paid') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PremiumPage(userId: user.uid),
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PremiumPage(userId: user.uid),
          ),
        );
      }
    } catch (e) {
      print("Error checking subscription status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<String>(
                      future: _getUsername(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text(
                            'Hi, User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(81, 75, 35, 1),
                            ),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${snapshot.data}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(81, 75, 35, 1),
                                ),
                              ),
                              const Text(
                                "It's time to challenge your limits.",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle,
                          size: 50, color: Colors.black87),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecipeListPage()),
                      );
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.restaurant),
                        Text('Nutrition')
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PremiumPage(userId: user.uid),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.card_membership),
                        Text('Premium')
                      ],
                    ),
                  ),
                ],
              ),
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
                        imageUrl:
                            'https://images.pexels.com/photos/29575475/pexels-photo-29575475/free-photo-of-muscular-man-exercising-with-gym-equipment.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                        duration: '10-15 mins',
                        onTap: () async {
                          await _checkSubscriptionStatus(context);
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UpperBody()),
                            );
                          }
                        },
                      ),
                      WorkoutCard(
                        title: 'Core',
                        imageUrl:
                            'https://cdn.sanity.io/images/uhnffrl6/production/67684a557f13c0706e757b46b4c3917f23505fe0-7858x5344.jpg?w=1200&fit=min&auto=format',
                        duration: '10-15 mins',
                        onTap: () async {
                          await _checkSubscriptionStatus(context);
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Core()),
                            );
                          }
                        },
                      ),
                      WorkoutCard(
                        title: 'Lower Body',
                        imageUrl:
                            'https://www.trxtraining.com/cdn/shop/articles/goblet-squat-kettlebell-leg-exercise.jpg?v=1695794753',
                        duration: '10-15 mins',
                        onTap: () async {
                          await _checkSubscriptionStatus(context);
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LowerBody()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              WeeklyChallenge(
                title: 'Weekly Challenge',
                description: 'Plank With Hip Twist',
                imageUrl:
                    'https://i.ytimg.com/vi/5iLPOi_XlFE/maxresdefault.jpg',
                onTap: () => _launchURL(
                    'https://www.google.com/search?q=Plank+With+Hip+Twist&sca_esv=be7123bc69849c3e&udm=2&biw=1328&bih=776&sxsrf=ADLYWIJN2uBQMhB5ttd7D0wAyj33VfnQqg:1736418003222&ei=06J_Z4eiDfWb0PEP-e6csQI&ved=0ahUKEwjH142SteiKAxX1DTQIHXk3JyYQ4dUDCBA&uact=5&oq=Plank+With+Hip+Twist&gs_lp=EgNpbWciFFBsYW5rIFdpdGggSGlwIFR3aXN0MgUQABiABEiaBlAAWABwAHgAkAEAmAH2AaAB9gGqAQMyLTG4AQPIAQD4AQL4AQGYAgGgAvgBmAMAkgcDMi0xoAdN&sclient=img#vhid=uNT84WyFttWfZM&vssid=mosaic'),
              ),
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
                      onTap: () => _launchURL(
                          'https://www.youtube.com/watch?v=H2U3HwAyBXg'),
                      child: _buildArticleCard(context, 'Daily Routines',
                          'https://www.eatthis.com/wp-content/uploads/sites/4/2023/09/woman-squats-1.jpeg?quality=82&strip=1'),
                    ),
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://www.muscleandfitness.com/supplements/build-muscle/ultimate-beginner-s-guide-supplements/'),
                      child: _buildArticleCard(context, 'Supplement Guide',
                          'https://i.ytimg.com/vi/1E9pRu43A-8/maxresdefault.jpg'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 54),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
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

  Widget _buildArticleCard(
      BuildContext context, String title, String imageUrl) {
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

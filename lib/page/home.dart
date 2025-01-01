import 'package:firebase_auth/firebase_auth.dart';
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
    // Get the currently signed-in user
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            // User Greeting Section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.displayName ?? "User"}', // Use FirebaseAuth's displayName
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const Text(
                          "It's time to challenge your limits.",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeListPage()),
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
                        MaterialPageRoute(builder: (context) => PremiumPage()),
                      );
                  },
                  child: Column(
                    children: const [Icon(Icons.card_membership), Text('Premium')],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
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
                            GestureDetector(
                              onTap: () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => UpperBody()),
                                  (route) => false),
                              child: Container(
                                width: 150,
                                height: 100,
                                margin: const EdgeInsets.only(right: 10),
                                color: Colors.grey[300],
                                child: const Center(child: Text('Upper Body')),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => Core()),
                                  (route) => false),
                              child: Container(
                                width: 150,
                                height: 100,
                                margin: const EdgeInsets.only(right: 10),
                                color: Colors.grey[300],
                                child: const Center(child: Text('Core')),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => LowerBody()),
                                  (route) => false),
                              child: Container(
                                width: 150,
                                height: 100,
                                margin: const EdgeInsets.only(right: 10),
                                color: Colors.grey[300],
                                child: const Center(child: Text('Lower Body')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    WeeklyChallenge(
                      title: 'Weekly Challenge',
                      description: 'Plank With Hip Twist',
                      imageUrl: 'https://example.com/challenge',
                      onTap: () => _launchURL('https://example.com/challenge'),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Articles & Tips',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => _launchURL('https://example.com/supplement-guide'),
                          child: Container(
                            width: 150,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(child: Text('Supplement Guide')),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _launchURL('https://example.com/daily-routines'),
                          child: Container(
                            width: 150,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(child: Text('Daily Routines')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
}

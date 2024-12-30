import 'package:fitopia/page/premium.dart';
import 'package:fitopia/page/profile.dart';
import 'package:fitopia/page/settings.dart';
import 'package:fitopia/page/workout/core.dart';
import 'package:fitopia/page/workout/lowerBody.dart';
import 'package:fitopia/widget/floatingNavBar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fitopia/page/workout/upperBody.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
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
                          'Hi, User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          "It's time to challenge your limits.",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.account_circle, size: 50, color: Colors.black87),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // InkWell(
                //   onTap: () {
                //     // Add your onTap functionality here
                //   },
                //   child: Column(
                //     children: [Icon(Icons.fitness_center), Text('Workout')],
                //   ),
                // ),
                InkWell(
                  onTap: () {
                    // Add your onTap functionality here
                  },
                  child: Column(
                    children: [Icon(Icons.restaurant), Text('Nutrition')],
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
                    children: [Icon(Icons.card_membership), Text('Premium')],
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
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
                                margin: const EdgeInsets.only(right: 10), // Add spacing between items
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
                                margin: const EdgeInsets.only(right: 10), // Add spacing between items
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
                                margin: const EdgeInsets.only(right: 10), // Add spacing between items
                                color: Colors.grey[300],
                                child: const Center(child: Text('Lower Body')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      color: Colors.grey[200],
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Weekly Challenge',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Plank With Hip Twist'),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => _launchURL('https://example.com/challenge'),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.15,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    color: Colors.grey[300],
                                    child: Center(child: Text('Image Placeholder')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Articles & Tips',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => _launchURL('https://example.com/supplement-guide'),
                          child: Container(
                            width: 150,
                            height: 100,
                            color: Colors.grey[300],
                            child: Center(child: Text('Supplement Guide')),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _launchURL('https://example.com/daily-routines'),
                          child: Container(
                            width: 150,
                            height: 100,
                            color: Colors.grey[300],
                            child: Center(child: Text('Daily Routines')),
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
        width: MediaQuery.of(context).size.width*0.5,
        child: FloatingNavigationBar(
          onHomePressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          ),
          // onChartPressed: () {
          //   // Implement chart action here
          // },
          onSettingsPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingPage()),
          ),
      ),
    ));
  }
}

import 'package:fitopia/page/home.dart';
import 'package:fitopia/page/settings.dart';
import 'package:fitopia/widget/exerciseDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:fitopia/widget/floatingNavBar.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;


class UpperBody extends StatefulWidget {
  const UpperBody({super.key});

  @override
  State<UpperBody> createState() => _UpperBodyState();
}

class _UpperBodyState extends State<UpperBody> {
  String selectedDifficulty = 'BEGINNER';

  final Map<String, List<Map<String, dynamic>>> workouts = {
  'BEGINNER': [
    {
      'name': 'Push-Ups',
      'image': 'https://img.freepik.com/free-photo/man-doing-push-ups-listening-music_23-2148375908.jpg',
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
    {
      'name': 'Squats',
      'image': 'https://img.freepik.com/free-photo/young-man-working-out-gym-bodybuilding_23-2149552302.jpg',
      'steps': [
        'Stand with feet shoulder-width apart.',
        'Lower your hips as if sitting back into a chair.',
        'Keep your back straight and knees behind your toes.',
        'Return to the starting position.',
      ],
      'challenges': [
        'Do 3 sets of 15–20 reps.',
        'Hold the squat position for 5 seconds before standing up.',
      ],
    },{
      'name': 'Jumping Jacks',
      'image': 'https://images.pexels.com/photos/4853082/pexels-photo-4853082.jpeg',
      'steps': [
        'Stand with feet shoulder-width apart.',
        'Lower your hips as if sitting back into a chair.',
        'Keep your back straight and knees behind your toes.',
        'Return to the starting position.',
      ],
      'challenges': [
        'Lorem ipsum',
        'Lorem ipsum dolor sit amet',
      ],
    },
  ],
    'INTERMEDIATE': [
      {
      'name': 'lorem ipsum',
      'image': 'https://images.pexels.com/photos/4853082/pexels-photo-4853082.jpeg',
      'steps': [
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
      ],
      'challenges': [
        'lorem ipsum',
        'lorem ipsum',
      ],
    },
      {
      'name': 'lorem ipsum',
      'image': 'https://images.pexels.com/photos/4853082/pexels-photo-4853082.jpeg',
      'steps': [
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
      ],
      'challenges': [
        'lorem ipsum',
        'lorem ipsum',
      ],
    },
      {
      'name': 'lorem ipsum',
      'image': 'https://images.pexels.com/photos/4853082/pexels-photo-4853082.jpeg',
      'steps': [
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
      ],
      'challenges': [
        'lorem ipsum',
        'lorem ipsum',
      ],
    },
    ],
    'ADVANCE': [
      {
      'name': 'lorem ipsum',
      'image': 'https://images.pexels.com/photos/4853082/pexels-photo-4853082.jpeg',
      'steps': [
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
      ],
      'challenges': [
        'lorem ipsum',
        'lorem ipsum',
      ],
    },
      {
      'name': 'lorem ipsum',
      'image': 'https://images.pexels.com/photos/4853082/pexels-photo-4853082.jpeg',
      'steps': [
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
      ],
      'challenges': [
        'lorem ipsum',
        'lorem ipsum',
      ],
    },
      {
      'name': 'lorem ipsum',
      'image': 'https://images.pexels.com/photos/4853082/pexels-photo-4853082.jpeg',
      'steps': [
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
        'lorem ipsum',
      ],
      'challenges': [
        'lorem ipsum',
        'lorem ipsum',
      ],
    },
    ],
  };

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
                    _buildDifficultyButton('INTERMEDIATE'),
                    _buildDifficultyButton('ADVANCE'),
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
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          workout['image'],
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.2,
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
          color: selectedDifficulty == difficulty ? Color.fromRGBO(101,104,57, 1) : const Color.fromRGBO(217, 217, 217, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          difficulty,
          style: TextStyle(
            color: selectedDifficulty == difficulty ? const Color.fromRGBO(217, 217, 217, 1) : Color.fromRGBO(101,104,57, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
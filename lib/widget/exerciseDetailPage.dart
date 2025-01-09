import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class ExerciseDetailPage extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetailPage({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          iconSize: 18,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushNamed(context, '/exercise');
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('workouts')
            .doc(exerciseId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Exercise not found.'));
          }

          final exerciseData = snapshot.data!.data() as Map<String, dynamic>;

          // Extract main exercise details
          final title = exerciseData['name'] ?? 'Unknown Exercise';
          final imageUrl = exerciseData['image'] ?? '';
          final time = exerciseData['time'] ?? 'Unknown time';
          final calories = exerciseData['calories'] ?? 'Unknown calories';

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('workouts')
                .doc(exerciseId)
                .collection('exercise_detail')
                .get(),
            builder: (context, subSnapshot) {
              if (subSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!subSnapshot.hasData || subSnapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('Exercise details not available.'));
              }

              // Extract steps and challenges
              final exerciseDetail =
                  subSnapshot.data!.docs.first.data() as Map<String, dynamic>;
              final steps = (exerciseDetail['steps'] as List<dynamic>? ?? [])
                  .map((step) => step.toString())
                  .toList();

              final challenges =
                  (exerciseDetail['challenges'] as List<dynamic>? ?? [])
                      .map((challenge) => challenge.toString())
                      .toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Exercise Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30.0)),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 200), // Placeholder
                      ),
                    ),

                    // Exercise Details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(81, 75, 35, 1),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "$time | $calories",
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Steps Section
                          const Text(
                            "Steps:",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(101, 104, 57, 1),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: steps.map<Widget>((step) {
                              return Text(
                                "- $step",
                                style: const TextStyle(fontSize: 14.0),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16.0),

                          // Challenges Section
                          const Text(
                            "Challenges:",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(101, 104, 57, 1),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: challenges.map<Widget>((challenge) {
                              return Text(
                                "- $challenge",
                                style: const TextStyle(fontSize: 14.0),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;


class ExerciseDetailPage extends StatelessWidget {
  final String name;
  final String image;
  final List<String> steps;
  final List<String> challenges;

  const ExerciseDetailPage({
    super.key,
    required this.name,
    required this.image,
    required this.steps,
    required this.challenges,
  });

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
                Navigator.pop(context);
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'How To Do',
                style: gfonts.GoogleFonts.getFont(
                'Poppins',
                color: const Color(0xFF656839),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color.fromRGBO(203, 208, 185, 1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((step) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• $step',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Challenges',
                style: gfonts.GoogleFonts.getFont(
                'Poppins',
                color: const Color(0xFF656839),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color.fromRGBO(203, 208, 185, 1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: challenges.map((challenge) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• $challenge',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

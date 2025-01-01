import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class Recipe {
  final String title;
  final String image;
  final String details;
  final String ingredients;
  final String instructions;
  final String time;
  final String calories;

  Recipe({
    required this.title,
    required this.image,
    required this.details,
    required this.ingredients,
    required this.instructions,
    required this.time,
    required this.calories,
  });
}

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: IconButton(
          iconSize: 18,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushNamed(context, '/recipe');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30.0)),
              child: Image.network(
                recipe.image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 200), // Placeholder for invalid URLs
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(81, 75, 35, 1),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Ingredients:",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(101, 104, 57, 1),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(recipe.ingredients),
                  const SizedBox(height: 16.0),
                  const Text(
                    "Instructions:",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(101, 104, 57, 1),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(recipe.instructions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

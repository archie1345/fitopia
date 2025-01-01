import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class RecipeDetailPage extends StatelessWidget {
  final String recipeId; // Identifier for the recipe

  const RecipeDetailPage({super.key, required this.recipeId, required title, required imageUrl, required String details, required ingredients, required instructions});

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipeId)
            .get(), // Fetch the recipe details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Recipe not found.'));
          }

          final recipeData = snapshot.data!.data() as Map<String, dynamic>;
          final recipe = Recipe(
            title: recipeData['title'] ?? 'Unknown Title',
            image: recipeData['imageUrl'] ?? '',
            details: '${recipeData['time']} | ${recipeData['calories']}',
            ingredients: recipeData['ingredients'] ?? '',
            instructions: recipeData['instructions'] ?? '',
            time: recipeData['time'] ?? '',
            calories: recipeData['calories'] ?? '',
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30.0)),
                  child: Image.network(
                    recipe.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 200), // Placeholder
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
          );
        },
      ),
    );
  }
}

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

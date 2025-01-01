import 'package:flutter/material.dart';

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
        title: const Text("Back"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  recipe.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 200), // Placeholder for invalid URLs
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Ingredients:",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
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
                ),
              ),
              const SizedBox(height: 8.0),
              Text(recipe.instructions),
            ],
          ),
        ),
      ),
    );
  }
}

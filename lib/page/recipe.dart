import 'package:fitopia/page/home.dart';
import 'package:fitopia/page/settings.dart';
import 'package:fitopia/widget/floatingNavBar.dart';
import 'package:fitopia/widget/recipeWidgetBuilder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts; // Use a prefix for google_fonts



class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Recipe> recipes = [
      Recipe(
        title: "Delights With Greek Yogurt",
        image: 'https://img.freepik.com/free-photo/natural-healthy-dessert-transparent-glass_23-2148650243.jpg?t=st=1735713117~exp=1735716717~hmac=853f8eb0c8b5b47816affdeab9bf9b6711f01149fb6a3cb88c68276909af0f69&w=740', // Use a valid image URL
        details: "6 Minutes | 200 Cal",
        ingredients: """
- 1 Cup Plain Greek Yogurt (Full-Fat or Low-Fat, as preferred)
- 2 Tablespoons Honey
- 2 Tablespoons Chopped Walnuts
- 1/4 Teaspoon Ground Cinnamon
- Optional Toppings: Fresh Fruits like Berries or Banana Slices
""",
        instructions: """
1. Prepare the yogurt base: Scoop the Greek yogurt into a serving bowl or glass.
2. Add sweetness: Drizzle the honey over the yogurt evenly.
3. Nutty crunch: Sprinkle the chopped walnuts on top.
4. Spice it up: Lightly dust with ground cinnamon for an aromatic touch.
5. Optional fruits: Add fresh fruits like blueberries, raspberries, or sliced bananas for extra flavor and color.
6. Serve & enjoy: Serve immediately as a breakfast, snack, or dessert.
""",
        time: "6 Minutes",
        calories: "200 Cal",
      ),
      Recipe(
        title: "Baked Salmon",
        image: 'https://img.freepik.com/free-photo/grilled-salmon-steak_1339-5877.jpg?t=st=1735713202~exp=1735716802~hmac=6c7c4e8ec36cc2ad544dec02e9cebfccdb7f6a93fb7d3e7392d17ed5b1940e39&w=1060', // Use a valid image URL
        details: "30 Minutes | 350 Cal",
        ingredients: """
- 2 Salmon Fillets
- 1 Tablespoon Olive Oil
- 1 Teaspoon Garlic Powder
- 1 Teaspoon Lemon Juice
- 1 Teaspoon Paprika
- Salt and Pepper to Taste
""",
        instructions: """
1. Preheat the oven to 375°F (190°C).
2. Season the salmon: Rub the fillets with olive oil, garlic powder, lemon juice, paprika, salt, and pepper.
3. Bake: Place the fillets on a baking sheet lined with parchment paper and bake for 20-25 minutes.
4. Serve: Garnish with fresh herbs and serve with a side of vegetables or rice.
""",
        time: "30 Minutes",
        calories: "350 Cal",
      ),
    ];

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
          
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(recipe: recipe),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0),
                      ),
                      child: Image.network(
                        recipe.image,
                        width: 175,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50), // Placeholder for invalid URLs
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(81, 75, 35, 1)
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(recipe.details),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
      ),
    );
  }
}

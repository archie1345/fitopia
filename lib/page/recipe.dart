import 'package:fitopia/page/home.dart';
import 'package:fitopia/page/settings.dart';
import 'package:fitopia/widget/floatingNavBar.dart';
import 'package:fitopia/widget/recipeWidgetBuilder.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

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
        body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('recipes').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No recipes found'));
            }

            final recipes = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final title = recipe['title'];
                final imageUrl = recipe['imageUrl'];
                final time = recipe['time'];
                final calories = recipe['calories'];
                final details = "$time | $calories";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(
                          title: title,
                          imageUrl: imageUrl,
                          details: details,
                          ingredients: recipe['ingredients'],
                          instructions: recipe['instructions'], 
                          recipeId: '',
                        ),
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
                            imageUrl,
                            width: 175,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, size: 50),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(81, 75, 35, 1),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(details),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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

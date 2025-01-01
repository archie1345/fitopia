import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
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
          
      backgroundColor: Colors.white,
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

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  Text(
                    'Nutrition',
                    style: gfonts.GoogleFonts.poppins(
                      color: const Color(0xFF514B23),
                      fontSize: width * 0.07,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    'Recipes For You',
                    style: gfonts.GoogleFonts.poppins(
                      color: const Color(0xFF514B23),
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      final title = recipe['title'];
                      final imageUrl = recipe['imageUrl'];
                      final time = recipe['time'];
                      final calories = recipe['calories'];

                      return Padding(
                        padding: EdgeInsets.only(bottom: height * 0.02),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(width * 0.05),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.02,
                                    horizontal: width * 0.04,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: gfonts.GoogleFonts.poppins(
                                          color: const Color(0xFF212020),
                                          fontSize: width * 0.045,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: width * 0.04,
                                            color: const Color(0xFF7B7B7B),
                                          ),
                                          SizedBox(width: width * 0.01),
                                          Text(
                                            time,
                                            style: gfonts.GoogleFonts.poppins(
                                              color: const Color(0xFF7B7B7B),
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                          SizedBox(width: width * 0.05),
                                          Icon(
                                            Icons.local_fire_department,
                                            size: width * 0.04,
                                            color: const Color(0xFF7B7B7B),
                                          ),
                                          SizedBox(width: width * 0.01),
                                          Text(
                                            calories,
                                            style: gfonts.GoogleFonts.poppins(
                                              color: const Color(0xFF7B7B7B),
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(width * 0.05),
                                child: Image.network(
                                  imageUrl,
                                  width: width * 0.3,
                                  height: height * 0.12,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

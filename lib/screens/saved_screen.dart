import 'package:flutter/material.dart';
import 'package:kitchensop/models/recipe_card.dart';
import '../models/recipe.dart';


class SavedScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onFavorite;

  const SavedScreen({
    super.key,
    required this.recipes,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final savedRecipes =
        recipes.where((recipe) => recipe.isFavorite).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Saved Recipes',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: savedRecipes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 42,
                        color: Color(0xFFF59E0B),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'No Saved Recipes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Recipes you save will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                100,
              ),
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];

                return RecipeCard(
                  recipe: recipe,
                  onFavorite: () {
                    onFavorite(recipe);
                  },
                  onTap: () {
                    // Recipe detail screen later.
                  },
                );
              },
            ),
    );
  }
}
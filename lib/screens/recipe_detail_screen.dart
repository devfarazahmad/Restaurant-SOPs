import 'package:flutter/material.dart';

import 'package:kitchensop/database/database_helper.dart';
import 'package:kitchensop/database/user.dart';
import 'package:kitchensop/models/recipe.dart';

import 'package:kitchensop/screens/edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final User user;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.user,
  });

  @override
  State<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState
    extends State<RecipeDetailScreen> {

  late Recipe recipe;

  @override
  void initState() {
    super.initState();

    recipe = widget.recipe;
  }

  // ==========================================
  // EDIT
  // ==========================================
  Future<void> editRecipe() async {
    if (!widget.user.isChefMaster) {
      return;
    }

    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditRecipeScreen(
          recipe: recipe,
        ),
      ),
    );

    if (result == true) {
      final data =
          await DatabaseHelper
              .instance
              .getRecipeById(
            recipe.id,
          );

      if (data != null &&
          mounted) {
        setState(() {
          recipe =
              Recipe.fromMap(data);
        });
      }
    }
  }

  // ==========================================
  // DELETE
  // ==========================================
  Future<void> deleteRecipe() async {
    if (!widget.user.isChefMaster) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Delete Recipe',
          ),
          content:
              Text(
            'Are you sure you want to delete "${recipe.name}"?',
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await DatabaseHelper.instance
        .deleteRecipe(
      recipe.id,
    );

    if (!mounted) return;

    Navigator.pop(
      context,
      true,
    );
  }

  // ==========================================
  // SECTION
  // ==========================================
  Widget section({
    required String title,
    required String content,
  }) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width:
          double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE5E7EB,
          ),
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(
                0xFF111827,
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            content,
            style:
                const TextStyle(
              fontSize: 14,
              height: 1.6,
              color:
                  Color(
                0xFF4B5563,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF9FAFB,
      ),

      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFFF9FAFB,
        ),
        elevation: 0,
        title:
            const Text(
          'Recipe Details',
          style:
              TextStyle(
            color:
                Color(
              0xFF111827,
            ),
            fontWeight:
                FontWeight.bold,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color:
              Color(
            0xFF111827,
          ),
        ),
        actions:
            widget.user.isChefMaster
                ? [

                    IconButton(
                      onPressed:
                          editRecipe,
                      icon:
                          const Icon(
                        Icons
                            .edit_rounded,
                      ),
                    ),

                    IconButton(
                      onPressed:
                          deleteRecipe,
                      icon:
                          const Icon(
                        Icons
                            .delete_outline_rounded,
                        color:
                            Colors.red,
                      ),
                    ),
                  ]
                : null,
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // ==========================================
            // TITLE CARD
            // ==========================================
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border:
                    Border.all(
                  color:
                      const Color(
                    0xFFE5E7EB,
                  ),
                ),
              ),
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    recipe.name,
                    style:
                        const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(
                        0xFF111827,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    recipe.category,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFFD97706,
                      ),
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    recipe.description,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF6B7280,
                      ),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Row(
                    children: [

                      const Icon(
                        Icons
                            .schedule_rounded,
                        size: 20,
                        color:
                            Color(
                          0xFFF59E0B,
                        ),
                      ),

                      const SizedBox(
                        width: 7,
                      ),

                      Text(
                        '${recipe.preparationTime} minutes',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            section(
              title:
                  'Ingredients',
              content:
                  recipe.ingredients,
            ),

            section(
              title:
                  'Preparation Steps',
              content:
                  recipe.preparationSteps,
            ),

            section(
              title:
                  'Cooking Instructions',
              content:
                  recipe.cookingInstructions,
            ),

            section(
              title:
                  'Storage Instructions',
              content:
                  recipe.storageInstructions,
            ),

            section(
              title:
                  'Freezing Instructions',
              content:
                  recipe.freezingInstructions,
            ),

            section(
              title:
                  'Thawing Instructions',
              content:
                  recipe.thawingInstructions,
            ),
          ],
        ),
      ),
    );
  }
}
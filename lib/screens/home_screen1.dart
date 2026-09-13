import 'package:flutter/material.dart';

import 'package:kitchensop/database/user.dart';
import 'package:kitchensop/models/category_card.dart';
import 'package:kitchensop/models/recipe_card.dart';

import 'package:kitchensop/screens/create_recipe_screen.dart';
import 'package:kitchensop/screens/recipe_detail_screen.dart';

import '../models/recipe.dart';

class HomeScreen extends StatefulWidget {
  final List<Recipe> recipes;

  final Function(Recipe) onFavorite;

  final User user;

  final Future<void> Function()
      onRecipeChanged;

  const HomeScreen({
    super.key,
    required this.recipes,
    required this.onFavorite,
    required this.user,
    required this.onRecipeChanged,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  final TextEditingController
      searchController =
      TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // FILTER RECIPES
  // ==========================================
  List<Recipe> get filteredRecipes {
    if (searchText.trim().isEmpty) {
      return widget.recipes;
    }

    final query =
        searchText
            .toLowerCase()
            .trim();

    return widget.recipes
        .where(
          (recipe) {
            return recipe.name
                    .toLowerCase()
                    .contains(query) ||
                recipe.category
                    .toLowerCase()
                    .contains(query);
          },
        )
        .toList();
  }

  // ==========================================
  // CREATE RECIPE
  // ==========================================
  Future<void> createRecipe() async {
    if (!widget.user.isChefMaster) {
      return;
    }

    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CreateRecipeScreen(),
      ),
    );

    if (result == true) {
      await widget.onRecipeChanged();

      if (!mounted) return;

      setState(() {});
    }
  }

  // ==========================================
  // OPEN RECIPE
  // ==========================================
  Future<void> openRecipe(
    Recipe recipe,
  ) async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RecipeDetailScreen(
          recipe: recipe,
          user: widget.user,
        ),
      ),
    );

    if (result == true) {
      await widget.onRecipeChanged();

      if (!mounted) return;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9FAFB),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            120,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ==========================================
              // HEADER
              // ==========================================
              Row(
                children: [

                  Container(
                    width: 48,
                    height: 48,
                    padding:
                        const EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFFE5E7EB,
                        ),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/kitchenops_logo.png',
                      fit:
                          BoxFit.contain,
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons
                              .restaurant_menu,
                          color:
                              Color(
                            0xFFF59E0B,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        const Text(
                          'Good Morning 👋',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF6B7280,
                            ),
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          widget.user.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF111827,
                            ),
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 45,
                    height: 45,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        14,
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
                        IconButton(
                      onPressed: () {},
                      icon:
                          const Icon(
                        Icons
                            .notifications_none_rounded,
                        color:
                            Color(
                          0xFF374151,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 25,
              ),

              // ==========================================
              // WELCOME
              // ==========================================
              const Text(
                'What are you cooking today?',
                style:
                    TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF111827),
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              const Text(
                'Find recipes and kitchen procedures quickly.',
                style:
                    TextStyle(
                  fontSize: 13,
                  color:
                      Color(0xFF6B7280),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==========================================
              // CHEF MASTER ONLY
              // ==========================================
              if (widget.user.isChefMaster) ...[
                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        createRecipe,
                    icon:
                        const Icon(
                      Icons.add_rounded,
                      size: 22,
                    ),
                    label:
                        const Text(
                      'Create Recipe',
                      style:
                          TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFF59E0B,
                      ),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],

              // ==========================================
              // SEARCH
              // ==========================================
              TextField(
                controller:
                    searchController,
                onChanged:
                    (value) {
                  setState(() {
                    searchText =
                        value;
                  });
                },
                decoration:
                    InputDecoration(
                  hintText:
                      'Search recipes...',
                  prefixIcon:
                      const Icon(
                    Icons.search_rounded,
                    color:
                        Color(
                      0xFF9CA3AF,
                    ),
                  ),
                  suffixIcon:
                      searchText.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchController
                                    .clear();

                                setState(() {
                                  searchText =
                                      '';
                                });
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .close_rounded,
                              ),
                            )
                          : null,
                  filled:
                      true,
                  fillColor:
                      Colors.white,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFFE5E7EB,
                      ),
                    ),
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFFE5E7EB,
                      ),
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFFF59E0B,
                      ),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==========================================
              // CATEGORIES
              // ==========================================
              const Text(
                'Categories',
                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF111827),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              SizedBox(
                height: 105,
                child: ListView(
                  scrollDirection:
                      Axis.horizontal,
                  children: [

                    CategoryCard(
                      name: 'Burgers',
                      icon:
                          Icons
                              .lunch_dining_rounded,
                      onTap: () {},
                    ),

                    CategoryCard(
                      name: 'Pizza',
                      icon:
                          Icons
                              .local_pizza_rounded,
                      onTap: () {},
                    ),

                    CategoryCard(
                      name: 'Chicken',
                      icon:
                          Icons
                              .set_meal_rounded,
                      onTap: () {},
                    ),

                    CategoryCard(
                      name: 'Fries',
                      icon:
                          Icons
                              .fastfood_rounded,
                      onTap: () {},
                    ),

                    CategoryCard(
                      name: 'Drinks',
                      icon:
                          Icons
                              .local_drink_rounded,
                      onTap: () {},
                    ),

                    CategoryCard(
                      name: 'Desserts',
                      icon:
                          Icons
                              .cake_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==========================================
              // RECIPES HEADER
              // ==========================================
              Row(
                children: [

                  const Expanded(
                    child:
                        Text(
                      'All Recipes',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            Color(
                          0xFF111827,
                        ),
                      ),
                    ),
                  ),

                  Text(
                    '${filteredRecipes.length} recipes',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF9CA3AF,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              // ==========================================
              // RECIPES
              // ==========================================
              if (filteredRecipes.isEmpty)
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(30),
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
                      const Column(
                    children: [

                      Icon(
                        Icons
                            .restaurant_menu_rounded,
                        size: 45,
                        color:
                            Color(
                          0xFF9CA3AF,
                        ),
                      ),

                      SizedBox(
                        height: 12,
                      ),

                      Text(
                        'No recipes yet',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Chef Master can create the first recipe.',
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF6B7280,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredRecipes.map(
                  (recipe) {
                    return RecipeCard(
                      recipe:
                          recipe,
                      onFavorite:
                          () {
                        widget
                            .onFavorite(
                          recipe,
                        );

                        setState(
                          () {},
                        );
                      },
                      onTap: () {
                        openRecipe(
                          recipe,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
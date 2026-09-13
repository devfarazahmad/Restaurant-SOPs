
import 'package:flutter/material.dart';
import 'package:kitchensop/database/database_helper.dart';
import 'package:kitchensop/database/user.dart';
import 'package:kitchensop/models/recipe.dart';
import 'package:kitchensop/screens/Profile%20Screen.dart';
import 'package:kitchensop/screens/home_screen.dart';
import 'package:kitchensop/screens/saved_screen.dart';
import 'package:kitchensop/screens/more_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final User user;

  const MainNavigationScreen({
    super.key,
    required this.user,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int currentIndex = 0;

  List<Recipe> recipes = [];

  bool isLoadingRecipes = true;

  @override
  void initState() {
    super.initState();

    loadRecipes();
  }

  // ============================================================
  // LOAD RECIPES FROM SQLITE
  // ============================================================

  Future<void> loadRecipes() async {
    try {
      final data =
          await DatabaseHelper.instance
              .getAllRecipes();

      final loadedRecipes = data
          .map(
            (map) => Recipe.fromMap(map),
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        recipes = loadedRecipes;
        isLoadingRecipes = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingRecipes = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not load recipes: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FAVORITE
  // ============================================================

  void toggleFavorite(Recipe recipe) {
    setState(() {
      recipe.isFavorite =
          !recipe.isFavorite;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        recipes: recipes,

        user: widget.user,

        onFavorite: toggleFavorite,

        onRecipeChanged: loadRecipes,
      ),

      SavedScreen(
        recipes: recipes,
        onFavorite: toggleFavorite,
      ),

      ProfileScreen(
        user: widget.user,
      ),

      const MoreScreen(),
    ];

    return Scaffold(
      body: isLoadingRecipes
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : IndexedStack(
              index: currentIndex,
              children: screens,
            ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: currentIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.bookmark_border,
            ),
            selectedIcon: Icon(
              Icons.bookmark,
            ),
            label: 'Saved',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.more_horiz,
            ),
            selectedIcon: Icon(
              Icons.more_horiz,
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:kitchensop/database/user.dart';
import 'package:kitchensop/screens/Profile%20Screen.dart';

import '../models/recipe.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'more_screen.dart';

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

  // ==========================================
  // TEMPORARY RECIPES
  // ==========================================
  final List<Recipe> recipes = [
    Recipe(
      id: 1,
      name: 'Classic Beef Burger',
      category: 'Burgers',
      description:
          'Classic restaurant-style beef burger preparation.',
      image: 'assets/images/burger.jpg',
      preparationTime: 15,
    ),
    Recipe(
      id: 2,
      name: 'Chicken Pizza',
      category: 'Pizza',
      description:
          'Restaurant chicken pizza preparation and assembly.',
      image: 'assets/images/pizza.jpg',
      preparationTime: 25,
    ),
    Recipe(
      id: 3,
      name: 'French Fries',
      category: 'Fries',
      description:
          'Crispy french fries preparation procedure.',
      image: 'assets/images/fries.jpg',
      preparationTime: 10,
    ),
    Recipe(
      id: 4,
      name: 'Fresh Lemonade',
      category: 'Drinks',
      description:
          'Fresh restaurant-style lemonade preparation.',
      image: 'assets/images/lemonade.jpg',
      preparationTime: 5,
    ),
  ];

  // ==========================================
  // FAVORITE
  // ==========================================
  void toggleFavorite(Recipe recipe) {
    setState(() {
      recipe.isFavorite =
          !recipe.isFavorite;
    });
  }

  // ==========================================
  // SCREENS
  // ==========================================
  List<Widget> get screens {
    return [
      HomeScreen(
        recipes: recipes,
        onFavorite: toggleFavorite,
        user: widget.user,
      ),

      SavedScreen(
        recipes: recipes,
        onFavorite: toggleFavorite,
      ),

      const ProfileScreen(),

      const MoreScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            currentIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            currentIndex = index;
          });
        },

        backgroundColor:
            Colors.white,

        indicatorColor:
            const Color(0xFFFFF3D6),

        elevation: 8,

        destinations: const [

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon:
                Icon(
              Icons.home_rounded,
              color:
                  Color(0xFFF59E0B),
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.favorite_border_rounded,
            ),
            selectedIcon:
                Icon(
              Icons.favorite_rounded,
              color:
                  Color(0xFFF59E0B),
            ),
            label: 'Saved',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon:
                Icon(
              Icons.person_rounded,
              color:
                  Color(0xFFF59E0B),
            ),
            label: 'Profile',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.more_horiz_rounded,
            ),
            selectedIcon:
                Icon(
              Icons.more_horiz_rounded,
              color:
                  Color(0xFFF59E0B),
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kitchensop/screens/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 3),
      _goToRoleSelection,
    );
  }

  // ==========================================
  // GO TO ROLE SELECTION
  // ==========================================
  void _goToRoleSelection() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RoleSelectionScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF111827),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                // ==========================================
                // LOGO
                // ==========================================
                Container(
                  width: 145,
                  height: 145,
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.30,
                        ),
                        blurRadius: 30,
                        offset:
                            const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/kitchenops_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 70,
                        color:
                            Color(0xFFF59E0B),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'KitchenOps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Smart Kitchen. Standard Recipes. Better Food.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Your restaurant recipes and kitchen\n'
                  'procedures, all in one place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 55),

                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      Color(0xFFF59E0B),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Preparing your kitchen...',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
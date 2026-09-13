import 'package:flutter/material.dart';

import 'package:kitchensop/login_screen/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState
    extends State<RoleSelectionScreen> {

  String? selectedRole;

  // ==========================================
  // CONTINUE TO LOGIN
  // ==========================================
  void continueToLogin() {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select your role first.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LoginScreen(
          selectedRole: selectedRole!,
        ),
      ),
    );
  }

  // ==========================================
  // ROLE CARD
  // ==========================================
  Widget roleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final bool isSelected =
        selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        margin:
            const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE5E7EB),
            width:
                isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.04,
              ),
              blurRadius: 15,
              offset:
                  const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFF3D6)
                    : const Color(0xFFF9FAFB),
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 30,
                color:
                    const Color(0xFFF59E0B),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFFF59E0B)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9FAFB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            35,
            24,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ==========================================
              // LOGO
              // ==========================================
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  padding:
                      const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(
                          0.08,
                        ),
                        blurRadius: 20,
                        offset:
                            const Offset(0, 8),
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
                        size: 45,
                        color:
                            Color(0xFFF59E0B),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Welcome to KitchenOps',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF111827),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Select your role to continue',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color:
                        Color(0xFF6B7280),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==========================================
              // CHEF MASTER
              // ==========================================
              roleCard(
                role: 'chef_master',
                title: 'Chef Master',
                description:
                    'Create, edit, delete and manage restaurant recipes and kitchen procedures.',
                icon:
                    Icons.restaurant_rounded,
              ),

              // ==========================================
              // KITCHEN STAFF
              // ==========================================
              roleCard(
                role: 'staff',
                title: 'Kitchen Staff',
                description:
                    'View recipes, follow kitchen procedures, search and save favorite recipes.',
                icon:
                    Icons.groups_rounded,
              ),

              const SizedBox(height: 10),

              // ==========================================
              // CONTINUE
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      continueToLogin,
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
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'KitchenOps',
                  style: TextStyle(
                    color:
                        Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
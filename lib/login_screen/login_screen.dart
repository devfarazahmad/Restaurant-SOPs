import 'package:flutter/material.dart';
import 'package:kitchensop/screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kitchensop/database/database_helper.dart';
import 'package:kitchensop/database/user.dart';

import 'package:kitchensop/login_screen/create_account_screen.dart';


import 'package:kitchensop/screens/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  final String selectedRole;

  const LoginScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  String get roleTitle {
    if (widget.selectedRole ==
        'chef_master') {
      return 'Chef Master';
    }

    return 'Kitchen Staff';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOGIN
  // ==========================================
  Future<void> login() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final Map<String, dynamic>? userData =
          await DatabaseHelper.instance.login(
        emailController.text.trim(),
        passwordController.text,
        widget.selectedRole,
      );

      if (!mounted) return;

      // ==========================================
      // INVALID LOGIN
      // ==========================================
      if (userData == null) {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid email, password or $roleTitle account.',
            ),
            behavior:
                SnackBarBehavior.floating,
          ),
        );

        return;
      }

      final User user =
          User.fromMap(userData);

      // ==========================================
      // SAVE SESSION
      // ==========================================
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setInt(
        'logged_in_user_id',
        user.id,
      );

      await prefs.setString(
        'logged_in_user_role',
        user.role,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ==========================================
      // GO TO MAIN APPLICATION
      // ==========================================
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainNavigationScreen(
            user: user,
          ),
        ),
        (route) => false,
      );

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed. Please try again.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================
  // CHANGE ROLE
  // ==========================================
  void changeRole() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RoleSelectionScreen(),
      ),
    );
  }

  // ==========================================
  // CREATE ACCOUNT
  // ==========================================
  void openCreateAccountScreen() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CreateAccountScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9FAFB),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: Form(
              key: _formKey,
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
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.08),
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
                            (context,
                                error,
                                stackTrace) {
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

                  const SizedBox(height: 35),

                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in as $roleTitle.',
                    style: const TextStyle(
                      fontSize: 15,
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================================
                  // SELECTED ROLE
                  // ==========================================
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(14),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFFFF3D6),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Row(
                      children: [

                        const Icon(
                          Icons
                              .verified_user_rounded,
                          color:
                              Color(0xFFD97706),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Role: $roleTitle',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  Color(0xFF92400E),
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : changeRole,
                          child:
                              const Text(
                            'Change',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // EMAIL
                  // ==========================================
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF374151),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter your email',
                      prefixIcon:
                          const Icon(
                        Icons.email_outlined,
                      ),
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(0xFFE5E7EB),
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(0xFFF59E0B),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {

                      if (value == null ||
                          value.trim().isEmpty) {
                        return
                            'Please enter your email';
                      }

                      if (!value.contains('@')) {
                        return
                            'Please enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  // ==========================================
                  // PASSWORD
                  // ==========================================
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF374151),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        passwordController,
                    obscureText:
                        !isPasswordVisible,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter your password',
                      prefixIcon:
                          const Icon(
                        Icons
                            .lock_outline_rounded,
                      ),
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible =
                                !isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons
                                  .visibility_off_outlined
                              : Icons
                                  .visibility_outlined,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(0xFFE5E7EB),
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(0xFFF59E0B),
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {
                        return
                            'Please enter your password';
                      }

                      if (value.length < 6) {
                        return
                            'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color:
                              Color(0xFFD97706),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // LOGIN
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : login,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFF59E0B,
                        ),
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            const Color(
                          0xFFFBBF24,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // CREATE ACCOUNT
                  // ==========================================
                  Center(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [

                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color:
                                Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),

                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : openCreateAccountScreen,
                          style:
                              TextButton.styleFrom(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            minimumSize:
                                Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                          ),
                          child:
                              const Text(
                            'Create Account',
                            style:
                                TextStyle(
                              color:
                                  Color(0xFFD97706),
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          'KitchenOps',
                          style: TextStyle(
                            color:
                                Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Restaurant Recipe & Kitchen Management',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color:
                                Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
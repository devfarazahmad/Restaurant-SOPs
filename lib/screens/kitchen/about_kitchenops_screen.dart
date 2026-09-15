import 'package:flutter/material.dart';

class AboutKitchenOpsScreen extends StatelessWidget {
  const AboutKitchenOpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'About KitchenOps',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Image.asset(
                      'assets/images/kitchenops_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant_rounded,
                          size: 50,
                          color: Color(0xFFF59E0B),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'KitchenOps',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Smart Kitchen. Standard Recipes. Better Food.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'KitchenOps is a restaurant kitchen management application designed to help teams standardize recipes, document kitchen procedures, train staff and keep important operational information organized in one place.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _infoCard(
              icon: Icons.restaurant_menu_rounded,
              title: 'Standardized Recipes',
              description:
                  'Keep ingredients, preparation procedures, cooking instructions, storage information and other recipe standards organized for the kitchen team.',
            ),

            _infoCard(
              icon: Icons.menu_book_rounded,
              title: 'Kitchen SOPs',
              description:
                  'Document important kitchen procedures so staff can follow consistent and professional operating standards.',
            ),

            _infoCard(
              icon: Icons.school_outlined,
              title: 'Staff Training',
              description:
                  'Schedule training sessions and keep upcoming learning activities organized for kitchen staff.',
            ),

            _infoCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Quick Access',
              description:
                  'QR-based access can make recipes, SOPs and other kitchen resources available quickly at the point of work.',
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Built for better kitchen operations.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'KitchenOps',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Smart Kitchen. Standard Recipes. Better Food.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF59E0B),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
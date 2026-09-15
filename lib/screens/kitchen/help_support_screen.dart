import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFDE68A),
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFF59E0B),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How can we help?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Find answers or contact the KitchenOps support team.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Support',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 10),

          _supportItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Frequently Asked Questions',
            subtitle: 'Find answers to common questions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FaqScreen(),
                ),
              );
            },
          ),

          _supportItem(
            context,
            icon: Icons.email_outlined,
            title: 'Contact Support',
            subtitle: 'Send a support request',
            onTap: () {
              _showContactDialog(context);
            },
          ),

          _supportItem(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            subtitle: 'Tell us about an issue',
            onTap: () {
              _showReportDialog(context);
            },
          ),

          const SizedBox(height: 25),

          const Text(
            'Quick Guides',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 10),

          _guideCard(
            Icons.menu_book_rounded,
            'Managing Recipes',
            'Create and maintain standardized restaurant recipes.',
          ),

          _guideCard(
            Icons.assignment_outlined,
            'Managing SOPs',
            'Create procedures that help kitchen staff follow consistent processes.',
          ),

          _guideCard(
            Icons.school_outlined,
            'Staff Training',
            'Schedule and manage staff learning sessions.',
          ),

          _guideCard(
            Icons.qr_code_scanner_rounded,
            'QR Scanner',
            'Quickly access kitchen resources using QR codes.',
          ),
        ],
      ),
    );
  }

  Widget _supportItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF59E0B),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _guideCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFF59E0B),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final subjectController =
            TextEditingController();

        final messageController =
            TextEditingController();

        return AlertDialog(
          title: const Text('Contact Support'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Support request saved. Connect your email/API service to send it.',
                    ),
                    behavior:
                        SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report a Problem'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'Describe the problem you experienced...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Problem report recorded.',
                    ),
                    behavior:
                        SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Who can create recipes?',
        'a':
            'Chef Master users can create, edit and delete recipes. Kitchen Staff users can view recipes.',
      },
      {
        'q': 'Where are recipes stored?',
        'a':
            'Recipes are currently stored in the KitchenOps local SQLite database.',
      },
      {
        'q': 'Can I create kitchen SOPs?',
        'a':
            'Yes. Kitchen SOPs can be created, edited, viewed and deleted from the Kitchen SOPs section.',
      },
      {
        'q': 'Can I schedule staff training?',
        'a':
            'Yes. You can select a date and time, add a trainer, location and notes, and save the training schedule.',
      },
      {
        'q': 'What can QR codes be used for?',
        'a':
            'QR codes can be used to quickly open recipes, SOPs, training resources and other kitchen information.',
      },
      {
        'q': 'Does KitchenOps require Firebase?',
        'a':
            'The current version does not require Firebase. Local application data is stored on the device.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'FAQs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: faqs.map((faq) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: ExpansionTile(
              title: Text(
                faq['q']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              childrenPadding:
                  const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              children: [
                Text(
                  faq['a']!,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
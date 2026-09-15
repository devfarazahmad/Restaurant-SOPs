import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool trainingReminders = true;
  bool recipeUpdates = true;
  bool autoSave = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notifications =
          prefs.getBool('notifications') ?? true;

      trainingReminders =
          prefs.getBool('training_reminders') ?? true;

      recipeUpdates =
          prefs.getBool('recipe_updates') ?? true;

      autoSave =
          prefs.getBool('auto_save') ?? true;
    });
  }

  Future<void> _setPreference(
    String key,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle('Notifications'),

          const SizedBox(height: 10),

          _settingCard(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle:
                'Receive important KitchenOps notifications',
            value: notifications,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });

              _setPreference(
                'notifications',
                value,
              );
            },
          ),

          _settingCard(
            icon: Icons.school_outlined,
            title: 'Training Reminders',
            subtitle:
                'Remind staff about upcoming training',
            value: trainingReminders,
            onChanged: (value) {
              setState(() {
                trainingReminders = value;
              });

              _setPreference(
                'training_reminders',
                value,
              );
            },
          ),

          _settingCard(
            icon: Icons.restaurant_menu_outlined,
            title: 'Recipe Updates',
            subtitle:
                'Notify when recipes are updated',
            value: recipeUpdates,
            onChanged: (value) {
              setState(() {
                recipeUpdates = value;
              });

              _setPreference(
                'recipe_updates',
                value,
              );
            },
          ),

          const SizedBox(height: 25),

          _sectionTitle('Data & Storage'),

          const SizedBox(height: 10),

          _settingCard(
            icon: Icons.save_outlined,
            title: 'Auto Save',
            subtitle:
                'Automatically save application changes',
            value: autoSave,
            onChanged: (value) {
              setState(() {
                autoSave = value;
              });

              _setPreference(
                'auto_save',
                value,
              );
            },
          ),

          const SizedBox(height: 25),

          _sectionTitle('Application'),

          const SizedBox(height: 10),

          _actionCard(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              _showComingSoon(
                'Additional languages will be available in a future version.',
              );
            },
          ),

          _actionCard(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Light theme',
            onTap: () {
              _showComingSoon(
                'Theme customization will be available in a future version.',
              );
            },
          ),

          _actionCard(
            icon: Icons.storage_outlined,
            title: 'Storage',
            subtitle: 'Local KitchenOps data',
            onTap: () {
              _showStorageInfo();
            },
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFDE68A),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your current KitchenOps recipes, SOPs and training schedules are stored locally on this device.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFF59E0B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        secondary: Container(
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
      ),
    );
  }

  Widget _actionCard({
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

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Storage'),
          content: const Text(
            'KitchenOps currently uses local storage for application preferences, SOPs and training schedules. Recipes are stored in the local SQLite database.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
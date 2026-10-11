import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _pureVegDefault = false;
  bool _pushNotifications = true;
  bool _smsUpdates = true;
  bool _soundEffects = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Hindi (हिंदी)',
    'Kannada (ಕನ್ನಡ)',
    'Tamil (தமிழ்)',
    'Telugu (తెలుగు)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestyColors.darkCanvas,
      appBar: AppBar(
        title: const Text('Preferences & Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ZestySpacing.md),
        children: [
          // Section 1: Appearance
          _sectionTitle('APPEARANCE & THEME'),
          _toggleTile(
            title: 'Dark Obsidian Theme',
            subtitle: 'Recommended for AMOLED screens and battery saving',
            icon: Icons.dark_mode_rounded,
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
          ),

          const SizedBox(height: 16),

          // Section 2: Dietary
          _sectionTitle('FOOD & DIETARY PREFERENCES'),
          _toggleTile(
            title: 'Pure Vegetarian Mode',
            subtitle: 'Only show certified green-dot pure veg restaurants and kitchens',
            icon: Icons.eco_rounded,
            value: _pureVegDefault,
            onChanged: (val) {
              setState(() => _pureVegDefault = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val ? 'Pure Veg filter set as default' : 'Veg filter reset'),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Section 3: Notifications & Sounds
          _sectionTitle('NOTIFICATIONS & SOUNDS'),
          _toggleTile(
            title: 'Order Status Push Notifications',
            subtitle: 'Receive real-time updates when meal is preparing or out for delivery',
            icon: Icons.notifications_active_rounded,
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          _toggleTile(
            title: 'SMS Delivery OTP Alerts',
            subtitle: 'Receive backup SMS messages for driver handoff PIN',
            icon: Icons.sms_rounded,
            value: _smsUpdates,
            onChanged: (val) => setState(() => _smsUpdates = val),
          ),
          _toggleTile(
            title: 'In-app Sound & Haptic Feedback',
            subtitle: 'Audio chime when payment succeeds or order updates',
            icon: Icons.volume_up_rounded,
            value: _soundEffects,
            onChanged: (val) => setState(() => _soundEffects = val),
          ),

          const SizedBox(height: 16),

          // Section 4: Language
          _sectionTitle('LANGUAGE PREFERENCE'),
          Material(
            color: ZestyColors.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ZestyColors.glassBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.language_rounded, color: ZestyColors.primaryAmber),
              title: const Text('App Language', style: TextStyle(color: ZestyColors.textLight, fontSize: 14)),
              subtitle: Text(_selectedLanguage, style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12)),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: ZestyColors.darkCard,
                underline: const SizedBox(),
                items: _languages.map((l) {
                  return DropdownMenuItem(
                    value: l,
                    child: Text(l, style: const TextStyle(color: ZestyColors.textLight, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (newLang) {
                  if (newLang != null) setState(() => _selectedLanguage = newLang);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section 5: App Info & Danger Zone
          _sectionTitle('ABOUT ZESTYGO'),
          Material(
            color: ZestyColors.darkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ZestyColors.glassBorder),
            ),
            child: Column(
              children: [
                const ListTile(
                  title: Text('App Version', style: TextStyle(color: ZestyColors.textLight, fontSize: 13)),
                  trailing: Text('v2.4.0 (Build 20261011)', style: TextStyle(color: ZestyColors.textMuted, fontSize: 12)),
                ),
                const Divider(color: ZestyColors.glassBorder, height: 1),
                ListTile(
                  title: const Text('Clear Image Cache & Temp Data', style: TextStyle(color: ZestyColors.textLight, fontSize: 13)),
                  trailing: const Icon(Icons.cleaning_services_rounded, color: ZestyColors.textMuted, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared (14.2 MB freed)')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: ZestyColors.primaryAmber,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: ZestyColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ZestyColors.glassBorder),
        ),
        child: SwitchListTile(
          value: value,
          activeThumbColor: ZestyColors.primary,
          onChanged: onChanged,
          secondary: Icon(icon, color: ZestyColors.primaryAmber),
          title: Text(
            title,
            style: const TextStyle(color: ZestyColors.textLight, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: ZestyColors.textMuted, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

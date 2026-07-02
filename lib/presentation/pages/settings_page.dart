import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iot_manager/presentation/viewmodels/user_settings_viewmodel.dart';

final getIt = GetIt.instance;

/// Settings Page - Manage user preferences and application configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserSettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<UserSettingsViewModel>();
    // Settings would be loaded with userId
    // _viewModel.loadSettings('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Appearance Settings
            _buildSectionHeader('Appearance'),
            _buildThemeSettings(),
            _buildLanguageSettings(),
            
            const Divider(height: 32),
            
            // Notification Settings
            _buildSectionHeader('Notifications'),
            _buildNotificationSettings(),
            
            const Divider(height: 32),
            
            // Sync Settings
            _buildSectionHeader('Sync'),
            _buildAutoRefreshSettings(),
            
            const Divider(height: 32),
            
            // About
            _buildSectionHeader('About'),
            _buildAboutSection(),
            
            const SizedBox(height: 32),
            
            // Reset Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showResetConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reset to Defaults'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSettings() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.isDarkMode,
      builder: (context, isDarkMode, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme for the application'),
            value: isDarkMode,
            onChanged: (value) => _viewModel.toggleDarkMode(value),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSettings() {
    return ValueListenableBuilder<String>(
      valueListenable: _viewModel.language,
      builder: (context, language, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Language',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: language,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                    DropdownMenuItem(value: 'de', child: Text('German')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _viewModel.setLanguage(value);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationSettings() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.notificationsEnabled,
      builder: (context, notificationsEnabled, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive alerts for important events'),
            value: notificationsEnabled,
            onChanged: (value) {
              // Toggle notifications - update settings
            },
          ),
        );
      },
    );
  }

  Widget _buildAutoRefreshSettings() {
    return ValueListenableBuilder<int>(
      valueListenable: _viewModel.autoRefreshInterval,
      builder: (context, interval, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Auto Refresh Interval',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$interval seconds', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Slider(
                  value: interval.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label: '$interval seconds',
                  onChanged: (value) {
                    _viewModel.setAutoRefreshInterval(value.toInt());
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('IoT Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            const Text('Connected Device Management System', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Text(
              '© 2026 IoT Manager. All rights reserved.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text('This will restore all settings to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset settings - userId would come from app state
              // _viewModel.resetToDefaults('user_id');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

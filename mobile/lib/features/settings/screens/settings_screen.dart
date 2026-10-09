import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Settings screen for app configuration
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'Appearance',
            children: [
              _buildThemeModeTile(context, ref, themeMode),
            ],
          ),
          _buildSection(
            context,
            title: 'Account',
            children: [
              _buildPlaceholderTile(
                context,
                title: 'Email',
                subtitle: 'Manage your email',
                icon: Icons.email_outlined,
              ),
              _buildPlaceholderTile(
                context,
                title: 'Password',
                subtitle: 'Change your password',
                icon: Icons.lock_outline,
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              _buildPlaceholderTile(
                context,
                title: 'Push Notifications',
                subtitle: 'Manage notification preferences',
                icon: Icons.notifications_outlined,
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'About',
            children: [
              _buildPlaceholderTile(
                context,
                title: 'Version',
                subtitle: '1.0.0',
                icon: Icons.info_outline,
              ),
              _buildPlaceholderTile(
                context,
                title: 'Terms of Service',
                subtitle: 'View terms',
                icon: Icons.description_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }
  
  Widget _buildThemeModeTile(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    return ListTile(
      leading: Icon(
        Icons.brightness_6_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeLabel(currentMode)),
      trailing: DropdownButton<ThemeMode>(
        value: currentMode,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text('Light'),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text('Dark'),
          ),
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('System'),
          ),
        ],
        onChanged: (mode) {
          if (mode != null) {
            ref.read(themeModeProvider.notifier).setThemeMode(mode);
          }
        },
      ),
    );
  }
  
  Widget _buildPlaceholderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Placeholder for future functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
  
  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }
}

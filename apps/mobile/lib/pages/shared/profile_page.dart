import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anti_gaspi_dz/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dev_provider.dart';
import '../dev_dashboard_page.dart';

/// Profile page with settings, language toggle, account deletion.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (user?['display_name'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?['display_name'] ?? user?['phone_number'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    user?['role']?.toString().toUpperCase() ?? '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language toggle
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.selectLanguage),
              trailing: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'fr', label: Text(l10n.french)),
                  ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                ],
                selected: {auth.selectedLanguage},
                onSelectionChanged: (v) => auth.setLanguage(v.first),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Dev Mode Toggle (MVP Showcase)
          Consumer<DevProvider>(
            builder: (context, dev, _) => Card(
              color: dev.isDevMode ? Colors.deepOrange.shade50 : null,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.devModeTitle),
                    subtitle: Text(l10n.devModeSubtitle),
                    value: dev.isDevMode,
                    activeColor: Colors.deepOrange,
                    onChanged: (v) => dev.toggleDevMode(v),
                    secondary: const Icon(Icons.bug_report, color: Colors.deepOrange),
                  ),
                  if (dev.isDevMode)
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.deepOrange),
                      title: Text(l10n.openAdminDashboard, style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepOrange),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DevDashboardPage()));
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Logout
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: Text(l10n.logout),
              onTap: () => auth.logout(),
            ),
          ),
          const SizedBox(height: 8),

          // Delete account
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                l10n.deleteAccount,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => _showDeleteDialog(context, auth, l10n),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AuthProvider auth, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              auth.deleteAccount();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }
}

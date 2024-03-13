import 'package:age_sync/pages/privacy_policy_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                onTap: () => print('TODO')),
            ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Language'),
                onTap: () => print('TODO')),
            ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Theme'),
                onTap: () => print('TODO')),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Change name'),
                onTap: () => print('TODO')),
            ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Change avatar'),
                onTap: () => print('TODO')),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Change email'),
                onTap: () => print('TODO')),
            ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change password'),
                onTap: () => print('TODO')),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                onTap: () => context.pushNamed(PrivacyPolicyPage.routeName)),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
              ),
              title: const Text('Delete account'),
              onTap: () => context.typeConfirmationDialog(
                title: 'Delete account',
                content: 'Are you sure you want to delete your account?',
                onConfirm: () {
                  print('TODO');
                },
                confirmText: 'DELETE',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

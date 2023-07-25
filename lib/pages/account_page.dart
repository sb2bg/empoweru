import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';
import '../utils/profile.dart';
import 'chat/view_messages.dart';
import 'log_in_page.dart';

class AccountPage extends StatefulWidget {
  static const routeName = '/account';

  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Profile _profile;
  final _loading = ValueNotifier(true);

  Future<void> _getProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final profile = await Profile.fromUuid(userId);

      setState(() {
        _profile = profile;
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar(message: error.toString());
      }
    } finally {
      if (mounted) {
        _loading.value = false;
      }
    }
  }

  _signOut() {
    supabase.auth.signOut().then(
        (value) => {context.pushReplacementNamed(LogInPage.logInRouteName)});
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _loading,
        builder: (context, value, child) {
          if (value) {
            return preloader;
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            CachedNetworkImageProvider(_profile.avatarUrl),
                      ),
                      title: Text(_profile.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => print('TODO'),
                      )),
                  const Divider(),
                  ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Change email'),
                      onTap: () => print('TODO')),
                  ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change password'),
                      onTap: () => print('TODO')),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: _signOut,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                    ),
                    title: const Text('Delete account'),
                    onTap: () => Navigator.of(context)
                        .pushNamed(ViewMessagesPage.routeName),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

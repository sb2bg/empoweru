import 'package:age_sync/pages/login_page.dart';
import 'package:age_sync/pages/view_messages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';
import '../utils/profile.dart';

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

      final data = await supabase
          .from('profiles')
          .select<Map<String, dynamic>>()
          .eq('id', userId)
          .single();

      setState(() {
        _profile = Profile.fromMap(data);
        _loading.value = false;
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: error.toString());
    }
  }

  _signOut() {
    supabase.auth.signOut().then((value) =>
        {if (mounted) context.pushReplacementNamed(LoginPage.routeName)});
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

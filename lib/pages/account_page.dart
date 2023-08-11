import 'package:age_sync/pages/friend_page.dart';
import 'package:age_sync/pages/task_page.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

class _AccountPageState extends LoadingState<AccountPage> {
  late final Profile _profile;

  @override
  onInit() async {
    final profile = await supabase.getCurrentUser();

    setState(() {
      _profile = profile;
    });
  }

  _signOut() {
    supabase.auth.signOut().then(
        (value) => {context.pushReplacementNamed(LogInPage.logInRouteName)});
  }

  @override
  AppBar? get constAppBar => AppBar(
        title: const Text('Account'),
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
              leading: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Change avatar'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Take a photo'),
                                  onTap: () => print('TODO'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo),
                                  title: const Text('Choose from gallery'),
                                  onTap: () => print('TODO'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Remove avatar'),
                                  onTap: () => print('TODO'),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.close),
                                  title: const Text('Cancel'),
                                  onTap: () => context.pop(),
                                ),
                              ],
                            ),
                          ));
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      CachedNetworkImageProvider(_profile.avatarUrl),
                ),
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
              leading: const Icon(Icons.cake),
              title: const Text('Change birthday'),
              onTap: () => print('TODO')),
          const Divider(),
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
            onTap: () => print('TODO: Delete account and all associated data'),
          ),
        ],
      ),
    );
  }
}

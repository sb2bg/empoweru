import 'package:age_sync/pages/admin/admin_page.dart';
import 'package:age_sync/pages/settings_page.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';
import '../utils/profile.dart';

class AccountPage extends StatefulWidget {
  static const routeName = '/account';

  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends LoadingState<AccountPage> {
  late Profile _profile;

  @override
  onInit() async {
    final profile = await supabase.getCurrentUser();

    setState(() {
      _profile = profile;
    });
  }

  _signOut() {
    supabase.auth.signOut();
  }

  @override
  AppBar? get constAppBar => AppBar(
        title: const Text('Account'),
      );

  changePfp() async {
    final picker = ImagePicker();

    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );

    if (imageFile == null) {
      return;
    }

    final bytes = await imageFile.readAsBytes();
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${supabase.userId}.$fileExt';
    final filePath = fileName;
    await supabase.storage.from('avatars').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: imageFile.mimeType),
        );
    final imageUrl = await supabase.storage
        .from('avatars')
        .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);

    // TODO: this won't work with RLS
    await supabase.from('profiles').upsert({
      'id': supabase.userId,
      'avatar_url': imageUrl,
    });
  }

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
                                  onTap: changePfp),
                              ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Remove avatar'),
                                  onTap: () {
                                    supabase.from('profiles').upsert({
                                      'id': supabase.userId,
                                      'avatar_url': defaultAvatarUrl,
                                    }).then((value) => context.pop());
                                  }),
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
                backgroundImage: CachedNetworkImageProvider(_profile.avatarUrl),
              ),
            ),
            title: Text(_profile.name),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.pushNamed(SettingsPage.routeName),
                ),
                if (_profile.admin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    onPressed: () => context.pushNamed(AdminPage.routeName),
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            onTap: () => print('TODO'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification Settings'),
            onTap: () => context.pushNamed(SettingsPage.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            onTap: () => print('TODO'),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('App Theme'),
            onTap: () => print('TODO'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Feedback'),
            onTap: () => print('TODO'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              context.showConfirmationDialog(
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  onConfirm: _signOut);
            },
          ),
        ],
      ),
    );
  }
}

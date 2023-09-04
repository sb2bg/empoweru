import 'package:age_sync/pages/admin/admin_page.dart';
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
                                    onTap: () async {
                                      final picker = ImagePicker();

                                      final imageFile = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 300,
                                        maxHeight: 300,
                                      );

                                      if (imageFile == null) {
                                        return;
                                      }

                                      final bytes =
                                          await imageFile.readAsBytes();
                                      final fileExt =
                                          imageFile.path.split('.').last;
                                      final fileName =
                                          '${supabase.userId}.$fileExt';
                                      final filePath = fileName;
                                      await supabase.storage
                                          .from('avatars')
                                          .uploadBinary(
                                            filePath,
                                            bytes,
                                            fileOptions: FileOptions(
                                                contentType:
                                                    imageFile.mimeType),
                                          );
                                      final imageUrl = await supabase.storage
                                          .from('avatars')
                                          .createSignedUrl(filePath,
                                              60 * 60 * 24 * 365 * 10);

                                      // TODO: this won't work with RLS
                                      await supabase.from('profiles').upsert({
                                        'id': supabase.userId,
                                        'avatar_url': imageUrl,
                                      });
                                    }),
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
          if (_profile.admin)
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin Panel'),
                  onTap: () => context.pushNamed(AdminPage.routeName),
                ),
                const Divider(),
              ],
            ),
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
            onTap: () {
              context.showConfirmationDialog(
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  onConfirm: _signOut);
            },
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

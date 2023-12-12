import 'package:age_sync/pages/settings_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/profile.dart';

class OrganizationDashboard extends StatefulWidget {
  static const routeName = '/org-dashboard';

  const OrganizationDashboard({super.key});

  @override
  State<OrganizationDashboard> createState() => _OrganizationDashboardState();
}

class _OrganizationDashboardState extends LoadingState<OrganizationDashboard> {
  late Profile _profile;

  @override
  Future<void> onInit() async {
    final profile = await Profile.fromId(supabase.userId);

    setState(() {
      _profile = profile;
    });
  }

  @override
  AppBar get loadingAppBar => AppBar();

  @override
  AppBar get loadedAppBar => AppBar(
        title: Text(_profile.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.pushNamed(SettingsPage.routeName);
            },
          ),
        ],
      );

  @override
  buildLoaded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
              radius: 100,
              child: CachedNetworkImage(
                imageUrl: _profile.avatarUrl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )),
          const SizedBox(height: 16),
          ListTile(
            title: Text(_profile.name,
                style: Theme.of(context).textTheme.headline5),
            subtitle: Text(
                'We strive to provide equal education opportunities for everyone'),
          ),
          ListTile(
            title: Text('Organization Type'),
            subtitle: Text('School'),
          ),
          ListTile(
            title: Text('Organization Address'),
            subtitle: Text('535 Portwall St, Houston, TX 77029'),
          ),
          ListTile(
            title: Text('Organization Website'),
            subtitle: Text('https://www.houstonfoodbank.org', maxLines: 1),
          ),
          ListTile(
            title: Text('Organization Email'),
            subtitle: Text('Recieving@houstonfoodbank.org'),
          ),
          ListTile(
            title: Text('Organization Phone'),
            subtitle: Text('713-547-8660)'),
          ),
          ListTile(
            title: Text('Organization Social Media'),
            subtitle: Text('https://www.twitter.com/houstonfoodbank'),
          ),
          Divider(),
          ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: // form to broadcast message
                              Center(
                            child: Column(
                              children: [
                                TextField(
                                  decoration:
                                      InputDecoration(hintText: 'Message'),
                                ),
                                TextButton.icon(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    icon: Text('Send message to 3 recipients'),
                                    label: Icon(Icons.send))
                              ],
                            ),
                          ),
                        ));
              },
              child: Text('Broadcast Message')),
          ElevatedButton(
              child: Text('View Volunteers'),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView(
                            children: [
                              ListTile(
                                title: Text('Brian Greene'),
                                subtitle: Text('President'),
                              ),
                              ListTile(
                                leading: IconButton(
                                  icon: Icon(Icons.message_outlined),
                                  onPressed: () {},
                                ),
                                title: Text('Sullivan Bognar'),
                                subtitle: Text('Student volunteer'),
                              ),
                              ListTile(
                                title: Text('Aryav Agrawal'),
                                subtitle: Text('Student volunteer'),
                                leading: IconButton(
                                  icon: Icon(Icons.message_outlined),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ));
              }),
        ],
      ),
    );
  }
}

import 'package:age_sync/pages/view_account_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/loading_state.dart';
import '../utils/profile.dart';

class FriendPage extends StatefulWidget {
  static const routeName = '/friends';

  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends LoadingState<FriendPage> {
  late List<Profile> _friends;

  @override
  onInit() async {
    final profile = await supabase.getCurrentUser();
    _friends = await profile.getFriends();
  }

  @override
  AppBar? get constAppBar => AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              print('TODO');
            },
          )
        ],
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: _friends.isEmpty
            ? Center(
                child: IntrinsicWidth(
                    child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'You have no friends',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('TODO');
                    },
                    child: const Text('Add friends'),
                  )
                ],
              )))
            : ListView.separated(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  final friend = _friends[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(friend.avatarUrl),
                    ),
                    title: Text(friend.name),
                    onTap: () {
                      context.pushNamed(ViewAccountPage.routeName,
                          arguments: friend.id);
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ));
  }
}

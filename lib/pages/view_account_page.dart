import 'package:age_sync/pages/chat/chat_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/profile.dart';

class ViewAccountPage extends StatefulWidget {
  static const routeName = '/view-account';

  const ViewAccountPage({super.key, required this.user});

  final Profile user;

  @override
  State<ViewAccountPage> createState() => _ViewAccountPageState();
}

class _ViewAccountPageState extends LoadingState<ViewAccountPage> {
  late Profile _profile;
  late FriendStatus _friendStatus;
  bool _updatingFriendStatus = false;

  @override
  Future<void> onInit() async {
    _profile = widget.user;
    final friendStatus = await _profile.friendStatus(supabase.userId);

    setState(() {
      _friendStatus = friendStatus;
    });
  }

  updateFriendStatus(Function() friendFn) async {
    setState(() {
      _updatingFriendStatus = true;
    });

    await friendFn();
    final friendStatus = await _profile.friendStatus(supabase.userId);

    setState(() {
      _friendStatus = friendStatus;
      _updatingFriendStatus = false;
    });
  }

  @override
  AppBar get loadingAppBar => AppBar();

  @override
  AppBar get loadedAppBar => AppBar(
        title: Text(_profile.name),
        actions: [
          IconButton(
              icon: const Icon(Icons.report_outlined),
              onPressed: () {
                print('TODO');
                showReportThankYouDialog(context);
              })
        ],
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(_profile.avatarUrl),
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              _profile.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Text(
            //   _profile.bio,
            //   style: Theme.of(context).textTheme.bodyText1,
            // ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _updatingFriendStatus
                  ? [const CircularProgressIndicator()]
                  : [
                      switch (_friendStatus) {
                        FriendStatus.notFriends => TextButton.icon(
                            onPressed: () async {
                              await updateFriendStatus(_profile.addFriend);
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Send organization request')),
                        FriendStatus.pendingSent => TextButton.icon(
                            onPressed: () async {
                              await updateFriendStatus(_profile.removeFriend);
                            },
                            icon: const Icon(Icons.person_add_disabled),
                            label: const Text('Cancel organization request')),
                        FriendStatus.pendingReceived => TextButton.icon(
                            onPressed: () async {
                              await updateFriendStatus(_profile.addFriend);
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Accept organization request')),
                        FriendStatus.friends => TextButton.icon(
                            onPressed: () async {
                              await updateFriendStatus(_profile.removeFriend);
                            },
                            icon: const Icon(Icons.person_remove),
                            label: const Text('Leave organization')),
                      },
                      _friendStatus == FriendStatus.friends
                          ? TextButton.icon(
                              icon: const Icon(Icons.message),
                              label: const Text('Send Message'),
                              onPressed: () {
                                context.pushNamed(ChatPage.routeName,
                                    arguments: _profile);
                              },
                            )
                          : const SizedBox(),
                    ],
            )
          ],
        ),
      ),
    );
  }
}

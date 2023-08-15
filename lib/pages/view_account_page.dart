import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/profile.dart';
import 'chat/chat_page.dart';

class ViewAccountPage extends StatefulWidget {
  static const routeName = '/view-account';

  const ViewAccountPage({super.key, required this.userId});

  final String userId;

  @override
  State<ViewAccountPage> createState() => _ViewAccountPageState();
}

class _ViewAccountPageState extends LoadingState<ViewAccountPage> {
  late Profile _profile;
  late bool _isFriend;

  @override
  Future<void> onInit() async {
    final profile = await Profile.fromId(widget.userId);
    final isFriend = await profile.isFriend(profile.id);

    setState(() {
      _profile = profile;
      _isFriend = isFriend;
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
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 16),
            // Text(
            //   _profile.bio,
            //   style: Theme.of(context).textTheme.bodyText1,
            // ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                    icon: Icon(_isFriend
                        ? Icons.remove_circle_outline
                        : Icons.person_add_alt_1_outlined),
                    label: Text(
                        _isFriend ? 'Remove Friend' : 'Send Friend Request'),
                    onPressed: () {}),
                _isFriend
                    ? TextButton.icon(
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Send Message'),
                        onPressed: () {
                          context.pushNamed(ChatPage.routeName,
                              arguments: _profile.id);
                        })
                    : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

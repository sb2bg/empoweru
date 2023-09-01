import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/profile.dart';
import 'chat_page.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends LoadingState<NewChatPage> {
  final _searchController = TextEditingController();
  final _friends = <Profile>[];

  @override
  onInit() async {
    final me = await supabase.getCurrentUser();
    _friends.addAll(await me.getFriends());
  }

  @override
  Widget? get header => Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search...",
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Center(
      child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _friends.length,
          itemBuilder: (context, index) {
            final friend = _friends[index];

            return FriendEntry(
              profile: friend,
            );
          }),
    );
  }
}

class FriendEntry extends StatelessWidget {
  const FriendEntry({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
          ),
          title: Text(profile.name),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.pushNamed(ChatPage.routeName, arguments: profile.id);
            },
          )),
    );
  }
}

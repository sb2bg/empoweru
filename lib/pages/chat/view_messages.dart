import 'package:age_sync/pages/chat/new_chat_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/message.dart';
import 'package:age_sync/utils/room.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

import '../../utils/profile.dart';
import 'chat_page.dart';

class ViewMessagesPage extends StatefulWidget {
  static const routeName = '/messages';

  const ViewMessagesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ViewMessagesPage(),
    );
  }

  @override
  State<ViewMessagesPage> createState() => _ViewMessagesPageState();
}

class _ViewMessagesPageState extends LoadingState<ViewMessagesPage> {
  late final List<RoomMeta> _rooms;

  @override
  onInit() async {
    final profile = await supabase.getCurrentUser();
    final rooms = await profile.getRooms();

    setState(() {
      _rooms = rooms;
    });
  }

  @override
  AppBar? get constAppBar => AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const NewChatPage(),
              );
            },
          )
        ],
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final room = _rooms[index];

        return _MessageEntry(profile: room.other, lastText: room.lastMessage);
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: _rooms.length,
    );
  }
}

class _MessageEntry extends StatelessWidget {
  const _MessageEntry({required this.profile, required this.lastText});

  final Profile profile;
  final Message? lastText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
        ),
        title: Text(profile.name),
        subtitle: Row(
          children: [
            Text(lastText?.content ?? 'Click to chat with ${profile.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Text(
              lastText != null
                  ? format(lastText!.createdAt, locale: 'en_short')
                  : '',
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
      onTap: () {
        context.pushNamed(ChatPage.routeName, arguments: profile.id);
      },
      onLongPress: () {
        context.showMenu([
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              print("TODO");
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block'),
            onTap: () {
              print("TODO");
            },
          )
        ]);
      },
    );
  }
}

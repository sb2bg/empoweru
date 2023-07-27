import 'package:age_sync/pages/chat/new_chat_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/room.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
        String? lastText = room.lastMessage?.content;

        return _MessageEntry(
            profile: room.other,
            lastText: lastText ?? 'Click to chat with ${room.other.name}');
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: _rooms.length,
    );
  }
}

class _MessageEntry extends StatelessWidget {
  const _MessageEntry({required this.profile, required this.lastText});

  final Profile profile;
  final String lastText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
        ),
        title: Text(profile.name),
        subtitle: Text(lastText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey)),
      ),
      onTap: () {
        supabase.rpc('create_new_room', params: {
          'other_user_id': profile.id,
        }).then(
            (value) => context.pushNamed(ChatPage.routeName, arguments: value));
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

import 'dart:async';

import 'package:age_sync/pages/chat/new_chat_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/chat/message.dart';
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

class RoomModel {
  final String roomId;
  final Profile other;
  final Message lastMessage;

  RoomModel({
    required this.roomId,
    required this.other,
    required this.lastMessage,
  });
}

class _ViewMessagesPageState extends LoadingState<ViewMessagesPage> {
  final List<RoomModel> _rooms = [];

  @override
  onInit() async {
    Completer<bool> completer = Completer();

    messageController.messageStream.listen((event) async {
      for (final room in event.keys) {
        _rooms.clear();

        final map = await supabase
            .from('room_participants')
            .select('profile_id')
            .eq('room_id', room)
            .neq('profile_id', supabase.userId)
            .single();

        Profile other = await Profile.fromId(map['profile_id']);

        _rooms.add(RoomModel(
            roomId: room, other: other, lastMessage: event[room]!.first));

        completer.complete(true);
        setState(() {});
      }
    });

    await completer.future;
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
    if (_rooms.isEmpty) {
      return const Center(
        child: Text('No messages yet'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];

        return Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: Card(
              child: _MessageEntry(
                  profile: room.other, lastText: room.lastMessage)),
        );
      },
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
        title: Row(
          children: [
            lastText?.unread() ?? true
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: themeData.colorScheme.primary,
                    ),
                  )
                : const SizedBox(),
            Text(profile.name),
          ],
        ),
        subtitle: Row(
          children: [
            Text(lastText?.content ?? 'Click to chat with ${profile.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: lastText?.unread() ?? true
                        ? Colors.white
                        : Colors.grey)),
            const Spacer(),
            Text(
              lastText != null
                  ? format(lastText!.createdAt, locale: 'en_short')
                  : 'TODO', // FIXME
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
      onTap: () {
        context.pushNamed(ChatPage.routeName, arguments: profile);
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

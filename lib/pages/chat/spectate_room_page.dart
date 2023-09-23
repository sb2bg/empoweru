import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/chat/message.dart';
import 'package:age_sync/utils/room.dart';
import 'package:age_sync/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

class SpectateChatRoomPage extends StatefulWidget {
  static const routeName = '/spectate';

  const SpectateChatRoomPage({super.key, required this.roomId});

  final String roomId;

  @override
  State<SpectateChatRoomPage> createState() => _SpectateChatRoomPageState();
}

class _SpectateChatRoomPageState extends LoadingState<SpectateChatRoomPage> {
  late final RoomMeta _room;
  late final Stream<List<Message>> _messagesStream;
  late final user1 = _room.user1;
  late final user2 = _room.user2;

  @override
  onInit() async {
    _room = await RoomMeta.fromRoomId(widget.roomId);

    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', widget.roomId)
        .order('created_at')
        .map((maps) => maps.map((map) => Message.fromMap(map: map)).toList());
  }

  @override
  AppBar get loadingAppBar => AppBar();

  @override
  AppBar get loadedAppBar =>
      AppBar(title: Text('${_room.user1.name} and ${_room.user2.name}'));

  @override
  bool get disableRefresh => true;

  @override
  Widget buildLoaded(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: _messagesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final messages = snapshot.data ?? [];

                return Column(
                  children: [
                    Expanded(
                      child: messages.isEmpty
                          ? const Center(
                              child: Text('No messages yet'),
                            )
                          : ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];

                                return ChatBubbleReceived(
                                  message: message,
                                  profile: message.profileId == user1.id
                                      ? user1
                                      : user2,
                                );
                              },
                            ),
                    ),
                  ],
                );
              } else {
                return preloader;
              }
            },
          ),
        ),
      ],
    );
  }
}

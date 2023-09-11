import 'dart:async';

import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

import 'package:age_sync/utils/message.dart';
import 'package:age_sync/utils/profile.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatPage({super.key, required this.otherId});

  final String otherId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends LoadingState<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  late final Profile _me;
  late final Profile _other;
  late final String _roomId;

  @override
  bool get disableRefresh => true;

  @override
  onInit() async {
    _roomId = await supabase.rpc('create_new_room', params: {
      'other_user_id': widget.otherId,
    });

    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', _roomId)
        .order('created_at')
        .map((maps) => maps.map((map) => Message.fromMap(map: map)).toList());

    await _loadProfiles();
  }

  _loadProfiles() async {
    final map = await supabase
        .from('room_participants')
        .select('profile_id')
        .eq('room_id', _roomId)
        .neq('profile_id', supabase.userId)
        .single();

    _other = await Profile.fromId(map['profile_id']);
    _me = await supabase.getCurrentUser();
  }

  @override
  AppBar get loadingAppBar => AppBar();

  @override
  AppBar get loadedAppBar => AppBar(title: Text(_other.name), actions: [
        IconButton(
          onPressed: () {
            context.pushNamed(ViewAccountPage.routeName, arguments: _other.id);
          },
          icon: const Icon(Icons.account_circle),
        ),
      ]);

  @override
  Widget buildLoaded(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                          child: Text('Say hello',
                              style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            return ChatBubble(
                              message: message,
                              profile: message.isMine ? _me : _other,
                            );
                          },
                        ),
                ),
                _MessageBar(roomId: _roomId),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar({required this.roomId});

  final String roomId;

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => _submitMessage(),
                onEditingComplete: () {},
                keyboardType: TextInputType.text,
                maxLines: null,
                autofocus: true,
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _submitMessage(),
              child: const Row(
                children: [
                  Text('Send', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 6),
                  Icon(Icons.send, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;

    if (text.isEmpty) {
      return;
    }

    _textController.clear();

    context.tryDatabaseAsync(() async {
      await Message.create(supabase.userId, text, widget.roomId);
    });
  }
}

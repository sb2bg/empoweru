import 'dart:async';

import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

import 'package:age_sync/utils/chat/message.dart';
import 'package:age_sync/utils/profile.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatPage({super.key, required this.other});

  final Profile other;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends LoadingState<ChatPage> {
  late final Profile _me;
  late final Profile _other;
  late final String _roomId;
  late List<Message> _optimisticMessages = [];
  late final StreamSubscription _streamSubscription;
  bool _shouldMarkMessagesAsRead = true;

  @override
  bool get disableRefresh => true;

  @override
  firstLoad() async {
    _roomId = await supabase.rpc('create_new_room', params: {
      'other_user_id': widget.other.id,
    });

    _streamSubscription = streamControllers.messageStream.listen((event) async {
      final messages = event[_roomId] ?? [];

      setState(() {
        _optimisticMessages = messages;
      });

      if (_shouldMarkMessagesAsRead) {
        await supabase.rpc('mark_messages_as_read', params: {
          '_room_id': _roomId,
        });

        _shouldMarkMessagesAsRead = false;

        Future.delayed(const Duration(milliseconds: 500), () {
          _shouldMarkMessagesAsRead = true;
        });
      }
    });
  }

  @override
  onInit() async {
    await _loadProfiles();
  }

  _loadProfiles() async {
    _other = widget.other;
    _me = await supabase.getCurrentUser();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  AppBar get loadingAppBar => AppBar();

  @override
  AppBar get loadedAppBar => AppBar(title: Text(_other.name), actions: [
        IconButton(
          onPressed: () {
            context.pushNamed(ViewAccountPage.routeName, arguments: _other);
          },
          icon: const Icon(Icons.account_circle),
        ),
      ]);

  @override
  Widget buildLoaded(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: _optimisticMessages.isEmpty
                  ? const Center(
                      child: Text('Say hello',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _optimisticMessages.length,
                      itemBuilder: (context, index) {
                        final message = _optimisticMessages[index];

                        return ChatBubble(
                          message: message,
                          profile: message.isMine ? _me : _other,
                        );
                      },
                    ),
            ),
            _MessageBar(roomId: _roomId),
          ],
        ));
  }
}

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
          bottom: context.bottomPadding,
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

import 'dart:async';

import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:age_sync/utils/message.dart';
import 'package:age_sync/utils/profile.dart';
import 'package:timeago/timeago.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatPage({super.key, required this.roomId});

  final String roomId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends LoadingState<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  late final Profile _me;
  late final Profile _other;

  @override
  onInit() async {
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', widget.roomId)
        .order('created_at')
        .map((maps) => maps.map((map) => Message.fromMap(map: map)).toList());

    await _loadProfiles();
  }

  _loadProfiles() async {
    final map = await supabase
        .from('room_participants')
        .select('profile_id')
        .eq('room_id', widget.roomId)
        .neq('profile_id', supabase.userId)
        .single();

    _other = await Profile.fromId(map['profile_id']);
    _me = await supabase.getCurrentUser();
  }

  @override
  AppBar get loadingAppBar => AppBar(
        title: const Text('Chat'),
      );

  @override
  AppBar get loadedAppBar => AppBar(title: const Text('Chat'), actions: [
        IconButton(
          onPressed: () {
            context.pushNamed(ViewAccountPage.routeName, arguments: _other.id);
          },
          icon: const Icon(Icons.account_circle),
        ),
      ]);

  @override
  Widget buildLoaded(BuildContext context) {
    return StreamBuilder(
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

                          return _ChatBubble(
                            message: message,
                            profile: message.isMine ? _me : _other,
                          );
                        },
                      ),
              ),
              _MessageBar(roomId: widget.roomId),
            ],
          );
        } else {
          return preloader;
        }
      },
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.profile,
  });

  final Message message;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine)
        GestureDetector(
          onTap: () => context.pushNamed(ViewAccountPage.routeName,
              arguments: profile.id),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
          ),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine ? Colors.blue[600] : Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short'),
          style: const TextStyle(color: Colors.grey)),
      const SizedBox(width: 60),
    ];

    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }

    final myActions = [
      ListTile(
        leading: const Icon(Icons.delete),
        title: const Text('Delete'),
        onTap: () {
          message.delete();
          context.pop();
        },
      ),
    ];

    final otherActions = [
      ListTile(
        leading: const Icon(Icons.account_circle),
        title: const Text('View profile'),
        onTap: () {
          context.pushNamed(ViewAccountPage.routeName, arguments: profile.id);
        },
      ),
      ListTile(
        leading: const Icon(Icons.report),
        title: const Text('Report Message'),
        onTap: () {
          print('TODO');
          context.pop();
          // thank you for reporting this message
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Report Received'),
                    content: const Text(
                        'We will review this message and take appropriate action. Thank you for helping us keep AgeSync safe.'),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ));
        },
      ),
    ];

    return GestureDetector(
      onLongPress: () {
        context.showMenu(message.isMine ? myActions : otherActions);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(
          mainAxisAlignment:
              message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: chatContents,
        ),
      ),
    );
  }
}

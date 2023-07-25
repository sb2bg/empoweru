import 'dart:async';

import 'package:age_sync/pages/account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:age_sync/utils/message.dart';
import 'package:age_sync/utils/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatPage({Key? key, required this.roomId}) : super(key: key);

  final String roomId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  late final Profile _me;

  @override
  void initState() {
    super.initState();

    try {
      final myUserId = supabase.auth.currentUser!.id;

      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('room_id', widget.roomId)
          .order('created_at')
          .map((maps) => maps
              .map((map) => Message.fromMap(map: map, myUserId: myUserId))
              .toList());

      _loadProfile(myUserId);
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  Future<void> _loadProfile(String id) async {
    try {
      final map =
          await supabase.from('profiles').select().eq('id', id).single();
      final profile = Profile.fromMap(map);

      setState(() {
        _me = profile;
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Chat'),
          leading: const BackButton(),
          actions: [
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AccountPage.routeName),
              icon: const Icon(Icons.account_circle),
            ),
          ]),
      body: StreamBuilder(
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
                              profile: message.isMine
                                  ? _me
                                  : _me, // TODO: fix this, it's not _me for the other person
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
    final myUserId = supabase.auth.currentUser!.id;

    if (text.isEmpty) {
      return;
    }

    _textController.clear();

    try {
      await supabase.from('messages').insert({
        'profile_id': myUserId,
        'content': text,
        'room_id': widget.roomId,
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
    required this.profile,
  }) : super(key: key);

  final Message message;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine)
        CircleAvatar(
          child:
              profile == null ? preloader : Text(profile!.name.substring(0, 2)),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}

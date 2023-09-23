import 'dart:async';
import 'dart:collection';

import 'package:age_sync/utils/chat/message.dart';
import 'package:age_sync/utils/constants.dart';

class MessageController {
  late final Stream<HashMap<String, List<Message>>> messageStream;
  int unread = 0;
  final List<Function> _listeners = [];

  MessageController() {
    messageStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) {
          final HashMap<String, List<Message>> messages = HashMap();

          for (final map in maps) {
            final message = Message.fromMap(map: map);

            if (!messages.containsKey(message.roomId)) {
              messages[message.roomId] = [];
            }

            messages[message.roomId]?.add(message);
          }

          return messages;
        });

    // update unread count
    messageStream.listen((event) {
      for (final room in event.values) {
        unread = 0;

        if (!room.first.read) {
          unread++;
        }
      }

      callListeners();
    });
  }

  callListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  addListener(Function listener) {
    _listeners.add(listener);
  }
}

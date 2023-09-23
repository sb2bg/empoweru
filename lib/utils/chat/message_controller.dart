import 'dart:async';
import 'dart:collection';

import 'package:age_sync/utils/chat/message.dart';
import 'package:age_sync/utils/constants.dart';

class MessageController {
  late final Stream<HashMap<String, List<Message>>> messageStream;

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
  }
}

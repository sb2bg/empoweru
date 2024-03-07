import 'dart:async';
import 'dart:collection';

import 'package:age_sync/utils/chat/message.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/room.dart';

class StreamControllers {
  late final Stream<HashMap<String, List<Message>>> messageStream;
  late final Stream<List<RoomMeta>> roomStream;

  StreamControllers() {
    roomStream = supabase
        .from('room_participants')
        .stream(primaryKey: ['room_id'])
        .eq('profile_id', supabase.userId)
        .asyncMap((maps) async {
          final List<RoomMeta> rooms = [];

          for (final map in maps) {
            rooms.add(await RoomMeta.fromRoomId(map['room_id']));
          }

          return rooms;
        });

    messageStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) {
          final HashMap<String, List<Message>> messages = HashMap();

          for (final map in maps) {
            final message = Message.fromMap(map: map);

            if (messages.containsKey(message.roomId)) {
              messages[message.roomId]!.add(message);
            } else {
              messages[message.roomId] = [message];
            }
          }

          return messages;
        });
  }
}

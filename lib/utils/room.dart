import 'package:age_sync/utils/profile.dart';

import 'constants.dart';
import 'chat/message.dart';

class Room {
  const Room({
    required this.id,
    required this.updatedAt,
  });

  final String id;
  final DateTime updatedAt;

  Room.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        updatedAt = DateTime.parse(map['updated_at']);

  static Future<Room> fromId(String id) async {
    return await supabase
        .from('rooms')
        .select()
        .eq('id', id)
        .single()
        .then((map) => Room.fromMap(map));
  }
}

class RoomMeta {
  const RoomMeta(
      {required this.room,
      required this.lastMessage,
      required this.user1,
      required this.user2});

  final Room room;
  final Message? lastMessage;
  final Profile user1;
  final Profile user2;

  static Future<RoomMeta> fromRoomId(String roomId) async {
    final room = await Room.fromId(roomId);
    final lastMessage = await Message.lastMessageFromRoomId(roomId);

    final participants = await supabase
        .from('room_participants')
        .select('profile_id')
        .eq('room_id', roomId)
        .limit(2);

    if (participants.length != 2) {
      throw Exception('Room must have 2 participants');
    }

    final user1 = await Profile.fromId(participants[0]['profile_id']);
    final user2 = await Profile.fromId(participants[1]['profile_id']);

    return RoomMeta(
        room: room, lastMessage: lastMessage, user1: user1, user2: user2);
  }

  Profile get other => user1.id == supabase.userId ? user2 : user1;

  bool unread() {
    if (lastMessage == null) {
      return true;
    }

    return !lastMessage!.read && !lastMessage!.isMine;
  }
}

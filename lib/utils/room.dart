import 'package:age_sync/utils/profile.dart';

import 'constants.dart';
import 'message.dart';

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
      {required this.room, required this.lastMessage, required this.other});

  final Room room;
  final Message? lastMessage;
  final Profile other;

  static Future<RoomMeta> fromRoomId(String roomId) async {
    final room = await Room.fromId(roomId);
    final lastMessage = await Message.lastMessageFromRoomId(roomId);

    final map = await supabase
        .from('room_participants')
        .select('profile_id')
        .eq('room_id', roomId)
        .neq('profile_id', supabase.userId)
        .single();

    final other = await Profile.fromId(map['profile_id']);

    return RoomMeta(room: room, lastMessage: lastMessage, other: other);
  }
}

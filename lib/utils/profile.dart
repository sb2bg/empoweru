import 'package:age_sync/utils/room.dart';

import 'constants.dart';

class Profile {
  Profile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.elder,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final bool elder;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'] ??
            '', // TODO: remove null check, enforce name not null in db
        avatarUrl = map['avatar_url'],
        elder = map['elder'];

  static Future<Profile> fromId(String uuid) async {
    return Profile.fromMap(
        await supabase.from('profiles').select().eq('id', uuid).single());
  }

// TODO: this can likely be optimized
  Future<List<Profile>> getFriends() async {
    final userId = supabase.userId;

    final myFriends = await supabase
        .from('friendships')
        .select()
        .eq('profile_id', userId)
        .eq('status', true);

    final asFriend = await supabase
        .from('friendships')
        .select()
        .eq('friend_id', userId)
        .eq('status', true);

    return await Future.wait([
      ...myFriends.map((map) => Profile.fromId(map['friend_id'])),
      ...asFriend.map((map) => Profile.fromId(map['profile_id']))
    ]);
  }

  Future<List<RoomMeta>> getRooms() async {
    DateTime now = DateTime.now();
    final List<dynamic> rooms =
        await supabase.from('room_participants').select().eq('profile_id', id);
    final List<Room> roomsList =
        await Future.wait(rooms.map((map) => Room.fromId(map['room_id'])));

    return await Future.wait(roomsList.map((e) => RoomMeta.fromRoomId(e.id)));
  }
}

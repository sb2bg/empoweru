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

    final friends = await supabase
        .from('friendships')
        .select()
        .or('friend_id.eq.$userId,profile_id.eq.$userId')
        .eq('status', true);

    List<Profile> mappedFriends = [];

    for (final friend in friends) {
      final friendId = friend['friend_id'] as String;

      if (friendId != userId) {
        mappedFriends.add(await Profile.fromId(friendId));
      } else {
        mappedFriends.add(await Profile.fromId(friend['profile_id'] as String));
      }
    }

    return mappedFriends;
  }

  Future<List<RoomMeta>> getRooms() async {
    final List<dynamic> rooms =
        await supabase.from('room_participants').select().eq('profile_id', id);
    final List<Room> roomsList =
        await Future.wait(rooms.map((map) => Room.fromId(map['room_id'])));

    return await Future.wait(roomsList.map((e) => RoomMeta.fromRoomId(e.id)));
  }

  Future<bool> isFriend(String otherId) async {
    return await supabase
            .from('friendships')
            .select()
            .eq('profile_id', id)
            .eq('friend_id', id)
            .eq('profile_id', otherId)
            .eq('friend_id', otherId)
            .eq('status', true) !=
        0;
  }
}

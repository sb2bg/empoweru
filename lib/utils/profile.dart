import 'package:age_sync/utils/room.dart';

import 'constants.dart';

enum FriendStatus { notFriends, pendingSent, pendingReceived, friends }

class Profile {
  Profile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.organizationId,
    required this.admin,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String? organizationId;
  final bool admin;

  bool get organization => organizationId != null;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        avatarUrl = map['avatar_url'],
        organizationId = map['organization'],
        admin = map['admin'];

  static Future<Profile> fromId(String uuid) async {
    if (uuid == supabase.userId) {
      return await supabase.getCurrentUser();
    }

    return Profile.fromMap(
        await supabase.from('profiles').select().eq('id', uuid).single());
  }

  Future<List<Profile>> getFriends() async {
    final friends =
        await supabase.from('friends').select('friend').eq('user', id);

    List<Profile> profiles = [];

    for (final friend in friends) {
      profiles.add(await Profile.fromId(friend['friend']));
    }

    return profiles;
  }

  Future<List<RoomMeta>> getRooms() async {
    final List<dynamic> rooms =
        await supabase.from('room_participants').select().eq('profile_id', id);
    final List<Room> roomsList =
        await Future.wait(rooms.map((map) => Room.fromId(map['room_id'])));

    return await Future.wait(roomsList.map((e) => RoomMeta.fromRoomId(e.id)));
  }

  Future<FriendStatus> friendStatus(String otherId) async {
    final sentList = await supabase
        .from('friendships')
        .select()
        .eq('profile_id', otherId)
        .eq('friend_id', id)
        .select();

    final sent = sentList.length > 0;

    final recList = await supabase
        .from('friendships')
        .select()
        .eq('profile_id', id)
        .eq('friend_id', otherId)
        .select();

    final received = recList.length > 0;

    if (sent && received) {
      return FriendStatus.friends;
    } else if (sent) {
      return FriendStatus.pendingSent;
    } else if (received) {
      return FriendStatus.pendingReceived;
    } else {
      return FriendStatus.notFriends;
    }
  }

  addFriend() async {
    await supabase.from('friendships').insert({
      'friend_id': id,
      'profile_id': supabase.userId,
    });
  }

  removeFriend() async {
    await supabase
        .from('friendships')
        .delete()
        .eq('friend_id', id)
        .eq('profile_id', supabase.userId);
  }
}

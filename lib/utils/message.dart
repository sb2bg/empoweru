import 'constants.dart';

class Message {
  Message({
    required this.id,
    required this.profileId,
    required this.content,
    required this.read,
    required this.createdAt,
    required this.isMine,
  });

  final String id;
  final String profileId;
  final String content;
  final bool read;
  final DateTime createdAt;
  final bool isMine;

  Message.fromMap({
    required Map<String, dynamic> map,
  })  : id = map['id'],
        profileId = map['profile_id'],
        content = map['content'],
        read = map['read'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = supabase.userId == map['profile_id'];

  static Future<Message> fromId(String id) async {
    final map = await supabase.from('messages').select().eq('id', id).single();
    return Message.fromMap(map: map);
  }

  // TODO: throws if no messages
  static Future<Message?> lastMessageFromRoomId(String id) async {
    return await supabase
        .from('messages')
        .select()
        .eq('room_id', id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle()
        .then((map) => map != null ? Message.fromMap(map: map) : null);
  }

  delete() async {
    await supabase.from('messages').delete().eq('id', id);
  }

  // TODO: RLS does not allow this yet
  markRead() async {
    await supabase.from('messages').update({'read': true}).eq('id', id);
  }

  markUnread() async {
    await supabase.from('messages').update({'read': false}).eq('id', id);
  }

  static create(String user, String contents, String roomId) async {
    await supabase
        .from('messages')
        .insert([
          {
            'profile_id': user,
            'content': contents,
            'room_id': roomId,
          }
        ])
        .select('id')
        .single();
  }

  bool unread() {
    return !read && !isMine;
  }
}

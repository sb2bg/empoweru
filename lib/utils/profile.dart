import 'constants.dart';

class Profile {
  Profile({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String avatarUrl;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'] ?? '', // TODO: remove null check, enforce name in db
        avatarUrl = map['avatar_url'];

  static Future<Profile> fromUuid(String uuid) async {
    return Profile.fromMap(
        await supabase.from('profiles').select().eq('id', uuid).single());
  }
}

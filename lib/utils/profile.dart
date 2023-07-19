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
}

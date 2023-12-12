import 'package:age_sync/utils/constants.dart';

class Organization {
  bool verified;
  final String name;
  final String mission;
  final String type;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String phone;
  final String email;
  final String? website;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String logo;
  final String id;

  Organization({
    required this.verified,
    required this.name,
    required this.mission,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.phone,
    required this.email,
    required this.website,
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.logo,
    required this.id,
  });

  Organization.fromMap(Map<String, dynamic> map)
      : verified = map['verified'],
        name = map['name'],
        mission = map['mission'],
        type = map['type'],
        address = map['address'],
        city = map['city'],
        state = map['state'],
        zip = map['zip'],
        phone = map['phone'],
        email = map['email'],
        website = map['website'],
        facebook = map['facebook'],
        twitter = map['twitter'],
        instagram = map['instagram'],
        logo = map['logo'],
        id = map['id'];

  static Future<Organization> fromId(String uuid) async {
    return Organization.fromMap(
        await supabase.from('organizations').select().eq('id', uuid).single());
  }
}

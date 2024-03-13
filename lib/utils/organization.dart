import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/profile.dart';

class Organization {
  bool verified;
  final String ein;
  final String name;
  final String mission;
  final String type;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String phone;
  final String email;
  final String website;
  final String facebook;
  final String twitter;
  final String instagram;
  final String profileId;
  final String id;

  Future<String> get logo async =>
      (await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', profileId)
          .maybeSingle())?['avatar_url'] ??
      'https://via.placeholder.com/150';

  Organization({
    required this.verified,
    required this.ein,
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
    required this.profileId,
    required this.id,
  });

  Organization.fromMap(Map<String, dynamic> map)
      : verified = map['verified'],
        ein = map['ein'],
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
        profileId = map['profile_id'],
        id = map['id'];

  static Future<Organization> fromId(String uuid) async {
    return Organization.fromMap(
        await supabase.from('organizations').select().eq('id', uuid).single());
  }
}

class OrganizationMeta {
  final Organization organization;
  final Profile profile;

  OrganizationMeta({required this.organization, required this.profile});

  static Future<OrganizationMeta> fromId(String uuid) async {
    final organization = await Organization.fromId(uuid);
    final profile = await Profile.fromId(organization.profileId);

    return OrganizationMeta(organization: organization, profile: profile);
  }
}

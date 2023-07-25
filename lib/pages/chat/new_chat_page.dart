import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/constants.dart';
import '../../utils/profile.dart';
import 'chat_page.dart';

class NewChatPage extends StatefulWidget {
  static const routeName = '/new-chat';

  const NewChatPage({Key? key}) : super(key: key);

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final _searchController = TextEditingController();
  final _friends = <Profile>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final userId = supabase.auth.currentUser!.id;

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

      final List<Profile> friends = await Future.wait([
        ...myFriends.map((map) => Profile.fromUuid(map['friend_id'])),
        ...asFriend.map((map) => Profile.fromUuid(map['profile_id']))
      ]);

      setState(() {
        _friends.addAll(friends);
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search...",
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? preloader
              : Center(
                  child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: _friends.length,
                      itemBuilder: (context, index) {
                        final friend = _friends[index];

                        return FriendEntry(
                          profile: friend,
                        );
                      }),
                ),
        ),
      ],
    ));
  }
}

class FriendEntry extends StatelessWidget {
  const FriendEntry({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(profile.avatarUrl),
          ),
          title: Text(profile.name),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              supabase.rpc('create_new_room', params: {
                'other_user_id': profile.id,
              }).then((value) =>
                  context.pushNamed(ChatPage.routeName, arguments: value));
            },
          )),
    );
  }
}

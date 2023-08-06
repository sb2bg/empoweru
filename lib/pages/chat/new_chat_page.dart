import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/constants.dart';
import '../../utils/profile.dart';
import 'chat_page.dart';

class NewChatPage extends StatefulWidget {
  static const routeName = '/new-chat';

  const NewChatPage({super.key});

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
      final me = await supabase.getCurrentUser();
      final friends = await me.getFriends();

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
            backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
          ),
          title: Text(profile.name),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.pushNamed(ChatPage.routeName, arguments: profile.id);
            },
          )),
    );
  }
}

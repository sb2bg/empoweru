import 'package:age_sync/pages/chat/new_chat_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/profile.dart';
import 'chat_page.dart';

class ViewMessagesPage extends StatefulWidget {
  static const routeName = '/messages';

  const ViewMessagesPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ViewMessagesPage(),
    );
  }

  @override
  State<ViewMessagesPage> createState() => _ViewMessagesPageState();
}

class _ViewMessagesPageState extends State<ViewMessagesPage> {
  late final Stream<List<Profile>> _roomStream;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  _loadRooms() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      _roomStream = supabase
          .from('room_participants')
          .stream(primaryKey: ['room_id'])
          .eq('profile_id', userId)
          .order('created_at')
          .map((maps) =>
              maps.map((map) => Profile.fromMap(map['profile_id'])).toList());
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const NewChatPage(),
            );
          },
        )
      ]),
      body: StreamBuilder(
        stream: _roomStream,
        builder: (context, snapshot) {
          final profiles = snapshot.data ?? [];

          return profiles.isEmpty
              ? const Center(
                  child: Text('You have no messages.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return _MessageEntry(
                      profile: profile,
                      lastText:
                          'Hey!!! I saw u were in town. Wanted to have coffee, are you down?????',
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: profiles.length,
                );
        },
      ),
    );
  }
}

class _MessageEntry extends StatelessWidget {
  const _MessageEntry({Key? key, required this.profile, required this.lastText})
      : super(key: key);

  final Profile profile;
  final String lastText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
        ),
        title: Text(profile.name),
        subtitle: Text(lastText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey)),
      ),
      onTap: () {
        Navigator.of(context).pushNamed(ChatPage.routeName, arguments: profile);
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () {
                    print("TODO");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Block'),
                  onTap: () {
                    print("TODO");
                  },
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            );
          },
        );
      },
    );
  }
}

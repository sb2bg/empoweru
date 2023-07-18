import 'package:flutter/material.dart';

import '../utils/profile.dart';

class ViewMessagesPage extends StatefulWidget {
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
  late final Stream<List<Profile>> _profilesStream;

  @override
  void initState() {
    _profilesStream = Stream.value([
      Profile(
        id: '1',
        name: 'Timothy Dee',
        avatarUrl: 'https://picsum.photos/200',
      ),
      Profile(
        id: '2',
        name: 'Sammy McDaniels',
        avatarUrl: 'https://picsum.photos/200',
      ),
      Profile(
        id: '3',
        name: 'Lime Green',
        avatarUrl: 'https://picsum.photos/200',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: StreamBuilder<List<Profile>>(
          stream: _profilesStream,
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
                            '***REMOVED***',
                      );
                    },
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey[900]),
                    itemCount: profiles.length,
                  );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("TODO");
          },
          child: const Icon(Icons.add),
        ));
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
          backgroundImage: NetworkImage(profile.avatarUrl),
        ),
        title: Text(profile.name),
        subtitle: Text(lastText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey)),
      ),
      onTap: () {
        Navigator.of(context).pushNamed('/chat', arguments: profile);
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
              ],
            );
          },
        );
      },
    );
  }
}

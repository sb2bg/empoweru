import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/message.dart';
import 'package:age_sync/utils/profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.profile,
  });

  final Message message;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine)
        GestureDetector(
          onTap: () => context.pushNamed(ViewAccountPage.routeName,
              arguments: profile.id),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
          ),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine ? Colors.blue[600] : Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short'),
          style: const TextStyle(color: Colors.grey)),
      const SizedBox(width: 60),
    ];

    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }

    final myActions = [
      ListTile(
        leading: const Icon(Icons.delete),
        title: const Text('Delete'),
        onTap: () {
          message.delete();
          context.pop();
        },
      ),
    ];

    final otherActions = [
      ListTile(
        leading: const Icon(Icons.account_circle),
        title: const Text('View profile'),
        onTap: () {
          context.pushNamed(ViewAccountPage.routeName, arguments: profile.id);
        },
      ),
      ListTile(
        leading: const Icon(Icons.report),
        title: const Text('Report Message'),
        onTap: () {
          print('Report message ${message.id}'); // TODO: Report message
          context.pop();
          showReportThankYouDialog(context);
        },
      ),
    ];

    return GestureDetector(
      onLongPress: () {
        context.showMenu(message.isMine ? myActions : otherActions);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(
          mainAxisAlignment:
              message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: chatContents,
        ),
      ),
    );
  }
}

class ChatBubbleReceived extends StatelessWidget {
  const ChatBubbleReceived({
    super.key,
    required this.message,
    required this.profile,
  });

  final Message message;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      GestureDetector(
        onTap: () =>
            context.pushNamed(ViewAccountPage.routeName, arguments: profile.id),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(profile.avatarUrl),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text('${format(message.createdAt, locale: 'en_short')} • ${profile.name}',
          style: const TextStyle(color: Colors.grey)),
      const SizedBox(width: 60),
    ];

    final actions = [
      ListTile(
        leading: const Icon(Icons.delete),
        title: const Text('Delete'),
        onTap: () {
          message.delete();
          context.pop();
        },
      ),
      ListTile(
        leading: const Icon(Icons.account_circle),
        title: const Text('View profile'),
        onTap: () {
          context.pushNamed(ViewAccountPage.routeName, arguments: profile.id);
        },
      ),
      ListTile(
        leading: const Icon(Icons.report),
        title: const Text('Report Message'),
        onTap: () {
          print('Report message ${message.id}'); // TODO: Report message
          context.pop();
          showReportThankYouDialog(context);
        },
      ),
    ];

    return GestureDetector(
      onLongPress: () {
        context.showMenu(actions);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: chatContents,
        ),
      ),
    );
  }
}

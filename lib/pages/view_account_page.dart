import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/profile.dart';

class ViewAccountPage extends StatefulWidget {
  static const routeName = '/view-account';

  const ViewAccountPage({super.key, required this.userId});

  final String userId;

  @override
  State<ViewAccountPage> createState() => _ViewAccountPageState();
}

class _ViewAccountPageState extends LoadingState<ViewAccountPage> {
  late final Profile _profile;

  @override
  Future<void> onInit() async {
    await context.tryDatabaseAsync(() async {
      final profile = await Profile.fromUuid(widget.userId);

      setState(() {
        _profile = profile;
      });
    });
  }

  @override
  AppBar get loadedAppBar => AppBar(
        title: Text(_profile.name),
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Center(
      child: Image(image: CachedNetworkImageProvider(_profile.avatarUrl)),
    );
  }
}

import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class OpportunityPage extends StatefulWidget {
  const OpportunityPage({Key? key}) : super(key: key);

  static const routeName = '/opportunity';

  @override
  State<OpportunityPage> createState() => _OpportunityPageState();
}

class _OpportunityPageState extends LoadingState<OpportunityPage> {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'pbifXGYzYXU',
    flags: YoutubePlayerFlags(
      autoPlay: false,
      mute: true,
    ),
  );

  @override
  onInit() async {}

  @override
  AppBar get constAppBar => AppBar(
        title: const Text('Connect'),
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Introduction to Houston Food Bank',
            style: titleStyle,
          ),
          const SizedBox(height: 10),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            progressColors: ProgressBarColors(
              playedColor: Colors.blueAccent,
              handleColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    ));
  }
}

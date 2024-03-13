import 'package:age_sync/pages/beta_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({Key? key}) : super(key: key);

  static const routeName = '/opportunity';
  static const beta = true;

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends LoadingState<LearningPage> {
  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: 'pbifXGYzYXU',
    flags: const YoutubePlayerFlags(
      autoPlay: false,
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
    if (LearningPage.beta) {
      return const BetaPage();
    }

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

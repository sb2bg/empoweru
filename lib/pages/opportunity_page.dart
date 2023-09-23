import 'package:age_sync/utils/loading_state.dart';
import 'package:flutter/material.dart';

class OpportunityPage extends StatefulWidget {
  const OpportunityPage({Key? key}) : super(key: key);

  static const routeName = '/opportunity';

  @override
  State<OpportunityPage> createState() => _OpportunityPageState();
}

class _OpportunityPageState extends LoadingState<OpportunityPage> {
  @override
  onInit() async {}

  @override
  AppBar get constAppBar => AppBar(
        title: const Text('Connect'),
      );

  @override
  Widget buildLoaded(BuildContext context) {
    return Center(
        child: IntrinsicWidth(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: () {},
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add),
                  label: const Text('Friend Requests'),
                ))
          ],
        ),
      ),
    ));
  }
}

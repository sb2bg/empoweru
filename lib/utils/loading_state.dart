import 'dart:async';

import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/widgets/error_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class LoadingState<T extends StatefulWidget> extends State<T> {
  bool _loading = true;
  bool _error = false;
  final List<StreamSubscription> subscriptions = [];

  setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  @nonVirtual
  initState() {
    super.initState();
    _initStateLogic();
  }

  _initStateLogic() {
    clearSubscriptions(); // clean up old subscriptions if we are reloading

    final start = DateTime.now();

    context.tryDatabaseAsync(
        () => onInit().then((_) {
              setLoading(false);
              afterInit();
              debugPrint(
                  'Loaded ${toString()} in ${DateTime.now().difference(start).inMilliseconds}ms');
            }), onError: (error, stackTrace) {
      setState(() {
        _error = true;
      });

      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
    });
  }

  afterInit() {}

  @override
  void dispose() {
    clearSubscriptions();
    super.dispose();
  }

  void clearSubscriptions() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  }

  Future<void> onInit();
  AppBar? get constAppBar => null;
  AppBar? get loadingAppBar => null;
  AppBar? get loadedAppBar => null;
  Widget? get header => null;
  bool get disableRefresh => false;

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
        appBar: constAppBar ?? (_loading ? loadingAppBar : loadedAppBar),
        body: _error
            ? ErrorPage(error: 'Failed to load page', onRetry: _initStateLogic)
            : Column(
                children: [
                  if (header != null) header!,
                  Expanded(
                    child: _loading ? preloader : buildLoaded(context),
                  ),
                ],
              ));

    return disableRefresh
        ? scaffold
        : RefreshIndicator(
            onRefresh: () async {
              await onInit();
            },
            edgeOffset: MediaQuery.of(context).padding.top,
            child: Stack(
                children: [ListView(), scaffold]), // TODO: fix, doesn't work
          );
  }

  Widget buildLoaded(BuildContext context);
}

import 'package:age_sync/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class LoadingState<T extends StatefulWidget> extends State<T> {
  bool _loading = true;
  bool _error = false;

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  bool get loading => _loading;

  @override
  @nonVirtual
  void initState() {
    super.initState();

    final start = DateTime.now();

    context.tryDatabaseAsync(
        () => onInit().then((_) {
              setLoading(false);
              afterInit();
              debugPrint(
                  'Loaded ${toString()} in ${DateTime.now().difference(start).inMilliseconds}ms');
            }), onError: (error) {
      setState(() {
        _error = true;
      });

      debugPrint(error.toString());
    });
  }

  void afterInit() {}

  Future<void> onInit();
  AppBar? get constAppBar => null;
  AppBar? get loadingAppBar => null;
  AppBar? get loadedAppBar => null;
  Widget? get header => null;

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: constAppBar ?? (_loading ? loadingAppBar : loadedAppBar),
        body: _error
            ? error
            : Column(
                children: [
                  if (header != null) header!,
                  Expanded(
                    child: _loading ? preloader : buildLoaded(context),
                  ),
                ],
              ));
  }

  Widget buildLoaded(BuildContext context);
}

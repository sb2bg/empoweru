import 'package:age_sync/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class LoadingState<T extends StatefulWidget> extends State<T> {
  bool _loading = true;

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  bool get loading => _loading;

  @override
  void initState() {
    super.initState();

    onInit().then((_) => setLoading(false));
  }

  Future<void> onInit();
  AppBar? get constAppBar => null;
  AppBar get loadingAppBar => AppBar();
  AppBar get loadedAppBar => AppBar();

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: constAppBar ?? (_loading ? loadingAppBar : loadedAppBar),
        body: _loading ? preloader : buildLoaded(context));
  }

  Widget buildLoaded(BuildContext context);
}

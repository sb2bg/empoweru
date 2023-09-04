import 'package:age_sync/utils/constants.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key, required this.error, this.onRetry})
      : super(key: key);

  final String error;
  final Function()? onRetry;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  bool _retrying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _retrying
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.error,
                      style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  TextButton.icon(
                      icon: Icon(widget.onRetry == null
                          ? Icons.arrow_back
                          : Icons.refresh),
                      onPressed: () async {
                        setState(() {
                          _retrying = true;
                        });

                        final time = DateTime.now();

                        if (widget.onRetry != null) {
                          widget.onRetry!();
                        } else {
                          context.pop();
                          return;
                        }

                        // Wait at least 500ms
                        if (DateTime.now().difference(time).inMilliseconds <
                            500) {
                          await Future.delayed(Duration(
                              milliseconds: 500 -
                                  DateTime.now()
                                      .difference(time)
                                      .inMilliseconds));
                        }

                        setState(() {
                          _retrying = false;
                        });
                      },
                      label:
                          Text(widget.onRetry == null ? 'Go back' : 'Retry')),
                ],
              ),
      ),
    );
  }
}

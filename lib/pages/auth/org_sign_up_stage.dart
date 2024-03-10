import 'package:age_sync/widgets/password_text_field.dart';
import 'package:age_sync/widgets/sliding_text.dart';
import 'package:flutter/material.dart';

class FieldInfo {
  const FieldInfo(this.label, this.icon, this.validator,
      {this.textInputType = TextInputType.text, this.password = false});

  final String label;
  final IconData icon;
  final TextInputType textInputType;
  final bool password;
  final String? Function(String) validator;
}

class OrgStage extends StatefulWidget {
  OrgStage({
    super.key,
    required this.title,
    this.subtitle,
    required this.fields,
    required this.parentSetState,
    required this.submitted,
  }) {
    for (var i = 0; i < fields.length; i++) {
      controllers.add(TextEditingController());
    }
  }

  final String title;
  final String? subtitle;
  final List<FieldInfo> fields;
  final List<TextEditingController> controllers = [];
  final Function() parentSetState;
  final ValueNotifier<bool> submitted;

  bool get isValid {
    return controllers.every((controller) {
      return fields[controllers.indexOf(controller)]
              .validator(controller.text) ==
          null;
    });
  }

  @override
  State<OrgStage> createState() => _OrgStageState();
}

class _OrgStageState extends State<OrgStage> {
  late final List<String?> _errors;
  bool _showErrors = false;

  onSubmitted() {
    showErrors();
  }

  @override
  initState() {
    super.initState();

    _errors = List.filled(widget.fields.length, null);
    checkValidators();

    widget.submitted.addListener(onSubmitted);
  }

  showErrors() {
    if (widget.isValid) {
      return;
    }

    setState(() {
      _showErrors = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _showErrors = false;
      });

      widget.submitted.value = false;
    });
  }

  @override
  dispose() {
    widget.submitted.removeListener(onSubmitted);
    super.dispose();
  }

  checkValidators() {
    setState(() {
      for (var i = 0; i < _errors.length; i++) {
        _errors[i] = widget.fields[i].validator(widget.controllers[i].text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 20)),
                if (widget.subtitle != null)
                  Text(widget.subtitle!, style: const TextStyle(fontSize: 16)),
              ],
            ),
          )),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.fields.length,
            itemBuilder: (context, index) {
              final field = widget.fields[index];
              final controller = widget.controllers[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    field.password
                        ? PasswordTextField(
                            controller: controller,
                          )
                        : TextField(
                            keyboardType: field.textInputType,
                            onChanged: (value) {
                              checkValidators();
                              widget.parentSetState();
                            },
                            controller: widget
                                .controllers[widget.fields.indexOf(field)],
                            decoration: InputDecoration(
                              hintText: field.label,
                              prefixIcon: Icon(field.icon),
                              suffixIcon: Icon(
                                  _errors[widget.fields.indexOf(field)] == null
                                      ? Icons.check
                                      : Icons.error_outline,
                                  color:
                                      _errors[widget.fields.indexOf(field)] ==
                                              null
                                          ? Colors.green
                                          : Colors.red),
                            )),
                    if (_errors[widget.fields.indexOf(field)] != null &&
                        _showErrors)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: SlidingText(
                            word: _errors[widget.fields.indexOf(field)]!,
                            interval: 250,
                            style: const TextStyle(color: Colors.red)),
                      )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

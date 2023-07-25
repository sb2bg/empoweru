import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({super.key, required this.controller, this.hintText});

  final TextEditingController controller;
  final String? hintText;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  String get _hintText => widget.hintText ?? 'Password';

  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: _hintText,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: toggle,
          ),
          prefixIcon: const Icon(Icons.lock),
        ),
        controller: widget.controller,
        keyboardType: TextInputType.visiblePassword);
  }
}

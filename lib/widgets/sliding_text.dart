import 'package:flutter/material.dart';

class SlidingText extends StatefulWidget {
  final String word;
  final int interval;
  final TextStyle style;

  const SlidingText(
      {super.key,
      required this.word,
      required this.interval,
      required this.style});

  @override
  State<SlidingText> createState() => _SlidingTextState();
}

class _SlidingTextState extends State<SlidingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animControllerSlideIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();

    _animControllerSlideIn = AnimationController(
        duration: Duration(milliseconds: widget.interval), vsync: this);

    _slideIn =
        Tween<Offset>(begin: const Offset(1.1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animControllerSlideIn, curve: Curves.easeOut));

    _animControllerSlideIn.forward();
  }

  @override
  void dispose() {
    _animControllerSlideIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideIn,
      child: Text(widget.word, style: widget.style),
    );
  }
}

import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  static const routeName = '/intro';

  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Image.asset(
            'assets/images/logo.png',
            width: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'A simple task manager',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    ));
  }
}

import 'package:age_sync/pages/account_page.dart';
import 'package:age_sync/pages/login_page.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;

    if (session != null) {
      Navigator.of(context).pushReplacementNamed(AccountPage.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

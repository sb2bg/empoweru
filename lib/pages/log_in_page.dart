import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/auth/facebook.dart';
import '../supabase/auth/google.dart';
import '../utils/constants.dart';
import 'account_page.dart';
import 'email_log_in_page.dart';
import 'email_sign_up_page.dart';

enum LogInType {
  signUp('Sign up', LogInPage.signUpRouteName),
  signIn('Log in', LogInPage.logInRouteName);

  const LogInType(this.title, this.routeName);

  final String title;
  final String routeName;

  LogInType alternate() {
    return this == LogInType.signUp ? LogInType.signIn : LogInType.signUp;
  }
}

class LogInPage extends StatefulWidget {
  const LogInPage({super.key, required this.type});

  final LogInType type;
  static const String logInRouteName = '/login';
  static const String signUpRouteName = '/sign-up';

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final String _title;

  late final StreamSubscription<AuthState> _authStateSubscription;

  _signIn(Function() signInMethod) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await signInMethod();
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } on PlatformException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message!),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _title = widget.type.title;

    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;

      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed(AccountPage.routeName);
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_title,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold)),
                const Text('to continue to AgeSync'),
                const SizedBox(height: 16),
                IntrinsicWidth(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _signIn(signInWithGoogle),
                        child: Text(
                            _isLoading ? 'Loading' : '$_title with Google'),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _signIn(signInWithFacebook),
                        child: Text(
                            _isLoading ? 'Loading' : '$_title with Facebook'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black),
                        onPressed: () => Navigator.of(context).pushNamed(
                            widget.type == LogInType.signUp
                                ? EmailSignUpPage.routeName
                                : EmailLogInPage.routeName),
                        child:
                            Text(_isLoading ? 'Loading' : '$_title with Email'),
                      ),
                      Row(
                        children: [
                          Text(
                              widget.type == LogInType.signUp
                                  ? 'Already have an account?'
                                  : 'Don\'t have an account?',
                              style: const TextStyle(fontSize: 16)),
                          TextButton(
                            onPressed: () {
                              context.popOrPushNamed(
                                  widget.type.alternate().routeName);
                            },
                            child: Text(
                              widget.type.alternate().title,
                            ),
                          )
                        ],
                      )
                    ])),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ));
  }
}

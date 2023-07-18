import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/auth/facebook.dart';
import '../supabase/auth/google.dart';
import '../utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _redirecting = false;

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
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;

      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });

    super.initState();
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
          title: const Text('Sign In'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Sign in',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                            _isLoading ? 'Loading' : 'Sign in with Google'),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _signIn(signInWithFacebook),
                        child: Text(
                            _isLoading ? 'Loading' : 'Sign in with Facebook'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black),
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/email-sign-up'),
                        child:
                            Text(_isLoading ? 'Loading' : 'Sign in with Email'),
                      ),
                      Row(
                        children: [
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/sign-up');
                            },
                            child: const Text('Sign up'),
                          )
                        ],
                      )
                    ]))
              ],
            ),
          ),
        ));
  }
}

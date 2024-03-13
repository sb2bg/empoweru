import 'package:age_sync/pages/auth/org_sign_up_page.dart';
import 'package:age_sync/pages/privacy_policy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../supabase/auth/facebook.dart';
import '../../supabase/auth/google.dart';
import '../../utils/constants.dart';
import '../auth/email_log_in_page.dart';
import '../auth/email_sign_up_page.dart';

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
  late final String _title;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_title,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      const Text('to continue to EmpowerU'),
                      const SizedBox(height: 16),
                      IntrinsicWidth(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _signIn(signInWithGoogle),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/images/google.png',
                                      height: 20),
                                  SizedBox(
                                    width: 150,
                                    child: Text(_isLoading
                                        ? 'Loading'
                                        : '$_title with Google'),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _signIn(signInWithFacebook),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset('assets/images/facebook.png',
                                      height: 20),
                                  SizedBox(
                                    width: 150,
                                    child: Text(_isLoading
                                        ? 'Loading'
                                        : '$_title with Facebook'),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black),
                              onPressed: () => _isLoading
                                  ? null
                                  : context.pushNamed(
                                      widget.type == LogInType.signUp
                                          ? EmailSignUpPage.routeName
                                          : EmailLogInPage.routeName),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.email),
                                  SizedBox(
                                      width: 150,
                                      child: Text(_isLoading
                                          ? 'Loading'
                                          : '$_title with Email')),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black),
                              onPressed: () => _isLoading
                                  ? null
                                  : widget.type == LogInType.signUp
                                      ? context
                                          .pushNamed(OrgSignUpPage.routeName)
                                      : context.pushNamed(
                                          EmailLogInPage.routeName,
                                          arguments: OrgSignUpPage.routeName),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.business),
                                  SizedBox(
                                      width: 150,
                                      child: Text(_isLoading
                                          ? 'Loading'
                                          : 'For organizations')),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    widget.type == LogInType.signUp
                                        ? 'Already have an account?'
                                        : 'Don\'t have an account?',
                                    style: const TextStyle(fontSize: 16)),
                                TextButton(
                                  onPressed: () {
                                    context.pushNamed(
                                        widget.type.alternate().routeName);
                                  },
                                  child: Text(
                                    widget.type.alternate().title,
                                  ),
                                )
                              ],
                            ),
                          ])),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('© ${DateTime.now().year} EmpowerU'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () =>
                      context.pushNamed(PrivacyPolicyPage.routeName),
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ));
  }
}

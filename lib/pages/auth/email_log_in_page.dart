import 'package:age_sync/pages/auth/email_sign_up_page.dart';
import 'package:age_sync/supabase/auth/email.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/widgets/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailLogInPage extends StatefulWidget {
  static const routeName = '/email-log-in';

  const EmailLogInPage({super.key});

  @override
  State<EmailLogInPage> createState() => _EmailLogInPageState();
}

class _EmailLogInPageState extends State<EmailLogInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  // TODO: deduplicate this code from lib/pages/login_page.dart
  _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await signInWithEmail(_emailController.text, _passwordController.text);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in'), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 8),
            PasswordTextField(controller: _passwordController),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: _isLoading ? null : () => print("TODO"),
                          child: const Text('Forgot Password?')),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        child: const Text('Sign In'),
                      ),
                    ]),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => context.pushNamed(EmailSignUpPage.routeName),
                    child: const Text('Sign Up'))
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

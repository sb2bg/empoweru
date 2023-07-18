import 'package:age_sync/pages/account_page.dart';
import 'package:age_sync/pages/chat_page.dart';
import 'package:age_sync/pages/email_sign_up_page.dart';
import 'package:age_sync/pages/login_page.dart';
import 'package:age_sync/pages/splash.dart';
import 'package:age_sync/pages/view_messages.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authFlowType: AuthFlowType.pkce,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

    return MaterialApp(
      title: 'Home',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/account': (_) => const AccountPage(),
        '/messages': (_) => const ViewMessagesPage(),
        '/chat': (context) => ChatPage(profileId: "1"),
        '/email-sign-up': (_) => const EmailSignUpPage(),
      },
    );
  }
}

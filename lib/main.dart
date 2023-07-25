import 'package:age_sync/pages/account_page.dart';
import 'package:age_sync/pages/chat/chat_page.dart';
import 'package:age_sync/pages/chat/new_chat_page.dart';
import 'package:age_sync/pages/chat/view_messages.dart';
import 'package:age_sync/pages/email_log_in_page.dart';
import 'package:age_sync/pages/email_sign_up_page.dart';
import 'package:age_sync/pages/log_in_page.dart';
import 'package:age_sync/pages/splash.dart';
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
        navigatorObservers: [navObserver],
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          dividerTheme: DividerThemeData(
            color: Colors.grey[900],
          ),
          listTileTheme: ListTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            prefixIconColor: Colors.grey[600],
            suffixIconColor: Colors.grey[600],
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          var routes = <String, WidgetBuilder>{
            SplashPage.routeName: (_) => const SplashPage(),
            LogInPage.logInRouteName: (_) =>
                const LogInPage(type: LogInType.signIn),
            LogInPage.signUpRouteName: (_) =>
                const LogInPage(type: LogInType.signUp),
            AccountPage.routeName: (_) => const AccountPage(),
            ViewMessagesPage.routeName: (_) => const ViewMessagesPage(),
            ChatPage.routeName: (_) =>
                ChatPage(roomId: settings.arguments as String),
            EmailLogInPage.routeName: (_) => const EmailLogInPage(),
            EmailSignUpPage.routeName: (_) => const EmailSignUpPage(),
            NewChatPage.routeName: (_) => const NewChatPage(),
          };

          WidgetBuilder builder = routes[settings.name]!;
          return MaterialPageRoute(
              builder: (ctx) => builder(ctx), settings: settings);
        });
  }
}

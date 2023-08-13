import 'package:age_sync/pages/account_page.dart';
import 'package:age_sync/pages/calendar_page.dart';
import 'package:age_sync/pages/chat/chat_page.dart';
import 'package:age_sync/pages/chat/new_chat_page.dart';
import 'package:age_sync/pages/chat/view_messages.dart';
import 'package:age_sync/pages/email_log_in_page.dart';
import 'package:age_sync/pages/email_sign_up_page.dart';
import 'package:age_sync/pages/error_page.dart';
import 'package:age_sync/pages/friend_page.dart';
import 'package:age_sync/pages/log_in_page.dart';
import 'package:age_sync/pages/splash.dart';
import 'package:age_sync/pages/task_page.dart';
import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authFlowType: AuthFlowType.pkce,
  );

  runApp(const MyApp());
}

WidgetBuilder getRoute(String routeName, RouteSettings settings) {
  return <String, WidgetBuilder>{
        SplashPage.routeName: (_) => const SplashPage(),
        LogInPage.logInRouteName: (_) =>
            const LogInPage(type: LogInType.signIn),
        LogInPage.signUpRouteName: (_) =>
            const LogInPage(type: LogInType.signUp),
        AccountPage.routeName: (_) => const AccountPage(),
        ViewAccountPage.routeName: (_) {
          final userId = settings.arguments as String;

          if (userId == supabase.userId) {
            return const AccountPage();
          }

          return ViewAccountPage(userId: userId);
        },
        ViewMessagesPage.routeName: (_) => const ViewMessagesPage(),
        ChatPage.routeName: (_) =>
            ChatPage(otherId: settings.arguments as String),
        EmailLogInPage.routeName: (_) => const EmailLogInPage(),
        EmailSignUpPage.routeName: (_) => const EmailSignUpPage(),
        NewChatPage.routeName: (_) => const NewChatPage(),
        TaskPage.routeName: (_) => const TaskPage(),
        FriendPage.routeName: (_) => const FriendPage(),
        CalendarPage.routeName: (_) => const CalendarPage(),
      }[routeName] ??
      (_) => const ErrorPage(error: 'Route not found');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final PersistentTabController _controller;

  @override
  initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;

    return GlobalLoaderOverlay(
        child: MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [navObserver],
      themeMode: ThemeMode.dark,
      darkTheme: themeData,
      initialRoute: '/',
      home: supabase.auth.currentSession != null
          ? PersistentTabView(
              context,
              controller: _controller,
              screens: generateScreens(),
              items: generateNavBarItems(),
              backgroundColor: Colors.grey[900]!,
              navBarStyle: NavBarStyle.style3,
            )
          : const LogInPage(type: LogInType.signIn),
    ));
  }

  PersistentBottomNavBarItem _generateNavBarItem(
      {required String title, required IconData icon}) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon),
      title: title,
      activeColorPrimary: themeData.colorScheme.primary,
      inactiveColorPrimary: Colors.grey,
    );
  }

  List<PersistentBottomNavBarItem> generateNavBarItems() {
    return [
      _generateNavBarItem(title: 'Messages', icon: Icons.message),
      _generateNavBarItem(title: 'Friends', icon: Icons.people),
      _generateNavBarItem(title: 'Tasks', icon: Icons.task),
      _generateNavBarItem(title: 'Events', icon: Icons.calendar_today),
      _generateNavBarItem(title: 'Account', icon: Icons.account_circle),
      // _generateNavBarItem(title: 'DEBUG SIGN IN', icon: Icons.account_circle)
    ];
  }

  List<Widget> generateScreens() {
    return [
      const ViewMessagesPage(),
      const FriendPage(),
      const TaskPage(),
      const CalendarPage(),
      const AccountPage(),
      // const LogInPage(type: LogInType.signIn),
    ];
  }
}

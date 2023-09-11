import 'package:age_sync/pages/account_page.dart';
import 'package:age_sync/pages/admin/admin_page.dart';
import 'package:age_sync/pages/calendar_page.dart';
import 'package:age_sync/pages/chat/chat_page.dart';
import 'package:age_sync/pages/chat/spectate_room_page.dart';
import 'package:age_sync/pages/chat/view_messages.dart';
import 'package:age_sync/pages/email_log_in_page.dart';
import 'package:age_sync/pages/email_sign_up_page.dart';
import 'package:age_sync/pages/friend_page.dart';
import 'package:age_sync/pages/intro_page.dart';
import 'package:age_sync/pages/log_in_page.dart';
import 'package:age_sync/pages/new_task_page.dart';
import 'package:age_sync/pages/task_page.dart';
import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/task.dart';
import 'package:age_sync/widgets/error_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:badges/badges.dart' as badges;

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authFlowType: AuthFlowType.pkce,
  );

  prefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

WidgetBuilder getRoute(String routeName, RouteSettings settings) {
  return <String, WidgetBuilder>{
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
        TaskPage.routeName: (_) => const TaskPage(),
        FriendPage.routeName: (_) => const FriendPage(),
        CalendarPage.routeName: (_) => const CalendarPage(),
        NewTaskPage.routeName: (_) =>
            NewTaskPage(tasks: settings.arguments as List<Task>),
        AdminPage.routeName: (_) => const AdminPage(),
        SpectateChatRoomPage.routeName: (_) =>
            SpectateChatRoomPage(roomId: settings.arguments as String),
      }[routeName] ??
      (_) => const ErrorPage(error: 'Route not found');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PersistentTabController _controller = PersistentTabController(
      initialIndex:
          4); // TODO: change to 0 when we have a home page (not account page)
  String? _textNotiCount;
  bool newUser = prefs.getBool(PrefKeys.newUser.key) ?? false;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        supabase.invalidateCache();
      }

      setState(() {});
      prefs.setBool(PrefKeys.newUser.key, false);
    });

    // TODO: optimize? plpgsql function?
    supabase
        .getCurrentUser()
        .then((profile) => profile.getRooms().then((rooms) {
              int count = 0;

              for (var room in rooms) {
                if (room.unread()) {
                  count++;
                }
              }

              if (count > 0) {
                setState(() {
                  _textNotiCount = count.toString();
                });
              }
            }));
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
          ? newUser
              ? const IntroPage()
              : PersistentTabView(
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
      {required String title, required IconData icon, String? badgeText}) {
    return PersistentBottomNavBarItem(
      icon: badgeText != null
          ? badges.Badge(
              badgeContent: Text(badgeText),
              child: Icon(icon),
            )
          : Icon(icon),
      title: title,
      activeColorPrimary: themeData.colorScheme.primary,
      inactiveColorPrimary: Colors.grey,
    );
  }

  List<PersistentBottomNavBarItem> generateNavBarItems() {
    return [
      _generateNavBarItem(
        title: 'Messages',
        icon: Icons.message,
        badgeText: _textNotiCount,
      ),
      _generateNavBarItem(title: 'Friends', icon: Icons.people),
      _generateNavBarItem(title: 'Tasks', icon: Icons.task),
      _generateNavBarItem(title: 'Events', icon: Icons.calendar_today),
      _generateNavBarItem(title: 'Account', icon: Icons.account_circle),
    ];
  }

  List<Widget> generateScreens() {
    return [
      const ViewMessagesPage(),
      const FriendPage(),
      const TaskPage(),
      const CalendarPage(),
      const AccountPage(),
    ];
  }
}

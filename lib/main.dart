import 'dart:async';
import 'dart:collection';

import 'package:age_sync/pages/account_page.dart';
import 'package:age_sync/pages/admin/admin_page.dart';
import 'package:age_sync/pages/approve_org_page.dart';
import 'package:age_sync/pages/auth/org_sign_up_page.dart';
import 'package:age_sync/pages/learning_page.dart';
import 'package:age_sync/pages/opportunity_page.dart';
import 'package:age_sync/pages/org_dashboard.dart';
import 'package:age_sync/pages/privacy_policy_page.dart';
import 'package:age_sync/pages/settings_page.dart';
import 'package:age_sync/pages/task/calendar_page.dart';
import 'package:age_sync/pages/chat/chat_page.dart';
import 'package:age_sync/pages/chat/spectate_room_page.dart';
import 'package:age_sync/pages/chat/view_messages.dart';
import 'package:age_sync/pages/auth/email_log_in_page.dart';
import 'package:age_sync/pages/auth/email_sign_up_page.dart';
import 'package:age_sync/pages/friend_page.dart';
import 'package:age_sync/pages/intro_page.dart';
import 'package:age_sync/pages/auth/log_in_page.dart';
import 'package:age_sync/pages/task/new_task_page.dart';
import 'package:age_sync/pages/task/task_page.dart';
import 'package:age_sync/pages/view_account_page.dart';
import 'package:age_sync/utils/chat/message.dart';
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/organization.dart';
import 'package:age_sync/utils/profile.dart';
import 'package:age_sync/widgets/error_page.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
          final user = settings.arguments as Profile;

          if (user.id == supabase.userId) {
            return const AccountPage();
          }

          return ViewAccountPage(user: user);
        },
        ViewMessagesPage.routeName: (_) => const ViewMessagesPage(),
        ChatPage.routeName: (_) =>
            ChatPage(other: settings.arguments as Profile),
        EmailLogInPage.routeName: (_) => settings.arguments == null
            ? const EmailLogInPage()
            : EmailLogInPage(redirectRoute: settings.arguments as String),
        EmailSignUpPage.routeName: (_) => const EmailSignUpPage(),
        TaskPage.routeName: (_) => const TaskPage(),
        FriendPage.routeName: (_) => const FriendPage(),
        CalendarPage.routeName: (_) => const CalendarPage(),
        NewTaskPage.routeName: (_) => NewTaskPage(
            start: settings.arguments as DateTime? ?? DateTime.now()),
        AdminPage.routeName: (_) => const AdminPage(),
        SpectateChatRoomPage.routeName: (_) =>
            SpectateChatRoomPage(roomId: settings.arguments as String),
        LearningPage.routeName: (_) => const LearningPage(),
        SettingsPage.routeName: (_) => const SettingsPage(),
        OrgSignUpPage.routeName: (_) => const OrgSignUpPage(),
        ApproveOrgPage.routeName: (_) =>
            ApproveOrgPage(org: settings.arguments as OrganizationMeta),
        OrganizationDashboard.routeName: (_) => const OrganizationDashboard(),
        PrivacyPolicyPage.routeName: (_) => const PrivacyPolicyPage(),
      }[routeName] ??
      (_) => const ErrorPage(error: 'Route not found');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _newUser = prefs.getBool(PrefKeys.newUser.key) ?? true;
  bool _loggedIn() => supabase.auth.currentSession != null;

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
      home: Home(loggedIn: _loggedIn(), newUser: _newUser),
    ));
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.loggedIn,
    this.newUser = false,
  });

  final bool loggedIn;
  final bool newUser;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends LoadingState<Home> {
  late Profile? _me;
  late PersistentTabController _controller;
  late ConnectivityResult _result;
  late StreamSubscription<ConnectivityResult> _subscription;
  StreamSubscription<HashMap<String, List<Message>>>? _unreadSub;
  int _unread = 0;

  @override
  bool get bare => true;

  @override
  Future<void> onInit() async {
    final connectivity = Connectivity();
    _result = await connectivity.checkConnectivity();

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _result = result;
      });
    });

    _me = widget.loggedIn ? await supabase.getCurrentUser() : null;

    final navScreens =
        _generateScreens(_me); // just to get the length (hacky, I know)
    _controller = PersistentTabController(initialIndex: navScreens.length - 1);

    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        supabase.invalidateCache();
        _unreadSub?.cancel();
        _unread = 0;
      }

      if (event == AuthChangeEvent.signedIn) {
        loadControllers();
        unreadUpdater();
      }

      setState(() {});
      prefs.setBool(PrefKeys.newUser.key, false);
    });
  }

  void unreadUpdater() {
    _unreadSub = streamControllers.messageStream.listen((event) async {
      int unread = 0;

      for (final messages in event.values) {
        final last = messages.first;

        if (last.unread) {
          unread++;
        }
      }

      setState(() {
        _unread = unread;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    _unreadSub?.cancel();
    super.dispose();
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

  List<PersistentBottomNavBarItem> _generateNavBarItems(Profile? user) {
    return [
      _generateNavBarItem(title: 'Learning', icon: Icons.school),
      user != null && user.organization
          ? _generateNavBarItem(title: 'Recruit', icon: Icons.person)
          : _generateNavBarItem(
              title: 'Opportunities', icon: Icons.calendar_today),
      _generateNavBarItem(
          title: 'Messages',
          icon: Icons.message,
          badgeText: _unread > 0 ? _unread.toString() : null),
      _generateNavBarItem(title: 'Tasks', icon: Icons.calendar_today),
      _generateNavBarItem(title: 'Account', icon: Icons.account_circle),
    ];
  }

  List<Widget> _generateScreens(Profile? user) {
    return [
      const LearningPage(),
      user != null && user.organization
          ? const OpportunityPage() // TODO: replace with RecruitPage
          : const OpportunityPage(),
      const ViewMessagesPage(),
      const TaskPage(),
      const AccountPage(),
    ];
  }

  @override
  Widget buildLoaded(BuildContext context) {
    return _result == ConnectivityResult.none
        ? ErrorPage(error: 'No internet connection', onRetry: () {})
        : widget.loggedIn
            ? widget.newUser
                ? const IntroPage()
                : PersistentTabView(
                    context,
                    controller: _controller,
                    screens: _generateScreens(_me),
                    items: _generateNavBarItems(_me),
                    backgroundColor: Colors.grey[900]!,
                    navBarStyle: NavBarStyle.style3,
                  )
            : const LogInPage(type: LogInType.signIn);
  }
}

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
import 'package:age_sync/utils/constants.dart';
import 'package:age_sync/utils/loading_state.dart';
import 'package:age_sync/utils/organization.dart';
import 'package:age_sync/utils/profile.dart';
import 'package:age_sync/widgets/error_page.dart';
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
  final newUser = prefs.getBool(PrefKeys.newUser.key) ?? true;
  bool loggedIn() => supabase.auth.currentSession != null;
  int unread = 0;

  void unreadUpdater() {
    streamControllers.roomStream.listen((event) {
      setState(() {
        unread = event.where((room) => room.lastMessage?.unread == true).length;
      });
    });
  }

  @override
  void initState() {
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        supabase.invalidateCache();
      }

      if (event == AuthChangeEvent.signedIn) {
        loadControllers();
        unreadUpdater();
      }

      setState(() {});
      prefs.setBool(PrefKeys.newUser.key, false);
    });

    super.initState();
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
      home: Home(loggedIn: loggedIn(), newUser: newUser, unread: unread),
    ));
  }
}

class Home extends StatefulWidget {
  const Home(
      {super.key,
      required this.loggedIn,
      this.newUser = false,
      required this.unread});

  final bool loggedIn;
  final bool newUser;
  final int unread;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends LoadingState<Home> {
  late PersistentTabController _controller;
  List<Widget> _navScreens = [];
  List<PersistentBottomNavBarItem> _navItems = [];

  @override
  bool get bare => true;

  @override
  void dispose() {
    _controller.dispose();
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

  Future<List<PersistentBottomNavBarItem>> generateNavBarItems(
      Profile user) async {
    return [
      _generateNavBarItem(title: 'Learning', icon: Icons.school),
      if (!user.organization)
        _generateNavBarItem(title: 'Opportunities', icon: Icons.business),
      _generateNavBarItem(
          title: 'Messages',
          icon: Icons.message,
          badgeText: widget.unread > 0 ? widget.unread.toString() : null),
      _generateNavBarItem(title: 'Tasks', icon: Icons.calendar_today),
      _generateNavBarItem(title: 'Account', icon: Icons.account_circle),
    ];
  }

  Future<List<Widget>> generateScreens(Profile user) async {
    return [
      const LearningPage(),
      if (!user.organization) const OpportunityPage(),
      const ViewMessagesPage(),
      const TaskPage(),
      const AccountPage(),
    ];
  }

  @override
  Future<void> onInit() async {
    Profile me = await supabase.getCurrentUser();

    _navScreens = await generateScreens(me);
    _navItems = await generateNavBarItems(me);
    _controller = PersistentTabController(initialIndex: _navScreens.length - 1);
  }

  @override
  Widget buildLoaded(BuildContext context) {
    return widget.loggedIn
        ? widget.newUser
            ? const IntroPage()
            : PersistentTabView(
                context,
                controller: _controller,
                screens: _navScreens,
                items: _navItems,
                backgroundColor: Colors.grey[900]!,
                navBarStyle: NavBarStyle.style3,
              )
        : const LogInPage(type: LogInType.signIn);
  }
}

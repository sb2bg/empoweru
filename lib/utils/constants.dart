import 'package:age_sync/utils/chat/message_controller.dart';
import 'package:age_sync/utils/profile.dart';
import 'package:age_sync/utils/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import 'observer.dart';

const supabaseUrl = 'https://xtxynmkzjewotpmxxxvy.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0eHlubWt6amV3b3RwbXh4eHZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg4MDAxNzAsImV4cCI6MjAwNDM3NjE3MH0.dHo4Jcnjx2xLuTRXWdWqQByAn6G-1DL6bqPQ5lplyZA';
const iosClientId =
    '585037508158-uh107osoinaus299vu9vb9kcuav3ev0q.apps.googleusercontent.com';
const defaultAvatarUrl =
    'https://xtxynmkzjewotpmxxxvy.supabase.co/storage/v1/object/public/avatars/default_avatar.jpg';

final supabase = Supabase.instance.client;
late final SharedPreferences prefs;
final CustomRouteObserver navObserver = CustomRouteObserver();
const preloader = Scaffold(body: Center(child: CircularProgressIndicator()));
const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const subtitleStyle = TextStyle(fontSize: 16);
const metaStyle = TextStyle(fontSize: 12, color: Colors.grey);
const whiteMetaStyle = TextStyle(fontSize: 12, color: Colors.white);
const unexpectedErrorMessage = 'Unexpected error occurred.';

late final TaskController taskController;
late final MessageController messageController;

bool controllersLoaded = false;

loadControllers() {
  if (controllersLoaded) {
    return;
  }

  taskController = TaskController();
  messageController = MessageController();

  controllersLoaded = true;
}

Brightness get deviceTheme =>
    SchedulerBinding.instance.platformDispatcher.platformBrightness;

enum PrefKeys {
  newUser('new_user'),
  theme('theme'),
  language('language');

  final String key;

  const PrefKeys(this.key);
}

showReportThankYouDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Report Received'),
            content: const Text(
                'We will review this message and take appropriate action. Thank you for helping us keep EmpowerU safe.'),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('OK'),
              ),
            ],
          ));
}

extension Confirmation on BuildContext {
  Future<bool> confirmation(String action) async {
    Future<bool> future = Future.value(false);

    await showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Are you sure you want to $action?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              future = Future.value(true);
              context.pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return future;
  }

  typeConfirmationDialog(
      {required String title,
      required String content,
      required Function() onConfirm,
      required String confirmText}) {
    String? typed;

    showDialog(
      context: this,
      builder: (context) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Type "$confirmText" to confirm',
                ),
                onChanged: (value) {
                  typed = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (confirmText.toLowerCase() == typed?.toLowerCase()) {
                  onConfirm();
                  context.pop();
                } else {
                  context.showErrorSnackBar(message: 'Incorrect text');
                }
              },
              child: const Text('Confirm'),
            ),
          ]),
    );
  }
}

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}

extension Navigate on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  Future<void> pushNamed(String routeName,
      {Object? arguments, bool withNavBar = false}) async {
    Route? previousRoute = navObserver.previousRoute;
    RouteSettings routeSettings =
        RouteSettings(arguments: arguments, name: routeName);

    WidgetBuilder builder = getRoute(routeName, routeSettings);
    Widget widget = builder(this);

    if (!navigator.canPop() || previousRoute == null) {
      await PersistentNavBarNavigator.pushNewScreenWithRouteSettings(this,
          screen: widget, settings: routeSettings, withNavBar: withNavBar);
      navObserver.push(CustomRoute(settings: routeSettings));
      return;
    }

    if (previousRoute.settings.name == routeName) {
      pop();
    } else {
      await PersistentNavBarNavigator.pushNewScreenWithRouteSettings(this,
          screen: widget, settings: routeSettings, withNavBar: withNavBar);
      navObserver.push(CustomRoute(settings: routeSettings));
    }
  }

  void pop() {
    navigator.pop();
  }
}

extension DatabaseQuery on BuildContext {
  tryDatabase(Function() func,
      {Function(Object)? onError, Function()? onDone}) {
    try {
      func();
    } on PostgrestException catch (error) {
      showErrorSnackBar(message: error.message);
      onError?.call(error);
    } catch (error) {
      showErrorSnackBar(message: unexpectedErrorMessage);
      onError?.call(error);
    } finally {
      onDone?.call();
    }
  }

  Future<void> tryDatabaseAsync(Future<void> Function() func,
      {Function(Object, StackTrace)? onError, Function()? onDone}) async {
    try {
      await func();
    } on PostgrestException catch (error, stackTrace) {
      showErrorSnackBar(message: error.message);
      onError?.call(error, stackTrace);
    } catch (error, stackTrace) {
      showErrorSnackBar(message: unexpectedErrorMessage);
      onError?.call(error, stackTrace);
    } finally {
      onDone?.call();
    }
  }
}

extension Show on BuildContext {
  showMenu(List<ListTile> tiles) {
    showModalBottomSheet(
      context: this,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: tiles,
        ),
      ),
    );
  }

  showConfirmationDialog(
      {String? title,
      String? message,
      String? cancelText,
      String? confirmText,
      Function()? onCancel,
      Function()? onConfirm}) {
    showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: message != null ? Text(message) : null,
        contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
        actions: [
          TextButton(
            onPressed: () {
              onCancel?.call();
              context.pop();
            },
            child: Text(cancelText ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm?.call();
              context.pop();
            },
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
  }
}

Profile? cachedProfile;
DateTime? lastProfileFetch;

extension CurrentUser on SupabaseClient {
  Future<Profile> getCurrentUser() async {
    if (cachedProfile != null &&
        lastProfileFetch != null &&
        DateTime.now().difference(lastProfileFetch!).inMinutes < 5) {
      return cachedProfile!;
    }

    var currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final id = currentUser.id;

    cachedProfile = Profile.fromMap(
        await supabase.from('profiles').select().eq('id', id).single());
    lastProfileFetch = DateTime.now();

    return cachedProfile!;
  }

  invalidateCache() {
    cachedProfile = null;
    lastProfileFetch = null;
  }

  String get userId {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    return currentUser.id;
  }
}

extension BottomPadding on BuildContext {
  double get bottomPadding => MediaQuery.of(this).padding.bottom;
}

final themeData = ThemeData(
  colorScheme: const ColorScheme.dark(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(color: Colors.black),
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
  dividerColor: Colors.grey[900],
  useMaterial3: true,
);

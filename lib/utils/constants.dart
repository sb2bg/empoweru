import 'package:age_sync/utils/profile.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import 'observer.dart';

const supabaseUrl = 'https://xtxynmkzjewotpmxxxvy.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0eHlubWt6amV3b3RwbXh4eHZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg4MDAxNzAsImV4cCI6MjAwNDM3NjE3MH0.dHo4Jcnjx2xLuTRXWdWqQByAn6G-1DL6bqPQ5lplyZA';
const iosClientId =
    '585037508158-uh107osoinaus299vu9vb9kcuav3ev0q.apps.googleusercontent.com';

final supabase = Supabase.instance.client;
final CustomRouteObserver navObserver = CustomRouteObserver();
const preloader = Scaffold(body: Center(child: CircularProgressIndicator()));
const error = Scaffold(
    body: Center(
        child: Text('Failed to load data.',
            style: TextStyle(
              color: Colors.grey,
            ))));
const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const subtitleStyle = TextStyle(fontSize: 16);
const metaStyle = TextStyle(fontSize: 12, color: Colors.grey);

const unexpectedErrorMessage = 'Unexpected error occurred.';

showReportThankYouDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Report Received'),
            content: const Text(
                'We will review this message and take appropriate action. Thank you for helping us keep AgeSync safe.'),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('OK'),
              ),
            ],
          ));
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

  void pushNamed(String routeName, {Object? arguments}) {
    Route? previousRoute = navObserver.previousRoute;
    RouteSettings routeSettings = RouteSettings(arguments: arguments);

    WidgetBuilder builder = getRoute(routeName, routeSettings);
    Widget widget = builder(this);

    if (!navigator.canPop() || previousRoute == null) {
      PersistentNavBarNavigator.pushNewScreenWithRouteSettings(this,
          screen: widget, settings: routeSettings);
      return;
    }

    if (previousRoute.settings.name == routeName) {
      pop();
    } else {
      PersistentNavBarNavigator.pushNewScreenWithRouteSettings(this,
          screen: widget, settings: routeSettings);
    }
  }

  void pushReplacementNamed(String routeName) {
    navigator.pushReplacementNamed(routeName);
  }

  void pop() {
    navigator.pop();
  }

  void popAndPushNamed(String routeName) {
    navigator.popAndPushNamed(routeName);
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
      {Function(Object)? onError, Function()? onDone}) async {
    try {
      await func();
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
}

extension ShowModalBottomSheet on BuildContext {
  void showMenu(List<ListTile> tiles) {
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
    cachedProfile = await Profile.fromId(id);
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

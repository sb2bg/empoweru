import 'package:age_sync/utils/profile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

const unexpectedErrorMessage = 'Unexpected error occurred.';

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
    navigator.pushNamed(routeName, arguments: arguments);
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

  void popOrPushNamed(String routeName) {
    Route? previousRoute = navObserver.previousRoute;

    if (!navigator.canPop() || previousRoute == null) {
      pushNamed(routeName);
      return;
    }

    if (previousRoute.settings.name == routeName) {
      pop();
    } else {
      pushNamed(routeName);
    }
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

  String get userId {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    return currentUser.id;
  }
}

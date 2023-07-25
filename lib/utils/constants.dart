import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://xtxynmkzjewotpmxxxvy.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0eHlubWt6amV3b3RwbXh4eHZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg4MDAxNzAsImV4cCI6MjAwNDM3NjE3MH0.dHo4Jcnjx2xLuTRXWdWqQByAn6G-1DL6bqPQ5lplyZA';
const iosClientId =
    '585037508158-uh107osoinaus299vu9vb9kcuav3ev0q.apps.googleusercontent.com';

final supabase = Supabase.instance.client;
final CustomRouteObserver navObserver = CustomRouteObserver();
const preloader = Scaffold(body: Center(child: CircularProgressIndicator()));

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
  void pushNamed(String routeName) {
    Navigator.of(this).pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    Navigator.of(this).pushReplacementNamed(routeName);
  }

  void pop() {
    Navigator.of(this).pop();
  }
}

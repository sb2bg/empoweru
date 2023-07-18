import '../../utils/constants.dart';

Future<void> signInWithEmail(String email, String password) async {
  await supabase.auth.signInWithPassword(email: email, password: password);
}

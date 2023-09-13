import '../../utils/constants.dart';

Future<void> signInWithEmail(String email, String password) async {
  await supabase.auth.signInWithPassword(email: email, password: password);
}

Future<void> signUpWithEmail(
    {required String email,
    required String password,
    required String name,
    required DateTime birthDate}) async {
  await supabase.auth.signUp(
    email: email,
    password: password,
    data: {'full_name': name, 'birth_date': birthDate.toIso8601String()},
  );
}

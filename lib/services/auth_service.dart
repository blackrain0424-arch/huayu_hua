import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  SupabaseClient get _sb => SupabaseService().client;

  User? get currentUser => _sb.auth.currentUser;
  bool get isLoggedIn => _sb.auth.currentUser != null;
  String? get userEmail => _sb.auth.currentUser?.email;

  Stream<AuthState> get onAuthChange => _sb.auth.onAuthStateChange;

  /// Register with email + password.
  /// Returns null on success, error message on failure.
  Future<String?> register(String email, String password) async {
    try {
      await _sb.auth.signUp(email: email.trim(), password: password);
      // Supabase sends a confirmation email by default, but the user
      // is still signed in and can use the app immediately.
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return '注册失败：$e';
    }
  }

  /// Login with email + password.
  Future<String?> login(String email, String password) async {
    try {
      await _sb.auth.signInWithPassword(email: email.trim(), password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return '登录失败：$e';
    }
  }

  Future<void> logout() async {
    StorageService().clearUserData();
    await _sb.auth.signOut();
  }
}

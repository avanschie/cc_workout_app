import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  Future<void> signInWithMagicLink(String email);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  Future<void> signInWithMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email);
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message, e.statusCode);
    } catch (e) {
      throw AuthRepositoryException(
        'An unexpected error occurred during sign in',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message, e.statusCode);
    } catch (e) {
      throw AuthRepositoryException(
        'An unexpected error occurred during sign out',
      );
    }
  }
}

class AuthRepositoryException implements Exception {
  final String message;
  final String? statusCode;

  const AuthRepositoryException(this.message, [this.statusCode]);

  @override
  String toString() => 'AuthRepositoryException: $message';
}

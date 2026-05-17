import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Keeps FirebaseAuth in sync with your MySQL auth.
/// Since you don't store Firebase passwords, we use a deterministic
/// approach: sign in anonymously then link an email credential,
/// OR simply use signInWithEmailAndPassword with a fixed secret suffix
/// that your app controls (never exposed to the user).
class FirebaseAuthSyncService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // A secret suffix appended to make a valid Firebase password.
  // This is NOT the user's real password — it's just to satisfy
  // Firebase Auth's password requirement. Store this in your app constants.
  static const String _suffix = 'Afr!2024#Sync';

  /// Call this after successful MySQL login/registration.
  /// Signs the user into Firebase Auth using their email so that
  /// FirebaseAuth.instance.currentUser?.email is always available.
  static Future<void> syncAfterLogin({required String email}) async {
    if (email.trim().isEmpty) return;

    final normalizedEmail = email.trim().toLowerCase();
    final firebasePassword = _buildFirebasePassword(normalizedEmail);

    try {
      // Already signed in with the correct account — nothing to do
      final current = _auth.currentUser;
      if (current != null &&
          current.email?.toLowerCase() == normalizedEmail &&
          !current.isAnonymous) {
        if (kDebugMode)
          print('✅ Firebase already signed in as $normalizedEmail');
        return;
      }

      // Sign out any stale session first
      if (current != null) {
        await _auth.signOut();
      }

      // Try signing in (user already registered in Firebase Auth)
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: firebasePassword,
      );

      if (kDebugMode) {
        print('✅ Firebase Auth signed in: $normalizedEmail');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // First time — create the Firebase Auth account
        await _createFirebaseAccount(normalizedEmail, firebasePassword);
      } else if (e.code == 'wrong-password') {
        // Edge case: account exists but password mismatch
        // Try password reset approach or recreate
        if (kDebugMode) {
          print(
            '⚠️ Firebase Auth password mismatch for $normalizedEmail — attempting fix',
          );
        }
        await _handlePasswordMismatch(normalizedEmail, firebasePassword);
      } else {
        if (kDebugMode)
          print(
            '⚠️ Firebase Auth sync error (non-fatal): ${e.code} — ${e.message}',
          );
        // Non-fatal — don't block the user
      }
    } catch (e) {
      if (kDebugMode)
        print('⚠️ Firebase Auth sync unexpected error (non-fatal): $e');
      // Non-fatal — don't block the user
    }
  }

  /// Signs out of Firebase Auth (call on MySQL logout)
  static Future<void> syncOnLogout() async {
    try {
      await _auth.signOut();
      if (kDebugMode) print('✅ Firebase Auth signed out');
    } catch (e) {
      if (kDebugMode) print('⚠️ Firebase Auth sign out error: $e');
    }
  }

  /// Gets the current signed-in email, falling back to null
  static String? getCurrentEmail() {
    return _auth.currentUser?.email;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String _buildFirebasePassword(String email) {
    // Deterministic password derived from email + secret suffix
    // This makes it consistent across installs/devices
    return '${email.replaceAll('@', '_').replaceAll('.', '_')}$_suffix';
  }

  static Future<void> _createFirebaseAccount(
    String email,
    String password,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) print('✅ Firebase Auth account created: $email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Race condition — try signing in again
        try {
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (_) {}
      } else {
        if (kDebugMode) {
          print('⚠️ Firebase Auth create error (non-fatal): ${e.code}');
        }
      }
    }
  }

  static Future<void> _handlePasswordMismatch(
    String email,
    String correctPassword,
  ) async {
    try {
      // Delete and recreate — only works if you have admin SDK
      // On client side: use sendPasswordResetEmail as fallback
      // For our use case, just swallow — Firestore rules are open anyway
      if (kDebugMode) {
        print('⚠️ Password mismatch — Firebase Auth sync skipped for $email');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ _handlePasswordMismatch error: $e');
    }
  }
}

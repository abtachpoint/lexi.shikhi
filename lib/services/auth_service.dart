import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _googleServerClientId =
      '950098443544-bn8fuurjadldehi8tootbdm1a1uvionj.apps.googleusercontent.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn.instance;

  bool _googleInitialized = false;
  bool busy = false;
  String? lastError;

  User? get user => _auth.currentUser;
  bool get isSignedIn => user != null;

  Future<void> initialize() async {
    if (_googleInitialized) return;
    try {
      await _google.initialize(serverClientId: _googleServerClientId);
      _googleInitialized = true;
    } catch (error) {
      lastError = _friendlyError(error);
    }
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  Future<UserCredential?> signInWithGoogle() async {
    return _guard<UserCredential?>(() async {
      if (!_googleInitialized) {
        await _google.initialize(serverClientId: _googleServerClientId);
        _googleInitialized = true;
      }
      final account = await _google.authenticate();
      final googleAuth = account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-google-token',
          message: 'Google sign-in did not return an ID token.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return _auth.signInWithCredential(credential);
    });
  }

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard<UserCredential?>(() async {
      return _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<UserCredential?> createEmailAccount({
    required String email,
    required String password,
  }) {
    return _guard<UserCredential?>(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
        final prefix = email.trim().split('@').first;
        await user.updateDisplayName(prefix);
      }
      try {
        await user?.sendEmailVerification();
      } catch (_) {}
      return credential;
    });
  }

  Future<bool> sendPasswordReset(String email) {
    return _guard<bool>(() async {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    }, fallback: false);
  }

  Future<void> signOut() async {
    await _guard<void>(() async {
      await _auth.signOut();
      if (_googleInitialized) {
        try {
          await _google.signOut();
        } catch (_) {}
      }
    });
  }

  Future<bool> deleteCurrentAccount({String? password}) {
    return _guard<bool>(() async {
      final current = _auth.currentUser;
      if (current == null) return false;

      final providers = current.providerData.map((e) => e.providerId).toSet();
      if (providers.contains('password')) {
        final email = current.email;
        if (email == null || password == null || password.isEmpty) {
          throw FirebaseAuthException(
            code: 'password-required',
            message: 'Enter your password to delete this account.',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await current.reauthenticateWithCredential(credential);
      } else if (providers.contains('google.com')) {
        if (!_googleInitialized) {
          await _google.initialize(serverClientId: _googleServerClientId);
          _googleInitialized = true;
        }
        final googleAccount = await _google.authenticate();
        final googleAuth = googleAccount.authentication;
        final idToken = googleAuth.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-google-token',
            message: 'Google re-authentication failed.',
          );
        }
        await current.reauthenticateWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }

      final uid = current.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await current.delete();
      if (_googleInitialized) {
        try {
          await _google.signOut();
        } catch (_) {}
      }
      return true;
    }, fallback: false);
  }

  Future<T> _guard<T>(
    Future<T> Function() action, {
    T? fallback,
  }) async {
    busy = true;
    lastError = null;
    notifyListeners();
    try {
      return await action();
    } catch (error) {
      lastError = _friendlyError(error);
      if (fallback != null) return fallback;
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'user-not-found':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'wrong-password':
          return 'Email or password is incorrect.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Use a stronger password.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'network-request-failed':
          return 'Check your internet connection and try again.';
        case 'requires-recent-login':
          return 'Please sign in again before deleting your account.';
        case 'password-required':
          return 'Enter your password to delete this account.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    final text = '$error';
    if (text.contains('canceled') || text.contains('cancelled')) {
      return 'Sign-in was cancelled.';
    }
    return 'Something went wrong. Please try again.';
  }
}

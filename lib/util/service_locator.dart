// utils/service_locator.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class ServiceLocator {
  static bool _firebaseInitialized = false;
  static bool _dependenciesInitialized = false;

  /// Check if Firebase is already initialized
  static bool get isFirebaseInitialized => _firebaseInitialized;

  /// Mark Firebase as initialized (call from main.dart after Firebase.initializeApp)
  static void markFirebaseInitialized() {
    _firebaseInitialized = true;
  }

  /// Check if main app dependencies are initialized
  static bool get areDependenciesInitialized => _dependenciesInitialized;

  /// Mark dependencies as initialized
  static void markDependenciesInitialized() {
    _dependenciesInitialized = true;
  }

  /// Safe Firebase initialization - skips if already done
  static Future<void> ensureFirebaseInitialized() async {
    if (_firebaseInitialized) return;

    try {
      await Firebase.initializeApp();
      _firebaseInitialized = true;
    } catch (e) {
      // Already initialized or error
      _firebaseInitialized = true;
    }
  }
}

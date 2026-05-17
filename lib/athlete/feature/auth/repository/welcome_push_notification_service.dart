import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Service that calls the Cloud Function to send welcome push notification
/// The welcome email is already handled separately via Mailtrap on Flutter side
class WelcomePushNotificationService {
  static final _functions = FirebaseFunctions.instance;

  /// Sends welcome push notification via Cloud Function
  /// Call this AFTER successful Firestore sync (which saves the FCM token)
  static Future<bool> sendWelcomePush({
    required String email,
    required String firstName,
    required String fieldOfSport,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 Calling Cloud Function: sendWelcomePushNotification');
        print('   📧 Email: $email');
        print('   👤 Name: $firstName');
        print('   🏅 Sport: $fieldOfSport');
      }

      final callable = _functions.httpsCallable(
        'sendWelcomePushNotification',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      final response = await callable.call({
        'email': email.trim().toLowerCase(),
        'firstName': firstName.trim(),
        'fieldOfSport': fieldOfSport.trim(),
      });

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] == true;

      if (kDebugMode) {
        print('📲 Cloud Function Response:');
        print('   Success: $success');
        print('   Message: ${data['message']}');
      }

      return success;
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        print('❌ Cloud Function error:');
        print('   Code: ${e.code}');
        print('   Message: ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Push notification error: $e');
      return false;
    }
  }
}

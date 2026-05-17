// lib/feature/auth/repository/brand_fan_welcome_push_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Service that calls the Cloud Function to send welcome push notification to Brand/Fan users
class BrandFanWelcomePushService {
  static final _functions = FirebaseFunctions.instance;

  /// Sends welcome push notification via Cloud Function
  /// Call this AFTER successful Firestore sync (which saves the FCM token)
  static Future<bool> sendWelcomePush({
    required String email,
    required String firstName,
    required String userType, // 'brand' or 'fan'
    String? brandName,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 Calling Cloud Function: sendBrandFanWelcomePush');
        print('   📧 Email: $email');
        print('   👤 Name: $firstName');
        print('   🏷️ Type: $userType');
      }

      final callable = _functions.httpsCallable(
        'sendBrandFanWelcomePush',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      final response = await callable.call({
        'email': email.trim().toLowerCase(),
        'firstName': firstName.trim(),
        'userType': userType.trim(),
        'brandName': brandName,
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
      if (kDebugMode) print('❌ Brand/Fan push notification error: $e');
      return false;
    }
  }
}

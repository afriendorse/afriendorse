// lib/feature/auth/repository/welcome_notification_service.dart
import 'package:flutter/foundation.dart';
import 'welcome_email_service.dart';
import 'welcome_push_notification_service.dart';

/// Unified service that sends BOTH welcome email and push notification
/// Call this once after successful registration
class WelcomeNotificationService {
  /// Sends welcome email AND push notification simultaneously
  ///
  /// [email] - The athlete's email address
  /// [firstName] - The athlete's first name for personalization
  /// [companyName] - The company/athlete name
  /// [fieldOfSport] - The sport field they registered with
  static Future<WelcomeNotificationResult> sendWelcomeNotifications({
    required String email,
    required String firstName,
    required String companyName,
    required String fieldOfSport,
  }) async {
    if (kDebugMode) {
      print('🚀 Sending welcome notifications to: $email');
    }

    // Send both notifications in parallel for speed
    final results = await Future.wait([
      WelcomeEmailService.sendWelcomeEmail(
        email: email,
        firstName: firstName,
        companyName: companyName,
        fieldOfSport: fieldOfSport,
      ),
      WelcomePushNotificationService.sendWelcomePush(
        email: email,
        firstName: firstName,
        fieldOfSport: fieldOfSport,
      ),
    ]);

    final emailSent = results[0];
    final pushSent = results[1];

    final result = WelcomeNotificationResult(
      emailSent: emailSent,
      pushSent: pushSent,
      allSuccessful: emailSent && pushSent,
    );

    if (kDebugMode) {
      print('📊 Welcome Notification Results:');
      print('   📧 Email: ${emailSent ? "✅ Sent" : "❌ Failed"}');
      print('   📲 Push: ${pushSent ? "✅ Sent" : "❌ Failed"}');
    }

    return result;
  }

  /// Sends only welcome email (useful for fallback or specific flows)
  static Future<bool> sendEmailOnly({
    required String email,
    required String firstName,
    required String companyName,
    required String fieldOfSport,
  }) async {
    return await WelcomeEmailService.sendWelcomeEmail(
      email: email,
      firstName: firstName,
      companyName: companyName,
      fieldOfSport: fieldOfSport,
    );
  }

  /// Sends only welcome push notification (useful for fallback or specific flows)
  static Future<bool> sendPushOnly({
    required String email,
    required String firstName,
    required String fieldOfSport,
  }) async {
    return await WelcomePushNotificationService.sendWelcomePush(
      email: email,
      firstName: firstName,
      fieldOfSport: fieldOfSport,
    );
  }
}

/// Result model for welcome notification delivery
class WelcomeNotificationResult {
  final bool emailSent;
  final bool pushSent;
  final bool allSuccessful;

  const WelcomeNotificationResult({
    required this.emailSent,
    required this.pushSent,
    required this.allSuccessful,
  });

  @override
  String toString() {
    return 'WelcomeNotificationResult(emailSent: $emailSent, pushSent: $pushSent, allSuccessful: $allSuccessful)';
  }
}

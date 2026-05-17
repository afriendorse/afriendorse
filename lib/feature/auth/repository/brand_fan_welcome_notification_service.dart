// lib/feature/auth/repository/brand_fan_welcome_notification_service.dart
import 'package:flutter/foundation.dart';
import 'brand_fan_welcome_email_service.dart';
import 'brand_fan_welcome_push_service.dart';

/// Unified service that sends BOTH welcome email and push notification to Brand/Fan users
/// Call this once after successful registration
class BrandFanWelcomeNotificationService {
  /// Sends welcome email AND push notification simultaneously
  ///
  /// [email] - The user's email address
  /// [firstName] - The user's first name for personalization
  /// [userType] - 'brand' or 'fan'
  /// [brandName] - Brand name (only for brand users)
  /// [industry] - Industry category (only for brand users)
  static Future<BrandFanWelcomeResult> sendWelcomeNotifications({
    required String email,
    required String firstName,
    required String userType,
    String? brandName,
    String? industry,
  }) async {
    if (kDebugMode) {
      print('🚀 Sending brand/fan welcome notifications to: $email');
    }

    // Send both notifications in parallel for speed
    final results = await Future.wait([
      BrandFanWelcomeEmailService.sendWelcomeEmail(
        email: email,
        firstName: firstName,
        userType: userType,
        brandName: brandName,
        industry: industry,
      ),
      BrandFanWelcomePushService.sendWelcomePush(
        email: email,
        firstName: firstName,
        userType: userType,
        brandName: brandName,
      ),
    ]);

    final emailSent = results[0];
    final pushSent = results[1];

    final result = BrandFanWelcomeResult(
      emailSent: emailSent,
      pushSent: pushSent,
      allSuccessful: emailSent && pushSent,
    );

    if (kDebugMode) {
      print('📊 Brand/Fan Welcome Notification Results:');
      print('   📧 Email: ${emailSent ? "✅ Sent" : "❌ Failed"}');
      print('   📲 Push: ${pushSent ? "✅ Sent" : "❌ Failed"}');
    }

    return result;
  }

  /// Sends only welcome email
  static Future<bool> sendEmailOnly({
    required String email,
    required String firstName,
    required String userType,
    String? brandName,
    String? industry,
  }) async {
    return await BrandFanWelcomeEmailService.sendWelcomeEmail(
      email: email,
      firstName: firstName,
      userType: userType,
      brandName: brandName,
      industry: industry,
    );
  }

  /// Sends only welcome push notification
  static Future<bool> sendPushOnly({
    required String email,
    required String firstName,
    required String userType,
    String? brandName,
  }) async {
    return await BrandFanWelcomePushService.sendWelcomePush(
      email: email,
      firstName: firstName,
      userType: userType,
      brandName: brandName,
    );
  }
}

/// Result model for brand/fan welcome notification delivery
class BrandFanWelcomeResult {
  final bool emailSent;
  final bool pushSent;
  final bool allSuccessful;

  const BrandFanWelcomeResult({
    required this.emailSent,
    required this.pushSent,
    required this.allSuccessful,
  });

  @override
  String toString() {
    return 'BrandFanWelcomeResult(emailSent: $emailSent, pushSent: $pushSent, allSuccessful: $allSuccessful)';
  }
}

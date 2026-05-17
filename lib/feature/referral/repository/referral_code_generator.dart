// lib/feature/referral/repository/referral_code_generator.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReferralCodeGenerator {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Generate a unique referral code for a user
  /// Format: FIRSTNAME + 4_RANDOM_CHARS (e.g., JOHN4X7Z)
  static Future<String> generateUniqueCode({
    required String firstName,
    required String email,
  }) async {
    try {
      // Clean first name (remove spaces, special chars, uppercase)
      final cleanName = firstName
          .trim()
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z]'), '')
          .substring(0, min(firstName.length, 6));

      int attempts = 0;
      const maxAttempts = 10;

      while (attempts < maxAttempts) {
        final randomSuffix = _generateRandomSuffix(4);
        final code = '$cleanName$randomSuffix';

        // Check if code already exists
        final exists = await _isCodeExists(code);

        if (!exists) {
          return code;
        }

        attempts++;
      }

      // Fallback: use timestamp-based code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      return '$cleanName${timestamp.substring(timestamp.length - 4)}';
    } catch (e) {
      if (kDebugMode) print('❌ Error generating referral code: $e');

      // Ultimate fallback
      final random = Random();
      return 'USER${random.nextInt(9999).toString().padLeft(4, '0')}';
    }
  }

  /// Generate random alphanumeric suffix
  static String _generateRandomSuffix(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed confusing chars
    final random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Check if referral code already exists
  static Future<bool> _isCodeExists(String code) async {
    try {
      final snapshot = await _db
          .collection('user_referral_codes')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking code existence: $e');
      return false; // Assume doesn't exist on error
    }
  }

  /// Validate referral code format
  static bool isValidCodeFormat(String code) {
    if (code.isEmpty || code.length < 4 || code.length > 15) return false;

    // Only alphanumeric characters
    return RegExp(r'^[A-Z0-9]+$').hasMatch(code);
  }
}

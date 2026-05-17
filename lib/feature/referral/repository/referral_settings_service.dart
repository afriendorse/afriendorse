// lib/feature/referral/repository/referral_settings_service.dart
// REPLACE ENTIRE FILE WITH THIS UPDATED VERSION

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReferralSettings {
  final int pointsPerDollar;
  final int pointsPerReferral;
  final int pointsPerReferee;
  final double brandCommissionPercentage;
  final String brandCommissionType;
  final bool enabled;

  // 🆕 Withdrawal Settings
  final bool withdrawalEnabled;
  final int pointsConversionRate; // points per $1 (e.g., 100)
  final int minimumWithdrawalPoints; // e.g., 1000 points = $10
  final int maximumWithdrawalPoints; // e.g., 50000 points = $500
  final int dailyWithdrawalLimit; // e.g., 10000 points = $100/day
  final bool requiresAdminApproval;
  final double
  autoApprovalThreshold; // auto-approve withdrawals under this amount

  final DateTime? updatedAt;

  ReferralSettings({
    required this.pointsPerDollar,
    required this.pointsPerReferral,
    required this.pointsPerReferee,
    required this.brandCommissionPercentage,
    required this.brandCommissionType,
    required this.enabled,
    required this.withdrawalEnabled,
    required this.pointsConversionRate,
    required this.minimumWithdrawalPoints,
    required this.maximumWithdrawalPoints,
    required this.dailyWithdrawalLimit,
    required this.requiresAdminApproval,
    required this.autoApprovalThreshold,
    this.updatedAt,
  });

  factory ReferralSettings.fromJson(Map<String, dynamic> json) {
    return ReferralSettings(
      pointsPerDollar: json['pointsPerDollar'] ?? 100,
      pointsPerReferral: json['pointsPerReferral'] ?? 50,
      pointsPerReferee: json['pointsPerReferee'] ?? 50,
      brandCommissionPercentage:
          double.tryParse(json['brandCommissionPercentage'].toString()) ?? 10.0,
      brandCommissionType: json['brandCommissionType'] ?? 'one_time',
      enabled: json['enabled'] ?? true,
      withdrawalEnabled: json['withdrawalEnabled'] ?? true,
      pointsConversionRate: json['pointsConversionRate'] ?? 100,
      minimumWithdrawalPoints: json['minimumWithdrawalPoints'] ?? 1000,
      maximumWithdrawalPoints: json['maximumWithdrawalPoints'] ?? 50000,
      dailyWithdrawalLimit: json['dailyWithdrawalLimit'] ?? 10000,
      requiresAdminApproval: json['requiresAdminApproval'] ?? false,
      autoApprovalThreshold:
          double.tryParse(json['autoApprovalThreshold'].toString()) ?? 50.0,
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pointsPerDollar': pointsPerDollar,
      'pointsPerReferral': pointsPerReferral,
      'pointsPerReferee': pointsPerReferee,
      'brandCommissionPercentage': brandCommissionPercentage,
      'brandCommissionType': brandCommissionType,
      'enabled': enabled,
      'withdrawalEnabled': withdrawalEnabled,
      'pointsConversionRate': pointsConversionRate,
      'minimumWithdrawalPoints': minimumWithdrawalPoints,
      'maximumWithdrawalPoints': maximumWithdrawalPoints,
      'dailyWithdrawalLimit': dailyWithdrawalLimit,
      'requiresAdminApproval': requiresAdminApproval,
      'autoApprovalThreshold': autoApprovalThreshold,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Helper method to convert points to cash
  double pointsToCash(double points) {
    return points / pointsConversionRate;
  }

  // Helper method to convert cash to points
  double cashToPoints(double cash) {
    return cash * pointsConversionRate;
  }
}

class ReferralSettingsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = 'referral_settings';
  static const String _docId = 'config';

  static ReferralSettings? _cachedSettings;
  static DateTime? _lastFetch;

  static Future<ReferralSettings> getSettings() async {
    if (_cachedSettings != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < const Duration(minutes: 5)) {
      return _cachedSettings!;
    }

    try {
      final doc = await _db.collection(_collectionName).doc(_docId).get();

      if (!doc.exists) {
        final defaultSettings = ReferralSettings(
          pointsPerDollar: 100,
          pointsPerReferral: 50,
          pointsPerReferee: 50,
          brandCommissionPercentage: 10.0,
          brandCommissionType: 'one_time',
          enabled: true,
          withdrawalEnabled: true,
          pointsConversionRate: 100,
          minimumWithdrawalPoints: 1000,
          maximumWithdrawalPoints: 50000,
          dailyWithdrawalLimit: 10000,
          requiresAdminApproval: false,
          autoApprovalThreshold: 50.0,
        );

        await _db
            .collection(_collectionName)
            .doc(_docId)
            .set(defaultSettings.toJson());

        _cachedSettings = defaultSettings;
        _lastFetch = DateTime.now();
        return defaultSettings;
      }

      _cachedSettings = ReferralSettings.fromJson(doc.data()!);
      _lastFetch = DateTime.now();
      return _cachedSettings!;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching referral settings: $e');

      return ReferralSettings(
        pointsPerDollar: 100,
        pointsPerReferral: 50,
        pointsPerReferee: 50,
        brandCommissionPercentage: 10.0,
        brandCommissionType: 'one_time',
        enabled: true,
        withdrawalEnabled: true,
        pointsConversionRate: 100,
        minimumWithdrawalPoints: 1000,
        maximumWithdrawalPoints: 50000,
        dailyWithdrawalLimit: 10000,
        requiresAdminApproval: false,
        autoApprovalThreshold: 50.0,
      );
    }
  }

  static Future<bool> updateSettings(ReferralSettings settings) async {
    try {
      await _db
          .collection(_collectionName)
          .doc(_docId)
          .set(settings.toJson(), SetOptions(merge: true));

      _cachedSettings = settings;
      _lastFetch = DateTime.now();
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updating referral settings: $e');
      return false;
    }
  }

  static void clearCache() {
    _cachedSettings = null;
    _lastFetch = null;
  }
}

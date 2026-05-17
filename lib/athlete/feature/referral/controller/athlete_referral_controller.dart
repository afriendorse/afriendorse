import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/feature/referral/repository/user_referral_code_service.dart';
import 'package:afriendorse/feature/referral/repository/referral_tracking_service.dart';
import 'package:afriendorse/feature/referral/repository/referral_reward_service.dart';
import 'package:afriendorse/feature/referral/repository/referral_settings_service.dart';
import 'package:afriendorse/feature/referral/repository/points_withdrawal_service.dart';

class AthleteReferralController extends GetxController implements GetxService {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isProcessingWithdrawal = false;
  bool get isProcessingWithdrawal => _isProcessingWithdrawal;

  UserReferralCodeData? _userReferralData;
  UserReferralCodeData? get userReferralData => _userReferralData;

  List<ReferralData> _referralsList = [];
  List<ReferralData> get referralsList => _referralsList;

  List<ReferralReward> _rewardsList = [];
  List<ReferralReward> get rewardsList => _rewardsList;

  List<PointsWithdrawal> _withdrawalList = [];
  List<PointsWithdrawal> get withdrawalList => _withdrawalList;

  Map<String, double> _rewardsSummary = {
    'totalPoints': 0,
    'totalCommission': 0,
    'pendingCommission': 0,
  };
  Map<String, double> get rewardsSummary => _rewardsSummary;

  ReferralSettings? _settings;
  ReferralSettings? get settings => _settings;

  String? _referralLandingUrl;
  String? get referralLandingUrl => _referralLandingUrl;

  final TextEditingController withdrawalAmountController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadReferralSettings();
    _loadLandingUrl();
  }

  @override
  void onClose() {
    withdrawalAmountController.dispose();
    super.onClose();
  }

  Future<void> _loadReferralSettings() async {
    _settings = await ReferralSettingsService.getSettings();
    update();
  }

  Future<void> _loadLandingUrl() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('store_links')
          .get();

      if (doc.exists) {
        _referralLandingUrl = doc.data()?['referral_landing_url'] as String?;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error loading landing URL: $e');
    }
  }

  Future<void> loadUserReferralData({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      update();
    }

    try {
      final userEmail = Get.find<UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo
          ?.owner
          ?.email;

      if (userEmail == null || userEmail.isEmpty) {
        if (kDebugMode) print('❌ User email not found');
        return;
      }

      final emailKey = userEmail.trim().toLowerCase();

      _userReferralData = await UserReferralCodeService.getUserReferralData(
        emailKey,
      );

      if (_userReferralData == null) {
        final firstName =
            Get.find<UserProfileController>()
                .providerModel
                ?.content
                ?.providerInfo
                ?.owner
                ?.firstName ??
            'Athlete';

        await UserReferralCodeService.getOrCreateReferralCode(
          email: emailKey,
          userType: 'athlete',
          firstName: firstName,
        );

        _userReferralData = await UserReferralCodeService.getUserReferralData(
          emailKey,
        );
      }

      _referralsList = await ReferralTrackingService.getUserReferrals(emailKey);

      _rewardsList = await ReferralRewardService.getUserRewards(emailKey);

      _rewardsSummary = await ReferralRewardService.getRewardsSummary(emailKey);

      _withdrawalList = await PointsWithdrawalService.getWithdrawalHistory(
        emailKey,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error loading referral data: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  void copyReferralCode() {
    if (_userReferralData?.referralCode != null) {
      Clipboard.setData(ClipboardData(text: _userReferralData!.referralCode));
      showCustomSnackBar(
        'referral_code_copied'.tr,
        type: ToasterMessageType.success,
      );
    }
  }

  void copyReferralLink() {
    final link = getReferralLink();
    if (link.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: link));
      showCustomSnackBar(
        'referral_link_copied'.tr,
        type: ToasterMessageType.success,
      );
    }
  }

  String getReferralLink() {
    if (_userReferralData?.referralCode == null) return '';
    if (_referralLandingUrl == null || _referralLandingUrl!.isEmpty) return '';

    final code = _userReferralData!.referralCode;
    final baseUrl = _referralLandingUrl!.endsWith('/')
        ? _referralLandingUrl!
        : '$_referralLandingUrl/';

    return '${baseUrl}download?ref=$code';
  }

  void copyReferralText() {
    if (_userReferralData?.referralCode == null) return;

    final code = _userReferralData!.referralCode;
    final link = getReferralLink();
    final refereePoints = getPointsPerReferee();

    final String text;
    if (link.isNotEmpty) {
      text =
          '''
🏆 Join AfriEndorse and we BOTH earn rewards!

Use my referral code: $code

✨ Get: $refereePoints welcome bonus points

Download: $link
''';
    } else {
      text =
          '''
🏆 Join AfriEndorse and we BOTH earn rewards!

Use my referral code: $code

✨ Get: $refereePoints welcome bonus points
''';
    }

    Clipboard.setData(ClipboardData(text: text.trim()));
    showCustomSnackBar(
      'referral_text_copied'.tr,
      type: ToasterMessageType.success,
    );
  }

  Future<void> shareReferralCode() async {
    if (_userReferralData?.referralCode == null) return;

    final code = _userReferralData!.referralCode;
    final link = getReferralLink();
    final refereePoints = getPointsPerReferee();

    if (link.isEmpty) {
      showCustomSnackBar(
        'app_link_not_available'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    final message =
        '''
🏆 Join AfriEndorse and we BOTH earn rewards!

Use my referral code: $code

✨ Get: $refereePoints welcome bonus points

Download: $link
''';

    try {
      await Share.share(
        message,
        subject: 'Join AfriEndorse with my referral code',
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error sharing referral code: $e');
    }
  }

  Map<String, dynamic> getReferralStats() {
    return {
      'totalReferrals': _userReferralData?.totalReferrals ?? 0,
      'successfulReferrals': _userReferralData?.successfulReferrals ?? 0,
      'pendingReferrals':
          (_userReferralData?.totalReferrals ?? 0) -
          (_userReferralData?.successfulReferrals ?? 0),
      'totalPoints': _rewardsSummary['totalPoints'] ?? 0,
      'totalCommission': _rewardsSummary['totalCommission'] ?? 0,
      'pendingCommission': _rewardsSummary['pendingCommission'] ?? 0,
    };
  }

  int getPointsPerReferral() {
    return _settings?.pointsPerReferral ?? 50;
  }

  int getPointsPerReferee() {
    return _settings?.pointsPerReferee ?? 50;
  }

  double getCommissionPercentage() {
    return _settings?.brandCommissionPercentage ?? 10.0;
  }

  bool isCommissionRecurring() {
    return _settings?.brandCommissionType == 'recurring';
  }

  double getCashEquivalent(double points) {
    if (_settings == null) return 0;
    return _settings!.pointsToCash(points);
  }

  int getMinimumWithdrawalPoints() {
    return _settings?.minimumWithdrawalPoints ?? 1000;
  }

  int getMaximumWithdrawalPoints() {
    return _settings?.maximumWithdrawalPoints ?? 50000;
  }

  int getDailyWithdrawalLimit() {
    return _settings?.dailyWithdrawalLimit ?? 10000;
  }

  bool isWithdrawalEnabled() {
    return _settings?.withdrawalEnabled ?? true;
  }

  void setWithdrawalAmount(String points) {
    withdrawalAmountController.text = points;
    update();
  }

  Future<void> processWithdrawal() async {
    try {
      final pointsText = withdrawalAmountController.text.trim();

      if (pointsText.isEmpty) {
        showCustomSnackBar('Please enter points amount');
        return;
      }

      final pointsAmount = double.tryParse(pointsText);

      if (pointsAmount == null || pointsAmount <= 0) {
        showCustomSnackBar('Please enter a valid amount');
        return;
      }

      _isProcessingWithdrawal = true;
      update();

      final userEmail =
          Get.find<UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.owner
              ?.email ??
          '';

      final result = await PointsWithdrawalService.requestWithdrawal(
        userEmail: userEmail.trim().toLowerCase(),
        pointsAmount: pointsAmount,
      );

      _isProcessingWithdrawal = false;
      update();

      Get.back();

      if (result['success']) {
        showCustomSnackBar(
          result['message'] ?? 'Withdrawal successful!',
          type: ToasterMessageType.success,
        );

        withdrawalAmountController.clear();
        await loadUserReferralData();
      } else {
        showCustomSnackBar(
          result['message'] ?? 'Withdrawal failed',
          type: ToasterMessageType.error,
        );
      }
    } catch (e) {
      _isProcessingWithdrawal = false;
      update();

      if (kDebugMode) print('❌ Error processing withdrawal: $e');
      showCustomSnackBar(
        'error_processing_withdrawal'.tr,
        type: ToasterMessageType.error,
      );
    }
  }

  Future<void> refreshAll() async {
    await _loadReferralSettings();
    await _loadLandingUrl();
    await loadUserReferralData(showLoader: false);
  }
}

// lib/athlete/feature/groups/controller/group_payment_controller.dart

import 'package:afriendorse/feature/wallet/controller/wallet_controller.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_deep_link_service.dart';
import 'package:afriendorse/athlete/feature/groups/screens/group_donation_screen.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart'
    as athlete_controller;
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as brandfan_controller;

class GroupPaymentController extends GetxController {
  final RxBool isLoading = false.obs;

  bool get _isAthleteMode {
    try {
      Get.find<athlete_controller.UserProfileController>();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get _isBrandFanMode {
    try {
      Get.find<brandfan_controller.UserController>();
      return true;
    } catch (_) {
      return false;
    }
  }

  String get _currentUserId {
    if (_isAthleteMode) {
      return Get.find<athlete_controller.UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.owner
              ?.email ??
          '';
    }
    if (_isBrandFanMode) {
      return Get.find<brandfan_controller.UserController>().userInfoModel?.id ??
          '';
    }
    return '';
  }

  String get _currentEmail {
    if (_isAthleteMode) {
      return Get.find<athlete_controller.UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.owner
              ?.email ??
          '';
    }
    if (_isBrandFanMode) {
      return Get.find<brandfan_controller.UserController>()
              .userInfoModel
              ?.email ??
          '';
    }
    return '';
  }

  String get _currentName {
    if (_isAthleteMode) {
      final owner = Get.find<athlete_controller.UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo
          ?.owner;
      return '${owner?.firstName ?? ''} ${owner?.lastName ?? ''}'.trim();
    }
    if (_isBrandFanMode) {
      return Get.find<brandfan_controller.UserController>()
              .userInfoModel
              ?.fName ??
          '';
    }
    return 'Donor';
  }

  Future<void> donateViaWallet({
    required String groupId,
    required double amount,
    required String donorId,
    required String donorEmail,
    required String donorName,
    required String donorType,
    String? message,
  }) async {
    isLoading.value = true;

    try {
      // Step 1 — Deduct from MySQL wallet
      final walletController = Get.find<WalletController>();

      final success = await walletController.deductAndRefresh(
        amount: amount,
        purpose: 'group_donation',
      );

      if (!success) {
        isLoading.value = false;
        Get.snackbar(
          'Payment Failed',
          'Wallet payment could not be processed. '
              'Please try again or use online payment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.red),
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Step 2 — Record donation in Firestore
      final donationId = await GroupFirestoreService.initiateDonation(
        groupId: groupId,
        amount: amount,
        donorId: donorId,
        donorEmail: donorEmail,
        donorName: donorName,
        donorType: donorType,
        message: message,
        isAnonymous: false,
      );

      if (donationId == null) {
        isLoading.value = false;
        final ref =
            'wallet_${donorId}_${DateTime.now().millisecondsSinceEpoch}';
        Get.snackbar(
          'Action Needed',
          'Your wallet was charged (ref: $ref) but the donation '
              'record failed. Please contact support.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          duration: const Duration(seconds: 8),
        );
        return;
      }

      // Step 3 — Mark Firestore donation as completed immediately
      final ref = 'wallet_${donorId}_${DateTime.now().millisecondsSinceEpoch}';
      await GroupFirestoreService.completeDonation(
        donationId: donationId,
        transactionRef: ref,
      );

      isLoading.value = false;

      Get.snackbar(
        'Donation Successful 🎉',
        'Thank you!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.black87,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) print('[WalletDonation] error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.black87,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> donateToGroup({
    required String groupId,
    required double amount,
    required String donorId,
    required String donorEmail,
    required String donorName,
    required String donorType,
    String? message,
    bool isAnonymous = false,
  }) async {
    isLoading.value = true;

    // Create a pending donation record first
    final donationId = await GroupFirestoreService.initiateDonation(
      groupId: groupId,
      amount: amount,
      donorId: isAnonymous ? '' : donorId,
      donorEmail: donorEmail,
      donorName: isAnonymous ? 'Anonymous' : donorName,
      donorType: donorType,
      message: message,
      isAnonymous: isAnonymous,
    );

    isLoading.value = false;

    if (donationId == null) {
      if (Get.key.currentState?.overlay != null) {
        // Use Get.snackbar as fallback — if this crashes too, silent fail
        try {
          Get.snackbar('Error', 'Failed to start donation. Please try again.');
        } catch (_) {}
      }
      return;
    }

    // Navigate to our self-contained donation screen
    // This screen talks directly to Paystack API — no domain/backend involved
    Get.to(
      () => GroupDonationScreen(
        donationId: donationId,
        groupId: groupId,
        amount: amount,
        email: donorEmail.isNotEmpty ? donorEmail : _currentEmail,
        donorName: donorName.isNotEmpty ? donorName : _currentName,
      ),
    );
  }

  Future<void> shareGroup(
    String groupId,
    String inviteCode,
    String groupName,
  ) async {
    isLoading.value = true;
    final link = GroupDeepLinkService.generateInviteLink(
      groupId: groupId,
      inviteCode: inviteCode,
    );
    isLoading.value = false;

    if (GetPlatform.isWeb) {
      await Clipboard.setData(ClipboardData(text: link));
      Get.snackbar('Copied!', 'Invite link copied to clipboard.');
    } else {
      await Share.share(
        'Join my group "$groupName" on Afriendorse!\n\nCode: $inviteCode\nLink: $link',
        subject: 'Join $groupName on Afriendorse',
      );
    }
  }
}

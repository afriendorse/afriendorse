// lib/feature/provider/controller/fan_deal_request_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/shared/currency_helper.dart';

// import both user controllers exactly as GroupController does
import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart'
    as athlete_controller;
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as brandfan_controller;

class FanDealRequestController extends GetxController implements GetxService {
  // ── observable state ───────────────────────────────────────────────────────
  final RxBool isSubmitting = false.obs;
  final RxBool hasAlreadyRequested = false.obs;
  final RxString currentUserType = ''.obs;
  final RxBool isRoleLoading = true.obs;

  // ── form fields ────────────────────────────────────────────────────────────
  final RxString selectedDealType = 'Sponsorship'.obs;
  final RxString selectedBudget = '${Currency.symbol}0–50k'.obs;
  final messageController = TextEditingController();

  static const List<String> dealTypes = [
    'Sponsorship',
    'Appearance',
    'Content',
    'Other',
  ];

  static final List<String> budgetRanges = [
    '${Currency.symbol}0–50k',
    '${Currency.symbol}50k–200k',
    '${Currency.symbol}200k+',
  ];

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // ── convenience getter ─────────────────────────────────────────────────────
  bool get isFan => currentUserType.value == 'fan';

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1: Fast-path role detection — mirrors GroupController exactly
  // No Firestore call needed if controller data already tells us the role
  // ─────────────────────────────────────────────────────────────────────────
  String _detectRoleFromControllers() {
    // ── Athlete side: if athlete controller exists and has profile data ──────
    try {
      final athleteCtrl = Get.find<athlete_controller.UserProfileController>();
      final hasProfile =
          athleteCtrl.providerModel?.content?.providerInfo != null;
      if (hasProfile) return 'athlete';
    } catch (_) {}

    // ── Brand/Fan side: controller present means brand or fan ────────────────
    try {
      Get.find<brandfan_controller.UserController>();
      // Controller exists → user is brand or fan
      // We can't distinguish brand vs fan from UserInfoModel alone
      // (no userType field) so we fall through to Firestore for that
      return 'brandfan'; // sentinel — needs Firestore to distinguish
    } catch (_) {}

    return 'unknown';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 2: Firestore lookup — only called when fast-path returns 'brandfan'
  // Uses email as doc ID, matching FirestoreSyncService exactly
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> resolveUserRole() async {
    isRoleLoading.value = true;

    try {
      final fastRole = _detectRoleFromControllers();

      // Definitive — no Firestore needed
      if (fastRole == 'athlete') {
        currentUserType.value = 'athlete';
        isRoleLoading.value = false;
        return;
      }

      if (fastRole == 'unknown') {
        currentUserType.value = 'unknown';
        isRoleLoading.value = false;
        return;
      }

      // fastRole == 'brandfan' — need Firestore to tell brand from fan
      // Get email from brandfan UserController (same as GroupController does)
      final email = _currentUserEmail;
      if (email.isEmpty) {
        // No email means no logged-in user → treat as guest/unknown, NOT fan
        currentUserType.value = 'unknown';
        isRoleLoading.value = false;
        return;
      }

      // Mirror FirestoreSyncService._resolveUserDocId:
      // try lowercase first, then raw casing
      final emailLower = email.trim().toLowerCase();

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(emailLower)
          .get();

      if (!doc.exists) {
        doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email.trim())
            .get();
      }

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final type = (data?['userType'] as String? ?? '').toLowerCase();
        currentUserType.value = type.isNotEmpty ? type : 'fan';
      } else {
        // Doc not found → default to fan (matches GroupController fallback)
        currentUserType.value = 'unknown';
      }

      if (kDebugMode) {
        print(
          '✅ FanDealRequestController — resolved role: '
          '${currentUserType.value} for $emailLower',
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ FanDealRequestController.resolveUserRole: $e');
      // Safe fallback — don't block the UI
      currentUserType.value = 'unknown';
    } finally {
      isRoleLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Current user helpers — mirrors GroupController getters
  // ─────────────────────────────────────────────────────────────────────────
  String get _currentUserEmail {
    try {
      // Athlete email
      final athleteEmail = Get.find<athlete_controller.UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo
          ?.owner
          ?.email;
      if (athleteEmail != null && athleteEmail.isNotEmpty) return athleteEmail;
    } catch (_) {}

    try {
      // Brand/fan email
      return Get.find<brandfan_controller.UserController>()
              .userInfoModel
              ?.email ??
          '';
    } catch (_) {}

    return '';
  }

  String get currentFanId {
    try {
      return Get.find<brandfan_controller.UserController>().userInfoModel?.id
              ?.toString() ??
          '';
    } catch (_) {
      return '';
    }
  }

  String get currentFanName {
    try {
      final u = Get.find<brandfan_controller.UserController>().userInfoModel;
      return '${u?.fName ?? ''} ${u?.lName ?? ''}'.trim();
    } catch (_) {
      return '';
    }
  }

  String get currentFanEmail => _currentUserEmail;

  // ── check if fan already submitted a request for this provider ─────────────
  Future<void> checkExistingRequest({
    required String fanId,
    required String providerId,
  }) async {
    if (fanId.trim().isEmpty) return;
    try {
      final query = await FirebaseFirestore.instance
          .collection('fan_deal_requests')
          .where('fanId', isEqualTo: fanId)
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      hasAlreadyRequested.value = query.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('❌ FanDealRequest check error: $e');
      hasAlreadyRequested.value = false;
    }
  }

  // ── submit deal request ────────────────────────────────────────────────────
  Future<void> submitRequest({
    required String fanId,
    required String fanName,
    required String fanEmail,
    required String providerId,
    required String providerName,
  }) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      await FirebaseFirestore.instance.collection('fan_deal_requests').add({
        'fanId': fanId,
        'fanName': fanName,
        'fanEmail': fanEmail,
        'providerId': providerId,
        'providerName': providerName,
        'dealType': selectedDealType.value,
        'budgetRange': selectedBudget.value,
        'message': messageController.text.trim(),
        'status': 'pending',
        'routedThrough': 'afriendorse',
        'createdAt': FieldValue.serverTimestamp(),
      });

      hasAlreadyRequested.value = true;
      messageController.clear();
      selectedDealType.value = dealTypes.first;
      selectedBudget.value = budgetRanges.first;

      Get.back();
      customSnackBar(
        'Deal request submitted! AfriEndorse will review and get back to you.',
        type: ToasterMessageType.success,
      );
    } catch (e) {
      if (kDebugMode) print('❌ FanDealRequest submit error: $e');
      customSnackBar('Failed to submit request. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  void selectDealType(String type) => selectedDealType.value = type;
  void selectBudget(String budget) => selectedBudget.value = budget;
}

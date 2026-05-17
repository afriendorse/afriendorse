import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/auth/repository/firestore_sync_service.dart';

class BrandVerificationController extends GetxController
    implements GetxService {
  final RxBool isLoading = false.obs;

  /// pending | approved | rejected | unknown
  final RxString verificationStatus = 'unknown'.obs;

  final RxString rejectionReason = ''.obs;

  String _email = '';

  bool get isApproved => verificationStatus.value == 'approved';
  bool get isPending => verificationStatus.value == 'pending';
  bool get isRejected => verificationStatus.value == 'rejected';

  String get email => _email;

  /// Safe load: never calls update() synchronously during build
  Future<void> load(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return;

    _email = normalized;

    // set observable only (no update() needed for Obx users)
    isLoading.value = true;

    try {
      final brandDoc = await FirestoreSyncService.getBrandByEmail(_email);

      if (brandDoc == null) {
        verificationStatus.value = 'unknown';
        rejectionReason.value = '';
      } else {
        verificationStatus.value = (brandDoc['verificationStatus'] ?? 'pending')
            .toString()
            .toLowerCase();

        rejectionReason.value = (brandDoc['rejectionReason'] ?? '').toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ BrandVerificationController.load error: $e');
      }
      verificationStatus.value = 'unknown';
      rejectionReason.value = '';
    } finally {
      isLoading.value = false;

      // If you are using GetBuilder anywhere, update AFTER async work ends.
      // This is safe because it happens after awaits.
      update();
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> stream() {
    if (_email.isEmpty) return const Stream.empty();
    return FirestoreSyncService.watchBrandByEmail(_email);
  }

  Future<void> refreshStatus() async {
    if (_email.isEmpty) return;
    await load(_email);
  }
}

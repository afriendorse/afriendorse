import 'dart:io';
import 'package:afriendorse/feature/referral/repository/brand_commission_tracking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class DealApprovalFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('deal_approvals');

  static DocumentReference<Map<String, dynamic>> doc(String bookingId) =>
      _col.doc(bookingId);

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watch(
    String bookingId,
  ) {
    return doc(bookingId).snapshots();
  }

  /// Upload photos to Firebase Storage and return download URLs
  static Future<List<String>> uploadEvidencePhotos(
    String bookingId,
    List<XFile> photos,
  ) async {
    if (photos.isEmpty) return [];

    final urls = <String>[];

    for (int i = 0; i < photos.length; i++) {
      final file = File(photos[i].path);

      // ✅ Fixed: plain Dart — no markdown artifact
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final ref = FirebaseStorage.instance.ref().child(
        'deal_evidence/$bookingId/$fileName',
      );

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await uploadTask.ref.getDownloadURL();

      // ✅ Sanity-check URL before storing
      assert(
        url.startsWith('https://firebasestorage.googleapis.com'),
        'Unexpected download URL format: $url',
      );

      urls.add(url);
    }

    return urls;
  }

  static Future<void> requestApproval({
    required String bookingId,
    required bool isSubBooking,
    required String readableId,
    required String brandEmail,
    required String brandPhone,
    required String athleteEmail,
    List<String>? photoEvidence,
  }) async {
    final data = <String, dynamic>{
      'bookingId': bookingId,
      'isSubBooking': isSubBooking,
      'readableId': readableId.trim(),
      'brandEmail': brandEmail.trim().toLowerCase(),
      'brandPhone': brandPhone.trim(),
      'athleteEmail': athleteEmail.trim().toLowerCase(),
      'status': 'requested',
      'reason': null,
      'otp': null,
      'otpSetAt': null,
      'requestedAt': FieldValue.serverTimestamp(),
      'expiresAt': null,
      'decidedAt': null,
      'attempt': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (photoEvidence != null && photoEvidence.isNotEmpty) {
      // ✅ Fixed: arrayUnion accumulates photos across attempts
      data['photoEvidence'] = FieldValue.arrayUnion(photoEvidence);
    }

    await doc(bookingId).set(data, SetOptions(merge: true));
  }

  static Future<void> approve({
    required String bookingId,
    required String otp,
    String? brandEmail,
    double? dealAmount,
  }) async {
    await doc(bookingId).set({
      'status': 'approved',
      'otp': otp.trim(),
      'otpSetAt': FieldValue.serverTimestamp(),
      'reason': null,
      'decidedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // ⭐⭐⭐ TRIGGER BRAND COMMISSION IF APPLICABLE ⭐⭐⭐
    if (brandEmail != null && dealAmount != null && dealAmount > 0) {
      try {
        await BrandCommissionTrackingService.processDealApprovalCommission(
          bookingId: bookingId,
          brandEmail: brandEmail,
          dealAmount: dealAmount,
        );
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error processing commission on deal approval: $e');
        }
      }
    }
  }

  static Future<void> decline({
    required String bookingId,
    required String reason,
  }) async {
    await doc(bookingId).set({
      'status': 'declined',
      'reason': reason.trim(),
      'decidedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> markCompleted(String bookingId) async {
    await doc(bookingId).set({
      'status': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

// lib/athlete/feature/profile/service/athlete_share_id_service.dart
//
// Generates a short, unique, non-PII share ID for each athlete.
// Stored in Firestore so it is stable across devices/reinstalls.
//
// Format:  8-char alphanumeric  e.g.  "a3f9k2mz"
// Firestore path:
//   athletes/{docId}.shareId          ← written here
//   athlete_share_ids/{shareId}       ← reverse-lookup collection

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AthleteShareIdService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const _chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static const _idLength = 8;

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Returns the stable shareId for [email].
  /// Creates one if it doesn't exist yet.
  static Future<String> getOrCreate(String email) async {
    final docId = email.trim().toLowerCase();

    // 1. Check if one already exists
    final athleteDoc = await _db.collection('athletes').doc(docId).get();
    final existing = athleteDoc.data()?['shareId'] as String?;
    if (existing != null && existing.isNotEmpty) return existing;

    // Also check athlete_profiles as a fallback
    final profileDoc = await _db
        .collection('athlete_profiles')
        .doc(docId)
        .get();
    final existingInProfile = profileDoc.data()?['shareId'] as String?;
    if (existingInProfile != null && existingInProfile.isNotEmpty) {
      // Back-fill athletes collection so we find it faster next time
      await _db.collection('athletes').doc(docId).set({
        'shareId': existingInProfile,
      }, SetOptions(merge: true));
      return existingInProfile;
    }

    // 2. Generate a collision-free ID
    final shareId = await _generateUniqueId();

    // 3. Persist in both directions
    await Future.wait([
      // Forward: athlete doc carries the shareId
      _db.collection('athletes').doc(docId).set({
        'shareId': shareId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
      // Forward mirror on athlete_profiles
      _db.collection('athlete_profiles').doc(docId).set({
        'shareId': shareId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
      // Reverse: shareId → email for inbound link resolution
      _db.collection('athlete_share_ids').doc(shareId).set({
        'email': docId,
        'createdAt': FieldValue.serverTimestamp(),
      }),
    ]);

    if (kDebugMode) print('✅ Share ID created: $shareId → $docId');
    return shareId;
  }

  /// Resolves a shareId → athlete email.
  /// Returns null if not found.
  static Future<String?> resolve(String shareId) async {
    try {
      final doc = await _db
          .collection('athlete_share_ids')
          .doc(shareId.trim().toLowerCase())
          .get();
      return doc.data()?['email'] as String?;
    } catch (e) {
      if (kDebugMode) print('❌ AthleteShareIdService.resolve error: $e');
      return null;
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  static Future<String> _generateUniqueId() async {
    final rng = Random.secure();

    for (int attempt = 0; attempt < 10; attempt++) {
      final candidate = List.generate(
        _idLength,
        (_) => _chars[rng.nextInt(_chars.length)],
      ).join();

      // Collision check
      final existing = await _db
          .collection('athlete_share_ids')
          .doc(candidate)
          .get();
      if (!existing.exists) return candidate;

      if (kDebugMode) {
        print('Share ID collision on attempt $attempt, retrying…');
      }
    }

    // Extremely unlikely fallback — add timestamp suffix
    final rng2 = Random.secure();
    final ts = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .substring(0, 4);
    return List.generate(4, (_) => _chars[rng2.nextInt(_chars.length)]).join() +
        ts;
  }
}

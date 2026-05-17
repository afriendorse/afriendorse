// lib/athlete/feature/profile/service/athlete_profile_deep_link_service.dart
//
// Share strategy (WhatsApp-friendly):
//   • Primary link:  https://afriendorse.com/p/{shareId}
//     - WhatsApp renders this as a tappable hyperlink ✅
//     - If app installed + App Links / Universal Links configured →
//       OS routes it here instead of the browser
//     - If app NOT installed → browser opens afriendorse.com/p/{shareId}
//       (your website can show a "Download the app" page)
//
//   • Custom-scheme fallback is intentionally removed from the shared
//     text because WhatsApp never makes it tappable anyway.
//
// Inbound handling:
//   afriendorse.com/p/{shareId}   (https — App Links / Universal Links)
//   afriendorse://p/{shareId}     (custom scheme — still supported for
//                                  QR codes or direct browser typing)

import 'dart:async';
import 'package:afriendorse/athlete/common/enums/enums.dart';
import 'package:afriendorse/athlete/common/widgets/custom_snackbar.dart';
import 'package:afriendorse/athlete/feature/profile/service/athlete_share_id_service.dart';
import 'package:afriendorse/helper/route_helper.dart';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class AthleteProfileDeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  /// Your live website / landing page base URL.
  /// The path  /p/{shareId}  should either:
  ///   a) Show a web profile + "Open in App" button, OR
  ///   b) Redirect to the Play Store / App Store if no app is installed.
  /// For now it falls back gracefully even if the page just shows
  /// the marketing homepage.
  static const String _webBase = 'https://afriendorse.com';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  static Future<void> init() async {
    await _handleInitialLink();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleLink,
      onError: (err) {
        if (kDebugMode) print('AthleteProfileDeepLink stream error: $err');
      },
    );
  }

  static void dispose() => _linkSubscription?.cancel();

  // ─── Inbound link handling ────────────────────────────────────────────────

  static Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) await _handleLink(uri);
    } catch (e) {
      if (kDebugMode) print('AthleteProfile getInitialLink error: $e');
    }
  }

  static Future<void> _handleLink(Uri uri) async {
    if (kDebugMode) print('AthleteProfile received link: $uri');

    String? shareId;

    // ── Custom scheme:  afriendorse://p/{shareId} ──────────────────────────
    if (uri.scheme == 'afriendorse' &&
        uri.host == 'p' &&
        uri.pathSegments.isNotEmpty) {
      shareId = uri.pathSegments.first.trim().toLowerCase();
    }
    // ── HTTPS App Link:  afriendorse.com/p/{shareId} ──────────────────────
    else if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'p') {
      shareId = uri.pathSegments[1].trim().toLowerCase();
    }

    if (shareId != null && shareId.isNotEmpty) {
      await _navigateToProfile(shareId);
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  static Future<void> _navigateToProfile(String shareId) async {
    // 1. Resolve shareId → email → mysqlAthleteId
    final email = await AthleteShareIdService.resolve(shareId);
    if (email == null || email.isEmpty) {
      showCustomSnackBar('Athlete profile not found.');
      return;
    }

    final mysqlId = await _resolveMysqlId(email);
    if (mysqlId == null || mysqlId.isEmpty) {
      showCustomSnackBar('Could not load athlete profile.');
      return;
    }

    try {
      Get.toNamed(RouteHelper.getProviderDetails(mysqlId));
    } catch (_) {
      showCustomSnackBar(
        'Share this link with brands and fans to view your profile.',
        type: ToasterMessageType.info,
      );
    }
  }

  /// email → mysqlAthleteId via Firestore
  static Future<String?> _resolveMysqlId(String email) async {
    final db = FirebaseFirestore.instance;
    final docId = email.trim().toLowerCase();

    try {
      // Try athlete_profiles first (more likely to have mysqlAthleteId)
      final profileSnap = await db
          .collection('athlete_profiles')
          .doc(docId)
          .get();
      final idFromProfile = profileSnap
          .data()?['mysqlAthleteId']
          ?.toString()
          .trim();
      if (idFromProfile != null && idFromProfile.isNotEmpty) {
        return idFromProfile;
      }

      // Fallback: athletes collection
      final athleteSnap = await db.collection('athletes').doc(docId).get();
      final idFromAthlete = athleteSnap
          .data()?['mysqlAthleteId']
          ?.toString()
          .trim();
      if (idFromAthlete != null && idFromAthlete.isNotEmpty) {
        return idFromAthlete;
      }
    } catch (e) {
      if (kDebugMode) print('_resolveMysqlId error: $e');
    }
    return null;
  }

  // ─── Outbound sharing ────────────────────────────────────────────────────

  /// Call this from any share button in the app.
  /// [athleteEmail] is used to look up / create the stable shareId.
  static Future<void> shareAthleteProfile({
    required String athleteEmail,
    required String athleteName,
  }) async {
    if (athleteEmail.trim().isEmpty) {
      showCustomSnackBar('Unable to share — profile not fully loaded yet.');
      return;
    }

    // Fetch (or lazily create) the stable share ID
    final shareId = await AthleteShareIdService.getOrCreate(athleteEmail);

    // This HTTPS link is tappable in WhatsApp, iMessage, Telegram, etc.
    final profileLink = '$_webBase/p/$shareId';

    final shareText =
        '🏆 Check out ${athleteName.trim()} on AfriEndorse!\n\n'
        'View their NIL profile, campaigns and sponsorship deals.\n\n'
        '👉 $profileLink';

    await Share.share(
      shareText,
      subject: '${athleteName.trim()} — AfriEndorse Athlete Profile',
    );
  }
}

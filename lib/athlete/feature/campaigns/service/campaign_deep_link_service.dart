// lib/athlete/feature/campaigns/service/campaign_deep_link_service.dart
//
// Mirrors AthleteProfileDeepLinkService but for campaigns.
// Share URL:  https://afriendorse.com/c/{campaignId}
// Manifest intent filter handles /c/ prefix → routes here via app_links.
// If app not installed → afriendorse.com/c/{id} should 302 to Play Store
// (configure that redirect on your server / .htaccess).

import 'dart:async';
import 'package:afriendorse/athlete/common/widgets/custom_snackbar.dart';
import 'package:afriendorse/athlete/feature/campaigns/controller/campaign_controller.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/screens/campaign_detail_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class CampaignDeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  static const String _webBase = 'https://afriendorse.com';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  static Future<void> init() async {
    await _handleInitialLink();
    _sub = _appLinks.uriLinkStream.listen(
      _handleLink,
      onError: (err) {
        if (kDebugMode) print('CampaignDeepLink stream error: $err');
      },
    );
  }

  static void dispose() => _sub?.cancel();

  // ─── Inbound handling ─────────────────────────────────────────────────────

  static Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) await _handleLink(uri);
    } catch (e) {
      if (kDebugMode) print('CampaignDeepLink getInitialLink error: $e');
    }
  }

  static Future<void> _handleLink(Uri uri) async {
    if (kDebugMode) print('CampaignDeepLink received: $uri');

    String? campaignId;

    // https://afriendorse.com/c/{campaignId}
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'c') {
      campaignId = uri.pathSegments[1].trim();
    }
    // afriendorse://c/{campaignId}  (custom scheme fallback)
    else if (uri.scheme == 'afriendorse' &&
        uri.host == 'c' &&
        uri.pathSegments.isNotEmpty) {
      campaignId = uri.pathSegments.first.trim();
    }

    if (campaignId != null && campaignId.isNotEmpty) {
      await _navigateToCampaign(campaignId);
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  static Future<void> _navigateToCampaign(String campaignId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(campaignId)
          .get();

      if (!doc.exists) {
        showCustomSnackBar('Campaign not found or has ended.');
        return;
      }

      final campaign = CampaignModel.fromDoc(doc);

      // Ensure controller is available
      AltCampaignController ctrl;
      try {
        ctrl = Get.find<AltCampaignController>();
      } catch (_) {
        ctrl = Get.put(AltCampaignController());
      }
      ctrl.selectCampaign(campaign);

      Get.to(() => CampaignDetailScreen(campaign: campaign));
    } catch (e) {
      if (kDebugMode) print('CampaignDeepLink _navigateToCampaign error: $e');
      showCustomSnackBar('Could not open campaign. Please try again.');
    }
  }

  // ─── Outbound sharing ────────────────────────────────────────────────────

  /// Call from any share button. campaignId is the Firestore doc ID —
  /// no extra lookup needed, it's already on CampaignModel.
  static Future<void> shareCampaign({
    required String campaignId,
    required String campaignTitle,
    required String creatorName,
    String? coverImage,
  }) async {
    if (campaignId.trim().isEmpty) {
      showCustomSnackBar('Cannot share — campaign not fully loaded.');
      return;
    }

    final link = '$_webBase/c/$campaignId';

    final shareText =
        '🚀 Support ${creatorName.trim()} on AfriEndorse!\n\n'
        '"${campaignTitle.trim()}"\n\n'
        'Help them reach their goal — every contribution counts.\n\n'
        '👉 $link';

    await Share.share(
      shareText,
      subject: '${campaignTitle.trim()} — AfriEndorse Campaign',
    );
  }
}

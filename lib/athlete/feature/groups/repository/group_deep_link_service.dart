// lib/athlete/feature/groups/repository/group_deep_link_service.dart

import 'package:app_links/app_links.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'dart:async';
import 'package:get/get.dart';

class GroupDeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  static Future<void> init() async {
    await _handleInitialLink();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleLink,
      onError: (err) {
        if (kDebugMode) print('Deep link error: $err');
      },
    );
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }

  static Future<void> _handleInitialLink() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        if (kDebugMode) print('Initial deep link: $initialUri');
        _handleLink(initialUri);
      }
    } catch (e) {
      if (kDebugMode) print('Error getting initial link: $e');
    }
  }

  static void _handleLink(Uri uri) {
    if (kDebugMode) print('Received deep link: $uri');

    // Handle: afriendorse.com/g/ABC123?gid=groupId
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'g') {
      final inviteCode = uri.pathSegments[1];
      final groupId = uri.queryParameters['gid'];
      if (groupId != null) _navigateToGroup(groupId, inviteCode);
      return;
    }

    // Handle: afriendorse.com/groups/groupId?code=ABC123
    if (uri.pathSegments.contains('groups') && uri.pathSegments.length >= 2) {
      final groupIdx = uri.pathSegments.indexOf('groups');
      final groupId = groupIdx + 1 < uri.pathSegments.length
          ? uri.pathSegments[groupIdx + 1]
          : uri.pathSegments.last;
      final inviteCode = uri.queryParameters['code'];
      _navigateToGroup(groupId, inviteCode);
    }
  }

  static void _navigateToGroup(String groupId, String? inviteCode) {
    // Check if user is logged in via AuthController
    bool isLoggedIn = false;
    try {
      isLoggedIn = Get.find<AuthController>().isLoggedIn();
    } catch (e) {
      // AuthController not available – treat as not logged in
      isLoggedIn = false;
    }

    if (!isLoggedIn) {
      // Store pending navigation, redirect to login
      Get.toNamed(RouteHelper.signIn);
      return;
    }

    Get.toNamed(
      RouteHelper.getGroupDetailRoute(groupId),
      arguments: {
        'groupId': groupId,
        'inviteCode': inviteCode,
        'autoJoin': inviteCode != null,
      },
    );
  }

  /// Generate shareable invite link
  static String generateInviteLink({
    required String groupId,
    required String inviteCode,
  }) {
    return 'https://afriendorse.com/g/$inviteCode?gid=$groupId';
  }
}

import 'package:afriendorse/athlete/feature/campaigns/service/campaign_deep_link_service.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_deep_link_service.dart';
import 'package:afriendorse/athlete/feature/profile/service/athlete_profile_deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'portal/portal_screen.dart';
import '/main_brand.dart' as brand;
import '/main_athlete.dart' as athlete;
import 'shared/currency_helper.dart';

void main() => initPortal();

Future<void> initPortal() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase once
  await Firebase.initializeApp();
  Currency.init();

  await GroupDeepLinkService.init();
  await AthleteProfileDeepLinkService.init();
  await CampaignDeepLinkService.init();

  // Check for persisted choice
  final prefs = await SharedPreferences.getInstance();
  final String? savedMode = prefs.getString('app_mode');

  if (savedMode != null) {
    // Auto-launch saved mode
    launchApp(savedMode);
  } else {
    // Show portal selector

    runApp(const PortalApp());
  }
}

void launchApp(String mode) {
  // ADD THIS: Clear all GetX dependencies before switching
  Get.reset();

  // Use deferred imports to avoid loading both apps into memory
  if (mode == 'brand') {
    // Import and initialize brand app

    brand.initBrandApp();
  } else if (mode == 'athlete') {
    // Import and initialize athlete app

    athlete.initAthleteApp();
  }
}

class PortalApp extends StatelessWidget {
  const PortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Afriendorse',
      theme: ThemeData.light(),
      home: const PortalScreen(),
    );
  }
}

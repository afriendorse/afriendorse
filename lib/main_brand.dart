import 'package:afriendorse/athlete/feature/groups/repository/group_deep_link_service.dart';
import 'package:afriendorse/shared/downloader_helper.dart';
import 'package:afriendorse/util/service_locator.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_links/app_links.dart';
import 'package:uuid/uuid.dart';
import '../helper/analytics/analytics_helper.dart';
import '../util/core_export.dart';
import '../helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initBrandApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (ResponsiveHelper.isMobilePhone()) {
    await DownloaderHelper.initialize(); // Uses shared helper
  }

  setPathUrlStrategy();
  AnalyticsHelper.init();

  // Rest of your code remains the same...
  ServiceLocator.markFirebaseInitialized();

  /* if (kIsWeb) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "482889663914976",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  } */

  if (defaultTargetPlatform == TargetPlatform.android) {
    await FirebaseMessaging.instance.requestPermission();
  }

  Map<String, Map<String, String>> languages = await di.init();
  ServiceLocator.markDependenciesInitialized();

  NotificationBody? body;
  String? path;
  try {
    if (!kIsWeb) {
      path = await initDynamicLinks();
    }

    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (remoteMessage != null) {
      body = NotificationHelper.convertNotification(remoteMessage.data);
    }
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  } catch (e) {
    if (kDebugMode) {
      print("");
    }
  }

  // Initialize deep links ONCE here
  await GroupDeepLinkService.init();

  runApp(BrandApp(languages: languages, body: body, route: path));
}

class BrandApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBody? body;
  final String? route;

  const BrandApp({
    super.key,
    required this.languages,
    required this.body,
    this.route,
  });

  @override
  State<BrandApp> createState() => _BrandAppState();
}

Future<String?> initDynamicLinks() async {
  final appLinks = AppLinks();
  final uri = await appLinks.getInitialLink();
  String? path;
  if (uri != null) {
    path = uri.path;
  } else {
    path = null;
  }
  return path;
}

class _BrandAppState extends State<BrandApp> {
  void _route() async {
    Get.find<SplashController>().getConfigData().then((success) async {
      if (Get.find<LocationController>().getUserAddress() != null) {
        AddressModel addressModel = Get.find<LocationController>()
            .getUserAddress()!;
        ZoneResponseModel responseModel = await Get.find<LocationController>()
            .getZone(
              addressModel.latitude.toString(),
              addressModel.longitude.toString(),
              false,
            );
        addressModel.availableServiceCountInZone =
            responseModel.totalServiceCount;
        Get.find<LocationController>().saveUserAddress(addressModel);
      }
      Get.find<AuthController>().updateToken();
    });
  }

  @override
  void dispose() {
    GroupDeepLinkService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb || widget.route != null) {
      Get.find<SplashController>().initSharedData();
      Get.find<SplashController>().getCookiesData();
      Get.find<CartController>().getCartListFromServer();

      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<UserController>().getUserInfo();
      }

      if (Get.find<SplashController>().getGuestId().isEmpty) {
        var uuid = const Uuid().v1();
        Get.find<SplashController>().setGuestId(uuid);
      }
      _route();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                if ((GetPlatform.isWeb &&
                    splashController.configModel.content == null)) {
                  return const SizedBox();
                } else if ((!GetPlatform.isWeb &&
                        !Get.currentRoute.contains('/splash') &&
                        Get.currentRoute.isNotEmpty) &&
                    splashController.configModel.content == null) {
                  return Material(child: SplashLogoWidget());
                } else {
                  return GetMaterialApp(
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,
                    navigatorKey: Get.key,
                    scrollBehavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch,
                      },
                    ),
                    theme: themeController.darkTheme ? dark : light,
                    locale: localizeController.locale,
                    translations: Messages(languages: widget.languages),
                    fallbackLocale: Locale(
                      AppConstants.languages[0].languageCode!,
                      AppConstants.languages[0].countryCode,
                    ),
                    initialRoute: GetPlatform.isWeb
                        ? RouteHelper.getInitialRoute()
                        : RouteHelper.getSplashRoute(widget.body, widget.route),
                    getPages: RouteHelper.routes,
                    defaultTransition: Transition.fadeIn,
                    transitionDuration: const Duration(milliseconds: 500),
                    builder: (context, widget) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1)),
                      child: Material(
                        child: SafeArea(
                          top: false,
                          bottom: GetPlatform.isAndroid,
                          child: Stack(
                            children: [
                              widget!,
                              GetBuilder<SplashController>(
                                builder: (splashController) {
                                  if (!splashController.savedCookiesData ||
                                      !splashController.getAcceptCookiesStatus(
                                        splashController
                                                .configModel
                                                .content
                                                ?.cookiesText ??
                                            "",
                                      )) {
                                    return ResponsiveHelper.isWeb()
                                        ? const Align(
                                            alignment: Alignment.bottomCenter,
                                            child: CookiesView(),
                                          )
                                        : const SizedBox();
                                  } else {
                                    return const SizedBox();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

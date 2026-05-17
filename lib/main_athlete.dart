import 'package:afriendorse/athlete/feature/auth/binding/sports_service.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_deep_link_service.dart';
import 'package:afriendorse/athlete/feature/nav/widgets/cash_overflow_dialog.dart';
import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:afriendorse/athlete/feature/tutorial/widgets/tutorial_button_widget.dart';
import 'package:afriendorse/athlete/helper/get_di.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/shared/downloader_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AndroidNotificationChannel? channel1;
AndroidNotificationChannel? channel2;

Future<void> initAthleteApp() async {
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase already initialized in portal
  await DownloaderHelper.initialize(debug: true, ignoreSsl: true);

  if (defaultTargetPlatform == TargetPlatform.android) {
    await FirebaseMessaging.instance.requestPermission();
  }

  // Initialize default sports in Firestore
  await SportsService.initializeDefaultSports();

  Map<String, Map<String, String>> languages = await init();
  NotificationBody? body;

  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (e) {
    if (kDebugMode) {
      print("");
    }
  }

  // Initialize deep links ONCE here
  await GroupDeepLinkService.init();

  runApp(AthleteApp(languages: languages, body: body));
}

class AthleteApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBody? body;

  const AthleteApp({super.key, required this.languages, required this.body});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetMaterialApp(
              routingCallback: (route) {
                Get.find<TutorialController>().onChangeBottomSheetStatus(
                  (route?.isBottomSheet ?? false) || (route?.isDialog ?? false),
                );
              },
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              navigatorKey: Get.key,
              theme: themeController.darkTheme ? dark : light,
              locale: localizeController.locale,
              translations: Messages(languages: languages),
              initialRoute: RouteHelper.getSplashRoute(body: body),
              getPages: RouteHelper.routes,
              defaultTransition: Transition.fadeIn,
              transitionDuration: const Duration(milliseconds: 500),
              builder: (context, widget) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1)),
                child: _GlobalScrollListener(
                  child: Material(
                    child: SafeArea(
                      top: false,
                      bottom: GetPlatform.isAndroid,
                      child: Stack(
                        children: [
                          widget!,
                          GetBuilder<UserProfileController>(
                            builder: (userProfileController) {
                              double receivableAmount =
                                  double.tryParse(
                                    userProfileController
                                            .providerModel
                                            ?.content
                                            ?.providerInfo
                                            ?.owner
                                            ?.account
                                            ?.accountReceivable ??
                                        "0",
                                  ) ??
                                  0;
                              double payableAmount =
                                  double.tryParse(
                                    userProfileController
                                            .providerModel
                                            ?.content
                                            ?.providerInfo
                                            ?.owner
                                            ?.account
                                            ?.accountPayable ??
                                        "0",
                                  ) ??
                                  0;

                              TransactionType transactionType =
                                  userProfileController.getTransactionType(
                                    payableAmount,
                                    receivableAmount,
                                  );
                              double transactionAmount = userProfileController
                                  .getTransactionAmountAmount(
                                    payableAmount,
                                    receivableAmount,
                                  );

                              double payablePercent =
                                  userProfileController.providerModel != null
                                  ? userProfileController.getOverflowPercent(
                                      payableAmount,
                                      receivableAmount,
                                      Get.find<SplashController>()
                                              .configModel
                                              .content
                                              ?.maxCashInHandLimit ??
                                          0,
                                    )
                                  : 0;

                              bool overFlowDialogStatus =
                                  userProfileController.showOverflowDialog &&
                                  userProfileController.providerModel != null &&
                                  Get.find<SplashController>()
                                          .configModel
                                          .content
                                          ?.suspendOnCashInHandLimit ==
                                      1 &&
                                  Get.find<SplashController>()
                                          .configModel
                                          .content
                                          ?.digitalPayment ==
                                      1;

                              return SafeArea(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 90),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        (transactionType ==
                                                        TransactionType
                                                            .payable ||
                                                    transactionType ==
                                                        TransactionType
                                                            .adjustAndPayable ||
                                                    transactionType ==
                                                        TransactionType
                                                            .adjust) &&
                                                (payablePercent >= 80 &&
                                                    overFlowDialogStatus) &&
                                                !userProfileController
                                                    .trialWidgetNotShow
                                            ? CashOverflowDialog(
                                                payablePercent: payablePercent,
                                                amount: transactionAmount,
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          TutorialButtonWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class _GlobalScrollListener extends StatelessWidget {
  final Widget child;

  const _GlobalScrollListener({required this.child});

  @override
  Widget build(BuildContext context) {
    bool isUserScrolling = false;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final tutorialController = Get.find<TutorialController>();

        if (notification is ScrollStartNotification) {
          tutorialController.setVisibility(false);
        } else if (notification is ScrollEndNotification) {
          tutorialController.setVisibility(true);
        }

        if (notification is UserScrollNotification) {
          isUserScrolling = notification.direction != ScrollDirection.idle;
        }

        if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent &&
            isUserScrolling) {
          tutorialController.setVisibility(false);
        }

        return false;
      },
      child: child,
    );
  }
}

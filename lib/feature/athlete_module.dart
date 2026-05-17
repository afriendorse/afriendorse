import 'package:afriendorse/athlete/feature/nav/widgets/cash_overflow_dialog.dart';
import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:afriendorse/athlete/feature/tutorial/widgets/tutorial_button_widget.dart';
import 'package:afriendorse/feature/portal_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/helper/get_di.dart' as athlete_di;

class AthletePortal extends StatefulWidget {
  const AthletePortal({super.key});

  @override
  State<AthletePortal> createState() => _AthletePortalState();
}

class _AthletePortalState extends State<AthletePortal> {
  bool _initialized = false;
  Map<String, Map<String, String>>? _languages; // Store languages map

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize Athlete specific dependencies and capture languages
    _languages = await athlete_di.init();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _languages == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetMaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              navigatorKey: Get.key,
              theme: themeController.darkTheme ? dark : light,
              locale: localizeController.locale,
              // Use stored _languages map
              translations: Messages(languages: _languages!),
              // Fix: Check RouteHelper.getSplashRoute signature - likely needs body only or no args
              initialRoute: RouteHelper.getSplashRoute(body: null),
              getPages: RouteHelper.routes,
              defaultTransition: Transition.fadeIn,
              transitionDuration: const Duration(milliseconds: 500),
              routingCallback: (route) {
                Get.find<TutorialController>().onChangeBottomSheetStatus(
                  (route?.isBottomSheet ?? false) || (route?.isDialog ?? false),
                );
              },
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

                          // Cash overflow dialog
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
                                    child:
                                        (transactionType ==
                                                    TransactionType.payable ||
                                                transactionType ==
                                                    TransactionType
                                                        .adjustAndPayable ||
                                                transactionType ==
                                                    TransactionType.adjust) &&
                                            (payablePercent >= 80 &&
                                                overFlowDialogStatus) &&
                                            !userProfileController
                                                .trialWidgetNotShow
                                        ? CashOverflowDialog(
                                            payablePercent: payablePercent,
                                            amount: transactionAmount,
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                              );
                            },
                          ),

                          TutorialButtonWidget(),

                          // Back to portal selection button
                          Positioned(
                            top: 50,
                            left: 16,
                            child: SafeArea(
                              child: GestureDetector(
                                onTap: () => Get.off(
                                  () => const PortalSelectionScreen(),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Portals',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
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

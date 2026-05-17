import 'package:afriendorse/athlete/feature/groups/screens/groups_list_screen.dart';
import 'package:afriendorse/athlete/feature/payement_information/controller/payment_info_controller.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

class BottomNavScreen extends StatefulWidget {
  final int pageIndex;
  final bool formTutorial;

  static Future<void> loadData({int pageIndex = 0}) async {
    Get.find<DashboardController>().getDashboardData(reload: true);
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<ServiceCategoryController>().getCategoryList(
      shouldUpdate: true,
      reloadSubcategory: true,
    );
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    Get.find<ConversationController>().getChannelList(1, type: "serviceman");
    Get.find<ConversationController>().getChannelList(1, type: "customer");
    Get.find<ServicemanSetupController>().getAllServicemanList(
      1,
      reload: true,
      status: 'all',
    );
    await Get.find<UserProfileController>().getProviderInfo(reload: true).then((
      isProviderModelAvailable,
    ) {
      Get.find<BusinessSubscriptionController>().getSubscriptionPackageList();
      if (pageIndex != 1) {
        Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet();
      }
      Get.find<UserProfileController>().trialWidgetShow(route: "");
    });
    Get.find<AuthController>().updateToken();
    Get.find<PaymentInfoController>().getPaymentMethods(
      isUpdate: false,
      isReload: false,
    );
  }

  const BottomNavScreen({
    super.key,
    required this.pageIndex,
    this.formTutorial = false,
  });

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  List<Widget>? _screens;
  bool _canExit = GetPlatform.isWeb ? true : false;
  bool isTutorialActive = false;

  @override
  void initState() {
    super.initState();

    final bool tutorialCurrentStatus =
        Get.find<UserProfileController>()
            .providerModel
            ?.content
            ?.providerInfo!
            .tutorialData?[AppConstants.serviceSubscriptionTutorialKey]
            ?.contains('0') ??
        true;

    isTutorialActive = widget.formTutorial && tutorialCurrentStatus;

    if (!isTutorialActive) {
      BottomNavScreen.loadData(pageIndex: widget.pageIndex);
    }
    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _screens = [
      const DashBoardScreen(),
      const BookingRequestScreen(),
      ShowCaseWidget(
        builder: (context) {
          return AllServicesScreen(isTutorialActive: isTutorialActive);
        },
      ),
      const GroupsListScreen(),
      Text("more".tr),
    ];

    final padding = MediaQuery.of(context).padding;

    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if (_canExit) {
            exit(0);
          } else {
            showCustomSnackBar(
              'back_press_again_to_exit'.tr,
              type: ToasterMessageType.info,
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            bottom: padding.bottom > 15 ? 0 : Dimensions.paddingSizeDefault,
          ),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 1),
                blurRadius: 5,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraSmall,
              ),
              child: Row(
                children: [
                  _getBottomNavItem(0, FontAwesomeIcons.house, 'dashboard'.tr),
                  _getBottomNavItem(
                    1,
                    FontAwesomeIcons.calendarCheck,
                    'requests'.tr,
                  ),
                  _getBottomNavItem(
                    2,
                    FontAwesomeIcons.briefcase,
                    'services'.tr,
                  ),
                  _getBottomNavItem(3, FontAwesomeIcons.userGroup, 'groups'.tr),
                  _getBottomNavItem(
                    4,
                    FontAwesomeIcons.barsStaggered,
                    'more'.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: GetBuilder<UserProfileController>(
          builder: (userProfileController) {
            return PageView.builder(
              controller: _pageController,
              itemCount: _screens!.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _screens![index];
              },
            );
          },
        ),
        floatingActionButton:
            Get.find<SplashController>().configModel.content?.biddingStatus ==
                    1 &&
                Get.find<SplashController>().showCustomBookingButton
            ? GestureDetector(
                onTap: () => Get.find<BusinessSubscriptionController>()
                    .openTrialEndBottomSheet()
                    .then((isTrial) {
                      if (isTrial) {
                        if (Get.find<UserProfileController>()
                            .checkAvailableFeatureInSubscriptionPlan(
                              featureType: 'bidding',
                            )) {
                          Get.to(() => const CustomerRequestListScreen());
                        }
                      }
                    }),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: context.customThemeColors.shadow,
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).cardColor,
                  ),
                  padding: const EdgeInsets.all(
                    Dimensions.paddingSizeDefault - 2,
                  ),
                  child: Image.asset(
                    Images.createPostIconWithRedDot,
                    height: 40,
                    width: 40,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _setPage(int pageIndex) {
    if (pageIndex == 4) {
      Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
      Get.bottomSheet(
        const MenuScreen(),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        barrierColor: Colors.black.withValues(
          alpha: Get.isDarkMode ? 0.7 : 0.6,
        ),
      ).then((_) {
        Get.find<UserProfileController>().trialWidgetShow(route: "");
      });
    } else {
      setState(() {
        if (pageIndex == 2) {
          final bool tutorialCurrentStatus =
              Get.find<UserProfileController>()
                  .providerModel
                  ?.content
                  ?.providerInfo!
                  .tutorialData?[AppConstants.serviceSubscriptionTutorialKey]
                  ?.contains('0') ??
              true;

          isTutorialActive = tutorialCurrentStatus;
        }

        _pageController?.jumpToPage(pageIndex);
        _pageIndex = pageIndex;
      });
    }
  }

  Widget _getBottomNavItem(int index, FaIconData icon, String title) {
    final bool isSelected = _pageIndex == index;
    final Color activeColor = Get.isDarkMode
        ? Theme.of(context).primaryColor
        : Colors.white;
    final Color inactiveColor = Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: () => _setPage(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 18,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              title,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

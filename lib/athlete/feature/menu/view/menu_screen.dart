import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    final List<MenuModel> menuList = [
      MenuModel(
        icon: Images.profileIcon,
        title: 'profile'.tr,
        route: RouteHelper.getProfileRoute(),
      ),
      /* MenuModel(
        icon: Images.mySubscriptions,
        title: 'mySubscription'.tr,
        route: RouteHelper.getMySubscriptionRoute(),
      ), */
      MenuModel(
        icon: Images.chatImage,
        title: 'chat'.tr,
        routeValidation: "chat",
        route: RouteHelper.getInboxScreenRoute(),
      ),
      /*  MenuModel(
        icon: Images.chatImage,
        title: 'groups'.tr,
        route: RouteHelper.groups,
      ), */
      MenuModel(
        icon: Images.settings,
        title: 'settings'.tr,
        route: RouteHelper.getLanguageBottomSheet('menu'),
      ),
      if (isLoggedIn)
        MenuModel(
          title: 'refer_and_earn'.tr,
          icon: Images.shareIcon,
          route: RouteHelper.getAthleteReferralRoute(),
        ),
      MenuModel(
        icon: Images.paymentInfoIcon,
        title: 'payment_information'.tr,
        route: RouteHelper.getPaymentInformationRoute(),
      ),
      MenuModel(
        icon: Images.notificationSetup,
        title: 'notification_channel'.tr,
        route: RouteHelper.getNotificationScreen(),
      ),
      MenuModel(
        icon: Images.transaction,
        title: 'withdraw_list'.tr,
        route: RouteHelper.transactions,
      ),
      /*  MenuModel(
        icon: Images.reportOverview2,
        title: 'reports'.tr,
        routeValidation: "reports_&_analytics",
        route: RouteHelper.getReportingPageRoute('menu'),
      ), */
      /*  MenuModel(
        icon: Images.menuAdvertisement,
        title: 'advertisements'.tr,
        routeValidation: "advertisement",
        route: RouteHelper.getAdvertisementListScreen(
          count:
              Get.find<DashboardController>()
                  .additionalInfoCount
                  ?.advertisementCount ??
              0,
        ),
      ), */
      MenuModel(
        icon: Images.businessPlanIcon,
        title: 'business_plan'.tr,
        route: RouteHelper.getBusinessPlanScreen(),
      ),
      MenuModel(
        icon: Images.helpIcon,
        title: 'help_&_support'.tr,
        route: RouteHelper.getHelpAndSupportScreen(),
      ),

      ...(Get.find<SplashController>().configModel.content!.businessPages ?? [])
          .map(
            (page) => MenuModel(
              icon: page.pageKey == HtmlType.aboutUs.value
                  ? Images.aboutUs
                  : page.pageKey == HtmlType.termsAndCondition.value
                  ? Images.termsConditionIcon
                  : page.pageKey == HtmlType.privacyPolicy.value
                  ? Images.privacyPolicyIcon
                  : page.pageKey == HtmlType.cancellationPolicy.value
                  ? Images.cancellation
                  : page.pageKey == HtmlType.refundPolicy.value
                  ? Images.refund
                  : Images.othersPageIcon, // Or choose icon based on page
              title: page.pageKey == HtmlType.aboutUs.value
                  ? 'about_us'.tr
                  : page.pageKey == HtmlType.termsAndCondition.value
                  ? 'terms_and_conditions'.tr
                  : page.pageKey == HtmlType.privacyPolicy.value
                  ? 'privacy_policy'.tr
                  : page.pageKey == HtmlType.cancellationPolicy.value
                  ? 'cancellation_policy'.tr
                  : page.pageKey == HtmlType.refundPolicy.value
                  ? 'refund_policy'.tr
                  : page.title ?? '',
              route: RouteHelper.getHtmlRoute(page.pageKey!),
            ),
          ),

      MenuModel(
        icon: Images.logout,
        title: isLoggedIn ? 'log_out'.tr : 'sign_in'.tr,
        route: RouteHelper.getSignInRoute("menu"),
      ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context)
                    ? 8
                    : ResponsiveHelper.isTab(context)
                    ? 7
                    : 4,
                mainAxisExtent: 120,
                crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
              ),
              itemCount: menuList.length,
              itemBuilder: (context, index) {
                return MenuButton(
                  menu: menuList[index],
                  isLogout: index == menuList.length - 1,
                );
              },
            ),
            SizedBox(
              height: ResponsiveHelper.isMobile(context)
                  ? Dimensions.paddingSizeSmall
                  : 0,
            ),
            SafeArea(
              child: RichText(
                text: TextSpan(
                  text: "app_version".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: " ${AppConstants.appVersion} ",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        ),
      ),
    );
  }
}

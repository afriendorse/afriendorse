import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class MenuButton extends StatelessWidget {
  final MenuModel? menu;
  final bool? isLogout;
  const MenuButton({super.key, this.menu, this.isLogout});

  @override
  Widget build(BuildContext context) {
    int count = ResponsiveHelper.isDesktop(context)
        ? 8
        : ResponsiveHelper.isTab(context)
        ? 7
        : 4;
    double size =
        ((context.width > Dimensions.webMaxWidth
                ? Dimensions.webMaxWidth
                : context.width) /
            count) -
        Dimensions.paddingSizeDefault;

    return InkWell(
      onTap: () async {
        if (isLogout!) {
          Get.back();
          if (Get.find<AuthController>().isLoggedIn()) {
            showCustomDialog(
              child: ConfirmationDialog(
                icon: Images.logout,
                title: 'are_you_sure_to_logout'.tr,
                onNoPressed: () {
                  Get.back();
                },
                onYesPressed: () {
                  Get.find<AuthController>().clearSharedData();
                  Get.find<UserProfileController>().clearUserProfileData();
                  Get.offAllNamed(
                    RouteHelper.getSignInRoute(RouteHelper.splash),
                  );
                },
                description: '',
              ),
              barrierDismissible: true,
              useSafeArea: true,
            );
          }
        } else if (menu!.route!.startsWith('http')) {
          if (await canLaunchUrl(Uri.parse(menu!.route!))) {
            launchUrl(Uri.parse(menu!.route!));
          }
        } else if (menu!.route!.contains('language')) {
          Get.back();
          showCustomBottomSheet(child: const SettingBottomSheet());
        } else {
          if (menu?.route == RouteHelper.businessPlan ||
              menu?.route == RouteHelper.profile ||
              menu?.route == RouteHelper.transactions ||
              menu!.route!.contains(RouteHelper.html) ||
              menu?.route == RouteHelper.mySubscription) {
            Get.offNamed(menu!.route!);
          } else {
            Get.find<BusinessSubscriptionController>()
                .openTrialEndBottomSheet()
                .then((isTrial) {
                  if (isTrial) {
                    if ((menu!.routeValidation != null &&
                            Get.find<UserProfileController>()
                                .checkAvailableFeatureInSubscriptionPlan(
                                  featureType: menu!.routeValidation!,
                                )) ||
                        menu!.routeValidation == null) {
                      Get.offNamed(menu!.route!);
                    }
                  } else {
                    Get.back();
                  }
                });
          }
        }
      },

      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              color: Get.isDarkMode
                  ? Colors.grey.withValues(alpha: 0.2)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ),
            height: size - (size * 0.2),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            alignment: Alignment.center,
            child: Image.asset(
              menu!.icon!,
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            menu!.title!,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

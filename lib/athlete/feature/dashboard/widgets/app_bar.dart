import 'package:afriendorse/athlete/helper/help_me.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color color;
  final bool fromBookingRequest;
  final double? titleFontSize;
  const MainAppBar({
    super.key,
    this.title,
    required this.color,
    this.fromBookingRequest = false,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (notificationController) {
        return GetBuilder<SplashController>(
          builder: (splashController) {
            List<String> bookingFilterList = [
              'all_booking',
              "regular_booking",
              "repeat_booking",
            ];

            return AppBar(
              elevation: 5,
              titleSpacing: -5,
              surfaceTintColor: Theme.of(context).cardColor,
              backgroundColor: Theme.of(context).cardColor,
              shadowColor: Get.isDarkMode
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              leading: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall + 3,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                child: Image.asset(Images.appbarLogo, fit: BoxFit.fitWidth),
              ),
              title: title != null
                  ? Text(
                      title!.tr,
                      style: robotoBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize:
                            titleFontSize ?? Dimensions.fontSizeExtraLarge,
                      ),
                    )
                  : Image.asset(Images.logo, width: 110),
              /*  actions: [
                (fromBookingRequest &&
                        Get.find<SplashController>()
                                .configModel
                                .content
                                ?.biddingStatus ==
                            1)
                    ? Row(
                        children: [
                          GetBuilder<BookingRequestController>(
                            builder: (bookingRequestController) {
                              return PopupMenuButton<String>(
                                shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimensions.radiusSmall),
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                surfaceTintColor: Theme.of(context).cardColor,
                                position: PopupMenuPosition.under,
                                elevation: 8,
                                shadowColor: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.3),
                                padding: EdgeInsets.zero,
                                menuPadding: EdgeInsets.zero,
                                itemBuilder: (BuildContext context) {
                                  return bookingFilterList.map((String option) {
                                    ServiceType type =
                                        option == "regular_booking"
                                        ? ServiceType.regular
                                        : option == "repeat_booking"
                                        ? ServiceType.repeat
                                        : ServiceType.all;
                                    return PopupMenuItem<String>(
                                      value: option,
                                      padding: EdgeInsets.zero,
                                      height: 45,
                                      child:
                                          bookingRequestController
                                                  .selectedServiceType ==
                                              type
                                          ? Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(
                                                      alpha: Get.isDarkMode
                                                          ? 0.2
                                                          : 0.08,
                                                    ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeDefault,
                                                    vertical: 12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    option.tr,
                                                    style: robotoRegular
                                                        .copyWith(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                              child: Text(
                                                option.tr,
                                                style: robotoRegular,
                                              ),
                                            ),
                                      onTap: () {
                                        bookingRequestController
                                            .updateSelectedServiceType(
                                              type: option == "regular_booking"
                                                  ? ServiceType.regular
                                                  : option == "repeat_booking"
                                                  ? ServiceType.repeat
                                                  : ServiceType.all,
                                            );//
                                      },
                                    );
                                  }).toList();
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.filter_list,
                                        size: 22,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    if (bookingRequestController
                                            .selectedServiceType !=
                                        ServiceType.all)
                                      Positioned(
                                        right: 5,
                                        top: 5,
                                        child: Icon(
                                          Icons.circle,
                                          size: 10,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),

                          GestureDetector(
                            onTap: () => Get.find<BusinessSubscriptionController>()
                                .openTrialEndBottomSheet()
                                .then((isTrial) {
                                  if (isTrial) {
                                    if (Get.find<UserProfileController>()
                                        .checkAvailableFeatureInSubscriptionPlan(
                                          featureType: 'bidding',
                                        )) {
                                      Get.to(
                                        () => const CustomerRequestListScreen(),
                                      );
                                    }
                                  }
                                }),

                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              child: Image.asset(
                                splashController.showRedDotIconForCustomBooking
                                    ? Images.createPostIconWithRedDot
                                    : Images.createPostIconWithoutDot,
                                height: 35,
                                width: 35,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Get.toNamed(
                                    RouteHelper.getInboxScreenRoute(),
                                  );
                                  if (isRedundentClick(DateTime.now())) {
                                    return;
                                  }
                                },
                                icon: Image.asset(
                                  Images.messageIcon,
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Stack(
                              children: [
                                IconButton(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onPressed: () {
                                    Get.toNamed(
                                      RouteHelper.getNotificationRoute(),
                                    );
                                    if (isRedundentClick(DateTime.now())) {
                                      return;
                                    }
                                    notificationController
                                        .resetNotificationCount();
                                  },
                                  icon: Image.asset(
                                    Images.notificationIcon,
                                    height: 22,
                                    width: 22,
                                  ),
                                ),
                                if (notificationController
                                        .unseenNotificationCount >
                                    0)
                                  Positioned(
                                    right: 2,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 3,
                                      ),
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      child: FittedBox(
                                        child: Text(
                                          notificationController
                                              .unseenNotificationCount
                                              .toString(),
                                          style: robotoRegular.copyWith(
                                            color: light.cardColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              ],
            */
            );
          },
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}

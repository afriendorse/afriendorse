import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_bottom_sheet.dart';

class AddressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? backButton;
  const AddressAppBar({super.key, this.backButton = true});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return AppBar(
      backgroundColor: Get.isDarkMode
          ? Theme.of(context).cardColor.withValues(alpha: .2)
          : Theme.of(context).primaryColor,
      shape: Border(
        bottom: BorderSide(
          width: .4,
          color: Theme.of(context).primaryColorLight.withValues(alpha: .2),
        ),
      ),
      elevation: 0,
      leadingWidth: backButton! ? Dimensions.paddingSizeLarge : 0,
      leading: backButton!
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).cardColor,
              onPressed: () => Navigator.pop(context),
            )
          : const SizedBox(),
      title: Row(
        children: [
          Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useRootNavigator: true,
                routeSettings: RouteSettings(name: '/'),
                builder: (context) => const AddressSelectionBottomSheet(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'services_in'.tr,
                    style: robotoRegular.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeTine),
                  GetBuilder<LocationController>(
                    builder: (locationController) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (locationController.getUserAddress() != null)
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: size.width * 0.4,
                              ),
                              child: Tooltip(
                                message:
                                    locationController
                                        .getUserAddress()
                                        ?.address ??
                                    '',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: Dimensions.paddingSizeDefault,
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeMini,
                                    ),

                                    Flexible(
                                      child: Text(
                                        locationController
                                                .getUserAddress()
                                                ?.address ??
                                            '',
                                        style: robotoMedium.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            child: const Icon(
              Icons.notifications,
              size: 25,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size(Dimensions.webMaxWidth, GetPlatform.isDesktop ? 70 : 56);
}

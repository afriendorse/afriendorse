import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
/*
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double? titleFontSize;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;

  const MainAppBar({
    super.key,
    this.title,
    this.titleFontSize,
    this.onNotificationTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 5,
      titleSpacing: -5,
      surfaceTintColor: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(
        context,
      ).primaryColor.withValues(alpha: Get.isDarkMode ? 0.5 : 0.1),
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
                fontSize: titleFontSize ?? Dimensions.fontSizeExtraLarge,
              ),
            )
          : Image.asset(Images.logo, width: 110),
      actions: [
        // Message Icon
        if (onMessageTap != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onMessageTap,
              icon: Image.asset(Images.messageIcon, height: 20, width: 20),
            ),
          ),

        // Notification Icon with Badge
        /*
        if (onNotificationTap != null)
          GetBuilder<NotificationController>(
            builder: (controller) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Stack(
                children: [
                  IconButton(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      onNotificationTap!();
                      controller.resetNotificationCount();
                    },
                    icon: Image.asset(
                      Images.notificationIcon,
                      height: 22,
                      width: 22,
                    ),
                  ),
                  if (controller.unseenNotificationCount > 0)
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
                            controller.unseenNotificationCount.toString(),
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
          ), */
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}

*/

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMessageTap;
  final VoidCallback? onNotificationTap;

  const MainAppBar({
    super.key,
    required this.title,
    this.onMessageTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 5,
      titleSpacing: -5,
      surfaceTintColor: Theme.of(context).cardColor,
      backgroundColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(
        context,
      ).primaryColor.withValues(alpha: Get.isDarkMode ? 0.5 : 0.1),
      leading: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall + 3,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        child: Image.asset(Images.appbarLogo, fit: BoxFit.fitWidth),
      ),
      title: title.isNotEmpty
          ? Text(
              title.tr,
              style: robotoBold.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
            )
          : Image.asset(Images.logo, width: 110),
      centerTitle: false,
      actions: [
        // Search Icon
        IconButton(
          onPressed: () => Get.toNamed(RouteHelper.getSearchResultRoute()),
          icon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).primaryColor,
          ),
        ),
        // Message Icon
        if (onMessageTap != null)
          IconButton(
            onPressed: onMessageTap,
            icon: Icon(
              Icons.message_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        // Notification Icon
        if (onNotificationTap != null)
          IconButton(
            onPressed: onNotificationTap,
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}

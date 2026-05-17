import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? name;
  final String? image;
  final String? phone;
  final String fromNotification;
  const ConversationDetailsAppBar({
    super.key,
    this.name,
    this.image,
    this.phone,
    this.fromNotification = "",
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 5,
      titleSpacing: 0,
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Get.isDarkMode
          ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
          : Theme.of(context).primaryColor.withValues(alpha: 0.1),

      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              Dimensions.paddingSizeExtraLarge * 2,
            ),
            child: CustomImage(
              image: image,
              height: 30,
              width: 30,
              placeholder: name == "admin"
                  ? Images.adminPlaceHolder
                  : Images.userPlaceHolder,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name?.tr ?? "",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Get.isDarkMode
                      ? Theme.of(context).hintColor
                      : Colors.black,
                ),
              ),

              /*  if (phone != "")
                Text(
                  phone ?? "",
                  style: robotoLight.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Get.isDarkMode
                        ? Theme.of(context).hoverColor
                        : Theme.of(context).hintColor,
                  ),
                ), */
            ],
          ),
        ],
      ),

      leading: Padding(
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
        child: IconButton(
          onPressed: () {
            if (fromNotification == "fromNotification") {
              Get.offNamed(
                RouteHelper.getInboxScreenRoute(
                  fromNotification: fromNotification,
                ),
              );
            } else {
              Get.back();
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Get.isDarkMode ? Theme.of(context).hintColor : Colors.black,
            size: Dimensions.paddingSizeLarge,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}

import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class NotificationSetupSearchWidget extends StatelessWidget {
  final TabController? tabController;
  const NotificationSetupSearchWidget({super.key, this.tabController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
      ),
      child: GetBuilder<NotificationSetupController>(
        builder: (notificationSetupController) {
          return TextField(
            controller: notificationSetupController.searchController,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeDefault,
            ),

            cursorColor: Theme.of(context).hintColor,
            autofocus: false,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            onChanged: (text) {
              notificationSetupController.showSuffixIcon(context, text);
              if (text.isNotEmpty) {
                notificationSetupController.searchItems(query: text.trim());
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 22,
              ),
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(10),
                  left: Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(10),
                  left: Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(10),
                  left: Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(10),
                  left: Radius.circular(10),
                ),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),

              isDense: true,
              hintText: 'search_by_topic_description'.tr,
              hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor,
              ),
              filled: true,
              suffixIcon: notificationSetupController.isActiveSuffixIcon
                  ? IconButton(
                      color: Get.isDarkMode
                          ? light.cardColor.withValues(alpha: 0.8)
                          : Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        if (notificationSetupController.searchController.text
                            .trim()
                            .isNotEmpty) {
                          notificationSetupController.clearSearchController();
                        }
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        Icons.cancel_outlined,
                        size: 18,
                        color: Theme.of(context).hintColor,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: Icon(
                        Icons.search_outlined,
                        color: Theme.of(context).hintColor,
                        size: 22,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

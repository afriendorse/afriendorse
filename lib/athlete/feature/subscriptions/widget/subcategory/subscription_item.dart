import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SubscriptionItem extends StatelessWidget {
  final int index;
  final SubscriptionModelData subscriptionModelData;
  const SubscriptionItem({
    super.key,
    required this.subscriptionModelData,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    int totalNumberOfServices = 0;
    if (subscriptionModelData.subCategory != null) {
      for (var element in subscriptionModelData.subCategory!.services!) {
        if (element.isActive == 1) {
          totalNumberOfServices++;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: 0.1),
        ),
        color: Theme.of(
          context,
        ).cardColor.withValues(alpha: Get.isDarkMode ? 0.5 : 1),
        boxShadow: context.customThemeColors.cardShadow,
      ),

      child: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomImage(
                    image:
                        "${subscriptionModelData.subCategory?.imageFullPath}",
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
              subscriptionModelData.subCategory != null
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscriptionModelData.subCategory?.name ?? "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),

                          Row(
                            children: [
                              Text(
                                'subscribed'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),

                              Text(
                                DateConverter.isoStringToLocalDateOnly(
                                  subscriptionModelData.createdAt!,
                                ),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              PopupMenuButton<int>(
                padding: EdgeInsets.zero,
                menuPadding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(
                  Dimensions.radiusExtraLarge,
                ),
                color: Get.isDarkMode
                    ? Theme.of(context).hintColor
                    : Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(Dimensions.radiusDefault),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                  ),
                ),

                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                ),
                offset: const Offset(0, 40),
                onSelected: (value) {
                  if (value == 1) {
                    Get.to(
                      ServicesScreen(
                        subscriptionModelData: subscriptionModelData,
                        fromPage: 'subscription_details',
                        index: index,
                      ),
                    );
                  } else if (value == 2) {
                    int? isSubscribe = subscriptionModelData.isSubscribed;
                    showCustomBottomSheet(
                      child: SubscribeUnsubscribeBottomSheet(
                        isSubscribe: isSubscribe == 1 ? false : true,
                        subscriptionModelData: subscriptionModelData,
                        index: index,
                        fromPage: 'subscription_list',
                      ),
                    );
                  }
                },

                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          '${'see_services'.tr} ($totalNumberOfServices) ',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                          maxLines: 2,
                        ),

                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          'Unsubscribe',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Row(
              children: [
                Expanded(
                  child: InfoCard(
                    color: Theme.of(context).primaryColor,
                    title: 'ongoing'.tr,
                    count: subscriptionModelData.ongoingBookingCount,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: InfoCard(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    title: 'completed'.tr,
                    count: subscriptionModelData.completedBookingCount,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: InfoCard(
                    color: Theme.of(context).colorScheme.error,
                    title: 'cancelled'.tr,
                    count: subscriptionModelData.canceledBookingCount,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final Color color;
  final String title;
  final int? count;

  const InfoCard({
    super.key,
    required this.color,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: color.withValues(alpha: 0.07),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${count ?? ""}",
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
            maxLines: 2,
          ),
          const SizedBox(height: 10), // Adjust height as needed
          Text(
            title,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

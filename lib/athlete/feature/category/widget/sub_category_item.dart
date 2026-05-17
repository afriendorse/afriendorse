import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:showcaseview/showcaseview.dart';

class SubCategoryView extends StatelessWidget {
  final List<ServiceSubCategoryModel> subCategoryList;
  final GlobalKey subscribeKey;
  const SubCategoryView({
    super.key,
    required this.subCategoryList,
    required this.subscribeKey,
  });
  @override
  Widget build(BuildContext context) {
    return subCategoryList.isEmpty &&
            !Get.find<ServiceCategoryController>().isSubCategoryLoading
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomShowCaseWidget(
                  isActive: true,
                  showcaseKey: subscribeKey,
                  showArrow: false,
                  child: SizedBox(),
                ),

                Text(
                  "no_sub_category_found".tr,
                  style: robotoMedium.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ],
            ),
          )
        : Get.find<ServiceCategoryController>().isSubCategoryLoading
        ? const SubCategoryItemShimmer()
        : Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isTab(context) ? 2 : 1,
                    mainAxisExtent: 170,
                  ),
                  controller:
                      Get.find<ServiceCategoryController>().scrollController,
                  itemCount: subCategoryList.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    int totalService = 0;
                    for (var element in subCategoryList[index].services!) {
                      if (element.isActive == 1) {
                        totalService++;
                      }
                    }
                    return GetBuilder<ServiceCategoryController>(
                      builder: (allServiceController) {
                        return Container(
                          margin: const EdgeInsets.fromLTRB(5, 2, 10, 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: context.customThemeColors.shadow,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(Dimensions.paddingSizeExtraSmall),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                ServicesScreen(
                                  subcategoryModel: allServiceController
                                      .serviceSubCategoryList[index],
                                  fromPage: 'category',
                                  index: index,
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: Dimensions.paddingSizeDefault,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CustomImage(
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                        image:
                                            '${subCategoryList[index].imageFullPath}',
                                      ),
                                    ),

                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subCategoryList[index].name
                                                .toString(),
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            height:
                                                Dimensions
                                                    .paddingSizeExtraSmall -
                                                2,
                                          ),
                                          Text(
                                            subCategoryList[index].description
                                                .toString(),
                                            textAlign: TextAlign.justify,
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall - 1,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.5),
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraSmall,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                  ),
                                  child: Divider(
                                    thickness: 0.5,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(1, 40),
                                          backgroundColor: Colors.transparent,
                                        ),
                                        onPressed: () => Get.to(
                                          ServicesScreen(
                                            subcategoryModel: allServiceController
                                                .serviceSubCategoryList[index],
                                            fromPage: 'category',
                                            index: index,
                                          ),
                                        ),
                                        child: Text(
                                          "${'services'.tr} ($totalService)",
                                          style: robotoRegular.copyWith(
                                            fontSize: Get.width < 350
                                                ? Dimensions.fontSizeSmall - 2
                                                : Dimensions.fontSizeDefault,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Theme.of(
                                              context,
                                            ).primaryColorLight,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 3,
                                      child: CustomShowCaseWidget(
                                        showcaseKey: subscribeKey,
                                        isActive: index == 0,
                                        child: GetBuilder<ServiceCategoryController>(
                                          builder: (allService) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall,
                                                        ),
                                                    side: BorderSide.none,
                                                  ),
                                                  minimumSize: Size.zero,
                                                  elevation: 0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 7,
                                                      ),
                                                  disabledBackgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSecondaryContainer
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                  backgroundColor:
                                                      subCategoryList[index]
                                                              .isSubscribed ==
                                                          1
                                                      ? Theme.of(context)
                                                            .colorScheme
                                                            .onSecondaryContainer
                                                            .withValues(
                                                              alpha: 0.3,
                                                            )
                                                      : Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                ),
                                                onPressed:
                                                    subCategoryList[index]
                                                            .isSubscribed ==
                                                        1
                                                    ? null
                                                    : () {
                                                        Get.find<
                                                              BusinessSubscriptionController
                                                            >()
                                                            .openTrialEndBottomSheet()
                                                            .then((isTrail) {
                                                              if (isTrail) {
                                                                int?
                                                                isSubscribe =
                                                                    subCategoryList[index]
                                                                        .isSubscribed;
                                                                showCustomBottomSheet(
                                                                  child: SubscribeUnsubscribeBottomSheet(
                                                                    isSubscribe:
                                                                        isSubscribe ==
                                                                            1
                                                                        ? false
                                                                        : true,
                                                                    subCategoryModel:
                                                                        subCategoryList[index],
                                                                    index:
                                                                        index,
                                                                    fromPage:
                                                                        'category',
                                                                  ),
                                                                );
                                                              }
                                                            });
                                                      },
                                                child: Text(
                                                  subCategoryList[index]
                                                              .isSubscribed ==
                                                          1
                                                      ? "already_subscribed".tr
                                                      : "subscribe".tr,
                                                  style: robotoRegular.copyWith(
                                                    color:
                                                        subCategoryList[index]
                                                                .isSubscribed ==
                                                            1
                                                        ? Theme.of(context)
                                                              .colorScheme
                                                              .onSecondaryContainer
                                                        : Colors.white,
                                                    fontSize: Get.width < 350
                                                        ? Dimensions
                                                                  .fontSizeSmall -
                                                              2
                                                        : Dimensions
                                                              .fontSizeSmall,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Get.find<ServiceCategoryController>().isPaginationLoading
                  ? CircularProgressIndicator(
                      color: Theme.of(context).hoverColor,
                    )
                  : const SizedBox.shrink(),
            ],
          );
  }
}

class CustomShowCaseWidget extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final bool showArrow;
  final GlobalKey? showcaseKey;
  const CustomShowCaseWidget({
    super.key,
    required this.child,
    required this.isActive,
    required this.showcaseKey,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return isActive && showcaseKey != null
        ? Showcase(
            showArrow: showArrow,
            key: showcaseKey!,

            descTextStyle: robotoRegular,
            descriptionPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            tooltipBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            tooltipPosition: TooltipPosition.top,
            tooltipActions: [
              TooltipActionButton(
                type: null,
                backgroundColor: Colors.transparent,
              ),

              TooltipActionButton(
                type: TooltipDefaultActionType.next,
                name: 'got_it'.tr.toUpperCase(),
                backgroundColor: Colors.transparent,
                textStyle: robotoBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),

              TooltipActionButton(
                type: null,
                backgroundColor: Colors.transparent,
              ),
            ],
            description: 'you_can_subscribe_to_your_preferred_service'.tr,
            child: child,
          )
        : child;
  }
}

import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class PreviewProviderPromotionWidget extends StatelessWidget {
  final String? title;
  final String? description;
  final String? validation;
  final String? networkCoverImage;
  final String? pickedCoverImage;
  final String? pickedProfileImage;
  final String? networkProfileImage;
  final bool? isShowRatings;
  final bool? isShowReview;

  const PreviewProviderPromotionWidget({
    super.key,
    this.title,
    this.description,
    this.validation,
    this.networkCoverImage,
    this.pickedCoverImage,
    this.networkProfileImage,
    this.pickedProfileImage,
    this.isShowRatings,
    this.isShowReview,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
          ),
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "template_preview".tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.clear,
                      color: Theme.of(context).hintColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              SizedBox(
                height: Get.size.height * 0.3,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusLarge,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.1),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.2),
                            ),
                          ),
                          padding: const EdgeInsets.only(bottom: 25),
                          child:
                              pickedCoverImage != null &&
                                  pickedCoverImage!.isNotEmpty
                              ? Image.file(
                                  File(pickedCoverImage!),
                                  fit: BoxFit.cover,
                                )
                              : networkCoverImage != null &&
                                    networkCoverImage!.isNotEmpty
                              ? CustomImage(
                                  image: networkCoverImage,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusLarge,
                          ),
                          color: Theme.of(context).cardColor,
                          boxShadow: context.customThemeColors.cardShadow,
                        ),
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusExtraLarge * 2,
                                ),
                                child:
                                    networkProfileImage != null &&
                                        networkProfileImage!.isNotEmpty
                                    ? CustomImage(
                                        image: networkProfileImage,
                                        fit: BoxFit.cover,
                                      )
                                    : pickedProfileImage != null &&
                                          pickedProfileImage!.isNotEmpty
                                    ? Image.file(
                                        File(pickedProfileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Theme.of(
                                          context,
                                        ).hintColor.withValues(alpha: 0.2),
                                      ),
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  title == null || title!.isEmpty
                                      ? Container(
                                          height: 17,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).hintColor.withValues(alpha: 0.1),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeDefault,
                                            ),

                                            Container(
                                              padding: const EdgeInsets.all(
                                                Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions
                                                          .radiusExtraLarge,
                                                    ),
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                              child: const Icon(
                                                Icons.favorite_outlined,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),

                                  description == null || description!.isEmpty
                                      ? Container(
                                          height: 17,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).hintColor.withValues(alpha: 0.1),
                                          ),
                                        )
                                      : Text(
                                          description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoRegular.copyWith(
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeDefault,
                                  ),

                                  Row(
                                    children: [
                                      isShowRatings != null && isShowRatings!
                                          ? RatingBar(
                                              rating:
                                                  Get.find<
                                                        UserProfileController
                                                      >()
                                                      .providerModel
                                                      ?.content
                                                      ?.providerInfo
                                                      ?.avgRating ??
                                                  0.0,
                                            )
                                          : const SizedBox(),

                                      isShowRatings! && isShowReview!
                                          ? Row(
                                              children: [
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                SizedBox(
                                                  height: Get.height * 0.015,
                                                  child: VerticalDivider(
                                                    thickness: 1,
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),

                                      isShowReview != null && isShowReview!
                                          ? Text(
                                              "${Get.find<UserProfileController>().providerModel?.content?.providerInfo?.ratingCount} Reviews",
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: Dimensions.paddingSizeLarge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class SubscriptionItemCard extends StatelessWidget {
  final bool isSelected;
  final SubscriptionPackage selectedPackage;
  final SubscriptionPackage? activePackage;
  final AutoScrollController? scrollController;
  final String? packageStatus;
  final Function()? onPressed;

  const SubscriptionItemCard({
    super.key,
    this.isSelected = false,
    required this.selectedPackage,
    this.activePackage,
    this.scrollController,
    this.onPressed,
    this.packageStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).primaryColor),
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).cardColor,
      ),
      width: ResponsiveHelper.isMobile(context) ? 270 : 350,

      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall + 3,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: TopCustomShape(),
                child: Container(
                  height: 85,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.05)
                        : Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isSelected
                            ? Image.asset(Images.approvedIcon, width: 25)
                            : const SizedBox(),
                        SizedBox(
                          width: isSelected ? Dimensions.paddingSizeSmall : 0,
                        ),

                        Flexible(
                          child: Text(
                            selectedPackage.name?.tr ?? "",
                            style: robotoMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                  Text(
                    selectedPackage.id == "0"
                        ? "${selectedPackage.price?.toStringAsFixed(0)} %"
                        : PriceConverter.convertPrice(
                            selectedPackage.price ?? 0,
                          ),
                    style: robotoBold.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  Text(
                    selectedPackage.duration != null
                        ? "${selectedPackage.duration ?? ""} ${"days".tr}"
                        : "",
                    style: robotoRegular.copyWith(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Container(
            height: 0.5,
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : Theme.of(context).primaryColor.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeLarge,
            ),
          ),

          selectedPackage.id == "0"
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault,
                    horizontal: Dimensions.paddingSizeLarge,
                  ),
                  child: Text(
                    selectedPackage.description ?? "",
                    style: robotoRegular.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : selectedPackage.featureList != null &&
                    selectedPackage.featureList!.isNotEmpty
              ? Column(
                  children: selectedPackage.featureList!.map((element) {
                    String? limitInString = element == "booking"
                        ? selectedPackage.featureLimit?.booking
                        : element == "category"
                        ? selectedPackage.featureLimit?.category
                        : null;
                    int? limit = int.tryParse(limitInString ?? "");

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: Text(
                        "• ${(element == "booking" || element == "category") && limit == null ? "unlimited".tr : limit ?? ""} "
                        "${(element == "category") ? "subcategory's_subscription".tr : element.tr}",
                        style: robotoRegular.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                )
              : const SizedBox(),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          const Expanded(child: SizedBox()),

          onPressed != null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: packageStatus == "renew"
                        ? Dimensions.paddingSizeLarge * 3
                        : Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: CustomButton(
                    color: isSelected
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).primaryColor,
                    btnTxt:
                        packageStatus == "renew" &&
                            Get.find<UserProfileController>()
                                    .providerModel
                                    ?.content
                                    ?.subscriptionInfo
                                    ?.subscribedPackageDetails
                                    ?.isPaid ==
                                0
                        ? "pay_now".tr
                        : packageStatus == "renew"
                        ? "renew".tr
                        : packageStatus == "shift"
                        ? "shift_in_this_plan".tr
                        : packageStatus == "purchase"
                        ? "purchase".tr
                        : "NULL".tr,
                    fontSize: Dimensions.fontSizeDefault,
                    onPressed: onPressed,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class TopCustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    var path = Path();
    path.lineTo(0, height - 50);
    path.quadraticBezierTo(width / 2, height, width, height - 50);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

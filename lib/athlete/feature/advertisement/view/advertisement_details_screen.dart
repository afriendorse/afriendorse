import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class AdvertisementDetailsScreen extends StatefulWidget {
  final String? id;
  final String? fromNotification;
  const AdvertisementDetailsScreen({
    super.key,
    required this.id,
    this.fromNotification = "",
  });

  @override
  State<AdvertisementDetailsScreen> createState() =>
      _AdvertisementDetailsScreenState();
}

class _AdvertisementDetailsScreenState
    extends State<AdvertisementDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<AdvertisementController>().getAdvertisementDetails(
      id: widget.id ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(
      builder: (advertisementController) {
        return SafeArea(
          child: Scaffold(
            appBar: CustomAppBar(
              title: "ad_details".tr,
              onBackPressed: () {
                if (widget.fromNotification == "fromNotification") {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                } else {
                  if (Navigator.canPop(context)) {
                    Get.back();
                  }
                }
              },
            ),
            body:
                advertisementController.advertisementDetailsModel == null &&
                    advertisementController
                            .advertisementDetailsModel
                            ?.advertisementData ==
                        null
                ? const Center(child: CircularProgressIndicator())
                : advertisementController.advertisementDetailsModel != null &&
                      advertisementController
                              .advertisementDetailsModel
                              ?.advertisementData ==
                          null
                ? SizedBox(
                    height: Get.height * 0.7,
                    child: AdvertisementDetailsEmptyScreen(
                      advertisementId: widget.id ?? "",
                    ),
                  )
                : GetBuilder<AdvertisementController>(
                    builder: (advertisementController) {
                      bool isExpired = advertisementController
                          .isAdvertisementExpired(
                            advertisementController
                                .advertisementDetailsModel!
                                .advertisementData!
                                .endDate!,
                          );
                      String? status = advertisementController
                          .advertisementDetailsModel
                          ?.advertisementData
                          ?.status;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                boxShadow: context.customThemeColors.cardShadow,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${'ad_id'.tr} #${advertisementController.advertisementDetailsModel?.advertisementData?.readableId}',
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color
                                                ?.withValues(alpha: 0.9),
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeDefault,
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),

                                              color: context
                                                  .customThemeColors
                                                  .buttonBackgroundColorMap[status],
                                            ),
                                            child: Center(
                                              child: Text(
                                                status!.tr,
                                                style: robotoMedium.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: context
                                                      .customThemeColors
                                                      .buttonTextColorMap[status],
                                                ),
                                              ),
                                            ),
                                          ),

                                          isExpired ||
                                                  (!isExpired &&
                                                      status == "approved")
                                              ? const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                )
                                              : const SizedBox(),

                                          isExpired ||
                                                  (!isExpired &&
                                                      status == "approved")
                                              ? Text(
                                                  '(${(!isExpired && status == "approved") ? 'running'.tr : 'expired'.tr})',
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
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

                                  const SizedBox(
                                    height: Dimensions.paddingSizeDefault,
                                  ),
                                  Divider(
                                    height: 0.5,
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeDefault,
                                  ),

                                  BookingItem(
                                    img: Images.iconCalendar,
                                    title: 'ad_created'.tr,
                                    subTitle: DateConverter.dateMonthYearTime(
                                      DateConverter.isoUtcStringToLocalDate(
                                        advertisementController
                                                .advertisementDetailsModel
                                                ?.advertisementData
                                                ?.createdAt ??
                                            "",
                                      ),
                                    ),
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                  const SizedBox(
                                    height:
                                        Dimensions.paddingSizeExtraSmall + 2,
                                  ),

                                  BookingItem(
                                    img: Images.iconCalendar,
                                    title: 'duration'.tr,
                                    subTitle:
                                        '${DateConverter.stringToLocalDateOnly(advertisementController.advertisementDetailsModel?.advertisementData?.startDate ?? "")} - ${DateConverter.stringToLocalDateOnly(advertisementController.advertisementDetailsModel?.advertisementData?.endDate ?? "")}',
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                  const SizedBox(
                                    height:
                                        Dimensions.paddingSizeExtraSmall + 2,
                                  ),

                                  BookingItem(
                                    img: Images.adsType,
                                    title: 'ads_type'.tr,
                                    subTitle:
                                        "${advertisementController.advertisementDetailsModel?.advertisementData?.type}"
                                            .tr,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    subtitleTextStyle: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall + 1,
                                    ),
                                  ),
                                  const SizedBox(
                                    height:
                                        Dimensions.paddingSizeExtraSmall + 2,
                                  ),

                                  BookingItem(
                                    img: Images.paymentStatus,
                                    title: 'payment_status'.tr,
                                    subTitle:
                                        advertisementController
                                                .advertisementDetailsModel
                                                ?.advertisementData
                                                ?.isPaid ==
                                            1
                                        ? "paid".tr
                                        : "unpaid".tr,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    subtitleTextStyle: robotoMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: Dimensions.fontSizeSmall + 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            advertisementController
                                            .advertisementDetailsModel!
                                            .advertisementData
                                            ?.additionalNote !=
                                        null &&
                                    advertisementController
                                        .advertisementDetailsModel!
                                        .advertisementData!
                                        .additionalNote!
                                        .isNotEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      boxShadow:
                                          context.customThemeColors.cardShadow,
                                    ),
                                    margin: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeDefault,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeLarge,
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error
                                              .withValues(alpha: 0.5),
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeLarge,
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(),

                                          Text(
                                            advertisementController
                                                        .advertisementDetailsModel!
                                                        .advertisementData
                                                        ?.status ==
                                                    'paused'
                                                ? "# ${'paused_note'.tr}"
                                                : "# ${'cancellation_note'.tr}",
                                            overflow: TextOverflow.ellipsis,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),

                                          Text(
                                            "${advertisementController.advertisementDetailsModel?.advertisementData?.additionalNote}",
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                            textAlign: TextAlign.justify,
                                            maxLines: 100,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),

                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                boxShadow: context.customThemeColors.cardShadow,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeLarge,
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(),

                                  Text(
                                    "service_info".tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),

                                  Text(
                                    "${advertisementController.advertisementDetailsModel?.advertisementData?.title}",
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                                    textAlign: TextAlign.justify,
                                    maxLines: 10,
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),

                                  Text(
                                    "description".tr.replaceAll(":", ""),
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Text(
                                    "${advertisementController.advertisementDetailsModel?.advertisementData?.description}",
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                                    textAlign: TextAlign.justify,
                                    maxLines: 100,
                                  ),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),
                                  advertisementController
                                              .advertisementDetailsModel
                                              ?.advertisementData
                                              ?.type ==
                                          'video_promotion'
                                      ? Text(
                                          "video".tr,
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),

                                  advertisementController
                                              .advertisementDetailsModel
                                              ?.advertisementData
                                              ?.type ==
                                          'video_promotion'
                                      ? NetworkVideoPreviewWidget(
                                          videoFile:
                                              advertisementController
                                                  .advertisementDetailsModel
                                                  ?.advertisementData
                                                  ?.promotionalVideoFullPath ??
                                              "",
                                        )
                                      : AspectRatio(
                                          aspectRatio: 20 / 9,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "logo/profile".tr,
                                                      style: robotoBold,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),

                                                    AspectRatio(
                                                      aspectRatio: 5 / 4.5,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                        ),
                                                        margin: const EdgeInsets.only(
                                                          top: Dimensions
                                                              .paddingSizeSmall,
                                                          right: Dimensions
                                                              .paddingSizeDefault,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              List<String>
                                                              profileImage = [];
                                                              profileImage.add(
                                                                advertisementController
                                                                        .advertisementDetailsModel
                                                                        ?.advertisementData
                                                                        ?.providerProfileImageFullPath ??
                                                                    "",
                                                              );

                                                              Get.to(
                                                                ImageDetailScreen(
                                                                  imageList:
                                                                      profileImage,
                                                                  index: 0,
                                                                  appbarTitle:
                                                                      advertisementController
                                                                          .advertisementDetailsModel
                                                                          ?.advertisementData
                                                                          ?.type
                                                                          ?.tr ??
                                                                      "",
                                                                  appbarSubtitle:
                                                                      "logo/profile"
                                                                          .tr,
                                                                ),
                                                              );
                                                            },
                                                            child: CustomImage(
                                                              image:
                                                                  "${advertisementController.advertisementDetailsModel?.advertisementData?.providerProfileImageFullPath}",
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeDefault,
                                              ),

                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "cover".tr,
                                                      style: robotoBold,
                                                    ),

                                                    AspectRatio(
                                                      aspectRatio: 20 / 12,
                                                      child: Container(
                                                        margin: const EdgeInsets.only(
                                                          top: Dimensions
                                                              .paddingSizeSmall,
                                                          right: Dimensions
                                                              .paddingSizeDefault,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              List<String>
                                                              coverImage = [];
                                                              coverImage.add(
                                                                advertisementController
                                                                        .advertisementDetailsModel
                                                                        ?.advertisementData
                                                                        ?.providerCoverImageFullPath ??
                                                                    '',
                                                              );

                                                              Get.to(
                                                                ImageDetailScreen(
                                                                  imageList:
                                                                      coverImage,
                                                                  index: 0,
                                                                  appbarTitle:
                                                                      advertisementController
                                                                          .advertisementDetailsModel
                                                                          ?.advertisementData
                                                                          ?.type
                                                                          ?.tr ??
                                                                      "",
                                                                  appbarSubtitle:
                                                                      "cover_image"
                                                                          .tr,
                                                                ),
                                                              );
                                                            },
                                                            child: CustomImage(
                                                              image:
                                                                  advertisementController
                                                                      .advertisementDetailsModel
                                                                      ?.advertisementData
                                                                      ?.providerCoverImageFullPath ??
                                                                  "",
                                                              fit: BoxFit.cover,
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
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    },
                  ),
            bottomSheet:
                advertisementController.advertisementDetailsModel != null &&
                    advertisementController
                            .advertisementDetailsModel
                            ?.advertisementData !=
                        null
                ? Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: context.customThemeColors.shadow,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            btnTxt: "edit_ads".tr,
                            fontSize: Dimensions.fontSizeDefault,
                            icon: Icons.edit,
                            onPressed: () {
                              Get.to(
                                () => CreateAdvertisementScreen(
                                  isEditScreen: true,
                                  advertisementData: advertisementController
                                      .advertisementDetailsModel
                                      ?.advertisementData,
                                  fromDetailsScreen: true,
                                ),
                              );
                            },
                          ),
                        ),

                        advertisementController
                                    .advertisementDetailsModel
                                    ?.advertisementData
                                    ?.status ==
                                'pending'
                            ? const SizedBox(
                                width: Dimensions.paddingSizeDefault,
                              )
                            : const SizedBox(),

                        advertisementController
                                    .advertisementDetailsModel
                                    ?.advertisementData
                                    ?.status ==
                                'pending'
                            ? Expanded(
                                child: CustomButton(
                                  btnTxt: "cancel_ads".tr,
                                  isShowLoadingButton: false,
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.07),
                                  fontSize: Dimensions.fontSizeDefault,
                                  onPressed: () {
                                    Get.find<AdvertisementController>()
                                        .resetNoteController();
                                    showCustomBottomSheet(
                                      child: ConfirmationBottomSheet(
                                        image: Images.cancelDialogIcon,
                                        title: "cancel_dialog_title",
                                        description:
                                            "cancel_dialog_description",
                                        status: "cancel_ads",
                                        yesButtonPressed: () async {
                                          if (advertisementController
                                              .noteFormKey
                                              .currentState!
                                              .validate()) {
                                            await Get.find<
                                                  AdvertisementController
                                                >()
                                                .changeAdvertisementStatus(
                                                  id:
                                                      advertisementController
                                                          .advertisementDetailsModel
                                                          ?.advertisementData
                                                          ?.id ??
                                                      "",
                                                  status: 'canceled',
                                                  isFromDetailsPage: true,
                                                );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                  icon: Icons.clear,
                                  textColor: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.8),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
        );
      },
    );
  }
}

class AdvertisementDetailsEmptyScreen extends StatelessWidget {
  final String advertisementId;
  const AdvertisementDetailsEmptyScreen({
    super.key,
    required this.advertisementId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Images.noResults,
            height: Get.height * 0.1,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text("information_not_found".tr, style: robotoRegular),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButton(
            height: 35,
            width: 120,
            radius: Dimensions.radiusExtraLarge,
            btnTxt: "go_back".tr,
            onPressed: () async {
              await Get.find<AdvertisementController>()
                  .removeAdvertisementItemFromList(
                    advertisementId,
                    shouldUpdate: true,
                  );
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

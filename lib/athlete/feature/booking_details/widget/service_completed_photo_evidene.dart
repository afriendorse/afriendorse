import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ServiceCompletedPhotoEvidence extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  const ServiceCompletedPhotoEvidence({
    super.key,
    required this.bookingDetails,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        bool showDeliveryConfirmImage =
            bookingDetailsController.showPhotoEvidenceField;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          margin: EdgeInsets.only(
            bottom:
                Get.find<SplashController>()
                            .configModel
                            .content
                            ?.bookingImageVerification ==
                        1 &&
                    showDeliveryConfirmImage &&
                    bookingDetails.bookingStatus != 'completed'
                ? 50
                : Dimensions.paddingSizeExtraSmall,
            top: Dimensions.paddingSizeExtraSmall,
          ),
          child: Column(
            children: [
              bookingDetails.photoEvidenceFullPath != null &&
                      bookingDetails.photoEvidenceFullPath!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text(
                            'completed_service_picture'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                            ),
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  bookingDetails.photoEvidenceFullPath?.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          ImageDetailScreen(
                                            imageList:
                                                bookingDetails
                                                    .photoEvidenceFullPath ??
                                                [],
                                            index: index,
                                            appbarTitle:
                                                'completed_service_picture'.tr,
                                          ),
                                        );
                                      },

                                      child: Hero(
                                        tag:
                                            bookingDetails
                                                .photoEvidenceFullPath?[index] ??
                                            "",
                                        child: CustomImage(
                                          image:
                                              bookingDetails
                                                  .photoEvidenceFullPath?[index] ??
                                              "",
                                          height: 70,
                                          width: 120,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),

              Get.find<SplashController>()
                              .configModel
                              .content
                              ?.bookingImageVerification ==
                          1 &&
                      showDeliveryConfirmImage &&
                      bookingDetails.bookingStatus != 'completed'
                  ? Padding(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'completed_service_picture'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                            ),
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            child: ListView.builder(
                              controller: bookingDetailsController
                                  .completedServiceImagesScrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  bookingDetailsController
                                      .pickedPhotoEvidence
                                      .length +
                                  1,
                              itemBuilder: (context, index) {
                                XFile? file =
                                    index ==
                                        bookingDetailsController
                                            .pickedPhotoEvidence
                                            .length
                                    ? null
                                    : bookingDetailsController
                                          .pickedPhotoEvidence[index];
                                if (index < 5 &&
                                    index ==
                                        bookingDetailsController
                                            .pickedPhotoEvidence
                                            .length) {
                                  return InkWell(
                                    onTap: () {
                                      showCustomBottomSheet(
                                        child: CameraButtonSheet(
                                          bookingId: bookingDetails.id!,
                                          isSubBooking: isSubBooking,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 60,
                                      width: 70,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        color: Theme.of(context).primaryColor,
                                        size: 30,
                                      ),
                                    ),
                                  );
                                }
                                return file != null
                                    ? Container(
                                        margin: const EdgeInsets.only(
                                          right: Dimensions.paddingSizeSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                              child: Image.file(
                                                File(file.path),
                                                width: 120,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              ),
                                            ),

                                            Positioned(
                                              top: -7,
                                              right: -7,
                                              child: IconButton(
                                                onPressed: () {},
                                                icon: Container(
                                                  padding: const EdgeInsets.all(
                                                    Dimensions
                                                            .paddingSizeExtraSmall -
                                                        2,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white54,
                                                      ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      bookingDetailsController
                                                          .removePhotoEvidence(
                                                            index,
                                                          );
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .delete_forever_outlined,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox();
                              },
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            'you_can_upload_max_5_picture'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}

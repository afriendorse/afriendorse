import 'package:afriendorse/athlete/feature/location/view/update_customer_address.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class UpdateServiceLocationWidget extends StatefulWidget {
  final BookingDetailsContent bookingDetails;
  final RepeatBooking? nextBooking;
  final bool isSubBooking;
  final BookingEditType bookingEditType;
  const UpdateServiceLocationWidget({
    super.key,
    required this.bookingDetails,
    required this.isSubBooking,
    required this.bookingEditType,
    this.nextBooking,
  });

  @override
  State<UpdateServiceLocationWidget> createState() =>
      _UpdateServiceLocationWidgetState();
}

class _UpdateServiceLocationWidgetState
    extends State<UpdateServiceLocationWidget> {
  @override
  void initState() {
    super.initState();

    Get.find<BookingEditController>().updateIsCheckedAllUpcomingBooking(
      shouldUpdate: false,
    );

    String? serviceLocation =
        widget.nextBooking?.serviceLocation ??
        widget.bookingDetails.serviceLocation;

    ServiceLocationType selectedServiceLocationType =
        serviceLocation == "provider"
        ? ServiceLocationType.provider
        : ServiceLocationType.customer;
    Get.find<BookingEditController>().updateServiceLocationType(
      type: selectedServiceLocationType,
      shouldUpdate: false,
    );
    Get.find<BookingEditController>().setPickedServiceAddress(
      address: null,
      shouldUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeLarge,
      ),
      child: GetBuilder<BookingEditController>(
        builder: (bookingEditController) {
          Provider? provider = widget.isSubBooking
              ? widget.bookingDetails.subBooking?.provider
              : widget.bookingDetails.provider;
          ServiceAddress? serviceAddress =
              (bookingEditController.pickedServiceAddress?.address != null &&
                  bookingEditController.pickedServiceAddress?.address != "")
              ? bookingEditController.pickedServiceAddress
              : (widget.isSubBooking
                    ? widget.bookingDetails.subBooking?.serviceAddress
                    : widget.bookingDetails.serviceAddress);
          Customer? customer = widget.isSubBooking
              ? widget.bookingDetails.subBooking?.customer
              : widget.bookingDetails.customer;

          String name =
              bookingEditController.selectedServiceLocationType ==
                  ServiceLocationType.provider
              ? provider?.companyName ?? ""
              : serviceAddress?.contactPersonName ?? "";

          String phone =
              bookingEditController.selectedServiceLocationType ==
                  ServiceLocationType.provider
              ? provider?.companyPhone ?? ""
              : serviceAddress?.contactPersonNumber ?? "";

          String? address =
              bookingEditController.selectedServiceLocationType ==
                  ServiceLocationType.provider
              ? provider?.companyAddress ?? ""
              : (serviceAddress?.address != null &&
                        serviceAddress?.address != ""
                    ? serviceAddress?.address
                    : null);

          String? image =
              bookingEditController.selectedServiceLocationType ==
                  ServiceLocationType.provider
              ? Get.find<UserProfileController>()
                        .providerModel
                        ?.content
                        ?.providerInfo
                        ?.logoFullPath ??
                    ""
              : (customer?.profileImageFullPath ?? "");

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: Get.height * 0.1,
                  maxHeight: (Get.height * 0.8 - 120),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "change_service_location".tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),
                      Text(
                        "change_service_location_hint".tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: Dimensions.paddingSizeLarge),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.05),
                        ),
                        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "change_service_location".tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault + 1,
                              ),
                            ),
                            SizedBox(height: Dimensions.paddingSizeSmall),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              child: Column(
                                children: [
                                  _RadioButtonWidget(
                                    title: "customer_location".tr,
                                    subTitle:
                                        "provider_has_to_go_customer_place".tr,
                                    isSelected:
                                        bookingEditController
                                            .selectedServiceLocationType ==
                                        ServiceLocationType.customer,
                                    onChanged: (bool value) {
                                      bookingEditController
                                          .updateServiceLocationType(
                                            type: ServiceLocationType.customer,
                                          );
                                    },
                                  ),
                                  _RadioButtonWidget(
                                    title: "provider_location".tr,
                                    subTitle:
                                        "customer_has_to_go_provider_place".tr,
                                    isSelected:
                                        bookingEditController
                                            .selectedServiceLocationType ==
                                        ServiceLocationType.provider,
                                    onChanged: (bool value) {
                                      bookingEditController
                                          .updateServiceLocationType(
                                            type: ServiceLocationType.provider,
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Dimensions.paddingSizeDefault),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.05),
                        ),
                        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Dimensions.paddingSizeSmall,
                          children: [
                            Text(
                              bookingEditController
                                          .selectedServiceLocationType ==
                                      ServiceLocationType.provider
                                  ? "provider_details".tr
                                  : "customer_details".tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault + 1,
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeSmall,
                              ),

                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: Dimensions.paddingSizeDefault,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CustomImage(
                                          height: 60,
                                          width: 60,
                                          placeholder: Images.userPlaceHolder,
                                          image: image,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 2,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    spacing: 2,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                        ),
                                                      ),

                                                      Text(
                                                        phone,
                                                        style: robotoRegular
                                                            .copyWith(
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .bodySmall
                                                                      ?.color
                                                                      ?.withValues(
                                                                        alpha:
                                                                            0.8,
                                                                      ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                if (bookingEditController
                                                        .selectedServiceLocationType ==
                                                    ServiceLocationType
                                                        .customer)
                                                  InkWell(
                                                    onTap: () => Get.to(
                                                      () =>
                                                          UpdateCustomerAddress(
                                                            address:
                                                                serviceAddress!,
                                                          ),
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSmall,
                                                            ),
                                                        border: Border.all(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                          width: 0.6,
                                                        ),
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 2,
                                                          ),
                                                      padding: EdgeInsets.all(
                                                        Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: address == null
                                                  ? Dimensions.paddingSizeSmall
                                                  : 0,
                                            ),

                                            if (address != null)
                                              Text(
                                                address,
                                                style: robotoRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color
                                                      ?.withValues(alpha: 0.6),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (address == null)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: 0.2),
                                      ),
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                        horizontal: Dimensions.paddingSizeSmall,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 5,
                                        children: [
                                          Icon(
                                            Icons.warning_rounded,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            size: Dimensions.paddingSizeLarge,
                                          ),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                text:
                                                    "to_provide_the_service_at_customer_place_need"
                                                        .tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall!.color,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        " ${'customer_address'.tr} ",
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .color,
                                                    ),
                                                  ),
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
                          ],
                        ),
                      ),

                      SizedBox(height: Dimensions.paddingSizeDefault),

                      widget.bookingEditType == BookingEditType.repeat
                          ? Padding(
                              padding: const EdgeInsets.only(
                                bottom: Dimensions.paddingSizeDefault,
                              ),
                              child: const CheckAllUpcomingBookingWidget(),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () {
                        String? serviceLocation =
                            widget.nextBooking?.serviceLocation ??
                            widget.bookingDetails.serviceLocation;
                        ServiceLocationType type = serviceLocation == "provider"
                            ? ServiceLocationType.provider
                            : ServiceLocationType.customer;

                        Get.find<BookingEditController>()
                            .updateIsCheckedAllUpcomingBooking(
                              shouldUpdate: false,
                            );
                        bookingEditController.setPickedServiceAddress(
                          address: null,
                          shouldUpdate: false,
                        );
                        bookingEditController.updateServiceLocationType(
                          type: type,
                          shouldUpdate: true,
                        );
                      },
                      btnTxt: 'reset'.tr,
                      radius: Dimensions.radiusDefault,
                      color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.2),
                      fontSize: Dimensions.fontSizeDefault,
                      textColor: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: CustomButton(
                      onPressed: address != null
                          ? () {
                              bookingEditController
                                  .changeServiceLocation(
                                    address: serviceAddress,
                                    serviceLocation: bookingEditController
                                        .selectedServiceLocationType
                                        .name,
                                    bookingId:
                                        Get.find<BookingDetailsController>()
                                            .bookingDetails
                                            ?.content
                                            ?.id,
                                    subBookingId:
                                        Get.find<BookingDetailsController>()
                                            .subBookingDetails
                                            ?.content
                                            ?.id,
                                    bookingEditType: widget.bookingEditType,
                                    changeNextAllBooking: bookingEditController
                                        .isCheckedAllUpcomingBooking,
                                  )
                                  .then((value) {
                                    if (value.isSuccess!) {
                                      Get.back();
                                      showCustomSnackBar(
                                        value.message,
                                        type: ToasterMessageType.success,
                                      );
                                    } else {
                                      showCustomSnackBar(value.message);
                                    }
                                  });
                            }
                          : null,
                      isLoading: bookingEditController.isLoading,
                      btnTxt: 'update'.tr,
                      fontSize: Dimensions.fontSizeDefault,
                      radius: Dimensions.radiusDefault,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RadioButtonWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool isSelected;
  final ValueChanged<bool> onChanged;
  const _RadioButtonWidget({
    required this.title,
    required this.subTitle,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  width: 1.8,
                ),
              ),
              margin: EdgeInsets.only(top: 3),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.tr,
                    style: robotoMedium.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subTitle.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class RenewSubscriptionPlanBottomSheet extends StatefulWidget {
  final SubscriptionPackage selectedPackage;
  final SubscriptionPackage? activePackage;
  final String? packageStatus;
  const RenewSubscriptionPlanBottomSheet({
    super.key,
    required this.selectedPackage,
    this.activePackage,
    this.packageStatus,
  });

  @override
  State<RenewSubscriptionPlanBottomSheet> createState() =>
      _RenewSubscriptionPlanBottomSheetState();
}

class _RenewSubscriptionPlanBottomSheetState
    extends State<RenewSubscriptionPlanBottomSheet> {
  @override
  void initState() {
    super.initState();
    Get.find<BusinessSubscriptionController>().updateDigitalPaymentMethodIndex(
      -1,
      shouldUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<BusinessSubscriptionController>(
        builder: (subscriptionController) {
          List<DigitalPaymentMethod> paymentMethodList =
              Get.find<SplashController>()
                  .configModel
                  .content
                  ?.paymentMethodList ??
              [];

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                topRight: Radius.circular(Dimensions.radiusExtraLarge),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: Dimensions.paddingSizeLarge,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                ),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: Get.height * 0.1,
                    maxHeight: (Get.height * 0.8 - 120),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.packageStatus == "renew"
                              ? 'renew_business_plan'.tr
                              : 'shift_to_new_business_plan'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Row(
                            mainAxisAlignment: widget.packageStatus == "renew"
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceBetween,
                            children: [
                              widget.activePackage?.id ==
                                      widget.selectedPackage.id
                                  ? const SizedBox()
                                  : Expanded(
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            child: Container(
                                              height: 125,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .hintColor
                                                      .withValues(alpha: 0.2),
                                                  width: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),

                                          ClipPath(
                                            clipper: TopCustomShape(),
                                            child: Container(
                                              height: 80,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.07),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            top: 20,
                                            left: 0,
                                            right: 0,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                  child: Text(
                                                    widget
                                                            .activePackage
                                                            ?.name
                                                            ?.tr ??
                                                        '',
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeLarge,
                                                      color:
                                                          Colors.cyan.shade700,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault,
                                                ),
                                                Text(
                                                  widget.activePackage?.id ==
                                                          "0"
                                                      ? "${widget.activePackage?.price?.toStringAsFixed(0)} %"
                                                      : PriceConverter.convertPrice(
                                                          widget
                                                                  .activePackage
                                                                  ?.price ??
                                                              0,
                                                        ),
                                                  style: robotoBold.copyWith(
                                                    fontSize: 25,
                                                    color: Colors.cyan.shade700,
                                                  ),
                                                ),

                                                Text(
                                                  widget.activePackage?.id ==
                                                          "0"
                                                      ? ""
                                                      : '${widget.activePackage?.duration} '
                                                                'days'
                                                            .tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(
                                                      context,
                                                    ).disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                              widget.activePackage?.id ==
                                      widget.selectedPackage.id
                                  ? const SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                      ),
                                      child: Image.asset(
                                        Images.shiftIcon,
                                        height: 30,
                                        width: 30,
                                      ),
                                    ),

                              widget.packageStatus == "renew"
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          child: Container(
                                            height: 125,
                                            width: 170,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  spreadRadius: 1,
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        ClipPath(
                                          clipper: TopCustomShape(),
                                          child: Container(
                                            height: 80,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.07),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusDefault,
                                                  ),
                                            ),
                                          ),
                                        ),

                                        Positioned(
                                          top: 20,
                                          left: 0,
                                          right: 0,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                child: Text(
                                                  widget
                                                          .selectedPackage
                                                          .name
                                                          ?.tr ??
                                                      '',
                                                  style: robotoBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault,
                                              ),
                                              Text(
                                                widget.selectedPackage.id == "0"
                                                    ? "${widget.selectedPackage.price?.toStringAsFixed(0)} %"
                                                    : PriceConverter.convertPrice(
                                                        widget
                                                                .selectedPackage
                                                                .price ??
                                                            0,
                                                      ),
                                                style: robotoBold.copyWith(
                                                  fontSize: 25,
                                                  color: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                ),
                                              ),

                                              Text(
                                                widget.selectedPackage.id == "0"
                                                    ? ""
                                                    : '${widget.selectedPackage.duration} '
                                                              'days'
                                                          .tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeDefault,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Expanded(
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            child: Container(
                                              height: 125,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    spreadRadius: 1,
                                                    blurRadius: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          ClipPath(
                                            clipper: TopCustomShape(),
                                            child: Container(
                                              height: 80,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.05,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                              ),
                                            ),
                                          ),

                                          Positioned(
                                            top: 20,
                                            left: 0,
                                            right: 0,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                  child: Text(
                                                    widget
                                                            .selectedPackage
                                                            .name
                                                            ?.tr ??
                                                        '',
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeLarge,
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault,
                                                ),
                                                Text(
                                                  widget.selectedPackage.id ==
                                                          "0"
                                                      ? "${widget.selectedPackage.price?.toStringAsFixed(0)} %"
                                                      : PriceConverter.convertPrice(
                                                          widget
                                                                  .selectedPackage
                                                                  .price ??
                                                              0,
                                                        ),
                                                  style: robotoBold.copyWith(
                                                    fontSize: 25,
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                  ),
                                                ),
                                                Text(
                                                  widget.selectedPackage.id ==
                                                          "0"
                                                      ? ""
                                                      : '${widget.selectedPackage.duration} '
                                                                'days'
                                                            .tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault,
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

                        widget.selectedPackage.name == "commission_base" &&
                                widget.selectedPackage.id == "0"
                            ? const SizedBox()
                            : const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),

                        widget.selectedPackage.name == "commission_base" &&
                                widget.selectedPackage.id == "0"
                            ? const SizedBox()
                            : Container(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall + 2,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).disabledColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'validity'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Text(
                                            '${widget.selectedPackage.duration} '
                                                    'days'
                                                .tr,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraLarge,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'price'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Text(
                                            PriceConverter.convertPrice(
                                              widget.selectedPackage.price,
                                            ),
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'bill_status'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Text(
                                            widget.packageStatus == "renew"
                                                ? 'renew'.tr
                                                : 'migrate'.tr,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        widget.selectedPackage.name == "commission_base" &&
                                widget.selectedPackage.id == "0"
                            ? const SizedBox()
                            : paymentMethodList.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).disabledColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${'pay_via_online'.tr} ',
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              "(${'faster_and_secure_way_to_pay_bill'.tr})",
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    ListView.builder(
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          children: [
                                            DigitalPaymentButtonWidget(
                                              isSelected:
                                                  subscriptionController
                                                      .selectedDigitalPaymentMethodIndex ==
                                                  index,
                                              paymentMethod:
                                                  paymentMethodList[index],
                                            ),

                                            Positioned.fill(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                child: CustomInkWell(
                                                  onTap: () {
                                                    subscriptionController
                                                        .updateDigitalPaymentMethodIndex(
                                                          index,
                                                        );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      shrinkWrap: true,
                                      itemCount: paymentMethodList.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeExtraLarge,
                                ),
                                child: Text(
                                  "no_payment_method_available".tr,
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: CustomButton(
                          onPressed: () => Get.back(),
                          btnTxt: 'cancel'.tr,
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
                        flex: 2,
                        child: CustomButton(
                          onPressed: () {
                            if (widget.selectedPackage.name ==
                                    "commission_base" &&
                                widget.selectedPackage.id == "0") {
                              subscriptionController.changeBusinessPlan(
                                packageId: "",
                                paymentMethod: "",
                                packageStatus: "commission",
                              );
                            } else if (subscriptionController
                                    .selectedDigitalPaymentMethodIndex ==
                                -1) {
                              showCustomSnackBar(
                                "select_payment_method".tr,
                                type: ToasterMessageType.info,
                              );
                            } else {
                              subscriptionController.changeBusinessPlan(
                                packageId: widget.selectedPackage.id!,
                                paymentMethod:
                                    paymentMethodList[subscriptionController
                                            .selectedDigitalPaymentMethodIndex]
                                        .gateway ??
                                    "",
                                packageStatus: widget.packageStatus ?? "",
                              );
                            }
                          },
                          btnTxt: widget.packageStatus == "renew"
                              ? 'renew_subscription_plan'.tr
                              : 'shift_subscription_plan'.tr,
                          fontSize: Dimensions.fontSizeDefault,
                          radius: Dimensions.radiusDefault,
                          isLoading: subscriptionController.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

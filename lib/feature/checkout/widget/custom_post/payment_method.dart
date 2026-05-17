import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class PaymentMethod extends StatefulWidget {
  final String? postId;
  final String? providerId;
  const PaymentMethod({super.key, this.postId, this.providerId});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  List<PaymentMethodButton> _getPaymentMethods() {
    List<PaymentMethodButton> methods = [];

    if (Get.find<SplashController>().configModel.content?.digitalPayment == 1) {
      methods.add(
        PaymentMethodButton(
          title: "pay_now".tr,
          paymentMethodName: PaymentMethodName.digitalPayment,
          assetName: Images.pay,
        ),
      );
    }
    if (Get.find<SplashController>().configModel.content?.cashAfterService ==
        1) {
      methods.add(
        PaymentMethodButton(
          title: "cash_after_service".tr,
          paymentMethodName: PaymentMethodName.cos,
          assetName: Images.cod,
        ),
      );
    }
    if (Get.find<SplashController>().configModel.content?.walletStatus == 1) {
      methods.add(
        PaymentMethodButton(
          title: "pay_via_wallet".tr,
          paymentMethodName: PaymentMethodName.walletMoney,
          assetName: Images.walletMenu,
        ),
      );
    }

    return methods;
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = _getPaymentMethods();

    return GetBuilder<CheckOutController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Payment Method Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: ResponsiveHelper.isMobile(context) ? 70 : 80,
                ),
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.easeOutBack,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: paymentMethods[index],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              // Digital Payment Options
              GetBuilder<CheckOutController>(
                builder: (controller) {
                  if (controller.selectedPaymentMethod ==
                      PaymentMethodName.digitalPayment) {
                    List<DigitalPaymentMethod>? paymentGateways =
                        Get.find<SplashController>()
                            .configModel
                            .content
                            ?.paymentMethodList;

                    if (paymentGateways != null && paymentGateways.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              'select_payment_gateway'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 70,
                                  crossAxisCount:
                                      ResponsiveHelper.isDesktop(context)
                                      ? 4
                                      : ResponsiveHelper.isTab(context)
                                      ? 3
                                      : 2,
                                ),
                            itemCount: paymentGateways.length,
                            itemBuilder: (context, index) {
                              final gateway = paymentGateways[index];
                              final isSelected =
                                  controller.selectedDigitalPaymentMethod ==
                                  gateway;

                              return TweenAnimationBuilder(
                                duration: Duration(
                                  milliseconds: 200 + (index * 50),
                                ),
                                tween: Tween<double>(begin: 0, end: 1),
                                curve: Curves.easeOut,
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: 0.9 + (value * 0.1),
                                    child: Opacity(
                                      opacity: value,
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.changePaymentMethod(
                                              digitalMethod: gateway,
                                            ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Theme.of(context)
                                                        .dividerColor
                                                        .withOpacity(0.2),
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.2),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: DigitalPayment(
                                                  paymentGateway:
                                                      gateway.gateway ?? '',
                                                ),
                                              ),
                                              if (isSelected)
                                                Positioned(
                                                  top: 6,
                                                  right: 6,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                          blurRadius: 8,
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'online_payment_option_is_not_available'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

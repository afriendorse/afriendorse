import 'package:afriendorse/athlete/utils/core_export.dart';

import 'package:get/get.dart';

class PaymentFailedScreen extends StatefulWidget {
  final String url;
  final String fromPage;
  const PaymentFailedScreen({
    super.key,
    required this.url,
    required this.fromPage,
  });
  @override
  State<PaymentFailedScreen> createState() => _PaymentFailedScreenState();
}

class _PaymentFailedScreenState extends State<PaymentFailedScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        return;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeLarge,
                          right: Dimensions.paddingSizeLarge,
                          top: Dimensions.paddingSizeExtraMoreLarge,
                          bottom: Dimensions.paddingSizeLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'provider_registration'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),

                            Text(
                              'transaction_failed'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            LinearProgressIndicator(
                              backgroundColor: Theme.of(context).disabledColor,
                              minHeight: 3,
                              value: 0.75,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: context.height * 0.17),

                      Column(
                        children: [
                          Image.asset(Images.cautionDialogIcon, height: 100),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),

                                Text(
                                  '${'transaction_failed'.tr}!',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                SizedBox(
                                  width: context.width,
                                  child: Text(
                                    'sorry_your_transaction_can_not_be_completed_please_choose_another_payment_method_or_try_again'
                                        .tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                TextButton(
                                  onPressed: () {
                                    Get.to(
                                      () => PaymentScreen(
                                        url: widget.url,
                                        fromPage: widget.fromPage,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'try_again'.tr,
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeDefault,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

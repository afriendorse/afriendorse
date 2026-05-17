import 'package:afriendorse/athlete/feature/payement_information/controller/payment_info_controller.dart';
import 'package:afriendorse/athlete/feature/payement_information/model/payment_method_list_model.dart';
import 'package:afriendorse/athlete/feature/payement_information/widgets/method_popup_button_widget.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class PaymentInfoCard extends StatelessWidget {
  final PaymentMethodItem? paymentMethod;
  final int? index;
  const PaymentInfoCard({super.key, this.index, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeEight),
      ),
      child: GetBuilder<PaymentInfoController>(
        builder: (paymentInfoController) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(paymentMethod?.methodName ?? '', style: robotoBold),
                  SizedBox(width: Dimensions.paddingSizeSmall),

                  if ((paymentMethod?.isDefault ?? false) && index != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeEight,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      decoration: BoxDecoration(
                        color: context.customThemeColors.success.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeExtraSmall,
                        ),
                      ),
                      child: Text(
                        'default'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: context.customThemeColors.success,
                        ),
                      ),
                    ),

                  Spacer(),

                  if (index != null)
                    MethodPopupButtonWidget(
                      paymentMethod: paymentMethod,
                      index: index,
                    ),
                ],
              ),

              Container(
                margin: EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(
                    Dimensions.paddingSizeExtraSmall,
                  ),
                ),
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String inputFieldKey =
                        paymentMethod?.methodFieldData?.keys.elementAt(index) ??
                        '';
                    String inputFieldValue =
                        paymentMethod?.methodFieldData?.values.elementAt(
                          index,
                        ) ??
                        'N/A';
                    return _InfoItemWidget(
                      label: inputFieldKey.tr,
                      info: inputFieldValue.tr,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  itemCount: paymentMethod?.methodFieldData?.length ?? 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoItemWidget extends StatelessWidget {
  final String? label;
  final String? info;
  const _InfoItemWidget({this.label, this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),

        Text(
          ' : ',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),

        Flexible(
          child: Text(
            info ?? '',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}

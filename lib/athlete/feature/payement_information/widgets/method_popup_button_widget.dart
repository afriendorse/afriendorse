import 'package:afriendorse/athlete/common/enums/payment_info_menu_enum.dart';
import 'package:afriendorse/athlete/common/widgets/custom_alert_dialog_widget.dart';
import 'package:afriendorse/athlete/common/widgets/custom_menu_item_widget.dart';
import 'package:afriendorse/athlete/common/widgets/custom_switch_widget.dart';
import 'package:afriendorse/athlete/feature/payement_information/controller/payment_info_controller.dart';
import 'package:afriendorse/athlete/feature/payement_information/model/payment_method_list_model.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MethodPopupButtonWidget extends StatelessWidget {
  const MethodPopupButtonWidget({
    super.key,
    required this.paymentMethod,
    required this.index,
  });

  final PaymentMethodItem? paymentMethod;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final PaymentInfoController paymentInfoController =
        Get.find<PaymentInfoController>();

    return PopupMenuButton<PaymentInfoMenuEnum>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      child: Skeleton.shade(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeTini,
            vertical: Dimensions.paddingSizeTini,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeEight),
            border: Border.all(
              color: Theme.of(context).primaryColorDark,
              width: 0.8,
            ),
          ),
          child: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryColor,
            size: Dimensions.paddingSizeLarge,
          ),
        ),
      ),
      onSelected: (value) async {
        switch (value) {
          case PaymentInfoMenuEnum.status:
            {
              if ((paymentMethod?.isDefault ?? false)) {
                showCustomSnackBar('can_not_change_default_method_status'.tr);
              } else {
                statusButtonClick(
                  context,
                  !(paymentInfoController
                          .paymentMethodListModel
                          ?.content?[index!]
                          .isActive ??
                      false),
                  paymentInfoController,
                );
              }
              break;
            }
          case PaymentInfoMenuEnum.markDefault:
            {
              if (paymentMethod?.isDefault ?? false) {
                showCustomSnackBar('already_marked_as_default'.tr);
                return;
              } else {
                await paymentInfoController.markPaymentMethodAsDefault(
                  paymentMethod?.id,
                );
              }
            }
            break;
          case PaymentInfoMenuEnum.edit:
            {
              Get.toNamed(
                RouteHelper.getAddPaymentInformationRoute(
                  index: index,
                  methodName: paymentMethod?.methodName,
                  methodId: paymentMethod?.id,
                  isActive: paymentMethod?.isActive,
                  isDefault: paymentMethod?.isDefault,
                ),
              );
              break;
            }
          case PaymentInfoMenuEnum.delete:
            {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => CustomAlertDialogWidget(
                  title: 'delete_payment_info'.tr,
                  subTitle: 'are_you_sure_delete_payment_info'.tr,
                  icon: Icons.delete,
                  onPressRight: () {
                    Get.back();
                    paymentInfoController.deletePaymentMethod(
                      paymentMethod?.id,
                    );
                  },
                ),
              );

              break;
            }
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<PaymentInfoMenuEnum>(
          padding: EdgeInsets.zero,
          enabled: !(paymentMethod?.isDefault ?? false),
          value: PaymentInfoMenuEnum.status,
          child: CustomMenuItemWidget(
            padding: EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeExtraSmall,
              top: Dimensions.paddingSizeExtraSmall,
              bottom: Dimensions.paddingSizeExtraSmall,
            ),
            title: 'status'.tr,
            child: GetBuilder<PaymentInfoController>(
              builder: (paymentInfoController) {
                return CustomSwitchWidget(
                  value:
                      paymentInfoController
                          .paymentMethodListModel
                          ?.content?[index!]
                          .isActive ??
                      false,
                  activeColor: (paymentMethod?.isDefault ?? false)
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                      : Theme.of(context).primaryColor,
                  onChanged: (value) async {
                    if ((paymentMethod?.isDefault ?? false)) {
                      showCustomSnackBar(
                        'can_not_change_default_method_status'.tr,
                      );
                    } else {
                      statusButtonClick(context, value, paymentInfoController);
                    }
                  },
                );
              },
            ),
          ),
        ),

        PopupMenuItem<PaymentInfoMenuEnum>(
          padding: EdgeInsets.zero,
          enabled: !(paymentMethod?.isDefault ?? false),
          value: PaymentInfoMenuEnum.markDefault,
          child: CustomMenuItemWidget(
            title: 'mark_as_default'.tr,
            child: Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeTini),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (paymentMethod?.isDefault ?? false)
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).colorScheme.tertiary,
              ),
              child: Icon(
                Icons.check,
                color: Theme.of(context).cardColor,
                size: Dimensions.paddingSizeDefault,
              ),
            ),
          ),
        ),

        PopupMenuItem<PaymentInfoMenuEnum>(
          padding: EdgeInsets.zero,
          value: PaymentInfoMenuEnum.edit,
          child: CustomMenuItemWidget(
            title: 'edit'.tr,
            child: Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeTini),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).cardColor,
                size: Dimensions.paddingSizeDefault,
              ),
            ),
          ),
        ),

        PopupMenuItem<PaymentInfoMenuEnum>(
          enabled: !(paymentMethod?.isDefault ?? false),
          padding: EdgeInsets.zero,
          value: PaymentInfoMenuEnum.delete,
          child: CustomMenuItemWidget(
            title: 'delete'.tr,
            child: Image.asset(
              Images.deleteIcon,
              height: Dimensions.paddingSizeLarge,
              width: Dimensions.paddingSizeLarge,
              color: (paymentMethod?.isDefault ?? false)
                  ? Theme.of(context).disabledColor
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void statusButtonClick(
    BuildContext context,
    bool value,
    PaymentInfoController paymentInfoController,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => CustomAlertDialogWidget(
        title:
            '${value ? 'do_you_want_to_to_enable_the_status_of'.tr : 'do_you_want_to_to_disable_the_status_of'.tr} ${paymentMethod?.methodName}?',
        subTitle: value
            ? 'turning_on_this_status_wil_make'.tr
            : 'turning_off_this_status_wil_make'.tr,
        subTitleStyle: robotoRegular.copyWith(
          color: Theme.of(
            context,
          ).textTheme.titleLarge?.color?.withValues(alpha: 0.5),
        ),
        image: Images.switchIcon,
        onPressRight: () async {
          Get.back();
          Get.back();

          await paymentInfoController.statusUpdatePaymentMethod(
            methodId: paymentMethod?.id,
            index: index,
            status: (paymentMethod?.isActive ?? false) ? false : true,
          );
        },
      ),
    );
  }
}

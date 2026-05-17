import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/reporting/model/transaction_report_model.dart';
import 'package:get/get.dart';

class TransactionReportStatistics extends StatelessWidget {
  final TransactionReportAccountInfo accountInfo;
  const TransactionReportStatistics({super.key, required this.accountInfo});

  @override
  Widget build(BuildContext context) {
    List<String> itemsTitle = [];
    List<String> itemsAmount = [];
    List<String> infoText = [];
    List<String> bg = [];

    double providerBalance =
        accountInfo.totalWithdrawn! + accountInfo.receivedBalance!;

    itemsTitle = [
      'provider_balance'.tr,
      'pending_balance'.tr,
      'commission_given'.tr,
      'account_payable'.tr,
      'account_receivable'.tr,
    ];
    bg = ['0xFF286FC6', '0xFF5ABD88', '0xFFD0517F', '0xFF2BA361', '0xFFFF6D6D'];
    infoText = [
      'provider_balance_info',
      'pending_balance_info',
      'already_withdrawn_info',
      'account_payable_info',
      'account_receivable_info',
    ];
    itemsAmount = [
      providerBalance.toString(),
      accountInfo.balancePending.toString(),
      accountInfo.totalWithdrawn.toString(),
      accountInfo.accountPayable.toString(),
      accountInfo.accountReceivable.toString(),
    ];

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? Theme.of(context).cardColor.withValues(alpha: 0.5)
            : Theme.of(context).cardColor,
        boxShadow: context.customThemeColors.lightShadow,
      ),
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Container(
              height: double.infinity,
              width: MediaQuery.of(context).size.width * 0.5,
              margin: const EdgeInsets.only(
                right: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Color(int.parse(bg[index]))),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PriceConverter.convertPrice(
                            double.tryParse(itemsAmount[index]),
                          ),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Color(int.parse(bg[index])),
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                        Text(
                          itemsTitle[index],
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(270),
                        ),
                        color: Color(
                          int.parse(bg[index]),
                        ).withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -10,
                    right: -10,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: Color(int.parse(bg[index])),
                      ),
                      //onSelected: handleClick,
                      itemBuilder: (BuildContext context) {
                        return {infoText[index]}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice.tr),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: 5,
        ),
      ),
    );
  }
}

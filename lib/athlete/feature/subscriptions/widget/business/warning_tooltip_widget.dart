import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';
import 'package:get/get.dart';

class WarningTooltipWidget extends StatefulWidget {
  final JustTheController? tooltipController;
  final SubscribedPackageDetails? subscriptionDetails;
  const WarningTooltipWidget({
    super.key,
    required this.tooltipController,
    this.subscriptionDetails,
  });

  @override
  State<WarningTooltipWidget> createState() => _WarningTooltipWidgetState();
}

class _WarningTooltipWidgetState extends State<WarningTooltipWidget> {
  @override
  Widget build(BuildContext context) {
    bool isFreeTrial = widget.subscriptionDetails?.trialDuration != 0;
    bool isPaid = widget.subscriptionDetails?.isPaid == 0 ? false : true;
    int remainingDays = widget.subscriptionDetails != null
        ? DateConverter.countDays(
            endDate: DateTime.tryParse(
              widget.subscriptionDetails?.packageEndDate ?? "",
            ),
          )
        : 0;

    return JustTheTooltip(
      controller: widget.tooltipController,
      tailLength: 0,
      content: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'attention'.tr,
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const Icon(Icons.close, color: Colors.white),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              (!isPaid && !isFreeTrial)
                  ? "unpaid_subscription_message".tr
                  : isFreeTrial && remainingDays > 0
                  ? '${'your_subscription_trial_period_is_ending_soon_please_renew_before'.tr} ${DateConverter.dateStringMonthYear(DateTime.tryParse(widget.subscriptionDetails?.packageEndDate ?? ""))}. ${'otherwise_all_your_activities_will_turn_off_automatically_after_that'.tr}'
                  : isFreeTrial && remainingDays <= 0
                  ? '${'your_free_trial_has_been_ended'.tr} ${DateConverter.dateStringMonthYear(DateTime.tryParse(widget.subscriptionDetails?.packageEndDate ?? "")?.subtract(const Duration(days: 1)))}.  ${'purchase_subscription_message'.tr}'
                  : !isFreeTrial && remainingDays > 0
                  ? '${'your_subscription_is_ending_soon_please_renew_before'.tr} ${DateConverter.dateStringMonthYear(DateTime.tryParse(widget.subscriptionDetails?.packageEndDate ?? ""))}. ${'otherwise_all_your_activities_will_turn_off_automatically_after_that'.tr}'
                  : "${'your_subscription_has_been_expired'.tr}. ${'purchase_subscription_message'.tr}",
              style: robotoRegular.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: () {
          widget.tooltipController?.showTooltip();
        },
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: Dimensions.paddingSizeExtraSmall,
          ),
          child: Icon(Icons.info, color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

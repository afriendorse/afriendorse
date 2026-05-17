import 'package:afriendorse/feature/booking/widget/custom_booking_details_expansion_tile.dart';
import 'package:afriendorse/feature/booking/widget/repeat/make_repeat_booking_payment.dart';
import 'package:afriendorse/feature/checkout/widget/payment_section/payment_dialog.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

// ═══════════════════════════════════════════════════════════════════════════
// payment_info_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

class PaymentView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;

  const PaymentView({
    super.key,
    required this.bookingDetails,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return isSubBooking &&
            bookingDetails.isPaid == 0 &&
            (bookingDetails.bookingStatus == 'ongoing' ||
                bookingDetails.bookingStatus == 'accepted')
        ? _MakePaymentView(bookingDetails)
        : _PaidPaymentView(bookingDetails);
  }
}

// ── Paid Payment View ──────────────────────────────────────────────────────

class _PaidPaymentView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const _PaidPaymentView(this.bookingDetails);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isPaid = bookingDetails.isPaid != 0;

    bool isPartialPayment =
        bookingDetails.partialPayments != null &&
        bookingDetails.partialPayments!.isNotEmpty;

    double payAmount = bookingDetails.totalBookingAmount ?? 0;
    if (isPartialPayment) {
      bookingDetails.partialPayments?.forEach((element) {
        if (element.paidWith == 'wallet') {
          payAmount = element.dueAmount ?? 0;
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Denied Note Banner ─────────────────────────────────────────
        if (bookingDetails.offlinePaymentDeniedNote != null &&
            bookingDetails.paymentMethod == 'offline_payment')
          _buildDeniedNoteBanner(context),

        if (bookingDetails.offlinePaymentDeniedNote != null &&
            bookingDetails.paymentMethod == 'offline_payment')
          const SizedBox(height: Dimensions.paddingSizeSmall),

        // ── Payment Card ───────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card Header ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment_rounded, size: 18, color: primary),
                        const SizedBox(width: 8),
                        Text(
                          'payment_method'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    _buildPaymentBadge(context, isPaid),
                  ],
                ),
              ),

              // ── Method + Amount Row ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _paymentIcon(bookingDetails.paymentMethod ?? ''),
                              size: 16,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${bookingDetails.paymentMethod}'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice(
                              payAmount,
                              isShowLongPrice: true,
                            ),
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Transaction ID ───────────────────────────────
                    if (bookingDetails.paymentMethod != 'offline_payment' &&
                        bookingDetails.paymentMethod != 'cash_after_service' &&
                        bookingDetails.transactionId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tag_rounded,
                                size: 13,
                                color: Theme.of(context).hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${'transaction_id'.tr}: ${bookingDetails.transactionId?.replaceAll("_", " ").capitalizeFirst}',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Offline Payment Details ───────────────────────
                    if (bookingDetails.paymentMethod == 'offline_payment' &&
                        bookingDetails.bookingOfflinePayment != null &&
                        bookingDetails.bookingOfflinePayment!.isNotEmpty)
                      _buildOfflineDetails(context),

                    // ── Action Buttons ───────────────────────────────
                    _buildPaymentActions(context, payAmount, primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _paymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash_after_service':
        return Icons.money_rounded;
      case 'wallet_payment':
        return Icons.account_balance_wallet_rounded;
      case 'offline_payment':
        return Icons.receipt_long_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  Widget _buildPaymentBadge(BuildContext context, bool isPaid) {
    final color = isPaid ? Colors.green : Colors.red;
    final icon = isPaid ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = isPaid ? 'paid'.tr : 'unpaid'.tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeniedNoteBanner(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: error.withOpacity(0.08),
        border: Border.all(color: error.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'denied_note'.tr}:',
                  style: robotoMedium.copyWith(color: error),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${bookingDetails.offlinePaymentDeniedNote}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: error.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: CustomBookingDetailsExpansionTile(
        isShowExpandIcon: true,
        tilePadding: EdgeInsets.zero,
        isShowTrailingExpandIcon: false,
        bookingTitle: 'payment_info'.tr,
        bookingType: bookingDetails.offlinePaymentMethodName ?? '',
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).primaryColor.withOpacity(0.15),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookingDetails.bookingOfflinePayment?.length,
            padding: const EdgeInsets.only(
              top: Dimensions.paddingSizeExtraSmall,
            ),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeExtraSmall,
              ),
              child: Text(
                '${bookingDetails.bookingOfflinePayment?[index].key?.replaceAll("_", " ").capitalizeFirst}'
                ': ${bookingDetails.bookingOfflinePayment?[index].value}',
                style: robotoRegular.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentActions(
    BuildContext context,
    double payAmount,
    Color primary,
  ) {
    // Switch + Update buttons (unpaid offline with evidence)
    if (bookingDetails.isPaid == 0 &&
        bookingDetails.paymentMethod == 'offline_payment' &&
        bookingDetails.bookingOfflinePayment != null &&
        bookingDetails.bookingOfflinePayment!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: Text(
                  'switch_to_cas_short'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                onPressed: () => Get.dialog(
                  ConfirmationDialog(
                    icon: Images.warning,
                    title: 'switch_to_cas'.tr,
                    description:
                        'are_you_sure_to_change_payment_offline_to_cas'.tr,
                    noButtonText: 'cancel'.tr,
                    yesButtonText: 'yes_continue'.tr,
                    yesButtonColor: primary,
                    onYesPressed: () async {
                      Get.back();
                      Get.dialog(
                        const CustomLoader(),
                        barrierDismissible: false,
                      );
                      await Get.find<CheckOutController>().switchPaymentMethod(
                        bookingId: bookingDetails.id ?? '',
                        paymentMethod: 'cash_after_service',
                      );
                      Get.back();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text(
                  'update_payment_info'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                onPressed: () {
                  final checkoutController = Get.find<CheckOutController>();
                  final list = checkoutController.offlinePaymentModelList;
                  int index = list.indexWhere(
                    (o) => o.id == bookingDetails.offlinePaymentId,
                  );
                  if (index != -1) {
                    checkoutController.changePaymentMethod(
                      offlinePaymentModel: list[index],
                    );
                  }
                  Get.toNamed(
                    RouteHelper.getOfflinePaymentRoute(
                      fromPage: 'booking_details',
                      totalAmount: payAmount,
                      index: index != -1 ? index : 0,
                      offlinePaymentData: bookingDetails.bookingOfflinePayment,
                      bookingId: bookingDetails.id,
                      offlinePaymentId: bookingDetails.offlinePaymentId,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Pay Now (offline, no evidence, not cancelled)
    if (bookingDetails.paymentMethod == 'offline_payment' &&
        bookingDetails.bookingOfflinePayment == null &&
        bookingDetails.bookingStatus != 'canceled') {
      return Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'payment_incomplete'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.payment_rounded, size: 16),
              label: Text(
                'pay_now'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              onPressed: () {
                Get.find<CheckOutController>().changePaymentMethod(
                  shouldUpdate: false,
                );
                if (ResponsiveHelper.isDesktop(context)) {
                  Get.dialog(
                    Center(child: PaymentDialog(booking: bookingDetails)),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => PaymentDialog(booking: bookingDetails),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}

// ── Make Payment View ──────────────────────────────────────────────────────

class _MakePaymentView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const _MakePaymentView(this.bookingDetails);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isPaid = bookingDetails.isPaid == 1;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          // ── Amount info ──────────────────────────────────────────────
          Expanded(
            flex: ResponsiveHelper.isDesktop(context) ? 4 : 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'total_amount'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice(
                      bookingDetails.totalBookingAmount ?? 0,
                    ),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (isPaid ? Colors.green : Colors.red).withOpacity(
                      0.12,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isPaid ? Colors.green : Colors.red).withOpacity(
                        0.35,
                      ),
                    ),
                  ),
                  child: Text(
                    isPaid ? 'paid'.tr : 'unpaid'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isPaid ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Make Payment Button ──────────────────────────────────────
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.payment_rounded, size: 18),
              label: Text(
                'make_payment'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              onPressed: () {
                if (ResponsiveHelper.isDesktop(context)) {
                  Get.dialog(
                    RepeatBookingPaymentDialog(bookingDetails: bookingDetails),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => RepeatBookingPaymentDialog(
                      bookingDetails: bookingDetails,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

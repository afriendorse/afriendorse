// ═══════════════════════════════════════════════════════════════════════════
// booking_summery_view.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:afriendorse/athlete/helper/booking_helper.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingSummeryView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;

  const BookingSummeryView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        final primary = Theme.of(context).colorScheme.primary;
        double paidAmount = 0;
        final double discount = bookingDetails.totalDiscountAmount ?? 0;
        final double campaignDiscount =
            bookingDetails.totalCampaignDiscountAmount ?? 0;
        final double totalDiscount = discount + campaignDiscount;
        final double subTotal = BookingHelper.getSubTotalCost(bookingDetails);
        final double totalBookingAmount =
            bookingDetails.totalBookingAmount ?? 0;
        final bool isPartialPayment =
            bookingDetails.partialPayments != null &&
            bookingDetails.partialPayments!.isNotEmpty;

        if (isPartialPayment) {
          bookingDetails.partialPayments?.forEach(
            (e) => paidAmount += e.paidAmount ?? 0,
          );
        } else {
          paidAmount =
              totalBookingAmount - (bookingDetails.additionalCharge ?? 0);
        }

        final double dueAmount = totalBookingAmount - paidAmount;
        final double additionalCharge = isPartialPayment
            ? totalBookingAmount - paidAmount
            : bookingDetails.additionalCharge ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              _buildCardHeader(context, primary),

              // ── Service table header ──────────────────────────────────
              _buildTableHeader(context, primary),

              // ── Service items ─────────────────────────────────────────
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                itemCount: bookingDetails.details?.length ?? 0,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                itemBuilder: (context, index) => ServiceInfoItem(
                  bookingService: bookingDetails.details?[index],
                  bookingDetailsController: bookingDetailsController,
                  index: index,
                ),
              ),

              // ── Price breakdown ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault,
                  0,
                ),
                child: Column(
                  children: [
                    Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    _summaryRow(
                      context,
                      'subtotal_vat_ex'.tr,
                      PriceConverter.convertPrice(
                        subTotal,
                        isShowLongPrice: true,
                      ),
                    ),

                    if (bookingDetails.isRepeatBooking == 1)
                      _summaryRow(
                        context,
                        '${'sub_total'.tr} x ${bookingDetails.totalCount ?? ''} ${'days'.tr}',
                        PriceConverter.convertPrice(
                          subTotal * (bookingDetails.totalCount ?? 1),
                          isShowLongPrice: true,
                        ),
                      ),

                    _summaryRow(
                      context,
                      'service_discount'.tr,
                      '(-) ${PriceConverter.convertPrice(totalDiscount, isShowLongPrice: true)}',
                      valueColor: Colors.red.withOpacity(0.8),
                    ),

                    _summaryRow(
                      context,
                      'coupon_discount'.tr,
                      '(-) ${PriceConverter.convertPrice(bookingDetails.totalCouponDiscountAmount ?? 0, isShowLongPrice: true)}',
                      valueColor: Colors.red.withOpacity(0.8),
                    ),

                    if ((bookingDetails.totalReferralDiscountAmount ?? 0) > 0)
                      _summaryRow(
                        context,
                        'referral_discount'.tr,
                        '(-) ${PriceConverter.convertPrice(bookingDetails.totalReferralDiscountAmount ?? 0)}',
                        valueColor: Colors.red.withOpacity(0.8),
                      ),

                    _summaryRow(
                      context,
                      'service_tax'.tr,
                      '(+) ${PriceConverter.convertPrice(bookingDetails.totalTaxAmount ?? 0, isShowLongPrice: true)}',
                      valueColor: Colors.orange.withOpacity(0.85),
                    ),

                    if ((bookingDetails.extraFee ?? 0) > 0)
                      _summaryRow(
                        context,
                        Get.find<SplashController>()
                                .configModel
                                .content
                                ?.additionalChargeLabelName ??
                            '',
                        '(+) ${PriceConverter.convertPrice(bookingDetails.extraFee ?? 0, isShowLongPrice: true)}',
                        valueColor: Colors.orange.withOpacity(0.85),
                      ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              ),

              // ── Grand total ───────────────────────────────────────────
              _buildGrandTotal(
                context,
                primary,
                totalBookingAmount,
                paidAmount,
                dueAmount,
                additionalCharge,
                isPartialPayment,
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],
          ),
        );
      },
    );
  }

  // ── Card Header ────────────────────────────────────────────────────────────

  Widget _buildCardHeader(BuildContext context, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_rounded, size: 18, color: primary),
          const SizedBox(width: 8),
          Text(
            'booking_summary'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Table Header ───────────────────────────────────────────────────────────

  Widget _buildTableHeader(BuildContext context, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 12,
      ),
      color: primary.withOpacity(0.07),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'service_info'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            'price'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Row ────────────────────────────────────────────────────────────

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color:
                    valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grand Total ────────────────────────────────────────────────────────────

  Widget _buildGrandTotal(
    BuildContext context,
    Color primary,
    double total,
    double paid,
    double due,
    double additionalCharge,
    bool isPartialPayment,
  ) {
    final isDark = Get.isDarkMode;
    final totalColor = isDark
        ? Theme.of(context).textTheme.bodyLarge?.color
        : primary;

    Widget grandRow() => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'grand_total'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: totalColor,
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              PriceConverter.convertPrice(total, isShowLongPrice: true),
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: totalColor,
              ),
            ),
          ),
        ],
      ),
    );

    // Simple grand total
    if (!isPartialPayment && bookingDetails.paymentMethod != 'wallet_payment') {
      if (additionalCharge == 0 ||
          bookingDetails.paymentMethod == 'cash_after_service') {
        return grandRow();
      }
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: _breakdownCard(
          context,
          primary,
          children: [
            grandRow(),
            if (additionalCharge > 0) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _buildDueRow(context, additionalCharge),
            ],
          ],
        ),
      );
    }

    // Wallet payment
    if (!isPartialPayment && bookingDetails.paymentMethod == 'wallet_payment') {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(
          children: [
            grandRow(),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _breakdownCard(
              context,
              primary,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: Text(
                    (bookingDetails.additionalCharge! <= 0)
                        ? 'total_order_amount_has_been_paid_by_customer'.tr
                        : 'has_been_paid_by_customer'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _buildWalletRow(context, paid),
                if (additionalCharge > 0) ...[
                  const SizedBox(height: 6),
                  _buildDueRow(context, additionalCharge),
                ],
              ],
            ),
          ],
        ),
      );
    }

    // Partial payments
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: _breakdownCard(
        context,
        primary,
        children: [
          grandRow(),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...List.generate(bookingDetails.partialPayments?.length ?? 0, (
            index,
          ) {
            final p = bookingDetails.partialPayments![index];
            final payWith = p.paidWith ?? '';
            return Padding(
              padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeExtraSmall,
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 14,
                        color: primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${payWith == "cash_after_service"
                            ? "paid_amount".tr
                            : payWith == "digital" && bookingDetails.paymentMethod == "offline_payment"
                            ? ""
                            : "paid_by".tr} '
                        '${payWith == "digital" ? "${bookingDetails.paymentMethod}".tr : (payWith == "cash_after_service" ? "(${"cash_after_service".tr})" : payWith).tr}',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      PriceConverter.convertPrice(
                        p.paidAmount ?? 0,
                        isShowLongPrice: true,
                      ),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if ((bookingDetails.partialPayments?.length ?? 0) == 1 && due > 0)
            _buildDueRow(context, due),
        ],
      ),
    );
  }

  Widget _breakdownCard(
    BuildContext context,
    Color primary, {
    required List<Widget> children,
  }) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        dashPattern: const [8, 4],
        strokeWidth: 1.1,
        color: primary,
        radius: const Radius.circular(Dimensions.radiusDefault),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildWalletRow(BuildContext context, double paid) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(Images.walletSmall, width: 16),
              const SizedBox(width: 6),
              Text(
                'via_wallet'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              PriceConverter.convertPrice(paid, isShowLongPrice: true),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueRow(BuildContext context, double amount) {
    final isPending =
        bookingDetails.bookingStatus == 'pending' ||
        bookingDetails.bookingStatus == 'accepted' ||
        bookingDetails.bookingStatus == 'ongoing';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${isPending ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              PriceConverter.convertPrice(amount, isShowLongPrice: true),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: isPending ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service Info Item ──────────────────────────────────────────────────────

class ServiceInfoItem extends StatelessWidget {
  final int index;
  final BookingDetailsController bookingDetailsController;
  final ItemService? bookingService;

  const ServiceInfoItem({
    super.key,
    required this.bookingService,
    required this.bookingDetailsController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Index badge ──────────────────────────────────────────────
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Details ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bookingService?.serviceName ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Text(
                      PriceConverter.convertPrice(
                        BookingHelper.getBookingServiceUnitConst(
                          bookingService,
                        ),
                        isShowLongPrice: true,
                      ),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                if (bookingService?.variantKey != null)
                  Wrap(
                    spacing: 6,
                    children: [
                      _metaChip(
                        context,
                        bookingService!.variantKey!
                            .replaceAll('-', ' ')
                            .capitalizeFirst!,
                      ),
                      _metaChip(
                        context,
                        '${"qty".tr}: ${bookingService?.quantity}',
                      ),
                    ],
                  ),

                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.sell_rounded,
                      size: 12,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${"unit_price".tr}: ${PriceConverter.convertPrice(double.tryParse(bookingService?.serviceCost?.toString() ?? "0") ?? 0, isShowLongPrice: true)}',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: robotoRegular.copyWith(
          fontSize: 10,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

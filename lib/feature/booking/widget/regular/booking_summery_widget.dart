import 'package:afriendorse/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

// ═══════════════════════════════════════════════════════════════════════════
// booking_summery_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

class BookingSummeryWidget extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingSummeryWidget({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    double paidAmount = 0;
    double totalBookingAmount = bookingDetails.totalBookingAmount ?? 0;
    bool isPartialPayment =
        bookingDetails.partialPayments != null &&
        bookingDetails.partialPayments!.isNotEmpty;
    double subTotal = BookingHelper.getSubTotalCost(bookingDetails);

    if (isPartialPayment) {
      bookingDetails.partialPayments?.forEach((e) {
        paidAmount += e.paidAmount ?? 0;
      });
    } else {
      paidAmount = totalBookingAmount - (bookingDetails.additionalCharge ?? 0);
    }

    double dueAmount = totalBookingAmount - paidAmount;
    double additionalCharge = isPartialPayment
        ? totalBookingAmount - paidAmount
        : bookingDetails.additionalCharge ?? 0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
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
              children: [
                Icon(Icons.receipt_long_rounded, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  'booking_summery'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),

          // ── Service Table Header ─────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeLarge
                  : Dimensions.paddingSizeDefault,
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
          ),

          // ── Service Items ────────────────────────────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: bookingDetails.bookingDetails?.length ?? 0,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.12),
              indent: Dimensions.paddingSizeDefault,
              endIndent: Dimensions.paddingSizeDefault,
            ),
            itemBuilder: (context, index) => _ServiceInfoItem(
              bookingService: bookingDetails.bookingDetails?[index],
              index: index,
            ),
          ),

          // ── Price Breakdown ──────────────────────────────────────────
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
                _buildSummaryRow(
                  context,
                  'sub_total'.tr,
                  PriceConverter.convertPrice(subTotal, isShowLongPrice: true),
                ),
                _buildSummaryRow(
                  context,
                  'service_discount'.tr,
                  '(-) ${PriceConverter.convertPrice(bookingDetails.totalDiscountAmount ?? 0)}',
                  valueColor: Colors.red.withOpacity(0.8),
                ),
                _buildSummaryRow(
                  context,
                  'coupon_discount'.tr,
                  '(-) ${PriceConverter.convertPrice(bookingDetails.totalCouponDiscountAmount ?? 0)}',
                  valueColor: Colors.red.withOpacity(0.8),
                ),
                _buildSummaryRow(
                  context,
                  'campaign_discount'.tr,
                  '(-) ${PriceConverter.convertPrice(bookingDetails.totalCampaignDiscountAmount ?? 0)}',
                  valueColor: Colors.red.withOpacity(0.8),
                ),
                if ((bookingDetails.totalReferralDiscountAmount ?? 0) > 0)
                  _buildSummaryRow(
                    context,
                    'referral_discount'.tr,
                    '(-) ${PriceConverter.convertPrice(bookingDetails.totalReferralDiscountAmount ?? 0)}',
                    valueColor: Colors.red.withOpacity(0.8),
                  ),
                _buildSummaryRow(
                  context,
                  'service_vat'.tr,
                  '(+) ${PriceConverter.convertPrice(bookingDetails.totalTaxAmount!.toDouble(), isShowLongPrice: true)}',
                  valueColor: Colors.orange.withOpacity(0.85),
                ),
                if ((bookingDetails.extraFee ?? 0) > 0)
                  _buildSummaryRow(
                    context,
                    Get.find<SplashController>()
                            .configModel
                            .content
                            ?.additionalChargeLabelName ??
                        '',
                    '(+) ${PriceConverter.convertPrice(bookingDetails.extraFee ?? 0, isShowLongPrice: true)}',
                    valueColor: Colors.orange.withOpacity(0.85),
                  ),
                if (bookingDetails.additionalCharge != null &&
                    additionalCharge < 0 &&
                    (bookingDetails.paymentMethod != 'cash_after_service' ||
                        bookingDetails.partialPayments!.isNotEmpty))
                  _buildSummaryRow(
                    context,
                    'refund'.tr,
                    PriceConverter.convertPrice(
                      additionalCharge,
                      isShowLongPrice: true,
                    ),
                    valueColor: Colors.green.withOpacity(0.85),
                  ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
              ],
            ),
          ),

          // ── Grand Total / Payment Breakdown ──────────────────────────
          _buildGrandTotalSection(
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
  }

  Widget _buildSummaryRow(
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
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
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

  Widget _buildGrandTotalSection(
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

    Widget grandTotalRow() => Padding(
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

    // Simple total (cash after service or no additional charge)
    if (!isPartialPayment && bookingDetails.paymentMethod != 'wallet_payment') {
      if (additionalCharge == 0 ||
          bookingDetails.paymentMethod == 'cash_after_service') {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
          child: grandTotalRow(),
        );
      }

      // Total + due breakdown
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: _buildBreakdownCard(
          context,
          primary,
          children: [
            grandTotalRow(),
            if (additionalCharge > 0)
              _buildDueRow(context, additionalCharge, bookingDetails),
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
            grandTotalRow(),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildBreakdownCard(
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
                if (additionalCharge > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildDueRow(
                      context,
                      additionalCharge,
                      bookingDetails,
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    // Partial payments
    if (isPartialPayment) {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: _buildBreakdownCard(
          context,
          primary,
          children: [
            grandTotalRow(),
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
              _buildDueRow(context, due, bookingDetails),
          ],
        ),
      );
    }

    return grandTotalRow();
  }

  Widget _buildBreakdownCard(
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

  Widget _buildDueRow(
    BuildContext context,
    double amount,
    BookingDetailsContent details,
  ) {
    final isPending =
        details.bookingStatus == 'pending' ||
        details.bookingStatus == 'accepted' ||
        details.bookingStatus == 'ongoing';

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

class _ServiceInfoItem extends StatelessWidget {
  final int index;
  final ItemService? bookingService;
  const _ServiceInfoItem({required this.bookingService, required this.index});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Index Badge ──────────────────────────────────────────────
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

          // ── Service Details ──────────────────────────────────────────
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

                // Variant + Qty
                if (bookingService?.variantKey != null)
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildMetaChip(
                        context,
                        bookingService!.variantKey!
                            .replaceAll('-', ' ')
                            .capitalizeFirst!,
                      ),
                      _buildMetaChip(
                        context,
                        '${'qty'.tr}: ${bookingService?.quantity}',
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
                      '${"unit_price".tr}: ${PriceConverter.convertPrice(bookingService?.serviceCost ?? 0, isShowLongPrice: true)}',
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

  Widget _buildMetaChip(BuildContext context, String label) {
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

class _ServiceItemText extends StatelessWidget {
  final String title;
  final double amount;

  const _ServiceItemText({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(
        children: [
          Text(
            "$title : ",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          Text(
            PriceConverter.convertPrice(amount, isShowLongPrice: true),
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

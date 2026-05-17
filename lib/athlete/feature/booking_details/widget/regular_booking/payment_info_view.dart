// ═══════════════════════════════════════════════════════════════════════════
// payment_info_view.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class PaymentInfoView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;

  const PaymentInfoView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        final primary = Theme.of(context).colorScheme.primary;
        final isDark = Get.isDarkMode;

        final bool isPartiallyPaid =
            bookingDetails.partialPayments != null &&
            bookingDetails.partialPayments!.isNotEmpty &&
            bookingDetails.isPaid == 0;
        final bool isPaid = bookingDetails.isPaid == 1;

        final payStatusLabel = isPartiallyPaid
            ? 'partially_paid'.tr
            : isPaid
            ? 'paid'.tr
            : 'unpaid'.tr;
        final payStatusColor = isPartiallyPaid
            ? primary
            : isPaid
            ? Colors.green
            : Colors.red;

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [primary.withOpacity(0.2), primary.withOpacity(0.1)]
                        : [
                            primary.withOpacity(0.13),
                            primary.withOpacity(0.05),
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payment_rounded, size: 18, color: primary),
                    const SizedBox(width: 8),
                    Text(
                      'payment_info'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Payment Status row ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'payment_status'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: payStatusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: payStatusColor.withOpacity(0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            payStatusLabel,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: payStatusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // ── Payment Method expansion ───────────────────────
                    CustomBookingDetailsExpansionTile(
                      isShowExpandIcon:
                          !(bookingDetails.paymentMethod ==
                                  'cash_after_service' ||
                              bookingDetails.paymentMethod ==
                                      'offline_payment' &&
                                  bookingDetails.bookingOfflinePayment == null),
                      tilePadding: EdgeInsets.zero,
                      isShowTrailingExpandIcon: false,
                      bookingTitle: 'payment_method'.tr,
                      bookingType: '${bookingDetails.paymentMethod}'.tr,
                      children: [
                        if (bookingDetails.paymentMethod != 'offline_payment' ||
                            bookingDetails.bookingOfflinePayment != null)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: primary.withOpacity(0.15),
                          ),

                        // Offline details
                        if (bookingDetails.paymentMethod == 'offline_payment' &&
                            bookingDetails.bookingOfflinePayment != null)
                          _buildOfflineDetails(context, primary),

                        // Transaction ID
                        if (bookingDetails.paymentMethod != 'offline_payment' &&
                            bookingDetails.paymentMethod !=
                                'cash_after_service')
                          _buildTransactionId(context, primary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfflineDetails(BuildContext context, Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 14, color: primary),
              const SizedBox(width: 6),
              Text(
                'customer_payment_info'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if (bookingDetails.offlinePaymentMethodName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'payment_method'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text(
                    ': ${bookingDetails.offlinePaymentMethodName}',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: bookingDetails.bookingOfflinePayment?.length ?? 0,
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            itemBuilder: (context, index) {
              final item = bookingDetails.bookingOfflinePayment![index];
              return Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 5,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.key?.replaceAll("_", " ").capitalizeFirst}: ',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value ?? '',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }

  Widget _buildTransactionId(BuildContext context, Color primary) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.tag_rounded, size: 15, color: primary),
            const SizedBox(width: 8),
            Text(
              '${'Transaction_ID'.tr}: ',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
            Expanded(
              child: Text(
                bookingDetails.transactionId
                        ?.replaceAll('_', ' ')
                        .capitalizeFirst ??
                    '',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

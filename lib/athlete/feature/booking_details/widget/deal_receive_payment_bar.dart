import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/feature/auth/repository/deal_approval_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DealReceivePaymentBar extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;

  const DealReceivePaymentBar({
    super.key,
    required this.bookingDetails,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    final bookingId = bookingDetails.id ?? '';
    if (bookingId.isEmpty) return const SizedBox();

    final primary = Theme.of(context).colorScheme.primary;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: DealApprovalFirestoreService.watch(bookingId),
      builder: (context, snap) {
        final data = snap.data?.data();
        if (data == null) return const SizedBox();

        final status = (data['status'] ?? '').toString();
        final reason = (data['reason'] ?? '').toString();
        final otp = (data['otp'] ?? '').toString();

        final Timestamp? expiresAtTs = data['expiresAt'] as Timestamp?;
        final expiresAt = expiresAtTs?.toDate();

        String countdownText() {
          if (expiresAt == null) return '';
          final diff = expiresAt.difference(DateTime.now());
          if (diff.isNegative) return 'Auto-approving…';
          final h = diff.inHours;
          final m = diff.inMinutes.remainder(60);
          return 'Auto-approves in ${h}h ${m}m';
        }

        if (status == 'declined') {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Changes requested', style: robotoBold),
                const SizedBox(height: 6),
                Text(
                  reason.isNotEmpty ? reason : 'Brand declined your request.',
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          );
        }

        if (status == 'requested') {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primary.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    countdownText().isNotEmpty
                        ? 'Awaiting approval. $countdownText()'
                        : 'Awaiting approval.',
                    style: robotoMedium,
                  ),
                ),
              ],
            ),
          );
        }

        final isApproved = status == 'approved' || status == 'auto_approved';

        if (isApproved && otp.isEmpty) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primary.withOpacity(0.25)),
            ),
            child: Text(
              'Approved. Preparing payment token…',
              style: robotoMedium,
            ),
          );
        }

        if (isApproved && otp.length == 6) {
          return GetBuilder<BookingDetailsController>(
            builder: (controller) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Approved', style: robotoBold),
                          const SizedBox(height: 4),
                          Text(
                            'Tap receive payment to complete this deal.',
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: CustomButton(
                        btnTxt: 'receive_payment'.tr,
                        isLoading: controller.isStatusUpdateLoading,
                        onPressed: controller.isStatusUpdateLoading
                            ? null
                            : () async {
                                // REQUIRED because repo uses dropdown value as the status to send
                                controller.changeBookingStatusDropDownValue(
                                  'completed',
                                  isSubBooking,
                                );

                                controller.setOtp(otp);

                                await controller.changeBookingStatus(
                                  bookingId,
                                  bookingStatus: 'completed',
                                  isBack: false,
                                  isSubBooking: isSubBooking,
                                );

                                await DealApprovalFirestoreService.markCompleted(
                                  bookingId,
                                );
                              },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}

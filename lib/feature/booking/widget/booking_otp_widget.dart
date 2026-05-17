import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class BookingOtpWidget extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingOtpWidget({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final otp = bookingDetails.bookingOtp?.replaceAll('null', '') ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.12), primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: primary.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Row(
        children: [
          // ── Lock Icon ────────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_rounded, color: primary, size: 24),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          // ── OTP Text ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'otp_verification_code'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black,
                    letterSpacing: 0.3,
                  ),
                ), //
                const SizedBox(height: 4),
                Text(
                  otp.isNotEmpty ? otp : '––––',
                  style: robotoBold.copyWith(
                    fontSize: 28,
                    color: primary,
                    letterSpacing: 8,
                  ),
                ),
                /*  const SizedBox(height: 2),
                Text(
                  'your_otp_is'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ), */
              ],
            ),
          ),

          // ── Copy hint ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 12, color: primary),
                const SizedBox(width: 4),
                Text(
                  'active'.tr,
                  style: robotoMedium.copyWith(fontSize: 10, color: primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

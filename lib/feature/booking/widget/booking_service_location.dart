import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

// ═══════════════════════════════════════════════════════════════════════════
// booking_service_location.dart
// ═══════════════════════════════════════════════════════════════════════════

class BookingServiceLocation extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingServiceLocation({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        final isProviderLocation = bookingDetails.serviceLocation == 'provider';
        final hasProvider = bookingDetails.provider != null;

        final address = isProviderLocation
            ? (hasProvider ? bookingDetails.provider?.companyAddress : null)
            : bookingDetails.serviceAddress?.address ??
                  bookingDetails.subBooking?.serviceAddress?.address;

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
              // ── Header ───────────────────────────────────────────────
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
                    Icon(Icons.location_on_rounded, size: 18, color: primary),
                    const SizedBox(width: 8),
                    Text(
                      'service_location'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    // Location type chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        isProviderLocation
                            ? 'provider_location'.tr
                            : 'customer_location'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: 10,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isProviderLocation
                            ? Icons.store_rounded
                            : Icons.home_rounded,
                        size: 20,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isProviderLocation && !hasProvider
                          ? RichText(
                              text: TextSpan(
                                text:
                                    'will_be_available_after_a_provider_accepts_hint_booking_details'
                                        .tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            )
                          : Text(
                              address ?? 'address_not_found'.tr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                    ),

                    // ── Map Button ──────────────────────────────────
                    if (isProviderLocation && hasProvider)
                      GestureDetector(
                        onTap: () => _checkPermission(() async {
                          Get.dialog(const CustomLoader());
                          await Geolocator.getCurrentPosition().then((pos) {
                            MapUtils.openMap(
                              bookingDetails.provider?.coordinates?.latitude ??
                                  bookingDetails
                                      .subBooking
                                      ?.provider
                                      ?.coordinates
                                      ?.latitude ??
                                  23.8103,
                              bookingDetails.provider?.coordinates?.longitude ??
                                  bookingDetails
                                      .subBooking
                                      ?.provider
                                      ?.coordinates
                                      ?.longitude ??
                                  90.4125,
                              pos.latitude,
                              pos.longitude,
                            );
                          });
                          Get.back();
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(left: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
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
}

void _checkPermission(Function onTap) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    customSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
  } else if (permission == LocationPermission.deniedForever) {
    Get.dialog(const PermissionDialog());
  } else {
    onTap();
  }
}

class MapUtils {
  MapUtils._();
  static Future<void> openMap(
    double destinationLatitude,
    double destinationLongitude,
    double userLatitude,
    double userLongitude,
  ) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude'
        '&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(
        Uri.parse(googleUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not open the map.';
    }
  }
}

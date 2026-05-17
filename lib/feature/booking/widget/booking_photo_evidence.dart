import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/image_dialog.dart';

// ═══════════════════════════════════════════════════════════════════════════
// booking_photo_evidence.dart
// ═══════════════════════════════════════════════════════════════════════════

class BookingPhotoEvidence extends StatelessWidget {
  final BookingDetailsContent bookingDetailsContent;
  const BookingPhotoEvidence({super.key, required this.bookingDetailsContent});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final photos = bookingDetailsContent.photoEvidenceFullPath ?? [];

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
          // ── Header ───────────────────────────────────────────────────
          Container(
            width: double.infinity,
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
                Icon(Icons.photo_library_rounded, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  'completed_service_picture'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${photos.length} ${"photos".tr}',
                    style: robotoMedium.copyWith(fontSize: 10, color: primary),
                  ),
                ),
              ],
            ),
          ),

          // ── Photo Strip ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: photos.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => ImageDialog(
                        imageUrl: photos[index],
                        title: 'completed_service_picture'.tr,
                        subTitle: '',
                      ),
                    ),
                    child: Hero(
                      tag: 'evidence_$index',
                      child: Container(
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomImage(
                                image: photos[index],
                                fit: BoxFit.cover,
                              ),
                              // Tap overlay
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.zoom_in_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

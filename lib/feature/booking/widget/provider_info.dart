import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

// ═══════════════════════════════════════════════════════════════════════════
// provider_info.dart
// ═══════════════════════════════════════════════════════════════════════════

class ProviderInfo extends StatelessWidget {
  final ProviderData? provider;
  const ProviderInfo({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
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
                Icon(Icons.business_rounded, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  'provider_info'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SizedBox(
                      width: Dimensions.imageSize,
                      height: Dimensions.imageSize,
                      child: CustomImage(
                        image: provider?.logoFullPath ?? '',
                        placeholder: Images.userPlaceHolder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider?.companyName != null)
                        Text(
                          provider!.companyName!,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      /*   const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            provider == null
                                ? Icons.info_outline_rounded
                                : Icons.phone_rounded,
                            size: 14,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider == null
                                ? 'no_provider_assigned'.tr
                                : provider?.companyPhone ?? '',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ), */
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

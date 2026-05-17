// ═══════════════════════════════════════════════════════════════════════════
// booking_item.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class BookingItem extends StatelessWidget {
  final String img;
  final String title;
  final String date;

  const BookingItem({
    super.key,
    required this.img,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Get.isDarkMode;
    final iconColor = isDark ? Theme.of(context).hintColor : primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Icon box ───────────────────────────────────────────────────
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).hintColor.withOpacity(0.08)
                : primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Image.asset(
              img,
              height: 14,
              width: 14,
              color: iconColor.withOpacity(0.65),
            ),
          ),
        ),

        const SizedBox(width: Dimensions.paddingSizeSmall),

        // ── Label ──────────────────────────────────────────────────────
        Flexible(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: '${title.tr} ',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.5),
              ),
              children: [
                if (date.isNotEmpty)
                  TextSpan(
                    text: date,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
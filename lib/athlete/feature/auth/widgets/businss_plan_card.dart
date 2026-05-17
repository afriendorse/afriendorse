import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class BusinessPlanCard extends StatelessWidget {
  final String? icon;
  final String? title;
  final String? subtitle;
  final bool? isSelected;
  final Color? cardColor;
  final bool showBorder;
  final Function()? onTap;

  const BusinessPlanCard({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.isSelected,
    this.cardColor,
    this.showBorder = true,
    this.onTap,
  });

  static const Color _primaryGreen = Color(0xFF045F25);
  static const Color _darkGreen = Color(0xFF033D18);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _accentGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final bool selected = isSelected ?? false;

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFF0FAF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : (cardColor ?? Colors.white),
            border: Border.all(
              color: selected
                  ? _primaryGreen
                  : showBorder
                  ? const Color(0xFFDDDDDD)
                  : Colors.transparent,
              width: selected ? 1.8 : 0.8,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _primaryGreen.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon badge
              if (icon != null) ...[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [_primaryGreen, _darkGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: selected ? null : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _primaryGreen.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Image.asset(
                      icon!,
                      width: 26,
                      color: selected ? Colors.white : _primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? _primaryGreen
                              : const Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: selected
                              ? _primaryGreen.withOpacity(0.7)
                              : const Color(0xFF888888),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Selection indicator
              if (isSelected != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected
                        ? const LinearGradient(
                            colors: [_primaryGreen, _darkGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: selected
                        ? null
                        : Border.all(
                            color: const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                    color: selected ? null : Colors.white,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
            ],
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}

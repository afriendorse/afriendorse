import 'package:afriendorse/athlete/utils/dimensions.dart';
import 'package:afriendorse/athlete/utils/styles.dart';
import 'package:flutter/material.dart';

class CategoryItemWidget extends StatelessWidget {
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;
  const CategoryItemWidget({
    super.key,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(text: categoryName, style: robotoMedium),
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.size.width;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              categoryName,
              style: robotoMedium.copyWith(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color?.withValues(alpha: 0.7),
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
            isSelected
                ? SizedBox(height: Dimensions.paddingSizeExtraSmall)
                : SizedBox.shrink(),

            isSelected
                ? Container(
                    height: 1,
                    width: textWidth,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

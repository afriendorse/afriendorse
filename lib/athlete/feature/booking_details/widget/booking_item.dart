import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class BookingItem extends StatelessWidget {
  const BookingItem({
    super.key,
    required this.img,
    required this.title,
    required this.subTitle,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.subtitleTextStyle,
  });
  final String img;
  final String title;
  final String subTitle;
  final TextStyle? subtitleTextStyle;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Image(image: AssetImage(img), height: 15, width: 15),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Flexible(
                child: Text(
                  title.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall + 1,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withValues(alpha: 0.65),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                subTitle,
                style:
                    subtitleTextStyle ??
                    robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall + 1,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.65),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

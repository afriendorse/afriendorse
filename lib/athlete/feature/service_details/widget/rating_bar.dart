import 'package:afriendorse/athlete/utils/core_export.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final int? ratingCount;
  const RatingBar({
    super.key,
    required this.rating,
    this.ratingCount,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> starList = [];
    int realNumber = rating.floor();
    bool partNumber = (rating - realNumber) > 0;

    for (int i = 0; i < 5; i++) {
      if (i < realNumber) {
        starList.add(
          Icon(
            Icons.star_rate_rounded,
            color: Theme.of(context).colorScheme.tertiary,
            size: size,
          ),
        );
      } else if (i == realNumber && partNumber) {
        starList.add(
          SizedBox(
            height: size,
            width: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Icon(
                  Icons.star_half_rounded,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: size,
                ),
              ],
            ),
          ),
        );
      } else {
        starList.add(
          Icon(
            Icons.star_outline_rounded,
            color: Theme.of(context).colorScheme.tertiary,
            size: size,
          ),
        );
      }
    }
    ratingCount != null
        ? starList.add(
            Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeExtraSmall,
              ),
              child: Text(
                '($ratingCount)',
                style: robotoRegular.copyWith(
                  fontSize: size * 0.8,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          )
        : const SizedBox();

    return Row(mainAxisSize: MainAxisSize.min, children: starList);
  }
}

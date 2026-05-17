import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ReviewLinearChart extends StatelessWidget {
  final Rating rating;
  const ReviewLinearChart({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    double fiveStar = 0.0,
        fourStar = 0.0,
        threeStar = 0.0,
        twoStar = 0.0,
        oneStar = 0.0;
    for (int i = 0; i < rating.ratingGroupCount!.length; i++) {
      if (rating.ratingGroupCount![i].reviewRating == 1) {
        oneStar =
            (rating.ratingGroupCount![i].reviewRating! * rating.ratingCount!) /
            100;
      }
      if (rating.ratingGroupCount![i].reviewRating == 2) {
        twoStar =
            (rating.ratingGroupCount![i].reviewRating! * rating.ratingCount!) /
            100;
      }
      if (rating.ratingGroupCount![i].reviewRating == 3) {
        threeStar =
            (rating.ratingGroupCount![i].reviewRating! * rating.ratingCount!) /
            100;
      }
      if (rating.ratingGroupCount![i].reviewRating == 4) {
        fourStar =
            (rating.ratingGroupCount![i].reviewRating! * rating.ratingCount!) /
            100;
      }
      if (rating.ratingGroupCount![i].reviewRating == 5) {
        fiveStar =
            (rating.ratingGroupCount![i].reviewRating! * rating.ratingCount!) /
            100;
      }
    }
    return Column(
      children: [
        ProgressBar(
          title: 'excellent'.tr,
          color: const Color(0xFF69B469),
          percent: fiveStar,
        ),
        ProgressBar(
          title: 'good'.tr,
          color: const Color(0xFFB0DC4B),
          percent: fourStar,
        ),
        ProgressBar(
          title: 'average'.tr,
          color: const Color(0xFFFFC700),
          percent: threeStar,
        ),
        ProgressBar(
          title: 'below_average'.tr,
          color: const Color(0xFFF7A41E),
          percent: twoStar,
        ),
        ProgressBar(
          title: 'poor'.tr,
          color: const Color(0xFFFF2828),
          percent: oneStar,
        ),
      ],
    );
  }
}

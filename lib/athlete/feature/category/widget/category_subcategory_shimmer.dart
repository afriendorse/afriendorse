import 'package:afriendorse/athlete/utils/core_export.dart';

class CategorySubcategoryShimmer extends StatelessWidget {
  const CategorySubcategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 110,
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return CategoryItemShimmer(index: index);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: Dimensions.paddingSizeSmall),

        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
            child: SubCategoryItemShimmer(),
          ),
        ),
      ],
    );
  }
}

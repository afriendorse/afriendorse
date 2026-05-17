import 'package:afriendorse/athlete/utils/core_export.dart';

class SearchedServiceListShimmer extends StatelessWidget {
  const SearchedServiceListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
        itemCount: 12,
        itemBuilder: (context, index) => const ServiceShimmer(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 0,
          mainAxisSpacing: 5,
          mainAxisExtent: 245,
          crossAxisCount: ResponsiveHelper.isTab(context) ? 4 : 2,
        ),
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}

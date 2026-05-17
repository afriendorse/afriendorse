import 'package:afriendorse/athlete/utils/core_export.dart';

class ServiceListShimmer extends StatelessWidget {
  const ServiceListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 20,
                  width: 30,
                  color: Theme.of(context).shadowColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Container(
                  height: 20,
                  width: 150,
                  color: Theme.of(context).shadowColor,
                ),
              ],
            ),
          ),
        ),

        Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeExtraSmall,
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            itemCount: 12,
            itemBuilder: (context, index) => const ServiceShimmer(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 0,
              mainAxisSpacing: 5,
              childAspectRatio: 0.85,
              crossAxisCount: ResponsiveHelper.isTab(context) ? 4 : 2,
            ),
            physics: const BouncingScrollPhysics(),
          ),
        ),
      ],
    );
  }
}

import 'package:afriendorse/athlete/utils/core_export.dart';

class FilterRemoveItem extends StatelessWidget {
  final String title;
  final Function()? onTap;
  const FilterRemoveItem({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).textTheme.bodyLarge!.color!.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      margin: const EdgeInsets.only(right: 10, top: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(title, style: robotoRegular),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          InkWell(onTap: onTap, child: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }
}

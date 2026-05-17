import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class ProfileCardItem extends StatelessWidget {
  final String leadingIcon;
  final bool? isDarkItem;
  final String title;
  final IconData? trailingIcon;

  const ProfileCardItem({
    super.key,
    this.trailingIcon = Icons.arrow_forward_ios,
    required this.title,
    required this.leadingIcon,
    this.isDarkItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: context.customThemeColors.shadow,
      ),

      child: Center(
        child: ListTile(
          horizontalTitleGap: Dimensions.paddingSizeExtraSmall,
          title: Text(title.tr),
          trailing: Icon(
            trailingIcon,
            size: 15,
            color: Theme.of(context).primaryColor,
          ),
          leading: Image.asset(
            leadingIcon,
            height: 20,
            width: 20,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

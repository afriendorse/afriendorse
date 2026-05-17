import 'package:get/get.dart';
import '../../../utils/core_export.dart';

class ProfileButton extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final bool? isButtonActive;
  final Function()? onTap;
  const ProfileButton({super.key, required this.icon, required this.title, required this.onTap, this.isButtonActive});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: isButtonActive != null ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 25),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Text(title!, style: robotoRegular)),
            isButtonActive != null ? Switch(
              value: isButtonActive!,
              onChanged: (bool isActive) => onTap,
              activeThumbColor: Theme.of(context).primaryColor,
              activeTrackColor: Theme.of(context).primaryColor.withValues(alpha:0.5),
            ): const SizedBox(),
          ]
        ),
      ),
    );
  }
}

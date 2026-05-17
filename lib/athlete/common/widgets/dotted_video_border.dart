import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class DottedVideoBorder extends StatelessWidget {
  final Function() onTap;
  final String? text;
  final bool showErrorBorder;
  const DottedVideoBorder({
    super.key,
    required this.onTap,
    this.showErrorBorder = false,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [8, 4],
          strokeWidth: 1,
          color: Theme.of(context).colorScheme.primary,
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_rounded,
                color: showErrorBorder
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                size: 30,
              ),
              const SizedBox(height: 5),
              Text(
                text ?? "upload_file".tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  color: showErrorBorder
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

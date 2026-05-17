import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class DottedBorderBox extends StatelessWidget {
  final double? height;
  final double? width;
  final Function()? onTap;
  final bool showErrorBorder;
  final Widget? child;
  const DottedBorderBox({
    super.key,
    this.onTap,
    this.height = 100,
    this.width = 100,
    this.showErrorBorder = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        // dashPattern: const [8, 4],
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [5, 5],
          strokeWidth: 1,
          color: Theme.of(context).colorScheme.primary,
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: SizedBox(
          height: height,
          width: width,
          child:
              child ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      color: showErrorBorder
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).textTheme.bodyLarge!.color!
                                .withValues(alpha: 0.6),
                      size: 30,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "upload_file".tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                        fontSize: 12,
                        color: showErrorBorder
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).textTheme.bodyLarge!.color!
                                  .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

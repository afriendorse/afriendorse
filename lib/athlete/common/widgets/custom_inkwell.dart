import 'package:afriendorse/athlete/utils/core_export.dart';

class CustomInkWell extends StatelessWidget {
  final double? radius;
  final Widget? child;
  final Function()? onTap;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? hoverColor;

  const CustomInkWell({
    super.key,
    this.radius,
    this.child,
    this.onTap,
    this.highlightColor,
    this.splashColor,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      radius ?? Dimensions.radiusDefault,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        highlightColor:
            highlightColor ?? Theme.of(context).primaryColor.withOpacity(0.05),
        splashColor:
            splashColor ?? Theme.of(context).primaryColor.withOpacity(0.08),
        hoverColor:
            hoverColor ?? Theme.of(context).primaryColor.withOpacity(0.03),
        child: child,
      ),
    );
  }
}

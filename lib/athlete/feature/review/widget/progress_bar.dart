import 'package:afriendorse/athlete/utils/core_export.dart';

class ProgressBar extends StatelessWidget {
  final String title;
  final double percent;
  final Color color;
  const ProgressBar({
    super.key,
    required this.title,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: robotoLight.copyWith(fontSize: Dimensions.fontSizeDefault),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeLarge),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: percent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: const Color(0xFFEAEAEA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

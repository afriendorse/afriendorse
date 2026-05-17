import 'package:afriendorse/athlete/utils/core_export.dart';

class TransactionEyeInfoCard extends StatelessWidget {
  final String infoText;
  const TransactionEyeInfoCard({super.key, required this.infoText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text(infoText, style: robotoRegular.copyWith())],
        ),
      ),
    );
  }
}

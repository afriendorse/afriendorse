import 'package:afriendorse/athlete/utils/core_export.dart';

class CustomDatePicker extends StatefulWidget {
  final String title;
  final String text;
  final String image;
  final bool requiredField;
  final Function()? selectDate;
  const CustomDatePicker({
    super.key,
    required this.title,
    required this.text,
    required this.image,
    this.requiredField = false,
    required this.selectDate,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.title,
            style: robotoRegular.copyWith(
              color: Theme.of(context).primaryColor,
            ),
            children: <TextSpan>[
              widget.requiredField
                  ? TextSpan(
                      text: '  *',
                      style: robotoBold.copyWith(color: Colors.red),
                    )
                  : const TextSpan(),
            ],
          ),
        ),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Container(
          height: 50,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor, width: 1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.text,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
              InkWell(
                onTap: widget.selectDate,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(widget.image),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

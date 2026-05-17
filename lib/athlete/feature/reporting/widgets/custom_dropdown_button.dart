import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class ReportCustomDropdownButton extends StatefulWidget {
  final String? value;
  final String? label;
  final List<String> items;
  final Function(String? value)? onChanged;
  final Function()? onTap;
  final double? height;
  final double? width;
  final Color? borderColor;
  final Color? dropdownBackgroundColor;
  const ReportCustomDropdownButton({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.height,
    this.width,
    this.borderColor,
    this.dropdownBackgroundColor,
    this.label,
    this.onTap,
  });

  @override
  State<ReportCustomDropdownButton> createState() =>
      _ReportCustomDropdownButtonState();
}

class _ReportCustomDropdownButtonState
    extends State<ReportCustomDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 50,
      width: widget.width ?? MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        dropdownColor:
            widget.dropdownBackgroundColor ?? Theme.of(context).cardColor,
        hint: Text(
          widget.value != null ? 'Not available' : 'select'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(
            color: widget.value != null
                ? Theme.of(context).textTheme.bodyLarge!.color
                : Theme.of(context).hintColor,
          ),
        ),
        initialValue: widget.value,
        items: widget.items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
              maxLines: 1,
            ),
          );
        }).toList(),
        isDense: true,
        onChanged: widget.onChanged,
        isExpanded: true,
        onTap: widget.onTap,
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 0.5,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(
              color: Theme.of(context).textTheme.bodySmall!.color!,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 0.5,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          labelText: widget.label,
          labelStyle: robotoMedium,
        ),
      ),
    );
  }
}

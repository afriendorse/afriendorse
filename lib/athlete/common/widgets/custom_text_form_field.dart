import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final double borderRadius;
  final Color? fillColor;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isShowBorder;
  final bool isIcon;
  final bool isShowSuffixIcon;
  final bool isShowPrefixIcon;
  final Function(String)? onSubmit;
  final Function()? onSaved;
  final String? Function(String?)? onValidate;
  final String? suffixIcon;
  final Function()? onPressedSuffix;
  final String? prefixIconUrl;
  final bool isSearch;
  final bool? enabled;
  final Function()? onTap;
  final int? maxLength;
  final TextCapitalization? capitalization;

  const CustomTextFormField({
    super.key,
    this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.fillColor,
    this.onSubmit,
    this.isCountryPicker = false,
    this.isShowBorder = false,
    this.isShowSuffixIcon = false,
    this.isShowPrefixIcon = false,
    this.isIcon = false,
    this.isPassword = false,
    this.prefixIconUrl,
    this.onSaved,
    this.onValidate,
    this.capitalization = TextCapitalization.none,
    this.enabled = true,
    this.isSearch = false,
    this.onTap,
    this.suffixIcon,
    this.onPressedSuffix,
    this.maxLength,
    this.borderRadius = Dimensions.radiusDefault,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      controller: widget.controller,
      focusNode: widget.focusNode,
      textCapitalization: widget.capitalization!,
      style: robotoRegular.copyWith(
        color: Theme.of(
          context,
        ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
        fontSize: Dimensions.fontSizeDefault,
      ),
      textInputAction: widget.inputAction,
      keyboardType: widget.inputType,
      cursorColor: Theme.of(context).hintColor,
      obscureText: widget.isPassword ? _obscureText : false,
      maxLength: widget.maxLength,

      decoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: Get.isDarkMode
                ? Theme.of(context).disabledColor.withValues(alpha: 0.5)
                : Theme.of(context).hintColor.withValues(alpha: 0.5),
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: Get.isDarkMode
                ? Theme.of(context).disabledColor
                : Theme.of(context).hintColor.withValues(alpha: 0.5),
          ),
        ),

        isDense: true,
        hintText: widget.hintText,
        fillColor:
            widget.fillColor ??
            Theme.of(context).cardColor.withValues(alpha: 0.1),
        hintStyle: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).hintColor.withValues(alpha: 0.5),
        ),
        filled: true,

        suffixIcon: widget.suffixIcon != null
            ? GestureDetector(
                onTap: widget.onPressedSuffix,
                child: Container(
                  margin: EdgeInsets.only(
                    right: widget.fillColor != null ? 0 : 10,
                  ),
                  width: 40,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: widget.fillColor != null
                        ? Colors.transparent
                        : Theme.of(context).primaryColor.withValues(alpha: 0.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.suffixIcon!,
                      height: 20,
                      width: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              )
            : widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                ),
                onPressed: _toggle,
              )
            : null,
      ),
      onTap: widget.onTap,
      validator: widget.onValidate,
      onFieldSubmitted: (text) => widget.nextFocus != null
          ? FocusScope.of(context).requestFocus(widget.nextFocus)
          : widget.onSubmit != null
          ? widget.onSubmit!(text)
          : null,

      /*onSaved: (value) {
        widget.controller != value;
      },*/
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}

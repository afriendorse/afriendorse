import 'dart:math';
import 'package:afriendorse/athlete/common/widgets/code_picker_widget.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? title;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final bool isPassword;
  final bool isShowBorder;
  final bool? isAutoFocus;
  final Function(String)? onSubmit;
  final bool isEnabled;
  final int? maxLines;
  final bool? isShowSuffixIcon;
  final TextCapitalization? capitalization;
  final Function(String text)? onChanged;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final String? Function(String?)? onValidate;
  final bool contentPadding;
  final double borderRadius;
  final bool isRequired;
  final String? prefixIcon;
  final Widget? errorWidget;
  final Function()? onPressedSuffix;
  final Color? fillColor;
  final String? suffixIcon;

  const CustomTextField({
    super.key,
    this.hintText = '',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.isShowSuffixIcon = false,
    this.onSubmit,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.isShowBorder = false,
    this.isAutoFocus = false,
    this.countryDialCode,
    this.onCountryChanged,
    this.onChanged,
    this.onValidate,
    this.title,
    this.contentPadding = true,
    this.borderRadius = 10,
    this.isRequired = true,
    this.prefixIcon,
    this.errorWidget,
    this.onPressedSuffix,
    this.fillColor,
    this.suffixIcon,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  VoidCallback? _focusListener;

  @override
  void initState() {
    super.initState();
    _attachFocusListener();
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusListener(oldWidget.focusNode);
      _attachFocusListener();
    }
  }

  void _attachFocusListener() {
    if (widget.focusNode == null) return;
    _focusListener = () => setState(() {});
    widget.focusNode!.addListener(_focusListener!);
  }

  void _detachFocusListener(FocusNode? node) {
    if (node == null || _focusListener == null) return;
    node.removeListener(_focusListener!);
  }

  @override
  void dispose() {
    _detachFocusListener(widget.focusNode);
    super.dispose();
  }

  void _toggle() => setState(() => _obscureText = !_obscureText);

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final hasText = controller?.text.isNotEmpty ?? false;
    final hasFocus = widget.focusNode?.hasFocus ?? false;

    final fill = widget.fillColor ?? Theme.of(context).colorScheme.surface;

    final borderColor = widget.errorWidget != null
        ? Theme.of(context).colorScheme.error
        : hasFocus
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor.withValues(alpha: 0.22);

    InputBorder outline(Color c) => OutlineInputBorder(
      borderSide: BorderSide(color: c, width: hasFocus ? 1.4 : 1.0),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );

    InputBorder underline(Color c) => UnderlineInputBorder(
      borderSide: BorderSide(color: c, width: hasFocus ? 1.4 : 1.0),
    );

    final enabledBorder = widget.isShowBorder
        ? outline(borderColor)
        : underline(borderColor);

    final focusedBorder = widget.isShowBorder
        ? outline(Theme.of(context).primaryColor)
        : underline(Theme.of(context).primaryColor);

    final errorBorder = widget.isShowBorder
        ? outline(Theme.of(context).colorScheme.error)
        : underline(Theme.of(context).colorScheme.error);

    final contentPadding = widget.contentPadding
        ? EdgeInsets.fromLTRB(
            widget.countryDialCode != null ? 8 : 14,
            16,
            14,
            16,
          )
        : EdgeInsets.zero;

    return TextFormField(
      maxLines: widget.maxLines,
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.isEnabled,
      autofocus: widget.isAutoFocus ?? false,
      style: robotoRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: widget.isEnabled == false
            ? Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)
            : Theme.of(context).textTheme.bodyLarge!.color,
      ),
      textInputAction: widget.inputAction,
      keyboardType: widget.inputType,
      cursorColor: Theme.of(context).primaryColor,
      textCapitalization: widget.capitalization ?? TextCapitalization.none,
      obscureText: widget.isPassword ? _obscureText : false,
      inputFormatters: widget.inputType == TextInputType.phone
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
            ]
          : widget.inputType == TextInputType.datetime
          ? [_DateInputFormatter()]
          : null,
      autofillHints: widget.inputType == TextInputType.name
          ? [AutofillHints.name]
          : widget.inputType == TextInputType.emailAddress
          ? [AutofillHints.email]
          : widget.inputType == TextInputType.phone
          ? [AutofillHints.telephoneNumber]
          : widget.inputType == TextInputType.streetAddress
          ? [AutofillHints.fullStreetAddress]
          : widget.inputType == TextInputType.url
          ? [AutofillHints.url]
          : widget.inputType == TextInputType.visiblePassword
          ? [AutofillHints.password]
          : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: widget.hintText,
        hintStyle: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(
            context,
          ).hintColor.withValues(alpha: Get.isDarkMode ? .55 : .65),
        ),

        // Modern floating label
        label: (widget.title == null || widget.countryDialCode != null)
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title!,
                    style: robotoMedium.copyWith(
                      fontSize: 14,
                      color: widget.errorWidget != null
                          ? Theme.of(context).colorScheme.error
                          : hasFocus || hasText
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.55),
                    ),
                  ),
                  if (widget.isRequired)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '*',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        contentPadding: contentPadding,

        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        disabledBorder: widget.isShowBorder
            ? outline(Theme.of(context).hintColor.withValues(alpha: 0.18))
            : underline(Theme.of(context).hintColor.withValues(alpha: 0.18)),
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,

        // Prefix: asset icon OR country picker
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Image.asset(
                  widget.prefixIcon!,
                  width: 20,
                  height: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.55),
                ),
              )
            : widget.countryDialCode != null
            ? Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CodePickerWidget(
                      onChanged: widget.onCountryChanged,
                      initialSelection: widget.countryDialCode,
                      favorite: [widget.countryDialCode ?? ""],
                      showDropDownButton: true,
                      padding: EdgeInsets.zero,
                      showFlagMain: true,
                      flagWidth: 26,
                      enabled: widget.isEnabled,
                      dialogSize: Size(
                        Dimensions.webMaxWidth / 2,
                        Get.height * 0.6,
                      ),
                      dialogBackgroundColor: Theme.of(context).cardColor,
                      barrierColor: Get.isDarkMode
                          ? Colors.black.withValues(alpha: 0.4)
                          : null,
                      textStyle: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: widget.isEnabled == false
                            ? Theme.of(context).textTheme.bodyLarge!.color
                                  ?.withValues(alpha: 0.6)
                            : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    Container(
                      height: 22,
                      width: 1,
                      margin: const EdgeInsets.only(left: 10),
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              )
            : null,

        // Suffix: asset icon OR password toggle
        suffixIcon: widget.suffixIcon != null
            ? GestureDetector(
                onTap: widget.onPressedSuffix,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset(
                    widget.suffixIcon!,
                    height: 22,
                    width: 22,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : widget.isPassword
            ? InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.45),
                  ),
                ),
              )
            : null,
      ),
      onFieldSubmitted: (text) => widget.nextFocus != null
          ? FocusScope.of(context).requestFocus(widget.nextFocus)
          : widget.onSubmit != null
          ? widget.onSubmit!(text)
          : null,
      onChanged: widget.onChanged,
      validator: widget.onValidate,
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  final String _placeholder = '--/----';
  TextEditingValue? _lastNewValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.isEmpty) {
      oldValue = oldValue.copyWith(text: _placeholder);
      newValue = newValue.copyWith(
        text: _fillInputToPlaceholder(newValue.text),
      );
      return newValue;
    }

    if (newValue == _lastNewValue) return oldValue;
    _lastNewValue = newValue;

    int offset = newValue.selection.baseOffset;
    if (offset > 7) return oldValue;

    if (oldValue.text == newValue.text && oldValue.text.isNotEmpty) {
      return newValue;
    }

    final oldText = oldValue.text;
    final newText = newValue.text;
    String? resultText;

    int index = _indexOfDifference(newText, oldText);
    if (oldText.length < newText.length) {
      String newChar = newText[index];
      if (index == 2) {
        index++;
        offset++;
      }
      resultText = oldText.replaceRange(index, index + 1, newChar);
      if (offset == 2) offset++;
    } else if (oldText.length > newText.length) {
      if (oldText[index] != '/') {
        resultText = oldText.replaceRange(index, index + 1, '-');
        if (offset == 2) offset--;
      } else {
        resultText = oldText;
      }
    }

    return oldValue.copyWith(
      text: resultText,
      selection: TextSelection.collapsed(offset: offset),
      composing: defaultTargetPlatform == TargetPlatform.iOS
          ? const TextRange(start: 0, end: 0)
          : TextRange.empty,
    );
  }

  int _indexOfDifference(String? cs1, String? cs2) {
    if (cs1 == cs2) return indexNotFound;
    if (cs1 == null || cs2 == null) return 0;
    int i;
    for (i = 0; i < cs1.length && i < cs2.length; ++i) {
      if (cs1[i] != cs2[i]) break;
    }
    if (i < cs2.length || i < cs1.length) return i;
    return indexNotFound;
  }

  String _fillInputToPlaceholder(String? input) {
    if (input == null || input.isEmpty) return _placeholder;
    String result = _placeholder;
    final index = [0, 1, 3, 4, 6, 7, 8, 9];
    final length = min(index.length, input.length);
    for (int i = 0; i < length; i++) {
      result = result.replaceRange(index[i], index[i] + 1, input[i]);
    }
    return result;
  }
}

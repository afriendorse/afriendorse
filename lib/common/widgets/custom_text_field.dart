// ============================================
// CUSTOM_TEXT_FIELD.DART
// ============================================

import 'package:afriendorse/common/widgets/code_picker_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? title;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final bool? isPassword;
  final bool? isShowBorder;
  final bool? isAutoFocus;
  final Function(String)? onSubmit;
  final bool? isEnabled;
  final int? maxLines;
  final bool? isShowSuffixIcon;
  final TextCapitalization? capitalization;
  final Function(String text)? onChanged;
  final String? countryDialCode;
  final String? suffixIconUrl;
  final Function(CountryCode countryCode)? onCountryChanged;
  final String? Function(String?)? onValidate;
  final bool contentPadding;
  final double? borderRadius;
  final bool isRequired;
  final String? prefixIcon;
  final bool? isFromOfflinePayment;
  final Function? onSuffixTap;

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
    this.isShowBorder,
    this.isAutoFocus = false,
    this.countryDialCode,
    this.onCountryChanged,
    this.suffixIconUrl,
    this.onChanged,
    this.onValidate,
    this.title,
    this.contentPadding = true,
    this.borderRadius,
    this.isRequired = true,
    this.prefixIcon,
    this.isFromOfflinePayment = false,
    this.onSuffixTap,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;

  // Brand colors
  static const Color primaryGreen = Color(0xFF045F25);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);

  late AnimationController _focusAnimationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _focusAnimationController, curve: Curves.easeOut),
    );

    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusAnimationController.dispose();
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
    if (_isFocused) {
      _focusAnimationController.forward();
    } else {
      _focusAnimationController.reverse();
    }
  }

  void onFocusChanged() {
    FocusScope.of(context).unfocus();
    FocusScope.of(Get.context!).requestFocus(widget.focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
        border: Border.all(
          color: _isFocused ? primaryGreen : pureBlack.withOpacity(0.1),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
        child: TextFormField(
          onTap: widget.isFromOfflinePayment == false ? onFocusChanged : null,
          maxLines: widget.maxLines,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: TextStyle(
            fontSize: Dimensions.fontSizeDefault,
            color: widget.isEnabled == false
                ? pureBlack.withOpacity(0.5)
                : pureBlack,
            fontWeight: FontWeight.w500,
          ),
          textInputAction: widget.inputAction,
          keyboardType: widget.inputType,
          cursorColor: primaryGreen,
          cursorWidth: 2,
          cursorRadius: const Radius.circular(1),
          textCapitalization: widget.capitalization!,
          enabled: widget.isEnabled,
          autofocus: widget.isAutoFocus!,
          autofillHints: _getAutofillHints(),
          obscureText: widget.isPassword! ? _obscureText : false,
          inputFormatters: widget.inputType == TextInputType.phone
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                ]
              : null,
          decoration: _buildInputDecoration(),
          onFieldSubmitted: (text) => widget.nextFocus != null
              ? FocusScope.of(context).requestFocus(widget.nextFocus)
              : widget.onSubmit != null
              ? widget.onSubmit!(text)
              : null,
          onChanged: widget.onChanged,
          validator: widget.onValidate,
        ),
      ),
    );
  }

  List<String>? _getAutofillHints() {
    switch (widget.inputType) {
      case TextInputType.name:
        return [AutofillHints.name];
      case TextInputType.emailAddress:
        return [AutofillHints.email];
      case TextInputType.phone:
        return [AutofillHints.telephoneNumber];
      case TextInputType.streetAddress:
        return [AutofillHints.fullStreetAddress];
      case TextInputType.url:
        return [AutofillHints.url];
      case TextInputType.visiblePassword:
        return [AutofillHints.password];
      default:
        return null;
    }
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      isCollapsed: false,
      isDense: true,

      // Title as floating label
      label: widget.title != null ? _buildLabel() : null,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: TextStyle(
        color: _isFocused ? primaryGreen : pureBlack.withOpacity(0.6),
        fontWeight: FontWeight.w600,
        fontSize: Dimensions.fontSizeDefault,
      ),

      // Country code picker prefix
      prefixIcon: _buildPrefixIcon(),
      prefixIconConstraints: widget.countryDialCode != null
          ? const BoxConstraints(minWidth: 90, maxHeight: 60)
          : widget.prefixIcon != null
          ? const BoxConstraints(minWidth: 50, maxHeight: 50)
          : null,

      // Content padding
      contentPadding: EdgeInsets.symmetric(
        horizontal: widget.countryDialCode != null ? 0 : 16,
        vertical: widget.maxLines! > 1 ? 16 : 18,
      ),

      // Borders - using container's border instead
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,

      // Hint text
      hintText: widget.hintText,
      hintStyle: TextStyle(
        fontSize: Dimensions.fontSizeDefault,
        color: pureBlack.withOpacity(0.4),
        fontWeight: FontWeight.normal,
      ),

      // Suffix icons
      suffixIcon: _buildSuffixIcon(),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, maxHeight: 48),
    );
  }

  Widget _buildLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title!,
          style: TextStyle(
            color: _isFocused ? primaryGreen : pureBlack.withOpacity(0.7),
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        if (widget.isRequired)
          Text(
            " *",
            style: TextStyle(
              color: Colors.red.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return Container(
        margin: const EdgeInsets.only(left: 12, right: 8),
        child: Image.asset(
          widget.prefixIcon!,
          width: 22,
          height: 22,
          color: _isFocused ? primaryGreen : pureBlack.withOpacity(0.4),
        ),
      );
    }

    if (widget.countryDialCode != null) {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        child: CodePickerWidget(
          onChanged: widget.onCountryChanged,
          initialSelection: widget.countryDialCode,
          favorite: [widget.countryDialCode ?? ""],
          showDropDownButton: true,
          padding: EdgeInsets.zero,
          showFlagMain: true,
          flagWidth: 24,
          dialogSize: Size(Dimensions.webMaxWidth / 2, Get.height * 0.6),
          dialogBackgroundColor: pureWhite,
          barrierColor: pureBlack.withOpacity(0.3),
          textStyle: TextStyle(
            fontSize: Dimensions.fontSizeDefault,
            color: pureBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword!) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggle,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _obscureText
                  ? pureBlack.withOpacity(0.05)
                  : primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _obscureText
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: _obscureText ? pureBlack.withOpacity(0.4) : primaryGreen,
            ),
          ),
        ),
      );
    }

    if (widget.suffixIconUrl != null) {
      return IconButton(
        onPressed: widget.onSuffixTap as void Function()?,
        icon: Image.asset(
          widget.suffixIconUrl!,
          width: 22,
          height: 22,
          color: _isFocused ? primaryGreen : pureBlack.withOpacity(0.4),
        ),
      );
    }

    return null;
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}

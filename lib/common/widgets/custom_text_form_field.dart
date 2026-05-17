// ============================================
// CUSTOM_TEXT_FORM_FIELD.DART
// ============================================

import 'package:afriendorse/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Color? fillColor;
  final Color? outlineInputBorderColor;
  final double? outlineInputBorderRadius;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isShowBorder;
  final bool isIcon;
  final bool isShowSuffixIcon;
  final bool isShowPrefixIcon;
  final Function? onTap;
  final Function? onChanged;
  final Function? onSuffixTap;
  final String? suffixIconUrl;
  final String? prefixIconUrl;
  final bool isSearch;
  final Function? onSubmit;
  final bool isEnabled;
  final TextCapitalization capitalization;
  final String? Function(String?)? onValidate;
  final InputDecoration? inputDecoration;

  const CustomTextFormField({
    super.key,
    this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSuffixTap,
    this.fillColor,
    this.outlineInputBorderColor,
    this.outlineInputBorderRadius,
    this.onSubmit,
    this.onChanged,
    this.capitalization = TextCapitalization.none,
    this.isCountryPicker = false,
    this.isShowBorder = false,
    this.isShowSuffixIcon = false,
    this.isShowPrefixIcon = false,
    this.onTap,
    this.isIcon = false,
    this.isPassword = false,
    this.suffixIconUrl,
    this.prefixIconUrl,
    this.isSearch = false,
    this.onValidate,
    this.inputDecoration,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;

  // Brand colors
  static const Color primaryGreen = Color(0xFF045F25);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);

  late AnimationController _focusAnimationController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _focusAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.fillColor ?? pureWhite,
            borderRadius: BorderRadius.circular(
              widget.outlineInputBorderRadius ?? 12,
            ),
            border: widget.isShowBorder
                ? Border.all(
                    color: _isFocused
                        ? (widget.outlineInputBorderColor ?? primaryGreen)
                        : pureBlack.withOpacity(0.1),
                    width: _isFocused ? 2 : 1,
                  )
                : null,
            boxShadow: _isFocused && widget.isShowBorder
                ? [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.15),
                      blurRadius: _elevationAnimation.value,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.outlineInputBorderRadius ?? 12,
            ),
            child: TextFormField(
              maxLines: widget.maxLines,
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: TextStyle(
                color: widget.isEnabled
                    ? pureBlack.withOpacity(0.9)
                    : pureBlack.withOpacity(0.4),
                fontSize: Dimensions.fontSizeDefault,
                fontWeight: FontWeight.w500,
              ),
              textInputAction: widget.inputAction,
              keyboardType: widget.inputType,
              cursorColor: primaryGreen,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(1),
              textCapitalization: widget.capitalization,
              enabled: widget.isEnabled,
              autofocus: false,
              obscureText: widget.isPassword ? _obscureText : false,
              inputFormatters: widget.inputType == TextInputType.phone
                  ? <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                    ]
                  : null,
              decoration: widget.inputDecoration ?? _buildDefaultDecoration(),
              onTap: widget.onTap as void Function()?,
              onFieldSubmitted: (text) => widget.nextFocus != null
                  ? FocusScope.of(context).requestFocus(widget.nextFocus)
                  : widget.onSubmit != null
                  ? widget.onSubmit!(text)
                  : null,
              onChanged: widget.onChanged as void Function(String)?,
              validator: widget.onValidate,
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildDefaultDecoration() {
    return InputDecoration(
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: InputBorder.none,
      isDense: true,
      hintText: widget.hintText,
      fillColor: Colors.transparent,
      filled: true,
      hintStyle: TextStyle(
        fontSize: Dimensions.fontSizeDefault,
        color: pureBlack.withOpacity(0.4),
        fontWeight: FontWeight.normal,
      ),

      // Prefix icon with modern styling
      prefixIcon: widget.isShowPrefixIcon
          ? Container(
              margin: const EdgeInsets.only(left: 12, right: 8),
              child: Image.asset(
                widget.prefixIconUrl!,
                width: 22,
                height: 22,
                color: _isFocused ? primaryGreen : pureBlack.withOpacity(0.4),
              ),
            )
          : null,
      prefixIconConstraints: widget.isShowPrefixIcon
          ? const BoxConstraints(minWidth: 50, maxHeight: 50)
          : null,

      // Suffix icon with modern styling
      suffixIcon: _buildSuffixIcon(),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, maxHeight: 48),
    );
  }

  Widget? _buildSuffixIcon() {
    if (!widget.isShowSuffixIcon) return null;

    if (widget.isPassword) {
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

    if (widget.isIcon && widget.suffixIconUrl != null) {
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

import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class FieldItemView extends StatelessWidget {
  final MethodField? methodField;
  final Map<String, TextEditingController>? textControllers;
  final Map<String, FocusNode>? focusNodes;
  final bool isCompact;

  const FieldItemView({
    super.key,
    this.methodField,
    this.textControllers,
    this.focusNodes,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isCompact ? 0 : Dimensions.paddingSizeDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Text(
                methodField!.inputName!
                    .replaceAll('_', ' ')
                    .formattedUpperCase(),
                style: robotoMedium.copyWith(
                  fontSize: isCompact
                      ? Dimensions.fontSizeSmall
                      : Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
              ),
              if (methodField?.isRequired == 1)
                Text(
                  ' *',
                  style: robotoMedium.copyWith(
                    color: Colors.red,
                    fontSize: isCompact
                        ? Dimensions.fontSizeSmall
                        : Dimensions.fontSizeDefault,
                  ),
                ),
            ],
          ),
          SizedBox(height: isCompact ? 6 : 8),

          // Input Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: textControllers![methodField!.inputName],
              focusNode: focusNodes![methodField!.inputName],
              keyboardType: _getType(methodField!.inputType ?? ""),
              obscureText: methodField!.inputType == 'password',
              style: robotoRegular.copyWith(
                fontSize: isCompact
                    ? Dimensions.fontSizeSmall
                    : Dimensions.fontSizeDefault,
              ),
              decoration: InputDecoration(
                hintText: methodField!.placeholder ?? '',
                hintStyle: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: isCompact
                      ? Dimensions.fontSizeSmall
                      : Dimensions.fontSizeDefault,
                ),
                prefixIcon: Icon(
                  _getFieldIcon(methodField!.inputType ?? ''),
                  color: Theme.of(context).hintColor,
                  size: isCompact ? 18 : 20,
                ),
                suffixIcon: methodField!.inputType == 'password'
                    ? Icon(
                        Icons.visibility_off_outlined,
                        color: Theme.of(context).hintColor,
                        size: isCompact ? 18 : 20,
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: isCompact ? 12 : 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              validator: (value) {
                if (methodField?.isRequired != 1) return null;
                return FormValidationHelper().validateDynamicTextFiled(
                  value!,
                  methodField!.placeholder
                          ?.replaceAll("_", " ")
                          .capitalizeFirst ??
                      "",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFieldIcon(String type) {
    switch (type) {
      case 'email':
        return Icons.email_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'password':
        return Icons.lock_outline;
      case 'number':
        return Icons.numbers;
      case 'date':
        return Icons.calendar_today_outlined;
      default:
        return Icons.edit_outlined;
    }
  }

  TextInputType _getType(String type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'date':
        return TextInputType.datetime;
      case 'password':
        return TextInputType.visiblePassword;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }
}

extension StringExtension on String {
  String formattedUpperCase() => replaceAllMapped(
    RegExp(r'(?<= |-|^).'),
    (match) => match[0]!.toUpperCase(),
  );
}

const indexNotFound = -1;

import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignUpStep2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const SignUpStep2({super.key, required this.formKey});

  @override
  State<SignUpStep2> createState() => _SignUpStep2State();
}

class _SignUpStep2State extends State<SignUpStep2> {
  final FocusNode _identityFocus = FocusNode();

  static const Color _primaryGreen = Color(0xFF045F25);
  static const Color _darkGreen = Color(0xFF033D18);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GetBuilder<SignUpController>(
          builder: (signUpController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryGreen.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGreen.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_primaryGreen, _darkGreen],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.business_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "business_information".tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Zone dropdown
                        TextFieldTitle(
                          title: "select_zone".tr,
                          requiredMark: true,
                          isPadding: false,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        const SizedBox(height: 6),
                        _StyledDropdown(
                          isValid: signUpController.isZoneValid,
                          hint: signUpController.selectedZoneName.isEmpty
                              ? "select_your_zone".tr
                              : signUpController.selectedZoneName,
                          hintIsValue:
                              signUpController.selectedZoneName.isNotEmpty,
                          items: signUpController.zoneList
                              .map(
                                (z) => DropdownMenuItem(
                                  value: z,
                                  child: Text(
                                    z.name!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (ZoneData? zoneData) {
                            if (zoneData != null) {
                              signUpController.setZoneData(
                                zoneData.name!,
                                zoneData.id!,
                              );
                              signUpController.checkOthersFieldValidity(
                                step2: true,
                              );
                            }
                          },
                        ),
                        if (!signUpController.isZoneValid)
                          _errorText(context, "fill_required_field".tr),

                        const SizedBox(height: 16),

                        // Identity type dropdown
                        TextFieldTitle(
                          title: "identity_type".tr,
                          requiredMark: true,
                          isPadding: false,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        const SizedBox(height: 6),
                        _StyledDropdown(
                          isValid: signUpController.isIdentityTypeValid,
                          hint: signUpController.selectedIdentityType.isEmpty
                              ? "select_identity_type".tr
                              : signUpController.selectedIdentityType.tr,
                          hintIsValue:
                              signUpController.selectedIdentityType.isNotEmpty,
                          items: AppConstants.identityTypeList
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item.tr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              signUpController.setIdentityType(newValue);
                              signUpController.checkOthersFieldValidity(
                                step2: true,
                              );
                            }
                          },
                        ),
                        if (!signUpController.isIdentityTypeValid)
                          _errorText(context, "fill_required_field".tr),

                        const SizedBox(height: 16),

                        // Identity number
                        CustomTextField(
                          inputType: TextInputType.text,
                          title: "identity_number".tr,
                          controller: signUpController.identityNumberController,
                          hintText: "enter_identity_number".tr,
                          maxLines: 1,
                          focusNode: _identityFocus,
                          isShowBorder: true,
                          borderRadius: 12,
                          fillColor: Colors.white,
                          onValidate: (value) =>
                              (value == null || value.isEmpty)
                              ? 'enter_identity_number'.tr
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // Identity image
                        TextFieldTitle(
                          title: "identity_image".tr,
                          requiredMark: true,
                        ),
                        if (signUpController
                            .selectedIdentityImageList
                            .isNotEmpty)
                          ListView.builder(
                            itemCount: signUpController
                                .selectedIdentityImageList
                                .length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(
                                          signUpController
                                              .selectedIdentityImageList[index]
                                              .file
                                              .path,
                                        ),
                                        fit: BoxFit.cover,
                                        height: 110,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: IconButton(
                                        onPressed: () =>
                                            signUpController.pickIdentityImage(
                                              true,
                                              index: index,
                                            ),
                                        icon: const Icon(
                                          Icons.highlight_remove_rounded,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        if (signUpController.selectedIdentityImageList.length <
                            AppConstants.limitOfPickedIdentityImageNumber)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DottedBorderBox(
                                height: 110,
                                width: double.infinity,
                                showErrorBorder:
                                    !signUpController.isIdentityImageValid,
                                onTap: () =>
                                    signUpController.pickIdentityImage(false),
                              ),
                              if (!signUpController.isIdentityImageValid)
                                _errorText(
                                  context,
                                  "provide_identity_image".tr,
                                ),
                            ],
                          ),
                        if (signUpController.selectedIdentityImageList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "image_validation_text_2".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                height: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _errorText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ── Reusable styled dropdown ───────────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  final bool isValid;
  final String hint;
  final bool hintIsValue;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.isValid,
    required this.hint,
    required this.hintIsValue,
    required this.items,
    required this.onChanged,
  });

  static const Color _primaryGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? _primaryGreen.withOpacity(0.25)
              : Theme.of(context).colorScheme.error,
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          menuMaxHeight: Get.height * 0.40,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 14,
              color: hintIsValue
                  ? const Color(0xFF1A1A1A)
                  : Colors.grey.shade500,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryGreen),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

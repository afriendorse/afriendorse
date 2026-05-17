import 'package:afriendorse/athlete/feature/auth/binding/sports_service.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SignUpStep1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const SignUpStep1({super.key, required this.formKey});

  @override
  State<SignUpStep1> createState() => _SignUpStep1State();
}

class _SignUpStep1State extends State<SignUpStep1> {
  final FocusNode _companyNameFocus = FocusNode();
  final FocusNode _companyPhoneFocus = FocusNode();
  final FocusNode _companyEmailFocus = FocusNode();
  final FocusNode _companyAddressFocus = FocusNode();

  // ── Contact person focus nodes (kept for future use) ──
  // final FocusNode _contactPersonNameFocus = FocusNode();
  // final FocusNode _contactPersonPhoneFocus = FocusNode();
  // final FocusNode _contactPersonEmailFocus = FocusNode();

  static const Color _primaryGreen = Color(0xFF045F25);
  static const Color _darkGreen = Color(0xFF033D18);

  @override
  void initState() {
    super.initState();
    // Auto-sync contact person info from business info on load
    // since the contact person section is hidden — prevents validation failures
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signUpController = Get.find<SignUpController>();
      if (!signUpController.keepPersonalInfoAsCompanyInfo) {
        signUpController.togglePersonalInfoAsCompanyInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GetBuilder<SignUpController>(
          builder: (signUpController) {
            return Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Section: Basic Information ───────────────────────
                  _SectionCard(
                    marginTop: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.person_outline_rounded,
                          label: "basic_information".tr,
                        ),
                        const SizedBox(height: 20),

                        // Company / Individual name
                        CustomTextField(
                          inputType: TextInputType.text,
                          controller: signUpController.companyNameController,
                          title: "company/individual_name".tr,
                          hintText: "company_name_hint".tr,
                          focusNode: _companyNameFocus,
                          nextFocus: _companyPhoneFocus,
                          capitalization: TextCapitalization.words,
                          isShowBorder: true,
                          borderRadius: 12,
                          fillColor: Colors.white,
                          onValidate: (value) =>
                              (value == null || value.isEmpty)
                              ? "company_name_hint".tr
                              : null,
                          onChanged: (_) => signUpController
                              .autoSaveContactPersonInfoAsGeneralInfo(),
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        CustomTextField(
                          onCountryChanged: (CountryCode countryCode) {
                            signUpController.countryDialCode =
                                countryCode.dialCode!;
                          },
                          countryDialCode: signUpController.countryDialCode,
                          hintText: 'ex : 123456789'.tr,
                          controller: signUpController.companyPhoneController,
                          inputType: TextInputType.phone,
                          focusNode: _companyPhoneFocus,
                          nextFocus: _companyEmailFocus,
                          isShowBorder: true,
                          borderRadius: 12,
                          fillColor: Colors.white,
                          onValidate: (value) {
                            if (value == null || value.isEmpty) {
                              return 'phone_number_hint'.tr;
                            }
                            return FormValidationHelper().isValidPhone(
                              signUpController.countryDialCode + value,
                            );
                          },
                          onChanged: (_) => signUpController
                              .autoSaveContactPersonInfoAsGeneralInfo(),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        CustomTextField(
                          inputType: TextInputType.emailAddress,
                          controller: signUpController.companyEmailController,
                          title: "email".tr,
                          hintText: 'enter_company_email_address'.tr,
                          focusNode: _companyEmailFocus,
                          nextFocus: _companyAddressFocus,
                          isShowBorder: true,
                          borderRadius: 12,
                          fillColor: Colors.white,
                          onValidate: (value) {
                            if (value == null || value.isEmpty) {
                              return 'empty_email_hint'.tr;
                            }
                            return FormValidationHelper().isValidEmail(value);
                          },
                          onChanged: (_) => signUpController
                              .autoSaveContactPersonInfoAsGeneralInfo(),
                        ),
                        const SizedBox(height: 16),

                        // Address
                        GetBuilder<LocationController>(
                          builder: (locationController) {
                            return GestureDetector(
                              onTap: () => _checkPermission(
                                () => Get.to(() => const PickMapScreen()),
                              ),
                              child: CustomTextField(
                                inputType: TextInputType.text,
                                controller:
                                    signUpController.companyAddressController,
                                hintText: "address_hint".tr,
                                title: "address".tr,
                                focusNode: _companyAddressFocus,
                                capitalization: TextCapitalization.sentences,
                                inputAction: TextInputAction.done,
                                isShowBorder: true,
                                borderRadius: 12,
                                fillColor: Colors.white,
                                isEnabled:
                                    locationController.pickAddress.address !=
                                    "",
                                suffixIcon: Images.pickPointLocation,
                                onPressedSuffix: () =>
                                    Get.to(() => const PickMapScreen()),
                                onValidate: (value) =>
                                    (value == null || value.isEmpty)
                                    ? "enter_address".tr
                                    : null,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Field of sport
                        TextFieldTitle(
                          title: "field_of_sport".tr,
                          requiredMark: true,
                          isPadding: false,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        const SizedBox(height: 6),
                        _SportDropdown(signUpController: signUpController),

                        const SizedBox(height: 20),

                        // Logo
                        TextFieldTitle(title: "logo".tr, requiredMark: true),
                        const SizedBox(height: 8),
                        _LogoPickerRow(signUpController: signUpController),

                        const SizedBox(height: 20),

                        // Cover image
                        TextFieldTitle(
                          title: "cover_image".tr,
                          requiredMark: true,
                          isPadding: false,
                        ),
                        const SizedBox(height: 10),
                        _CoverImageWidget(),
                      ],
                    ),
                  ),

                  // ── "Same as business info" toggle ────────────────────
                  /* Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => signUpController
                              .togglePersonalInfoAsCompanyInfo(),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              "same_as_business_info".tr,
                              style: TextStyle(
                                fontSize: 13,
                                color: _primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => signUpController
                              .togglePersonalInfoAsCompanyInfo(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color:
                                  signUpController.keepPersonalInfoAsCompanyInfo
                                  ? _primaryGreen
                                  : Colors.white,
                              border: Border.all(
                                color:
                                    signUpController
                                        .keepPersonalInfoAsCompanyInfo
                                    ? _primaryGreen
                                    : Colors.grey.shade400,
                                width: 1.8,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child:
                                signUpController.keepPersonalInfoAsCompanyInfo
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ), */

                  // ──────────────────────────────────────────────────────
                  // CONTACT PERSON SECTION — commented out / made optional
                  // Athletes can skip this; it is pre-filled from business
                  // info when "same as business info" is checked.
                  // ──────────────────────────────────────────────────────
                  /*
                  _SectionCard(
                    marginTop: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.contact_phone_outlined,
                          label: "contact_person_info_title".tr,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          inputType: TextInputType.text,
                          controller: signUpController.contactPersonNameController,
                          title: "contact_person_name".tr,
                          hintText: "enter_contact_person_name".tr,
                          capitalization: TextCapitalization.words,
                          focusNode: _contactPersonNameFocus,
                          nextFocus: _contactPersonPhoneFocus,
                          isShowBorder: true,
                          borderRadius: 12,
                          fillColor: Colors.white,
                          onValidate: (value) =>
                              (value == null || value.isEmpty)
                                  ? "enter_contact_person_name".tr
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          onCountryChanged: (CountryCode countryCode) {
                            signUpController.countryDialCode =
                                countryCode.dialCode!;
                          },
                          countryDialCode: signUpController.countryDialCode,
                          hintText: 'ex : 123456789'.tr,
                          controller: signUpController.contactPersonPhoneController,
                          inputType: TextInputType.phone,
                          focusNode: _contactPersonPhoneFocus,
                          nextFocus: _contactPersonEmailFocus,
                          isShowBorder: true,
                          borderRadius: 12,
                          fillColor: Colors.white,
                          onValidate: (value) {
                            if (value == null || value.isEmpty) {
                              return 'phone_number_hint'.tr;
                            }
                            return FormValidationHelper().isValidPhone(
                              signUpController.countryDialCode + value,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          inputType: TextInputType.emailAddress,
                          controller: signUpController.contactPersonEmailController,
                          title: "email".tr,
                          hintText: "enter_contact_person_email_address".tr,
                          focusNode: _contactPersonEmailFocus,
                          inputAction: TextInputAction.done,
                          isShowBorder: true,
                          borderRadius: 12,
                          fillColor: Colors.white,
                          onValidate: (value) {
                            if (value == null || value.isEmpty) {
                              return 'empty_email_hint'.tr;
                            }
                            return FormValidationHelper().isValidEmail(value);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  */
                  // ── END contact person (optional) ─────────────────────
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      showCustomDialog(
        child: const PermissionDialog(),
        barrierDismissible: true,
      );
    } else {
      onTap();
    }
  }
}

// ── Shared section card ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final double marginTop;
  const _SectionCard({required this.child, this.marginTop = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14, marginTop, 14, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF045F25).withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF045F25).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section header with icon badge ────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  static const Color _primaryGreen = Color(0xFF045F25);
  static const Color _darkGreen = Color(0xFF033D18);

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ── Sport dropdown ─────────────────────────────────────────────────────────

class _SportDropdown extends StatelessWidget {
  final SignUpController signUpController;
  const _SportDropdown({required this.signUpController});

  static const Color _primaryGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: signUpController.isFieldOfSportValid
                  ? _primaryGreen.withOpacity(0.25)
                  : Theme.of(context).colorScheme.error,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              menuMaxHeight: Get.height * 0.40,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              isExpanded: true,
              hint: Text(
                signUpController.selectedFieldOfSport.isEmpty
                    ? "select_field_of_sport".tr
                    : signUpController.sportsList
                          .firstWhere(
                            (s) =>
                                s.id == signUpController.selectedFieldOfSport,
                            orElse: () => SportModel(id: '', name: ''),
                          )
                          .name,
                style: TextStyle(
                  color: signUpController.selectedFieldOfSport.isEmpty
                      ? Colors.grey.shade500
                      : const Color(0xFF1A1A1A),
                  fontSize: 14,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _primaryGreen,
              ),
              items: signUpController.sportsList
                  .map(
                    (sport) => DropdownMenuItem<String>(
                      value: sport.id,
                      child: Row(
                        children: [
                          Text(
                            sport.icon ?? '',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            sport.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (sportId) {
                if (sportId != null) signUpController.setFieldOfSport(sportId);
              },
            ),
          ),
        ),
        if (!signUpController.isFieldOfSportValid)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "fill_required_field".tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Logo picker row ────────────────────────────────────────────────────────

class _LogoPickerRow extends StatelessWidget {
  final SignUpController signUpController;
  const _LogoPickerRow({required this.signUpController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        signUpController.profileImageFile != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(signUpController.profileImageFile!.path),
                      fit: BoxFit.cover,
                      height: 90,
                      width: 90,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: IconButton(
                      onPressed: () => signUpController.pickProfileImage(true),
                      icon: const Icon(
                        Icons.highlight_remove_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              )
            : DottedBorderBox(
                height: 90,
                width: 90,
                showErrorBorder: !signUpController.isLogoValid,
                onTap: () => signUpController.pickProfileImage(false),
              ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            "image_validation_text_1".tr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Cover image widget (unchanged logic, refreshed style) ─────────────────

class _CoverImageWidget extends StatelessWidget {
  const _CoverImageWidget();

  static const Color _primaryGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetBuilder<SignUpController>(
          builder: (signUpController) {
            return DottedBorderBox(
              showErrorBorder: !signUpController.isCoverImageValidity,
              width: context.width,
              height: context.width / 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                      child: signUpController.coverImageFile != null
                          ? Image.file(
                              File(signUpController.coverImageFile!.path),
                              fit: BoxFit.cover,
                            )
                          : CustomImage(
                              image: '',
                              errorWidget: InkWell(
                                onTap: () => signUpController.pickCoverImage(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      color: _primaryGreen.withOpacity(0.5),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'update_cover_image'.tr,
                                      style: TextStyle(
                                        color:
                                            !signUpController
                                                .isCoverImageValidity
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.error
                                            : Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (signUpController.coverImageFile != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => signUpController.pickCoverImage(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: _primaryGreen,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${'image_format_jpg_png'.tr} ${'image_size_maximum_size'.tr} ${'image_ratio_3_1'.tr}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

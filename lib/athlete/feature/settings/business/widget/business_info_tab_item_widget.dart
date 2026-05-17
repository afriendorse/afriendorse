// lib/athlete/feature/settings/business/widget/business_info_tab_item_widget.dart

import 'package:afriendorse/athlete/feature/profile/model/provider_model.dart';
import 'package:afriendorse/athlete/feature/tutorial/controller/tutorial_controller.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BusinessInfoTabItemWidget extends StatefulWidget {
  const BusinessInfoTabItemWidget({super.key});

  @override
  State<BusinessInfoTabItemWidget> createState() =>
      _BusinessInfoTabItemWidgetState();
}

class _BusinessInfoTabItemWidgetState extends State<BusinessInfoTabItemWidget> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  final TextEditingController _addressCtrl = TextEditingController();

  final GlobalKey _basicInfoSectionKey = GlobalKey();
  final GlobalKey _logoSectionKey = GlobalKey();
  final GlobalKey _coverSectionKey = GlobalKey();

  final _InfoSectionController _basicInfoSection = _InfoSectionController();
  final _InfoSectionController _logoSection = _InfoSectionController();
  final _InfoSectionController _coverSection = _InfoSectionController();

  final ScrollController _scrollController = ScrollController();

  static const kGreen = Color(0xFF045F25);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Get.find<UserProfileController>().getProviderInfo(reload: true);

      if (!mounted) return;

      final info = Get.find<UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo;

      _safeSetText(_addressCtrl, info?.companyAddress ?? '');
    });
  }

  void _safeSetText(TextEditingController controller, String text) {
    try {
      controller.text = text;
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _emailFocus.dispose();
    _addressCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(
    BuildContext context,
    UserProfileController upc,
  ) async {
    final bool formValid =
        upc.profileInformationFormKey.currentState?.validate() ?? false;
    final bool zoneValid = upc.isZoneValid;
    final bool hasCover =
        upc.coverImageFile != null ||
        (upc.providerModel?.content?.providerInfo?.coverFullPath?.isNotEmpty ??
            false);

    final List<_SectionError> sectionErrors = [];

    if (!formValid || !zoneValid) {
      sectionErrors.add(
        _SectionError(
          key: _basicInfoSectionKey,
          section: _basicInfoSection,
          label: 'basic_information'.tr,
        ),
      );
    }

    if (!hasCover) {
      sectionErrors.add(
        _SectionError(
          key: _coverSectionKey,
          section: _coverSection,
          label: 'cover_image'.tr,
        ),
      );
    }

    if (sectionErrors.isNotEmpty) {
      for (final e in sectionErrors) {
        e.section.expand();
      }

      await Future.delayed(const Duration(milliseconds: 260));

      if (!mounted) return;

      _scrollToKey(sectionErrors.first.key);

      final errorLabels = sectionErrors.map((e) => '• ${e.label}').join('\n');
      showCustomSnackBar(
        '${'please_complete_the_following'.tr}:\n$errorLabels',
      );
      return;
    }

    _proceedWithSave(upc);
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  void _proceedWithSave(UserProfileController upc) {
    if (upc
            .providerModel
            ?.content
            ?.providerInfo
            ?.tutorialData?[AppConstants.businessInfoTutorialKey]
            ?.contains('0') ??
        true) {
      Get.find<TutorialController>().updateTutorial(
        key: AppConstants.businessInfoTutorialKey,
      );
    }

    upc.updateProfile(address: _addressCtrl.text, identityNumber: '').then((
      status,
    ) {
      Get.find<ServiceCategoryController>().changeCategory(0, isUpdate: true);

      if (status.isSuccess!) {
        Get.find<AuthController>().updateToken();
        Get.find<SubcategorySubscriptionController>().getMySubscriptionData(
          1,
          false,
        );
        showCustomSnackBar(
          'profile_updated_successfully'.tr,
          type: ToasterMessageType.success,
        );
      } else {
        showCustomSnackBar(status.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (upc) {
        return Skeletonizer(
          enabled: upc.isLoading,
          child: Form(
            key: upc.profileInformationFormKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoSection(
                          key: _basicInfoSectionKey,
                          controller: _basicInfoSection,
                          step: '01',
                          title: 'basic_information'.tr,
                          subtitle:
                              'setup_your_responsible_contact_person_information'
                                  .tr,
                          icon: Icons.business_center_rounded,
                          child: BasicInfoWidget(
                            companyNameFocus: _nameFocus,
                            companyPhoneFocus: _phoneFocus,
                            companyEmailFocus: _emailFocus,
                            companyAddressFocus: _addressFocus,
                            companyAddressController: _addressCtrl,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _InfoSection(
                          key: _logoSectionKey,
                          controller: _logoSection,
                          step: '02',
                          title: 'logo'.tr,
                          subtitle: 'image_format_jpg_png'.tr,
                          icon: Icons.image_rounded,
                          child: const LogoWidget(),
                        ),

                        const SizedBox(height: 16),

                        _InfoSection(
                          key: _coverSectionKey,
                          controller: _coverSection,
                          step: '03',
                          title: 'cover_image'.tr,
                          subtitle: 'image_format_jpg_png'.tr,
                          icon: Icons.photo_size_select_actual_rounded,
                          child: const CoverImageWidget(),
                        ),
                      ],
                    ),
                  ),
                ),

                _SaveBar(
                  isLoading: upc.isLoading,
                  onSave: () => _updateProfile(context, upc),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section controller — lets the parent imperatively expand a section
// ─────────────────────────────────────────────────────────────────────────────

class _InfoSectionController {
  _InfoSectionState? _state;

  void _attach(_InfoSectionState state) => _state = state;
  void _detach() => _state = null;

  void expand() => _state?._setExpanded(true);
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class — pairs a section key with its controller and display label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionError {
  final GlobalKey key;
  final _InfoSectionController section;
  final String label;

  const _SectionError({
    required this.key,
    required this.section,
    required this.label,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic collapsible info section card
// ─────────────────────────────────────────────────────────────────────────────

class _InfoSection extends StatefulWidget {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final _InfoSectionController? controller;

  const _InfoSection({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.controller,
  });

  @override
  State<_InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<_InfoSection> {
  bool _expanded = true;
  static const kGreen = Color(0xFF045F25);

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  void _setExpanded(bool value) {
    if (_expanded != value) setState(() => _expanded = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: kGreen, size: 20),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: kGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.step,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.48),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: Column(
              children: [
                Divider(height: 1, color: Colors.black.withOpacity(0.07)),
                Padding(padding: const EdgeInsets.all(16), child: widget.child),
              ],
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Basic info fields
// ─────────────────────────────────────────────────────────────────────────────

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({
    super.key,
    required this.companyNameFocus,
    required this.companyPhoneFocus,
    required this.companyEmailFocus,
    required this.companyAddressFocus,
    required this.companyAddressController,
  });

  final FocusNode companyNameFocus;
  final FocusNode companyPhoneFocus;
  final FocusNode companyEmailFocus;
  final FocusNode companyAddressFocus;
  final TextEditingController companyAddressController;

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (upc) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              title: 'company/individual_name'.tr,
              controller: upc.companyNameController,
              hintText: 'company_name_hint'.tr,
              maxLines: 1,
              capitalization: TextCapitalization.words,
              inputAction: TextInputAction.next,
              focusNode: companyNameFocus,
              nextFocus: companyPhoneFocus,
              onValidate: (v) => (v == null || v.isEmpty)
                  ? 'enter_contact_person_name'.tr
                  : null,
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            CustomTextField(
              onCountryChanged: (c) => upc.countryDialCode = c.dialCode!,
              countryDialCode: upc.countryDialCode,
              title: 'phone_number'.tr,
              hintText: 'enter_company_phone_number'.tr,
              controller: upc.companyPhoneController,
              inputType: TextInputType.phone,
              inputAction: TextInputAction.next,
              focusNode: companyPhoneFocus,
              nextFocus: companyEmailFocus,
              onValidate: (v) {
                if (v == null || v.isEmpty) return 'phone_number_hint'.tr;
                return FormValidationHelper().isValidPhone(
                  upc.countryDialCode + v,
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            CustomTextField(
              title: 'email'.tr,
              inputType: TextInputType.emailAddress,
              controller: upc.companyEmailController,
              hintText: 'enter_company_email_address'.tr,
              focusNode: companyEmailFocus,
              nextFocus: companyAddressFocus,
              onValidate: (v) {
                if (v == null || v.isEmpty) return 'empty_email_hint'.tr;
                return FormValidationHelper().isValidEmail(v);
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            GetBuilder<LocationController>(
              builder: (lc) {
                return _MapAddressField(
                  upc: upc,
                  lc: lc,
                  addressCtrl: companyAddressController,
                  companyAddressFocus: companyAddressFocus,
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            _ZonePicker(upc: upc),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map address field
// ─────────────────────────────────────────────────────────────────────────────

class _MapAddressField extends StatelessWidget {
  final UserProfileController upc;
  final LocationController lc;
  final TextEditingController addressCtrl;
  final FocusNode companyAddressFocus;

  const _MapAddressField({
    required this.upc,
    required this.lc,
    required this.addressCtrl,
    required this.companyAddressFocus,
  });

  static const kGreen = Color(0xFF045F25);

  Future<void> _openMap(BuildContext context) async {
    await Get.to(
      () => PickMapScreen(
        initialPosition: LatLng(
          upc.providerModel?.content?.providerInfo?.coordinates?.latitude ??
              23.777176,
          upc.providerModel?.content?.providerInfo?.coordinates?.longitude ??
              -90.399452,
        ),
        initialAddress:
            upc.providerModel?.content?.providerInfo?.companyAddress,
      ),
    );
    if (lc.pickAddress.address != null && lc.pickAddress.address!.isNotEmpty) {
      addressCtrl.text = lc.pickAddress.address!;
    } else {
      addressCtrl.text =
          upc.providerModel?.content?.providerInfo?.companyAddress ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'address'.tr,
          style: TextStyle(
            color: Colors.black.withOpacity(0.72),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: () => _openMap(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.10)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: kGreen,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    addressCtrl.text.isEmpty
                        ? 'address_hint'.tr
                        : addressCtrl.text,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: addressCtrl.text.isEmpty
                          ? Colors.black.withOpacity(0.28)
                          : Colors.black.withOpacity(0.80),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to pick',
                  style: TextStyle(
                    fontSize: 11,
                    color: kGreen.withOpacity(0.80),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Zone picker
// ─────────────────────────────────────────────────────────────────────────────

class _ZonePicker extends StatelessWidget {
  final UserProfileController upc;
  const _ZonePicker({required this.upc});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'select_zone'.tr,
              style: TextStyle(
                color: Colors.black.withOpacity(0.72),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !upc.isZoneValid
                  ? Theme.of(context).colorScheme.error.withOpacity(0.6)
                  : Colors.black.withOpacity(0.10),
              width: !upc.isZoneValid ? 1.4 : 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ZoneData>(
              isExpanded: true,
              menuMaxHeight: Get.height * 0.40,
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              elevation: 8,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: kGreen),
              hint: Text(
                upc.selectedZoneName.isEmpty
                    ? upc.myZone
                    : upc.selectedZoneName,
                style: robotoRegular.copyWith(
                  fontSize: 13.5,
                  color: upc.selectedZoneName.isEmpty
                      ? Colors.black.withOpacity(0.40)
                      : Colors.black.withOpacity(0.80),
                ),
              ),
              items: upc.zoneList.map((z) {
                return DropdownMenuItem<ZoneData>(
                  value: z,
                  child: Text(
                    z.name!,
                    style: robotoRegular.copyWith(
                      fontSize: 13.5,
                      color: Colors.black.withOpacity(0.75),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (z) {
                if (z == null) return;
                upc.setNewZoneValue(z.name!, z.id!);
                upc.onProfileChangeValidationCheck();
              },
            ),
          ),
        ),

        if (!upc.isZoneValid)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Text(
              'fill_required_field'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo widget
// ─────────────────────────────────────────────────────────────────────────────

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (upc) {
        final hasImage =
            upc.pickedFile != null ||
            (upc
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.logoFullPath
                    ?.isNotEmpty ??
                false);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: upc.pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kGreen.withOpacity(0.30),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (upc.pickedFile != null)
                      Image.file(File(upc.pickedFile!.path), fit: BoxFit.cover)
                    else
                      CustomImage(
                        image:
                            upc
                                .providerModel
                                ?.content
                                ?.providerInfo
                                ?.logoFullPath ??
                            '',
                        fit: BoxFit.cover,
                        placeholder: Images.userPlaceHolder,
                        errorWidget: _UploadPlaceholder(
                          label: 'update_logo'.tr,
                        ),
                      ),
                    if (hasImage)
                      Positioned(right: 4, top: 4, child: _EditBadge()),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HintRow(
                    icon: Icons.image_outlined,
                    text: 'image_format_jpg_png'.tr,
                  ),
                  const SizedBox(height: 6),
                  _HintRow(
                    icon: Icons.straighten_rounded,
                    text: 'image_ratio_1_1'.tr,
                  ),
                  const SizedBox(height: 6),
                  _HintRow(
                    icon: Icons.data_usage_rounded,
                    text: 'image_size_maximum_size'.tr,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: upc.pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.upload_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasImage ? 'Change Logo' : 'Upload Logo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover image widget
// ─────────────────────────────────────────────────────────────────────────────

class CoverImageWidget extends StatelessWidget {
  const CoverImageWidget({super.key});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (upc) {
        final hasImage =
            upc.coverImageFile != null ||
            (upc
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.coverFullPath
                    ?.isNotEmpty ??
                false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: upc.pickCoverImage,
              child: Container(
                width: double.infinity,
                height: (context.width - 2 * Dimensions.paddingSizeDefault) / 3,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: kGreen.withOpacity(0.28),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (upc.coverImageFile != null)
                      Image.file(
                        File(upc.coverImageFile!.path),
                        fit: BoxFit.cover,
                      )
                    else
                      CustomImage(
                        image:
                            upc
                                .providerModel
                                ?.content
                                ?.providerInfo
                                ?.coverFullPath ??
                            '',
                        fit: BoxFit.cover,
                        errorWidget: _UploadPlaceholder(
                          label: 'update_cover_image'.tr,
                          isWide: true,
                        ),
                      ),
                    if (hasImage) ...[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(right: 8, top: 8, child: _EditBadge()),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _HintRow(
                    icon: Icons.straighten_rounded,
                    text: 'image_ratio_3_1'.tr,
                  ),
                ),
                Expanded(
                  child: _HintRow(
                    icon: Icons.data_usage_rounded,
                    text: 'image_size_maximum_size'.tr,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: upc.pickCoverImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.upload_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasImage ? 'Change Cover' : 'Upload Cover',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky save bar
// ─────────────────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSave;

  const _SaveBar({required this.isLoading, required this.onSave});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        12,
        Dimensions.paddingSizeDefault,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.07))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
            ),
            boxShadow: [
              BoxShadow(
                color: kGreen.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          // REPLACE the entire ElevatedButton with this:
          child: ElevatedButton(
            onPressed: isLoading
                ? () {}
                : onSave, // ← never null, blocks tap when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent, // ← safety net
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white, // ← now visible on green gradient
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'save_information'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared micro-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _UploadPlaceholder extends StatelessWidget {
  final String label;
  final bool isWide;
  const _UploadPlaceholder({required this.label, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: isWide ? 32 : 28,
            color: Colors.black.withOpacity(0.22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withOpacity(0.38),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
        ],
      ),
      child: const Icon(Icons.edit_rounded, size: 13, color: Color(0xFF045F25)),
    );
  }
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.black38),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black.withOpacity(0.45),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

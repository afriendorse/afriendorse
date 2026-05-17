// lib/athlete/feature/settings/verification/screen/athlete_verification_screen.dart

import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/settings/business/controller/identity_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

/// Standalone screen where the athlete submits their identity documents
/// for admin badge-verification.
///
/// Flow:
///   • If [verificationStatus] == 'verified'  → locked success state
///   • If [verificationStatus] == 'pending'   → locked pending state
///   • If [verificationStatus] == 'rejected'  → shows rejection reason + re-submit allowed
///   • Otherwise                              → normal upload form
class AthleteVerificationScreen extends StatefulWidget {
  const AthleteVerificationScreen({super.key});

  @override
  State<AthleteVerificationScreen> createState() =>
      _AthleteVerificationScreenState();
}

class _AthleteVerificationScreenState extends State<AthleteVerificationScreen> {
  static const kGreen = Color(0xFF045F25);
  static const kGreenDark = Color(0xFF033D18);

  final TextEditingController _identityNumberCtrl = TextEditingController();
  late final IdentityController _idCtrl;
  late final UserProfileController _upc;

  String? _firestoreVerificationStatus;
  String? _firestoreRejectionReason;

  @override
  void initState() {
    super.initState();
    _idCtrl = Get.find<IdentityController>();
    _upc = Get.find<UserProfileController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _upc.getProviderInfo(reload: true);
      if (!mounted) return;

      final info = _upc.providerModel?.content?.providerInfo;
      _identityNumberCtrl.text = info?.owner?.identificationNumber ?? '';

      _idCtrl.onChangeIdentityType(
        info?.owner?.identificationType,
        isUpdate: false,
      );
      _idCtrl.initializeCurrentImage(
        info?.owner?.identificationImageFullPath ?? [],
      );
      _idCtrl.identityImagePickInitialize();

      // ── Fetch verificationStatus from Firestore ──
      final email = info?.owner?.email ?? info?.companyEmail ?? '';
      if (email.isNotEmpty) {
        final athleteData = await AthleteFirestoreSyncService.getAthleteByEmail(
          email,
        );
        if (mounted) {
          setState(() {
            _firestoreVerificationStatus =
                athleteData?['verificationStatus'] as String?;
            _firestoreRejectionReason =
                athleteData?['rejectionReason'] as String?;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _identityNumberCtrl.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String? get _verificationStatus => _firestoreVerificationStatus;

  bool get _isPending => _verificationStatus == 'pending';
  bool get _isVerified => _verificationStatus == 'verified';
  bool get _isRejected => _verificationStatus == 'rejected';
  bool get _isLocked => _isPending || _isVerified;

  void _submit() {
    if (_idCtrl.isUploadEmpty()) {
      showCustomSnackBar('please_update_identity_images'.tr);
      return;
    }
    if (_identityNumberCtrl.text.trim().isEmpty) {
      showCustomSnackBar('enter_identity_number'.tr);
      return;
    }

    _upc
        .updateProfile(
          address:
              _upc.providerModel?.content?.providerInfo?.companyAddress ?? '',
          identityNumber: _identityNumberCtrl.text.trim(),
        )
        .then((status) async {
          if (!mounted) return;

          if (status.isSuccess!) {
            _idCtrl.initializeCurrentImage(
              _upc
                      .providerModel
                      ?.content
                      ?.providerInfo
                      ?.owner
                      ?.identificationImageFullPath ??
                  [],
            );
            _idCtrl.identityImagePickInitialize();

            // ✅ ALSO mark Firestore verification as pending
            final info = _upc.providerModel?.content?.providerInfo;
            final email = (info?.owner?.email ?? info?.companyEmail ?? '')
                .toString()
                .trim();

            if (email.isNotEmpty) {
              await AthleteFirestoreSyncService.setVerificationPending(email);

              // refresh local UI state
              final athleteData =
                  await AthleteFirestoreSyncService.getAthleteByEmail(email);
              if (mounted) {
                setState(() {
                  _firestoreVerificationStatus =
                      athleteData?['verificationStatus'] as String?;
                  _firestoreRejectionReason =
                      athleteData?['rejectionReason'] as String?;
                });
              }
            }

            showCustomSnackBar(
              'verification_submitted'.tr,
              type: ToasterMessageType.success,
            );
          } else {
            showCustomSnackBar(status.message);
          }
        });
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<UserProfileController>(
        builder: (upc) {
          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isVerified
                    ? _VerifiedState()
                    : _isPending
                    ? _PendingState()
                    : _buildForm(context, upc),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kGreen, kGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identity Verification',
                      style: robotoBold.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Upload your documents to get verified',
                      style: robotoRegular.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                isVerified: _isVerified,
                isPending: _isPending,
                isRejected: _isRejected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── scrollable form ───────────────────────────────────────────────────────

  Widget _buildForm(BuildContext context, UserProfileController upc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: GetBuilder<IdentityController>(
        builder: (idCtrl) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rejection banner
              if (_isRejected) ...[
                _RejectionBanner(reason: _firestoreRejectionReason),
                const SizedBox(height: 16),
              ],

              // Step 1 — ID type
              _StepCard(
                step: '01',
                title: 'Document Type',
                subtitle: 'Select the type of ID you are uploading',
                child: _IdentityTypeDropdown(idCtrl: idCtrl),
              ),

              const SizedBox(height: 14),

              // Step 2 — ID number
              _StepCard(
                step: '02',
                title: 'Document Number',
                subtitle: 'Enter the number printed on your document',
                child: CustomTextField(
                  inputType: TextInputType.text,
                  title: 'identity_number'.tr,
                  controller: _identityNumberCtrl,
                  hintText: 'enter_identity_number'.tr,
                  maxLines: 1,
                  onValidate: (v) => (v == null || v.isEmpty)
                      ? 'enter_identity_number'.tr
                      : null,
                ),
              ),

              const SizedBox(height: 14),

              // Step 3 — Images
              _StepCard(
                step: '03',
                title: 'Document Images',
                subtitle: 'Upload clear photos of your document',
                child: _IdentityImagesSection(idCtrl: idCtrl),
              ),

              const SizedBox(height: 24),

              // Info note
              _InfoNote(),

              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kGreen, Color(0xFF0A7A33)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kGreen.withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: upc.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: upc.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isRejected
                                    ? 'Resubmit Documents'
                                    : 'Submit for Verification',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom
                    : 16,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip shown in the header
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool isVerified;
  final bool isPending;
  final bool isRejected;

  const _StatusChip({
    required this.isVerified,
    required this.isPending,
    required this.isRejected,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return _chip(Icons.verified_rounded, 'Verified', Colors.greenAccent);
    }
    if (isPending) {
      return _chip(Icons.hourglass_top_rounded, 'Pending', Colors.amber);
    }
    if (isRejected) {
      return _chip(Icons.cancel_outlined, 'Rejected', Colors.redAccent);
    }
    return _chip(Icons.shield_outlined, 'Unverified', Colors.white54);
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verified full-screen state
// ─────────────────────────────────────────────────────────────────────────────

class _VerifiedState extends StatelessWidget {
  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGreen.withOpacity(0.1),
                border: Border.all(color: kGreen.withOpacity(0.3), width: 2),
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 48,
                color: kGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Identity Verified!',
              style: robotoBold.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Your identity has been verified. Your verification badge is now active on your profile.',
              style: robotoRegular.copyWith(
                color: Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGreen.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: kGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your badge helps sponsors and brands trust your identity on AfriEndorse.',
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pending full-screen state — form locked
// ─────────────────────────────────────────────────────────────────────────────

class _PendingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withOpacity(0.12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.35),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 46,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            Text('Under Review', style: robotoBold.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              'Your documents have been submitted and are currently being reviewed by our team.',
              style: robotoRegular.copyWith(
                color: Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _TimelineStep(
              icon: Icons.upload_file_rounded,
              label: 'Documents submitted',
              isDone: true,
            ),
            const SizedBox(height: 10),
            _TimelineStep(
              icon: Icons.manage_search_rounded,
              label: 'Admin review in progress',
              isDone: false,
              isActive: true,
            ),
            const SizedBox(height: 10),
            _TimelineStep(
              icon: Icons.verified_rounded,
              label: 'Badge awarded',
              isDone: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;

  const _TimelineStep({
    required this.icon,
    required this.label,
    this.isDone = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? const Color(0xFF045F25)
        : isActive
        ? Colors.amber
        : Colors.grey.shade300;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isDone || isActive ? FontWeight.w700 : FontWeight.w400,
            color: isDone || isActive ? Colors.black87 : Colors.black38,
          ),
        ),
        if (isDone) ...[
          const Spacer(),
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: Color(0xFF045F25),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rejection banner
// ─────────────────────────────────────────────────────────────────────────────

class _RejectionBanner extends StatelessWidget {
  final String? reason;
  const _RejectionBanner({this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Rejected',
                  style: robotoBold.copyWith(
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
                if (reason != null && reason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reason!,
                    style: robotoRegular.copyWith(
                      color: Colors.red.shade600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Please correct your documents and resubmit.',
                  style: robotoRegular.copyWith(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final Widget child;

  static const kGreen = Color(0xFF045F25);

  const _StepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
  });

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
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kGreen.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.article_outlined,
                        color: kGreen,
                        size: 19,
                      ),
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
                          step,
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
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.45),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.black.withOpacity(0.07)),

          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Identity type dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityTypeDropdown extends StatelessWidget {
  final IdentityController idCtrl;
  const _IdentityTypeDropdown({required this.idCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          elevation: 8,
          hint: Text(
            'select_identity_type'.tr,
            style: robotoRegular.copyWith(
              fontSize: 13.5,
              color: Colors.black.withOpacity(0.40),
            ),
          ),
          value: idCtrl.selectedIdentityType,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF045F25),
          ),
          items: AppConstants.identityTypeList.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item.tr,
                style: robotoRegular.copyWith(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            idCtrl.onChangeIdentityType(newValue);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Identity images section — reuses all existing IdentityController logic
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityImagesSection extends StatelessWidget {
  final IdentityController idCtrl;
  const _IdentityImagesSection({required this.idCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // existing server images
        if (idCtrl.currentIdentityImages.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.paddingSizeSmall),
            itemCount: idCtrl.currentIdentityImages.length,
            itemBuilder: (context, index) {
              final isReplaced = idCtrl.replacedIdentityImages?[index] != null;

              return _ImageTile(
                child: isReplaced
                    ? Image.file(
                        File(
                          idCtrl
                              .replacedIdentityImages![index]!
                              .imageFile!
                              .path,
                        ),
                        fit: BoxFit.cover,
                      )
                    : CustomImage(
                        fit: BoxFit.cover,
                        image: idCtrl.currentIdentityImages[index] ?? '',
                      ),
                onEdit: () => idCtrl.onReplacePickIdentityImage(
                  index: index,
                  isRemoved: isReplaced,
                ),
                onDelete: isReplaced
                    ? null
                    : () => showCustomDialog(
                        child: ConfirmationDialog(
                          icon: Images.deleteDialogIcon,
                          title: 'are_you_want_to_delete'.tr,
                          description: '',
                          onNoPressed: () => Get.back(),
                          onYesPressed: () {
                            idCtrl.removeCurrentImage(index);
                            Get.back();
                          },
                        ),
                        barrierDismissible: true,
                        useSafeArea: true,
                      ),
                editIcon: isReplaced ? Icons.close : Icons.edit,
              );
            },
          ),

        // newly picked images (not yet on server)
        if ((idCtrl.identityImages?.length ?? 0) > 0) ...[
          if (idCtrl.currentIdentityImages.isNotEmpty)
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) =>
                const SizedBox(height: Dimensions.paddingSizeSmall),
            itemCount: idCtrl.identityImages!.length,
            itemBuilder: (context, index) {
              return _ImageTile(
                child: Image.file(
                  File(idCtrl.identityImages![index]!.path),
                  fit: BoxFit.cover,
                ),
                onEdit: () =>
                    idCtrl.pickIdentityImage(index: index, isRemoved: true),
                editIcon: Icons.close,
              );
            },
          ),
        ],

        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Add new image slot
        if (_canAddMore(idCtrl)) ...[
          GestureDetector(
            onTap: () => idCtrl.pickIdentityImage(),
            child: DottedBorderBox(
              height: MediaQuery.of(context).size.width / 3.2,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF045F25).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF045F25),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to add image',
                    style: robotoRegular.copyWith(
                      color: Colors.black.withOpacity(0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Image format – jpg, png, jpeg · max 2 MB',
              style: robotoLight.copyWith(
                color: Colors.black.withOpacity(0.40),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _canAddMore(IdentityController idCtrl) {
    final existing =
        (idCtrl.currentIdentityImages.length) -
        idCtrl.deletedIdentityImages.length;
    final replaced = idCtrl.replacedIdentityImages?.length ?? 0;
    final newPicked = idCtrl.identityImages?.length ?? 0;
    return (existing + replaced + newPicked) <
        AppConstants.limitOfPickedIdentityImageNumber;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single image tile with edit/delete overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ImageTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final IconData editIcon;

  const _ImageTile({
    required this.child,
    required this.onEdit,
    this.onDelete,
    required this.editIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: MediaQuery.of(context).size.width / 3,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            // subtle dark overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
            ),
            // action buttons
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  if (onDelete != null)
                    _ActionBadge(
                      icon: Icons.delete_rounded,
                      color: Colors.red,
                      onTap: onDelete!,
                    ),
                  if (onDelete != null) const SizedBox(width: 6),
                  _ActionBadge(
                    icon: editIcon,
                    color: const Color(0xFF045F25),
                    onTap: onEdit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBadge({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info note at the bottom of the form
// ─────────────────────────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF045F25).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF045F25).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: Color(0xFF045F25),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your documents are used solely for identity verification and will never be shared publicly or used for login access.',
              style: robotoRegular.copyWith(
                fontSize: 12,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

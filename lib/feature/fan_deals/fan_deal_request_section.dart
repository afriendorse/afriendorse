// lib/feature/provider/widgets/fan_deal_request_section.dart

import 'dart:ui';
import 'package:afriendorse/athlete/common/widgets/custom_snackbar.dart';
import 'package:afriendorse/feature/fan_deals/fan_deal_request_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/auth/controller/auth_controller.dart';
import 'package:afriendorse/util/core_export.dart';

const Color _kGreen = Color(0xFF045F25);
const Color _kBlack = Color(0xFF000000);
const Color _kWhite = Color(0xFFFFFFFF);

class FanDealRequestSection extends StatefulWidget {
  final String providerId;
  final String providerName;

  const FanDealRequestSection({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<FanDealRequestSection> createState() => _FanDealRequestSectionState();
}

class _FanDealRequestSectionState extends State<FanDealRequestSection> {
  late final FanDealRequestController _ctrl;

  @override
  void initState() {
    super.initState();
    // Controller already registered + role already resolved
    // by ProviderDetailsScreen.initState()
    _ctrl = Get.find<FanDealRequestController>();

    // Only check existing request — role already known at this point
    final fanId = _ctrl.currentFanId;
    if (fanId.isNotEmpty) {
      _ctrl.checkExistingRequest(fanId: fanId, providerId: widget.providerId);
    }
  }

  String get _fanId =>
      Get.find<UserController>().userInfoModel?.id?.toString() ?? '';

  String get _fanName {
    final u = Get.find<UserController>().userInfoModel;
    final first = u?.fName ?? '';
    final last = u?.lName ?? '';
    return '$first $last'.trim();
  }

  String get _fanEmail => Get.find<UserController>().userInfoModel?.email ?? '';

  void _openSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FanDealRequestSheet(
        ctrl: _ctrl,
        fanId: _fanId,
        fanName: _fanName,
        fanEmail: _fanEmail,
        providerId: widget.providerId,
        providerName: widget.providerName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── while resolving role show nothing (seamless) ───────────────────────
      if (_ctrl.isRoleLoading.value) return const SizedBox.shrink();

      // ── only render for fans ───────────────────────────────────────────────
      if (!_ctrl.isFan) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // section label
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _kGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fan Deals',
                    style: robotoBold.copyWith(
                      fontSize: 15,
                      color: _kBlack,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            _FanDealCard(
              alreadyRequested: _ctrl.hasAlreadyRequested.value,
              providerName: widget.providerName,
              onTap: _ctrl.hasAlreadyRequested.value ? null : _openSheet,
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main deal card
// ─────────────────────────────────────────────────────────────────────────────
class _FanDealCard extends StatelessWidget {
  final bool alreadyRequested;
  final String providerName;
  final VoidCallback? onTap;

  const _FanDealCard({
    required this.alreadyRequested,
    required this.providerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGreen.withOpacity(0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: _kGreen.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── green header strip ─────────────────────────────────────���─
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.handshake_outlined,
                      color: _kWhite,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Interested in a Deal?',
                        style: robotoBold.copyWith(
                          color: _kWhite,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // AfriEndorse vetting badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.amber,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AfriEndorse Vetted',
                            style: robotoRegular.copyWith(
                              color: _kWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── body ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All fan deals with $providerName are managed through '
                      'AfriEndorse to ensure fair terms, quality assurance, '
                      'and secure transactions.',
                      style: robotoRegular.copyWith(
                        fontSize: 13,
                        color: _kBlack.withOpacity(0.65),
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── trust pills ──────────────────────────────────────
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: const [
                        _TrustPill(icon: Icons.security, label: 'Secure'),
                        _TrustPill(
                          icon: Icons.rate_review_outlined,
                          label: 'Vetted',
                        ),
                        _TrustPill(
                          icon: Icons.support_agent,
                          label: 'Supported',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── CTA button ───────────────────────────────────────
                    if (alreadyRequested)
                      _PendingBadge()
                    else
                      _RequestButton(onTap: onTap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust pill chip
// ─────────────────────────────────────────────────────────────────────────────
class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGreen.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _kGreen),
          const SizedBox(width: 5),
          Text(
            label,
            style: robotoMedium.copyWith(fontSize: 11, color: _kGreen),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA button
// ─────────────────────────────────────────────────────────────────────────────
class _RequestButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _RequestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.send_rounded, size: 17, color: _kWhite),
        label: Text(
          'Request a Deal via AfriEndorse',
          style: robotoBold.copyWith(color: _kWhite, fontSize: 13.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Already requested badge
// ─────────────────────────────────────────────────────────────────────────────
class _PendingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: 16,
            color: Colors.amber.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            'Request pending AfriEndorse review',
            style: robotoMedium.copyWith(
              fontSize: 13,
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deal Request Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _FanDealRequestSheet extends StatelessWidget {
  final FanDealRequestController ctrl;
  final String fanId;
  final String fanName;
  final String fanEmail;
  final String providerId;
  final String providerName;

  const _FanDealRequestSheet({
    required this.ctrl,
    required this.fanId,
    required this.fanName,
    required this.fanEmail,
    required this.providerId,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPad),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── drag handle ─────────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── header ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _kGreen.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    color: _kGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request a Deal',
                        style: robotoBold.copyWith(
                          fontSize: 16,
                          color: _kBlack,
                        ),
                      ),
                      Text(
                        'with $providerName · via AfriEndorse',
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: _kBlack.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── deal type ───────────────────────────────────────────────
            _SheetLabel(label: 'Deal Type'),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FanDealRequestController.dealTypes
                    .map(
                      (t) => _SelectableChip(
                        label: t,
                        selected: ctrl.selectedDealType.value == t,
                        onTap: () => ctrl.selectDealType(t),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ── budget ──────────────────────────────────────────────────
            _SheetLabel(label: 'Budget Range'),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FanDealRequestController.budgetRanges
                    .map(
                      (b) => _SelectableChip(
                        label: b,
                        selected: ctrl.selectedBudget.value == b,
                        onTap: () => ctrl.selectBudget(b),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ── message ─────────────────────────────────────────────────
            _SheetLabel(label: 'Brief Message (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl.messageController,
              maxLines: 3,
              maxLength: 280,
              decoration: InputDecoration(
                hintText:
                    'Tell ${providerName.split(' ').first} what you have in mind...',
                hintStyle: robotoRegular.copyWith(
                  color: _kBlack.withOpacity(0.35),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF7F9F7),
                counterStyle: robotoRegular.copyWith(
                  fontSize: 11,
                  color: _kBlack.withOpacity(0.35),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _kGreen.withOpacity(0.20)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _kGreen.withOpacity(0.20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kGreen, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── AfriEndorse note ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kGreen.withOpacity(0.12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 15, color: _kGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AfriEndorse will review your request and reach out '
                      'within 48 hours to facilitate the deal.',
                      style: robotoRegular.copyWith(
                        fontSize: 11.5,
                        color: _kGreen.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── submit ──────────────────────────────────────────────────
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.isSubmitting.value
                      ? null
                      : () => ctrl.submitRequest(
                          fanId: fanId,
                          fanName: fanName,
                          fanEmail: fanEmail,
                          providerId: providerId,
                          providerName: providerName,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    disabledBackgroundColor: _kGreen.withOpacity(0.55),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: ctrl.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _kWhite,
                          ),
                        )
                      : Text(
                          'Submit Request',
                          style: robotoBold.copyWith(
                            color: _kWhite,
                            fontSize: 14.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets for the sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String label;
  const _SheetLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: robotoMedium.copyWith(
        fontSize: 13,
        color: _kBlack.withOpacity(0.70),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kGreen : _kBlack.withOpacity(0.18),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: (selected ? robotoBold : robotoRegular).copyWith(
            fontSize: 13,
            color: selected ? _kWhite : _kBlack.withOpacity(0.65),
          ),
        ),
      ),
    );
  }
}

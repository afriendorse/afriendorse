import 'dart:ui';
import 'package:afriendorse/feature/auth/view/complete_brand_profile_screen.dart';
import 'package:afriendorse/feature/brand_verify/brand_verification_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

const Color _kGreen = Color(0xFF045F25);
const Color _kBlack = Color(0xFF000000);
const Color _kWhite = Color(0xFFFFFFFF);

class BrandVerificationStatusScreen extends StatefulWidget {
  final String email;
  final String? redirectUrl;

  const BrandVerificationStatusScreen({
    super.key,
    required this.email,
    this.redirectUrl,
  });

  @override
  State<BrandVerificationStatusScreen> createState() =>
      _BrandVerificationStatusScreenState();
}

class _BrandVerificationStatusScreenState
    extends State<BrandVerificationStatusScreen> {
  late final BrandVerificationController ctrl;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<BrandVerificationController>()) {
      Get.put(BrandVerificationController());
    }
    ctrl = Get.find<BrandVerificationController>();

    // IMPORTANT: call load after first frame to avoid "during build" updates.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.load(widget.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kWhite,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _kGreen),
          onPressed: () => Get.back(),
        ),
        title: const Text('KYC Verification', style: TextStyle(color: _kBlack)),
      ),
      body: GetBuilder<BrandVerificationController>(
        builder: (_) {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen),
            );
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: ctrl.stream(),
            builder: (context, snap) {
              final data = snap.data?.data();
              final status =
                  (data?['verificationStatus'] ?? ctrl.verificationStatus.value)
                      .toString()
                      .toLowerCase();

              final reason =
                  (data?['rejectionReason'] ?? ctrl.rejectionReason.value)
                      .toString();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatusCard(status: status, rejectionReason: reason),
                    const SizedBox(height: 14),
                    _NextStepsPanel(status: status),
                    const SizedBox(height: 18),

                    if (status == 'rejected') ...[
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Get.to(
                              () => CompleteBrandProfileScreen(
                                email: widget.email,
                                redirectUrl: widget.redirectUrl,
                              ),
                            );
                          },
                          child: const Text(
                            'Resubmit documents',
                            style: TextStyle(
                              color: _kWhite,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final String rejectionReason;

  const _StatusCard({required this.status, required this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    final ui = _StatusUi.from(status);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.86),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ui.border.withOpacity(0.30)),
            boxShadow: [
              BoxShadow(
                color: ui.shadow.withOpacity(0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ui.badgeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ui.border.withOpacity(0.25)),
                ),
                child: Icon(ui.icon, color: ui.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ui.title,
                      style: const TextStyle(
                        color: _kBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ui.subtitle,
                      style: TextStyle(
                        color: _kBlack.withOpacity(0.70),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (status == 'rejected' &&
                        rejectionReason.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Reason: $rejectionReason',
                        style: TextStyle(
                          color: _kBlack.withOpacity(0.80),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _NextStepsPanel extends StatelessWidget {
  final String status;
  const _NextStepsPanel({required this.status});

  @override
  Widget build(BuildContext context) {
    final tips = <String>[
      'We verify business information and documents to protect athletes, brands, and fans.',
      'Typical review time is 24–72 hours depending on volume.',
      if (status == 'pending')
        'You will be notified once verification is completed.',
      if (status == 'approved')
        'Your brand is verified. Deals and bookings are fully available.',
      if (status == 'rejected')
        'Update your details, ensure your documents are clear, and resubmit.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kGreen.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What happens next',
            style: TextStyle(color: _kBlack, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.90),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t,
                      style: TextStyle(
                        color: _kBlack.withOpacity(0.72),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusUi {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color border;
  final Color shadow;
  final Color badgeBg;

  _StatusUi({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.border,
    required this.shadow,
    required this.badgeBg,
  });

  static _StatusUi from(String status) {
    switch (status) {
      case 'approved':
        return _StatusUi(
          title: 'Verified',
          subtitle:
              'Your brand verification is complete. You now have full access to Deals and bookings.',
          icon: Icons.verified_rounded,
          iconColor: _kGreen,
          border: _kGreen,
          shadow: _kGreen,
          badgeBg: _kGreen.withOpacity(0.10),
        );
      case 'rejected':
        return _StatusUi(
          title: 'Action required',
          subtitle:
              'Your submission needs an update. Please review the reason and resubmit.',
          icon: Icons.error_outline_rounded,
          iconColor: const Color(0xFFB42318),
          border: const Color(0xFFB42318),
          shadow: const Color(0xFFB42318),
          badgeBg: const Color(0xFFB42318).withOpacity(0.08),
        );
      case 'pending':
      default:
        return _StatusUi(
          title: 'Under review',
          subtitle:
              'We’ve received your documents. Our compliance team is currently reviewing your submission.',
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFF7A5C00),
          border: const Color(0xFF7A5C00),
          shadow: const Color(0xFF7A5C00),
          badgeBg: const Color(0xFF7A5C00).withOpacity(0.10),
        );
    }
  }
}

import 'package:afriendorse/feature/auth/repository/deal_approval_firestore_service.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BookingApprovalWidget extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingApprovalWidget({super.key, required this.bookingDetails});

  // ── Inline fullscreen preview — no navigation, no re-fetch ──────────
  void _showPhotoPreview(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    final PageController pageController = PageController(
      initialPage: initialIndex,
    );
    int current = initialIndex;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          return GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  // ── Paged image viewer ───────────────────────────────
                  PageView.builder(
                    controller: pageController,
                    itemCount: photos.length,
                    onPageChanged: (i) => setState(() => current = i),
                    itemBuilder: (_, i) => Center(
                      child: Hero(
                        tag: 'evidence_${photos[i]}',
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: CustomImage(
                            image: photos[i],
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Close button ─────────────────────────────────────
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // ── Page indicator ───────────────────────────────────
                  if (photos.length > 1)
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: current == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: current == i
                                  ? Colors.white
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bookingId = bookingDetails.id ?? '';
    if (bookingId.isEmpty) return const SizedBox();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: DealApprovalFirestoreService.watch(bookingId),
      builder: (context, snap) {
        final data = snap.data?.data();
        final status = (data?['status'] ?? 'idle').toString();
        final reason = (data?['reason'] ?? '').toString();

        final Timestamp? expiresAtTs = data?['expiresAt'] as Timestamp?;
        final expiresAt = expiresAtTs?.toDate();

        String countdownText() {
          if (expiresAt == null) return '';
          final diff = expiresAt.difference(DateTime.now());
          if (diff.isNegative) return 'Auto-approving…';
          final h = diff.inHours;
          final m = diff.inMinutes.remainder(60);
          return 'Auto-approves in ${h}h ${m}m';
        }

        final otp = (bookingDetails.bookingOtp ?? '')
            .replaceAll('null', '')
            .trim();
        final bool canAct = status == 'requested';

        // ── Photo Evidence — filter out any non-http leftovers ───────────
        final photoEvidence =
            (data?['photoEvidence'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .where((url) => url.startsWith('http'))
                .toList() ??
            [];

        Color chipColor() {
          switch (status) {
            case 'requested':
              return Colors.orange;
            case 'approved':
            case 'auto_approved':
              return Colors.green;
            case 'declined':
              return Theme.of(context).colorScheme.error;
            case 'completed':
              return Colors.blue;
            default:
              return Theme.of(context).hintColor;
          }
        }

        String title() {
          switch (status) {
            case 'requested':
              return 'Approval requested';
            case 'approved':
              return 'Approved';
            case 'auto_approved':
              return 'Auto-approved';
            case 'declined':
              return 'Declined';
            case 'completed':
              return 'Completed';
            default:
              return 'Completion approval';
          }
        }

        String subtitle() {
          switch (status) {
            case 'requested':
              return countdownText().isNotEmpty
                  ? 'Review and decide. ${countdownText()}'
                  : 'Review and decide.';
            case 'approved':
              return 'Athlete can now receive payment.';
            case 'auto_approved':
              return 'System approved due to timeout.';
            case 'declined':
              return reason.isNotEmpty ? reason : 'You declined this request.';
            case 'completed':
              return 'Deal marked completed.';
            default:
              return 'Waiting for athlete to request approval.';
          }
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_user_rounded, color: primary),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title(), style: robotoBold),
                        const SizedBox(height: 4),
                        Text(
                          subtitle(),
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor().withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: chipColor().withOpacity(0.35)),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: robotoMedium.copyWith(
                        fontSize: 10,
                        color: chipColor(),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Photo Evidence Gallery ──────────────────────────────────
              if (photoEvidence.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text(
                  'service_proof'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photoEvidence.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: Dimensions.paddingSizeSmall,
                        ),
                        child: GestureDetector(
                          // ✅ Opens inline overlay — never navigates away
                          onTap: () =>
                              _showPhotoPreview(context, photoEvidence, index),
                          child: Hero(
                            // ✅ Unique tag avoids collisions with other heroes
                            tag: 'evidence_${photoEvidence[index]}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              child: CustomImage(
                                image: photoEvidence[index],
                                height: 100,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // ── Action Buttons ──────────────────────────────────────────
              if (canAct) ...[
                const SizedBox(height: Dimensions.paddingSizeDefault),

                if (otp.isEmpty) ...[
                  Text(
                    'Approval token not loaded yet. Pull-to-refresh booking details.',
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Decline',
                        color: Theme.of(context).colorScheme.error,
                        outline: true,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _DeclineReasonSheet(
                              onSubmit: (r) async {
                                await DealApprovalFirestoreService.decline(
                                  bookingId: bookingId,
                                  reason: r,
                                );
                                customSnackBar(
                                  'Declined. Athlete will see your note.',
                                  type: ToasterMessageType.info,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Approve',
                        color: Theme.of(context).primaryColor,
                        outline: false,
                        onTap: otp.isEmpty
                            ? () => customSnackBar(
                                'Please refresh to load approval token.',
                                type: ToasterMessageType.info,
                              )
                            : () async {
                                // Ensure WalletRepo is registered for commission processing
                                if (!Get.isRegistered<WalletRepo>()) {
                                  Get.lazyPut(
                                    () => WalletRepo(
                                      apiClient: Get.find(),
                                      sharedPreferences: Get.find(),
                                    ),
                                  );
                                }

                                // Extract brand email and deal amount from booking details
                                final brandEmail =
                                    bookingDetails.customer?.email;
                                final dealAmount =
                                    bookingDetails.totalBookingAmount ?? 0;

                                await DealApprovalFirestoreService.approve(
                                  bookingId: bookingId,
                                  otp: otp,
                                  brandEmail: brandEmail,
                                  dealAmount: dealAmount,
                                );

                                customSnackBar(
                                  'Approved. Athlete can now receive payment.',
                                  type: ToasterMessageType.success,
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Action Button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool outline;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.outline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: robotoMedium.copyWith(color: outline ? color : Colors.white),
          ),
        ),
      ),
    );
  }
}

// ── Decline Reason Sheet ─────────────────────────────────────────────────────

class _DeclineReasonSheet extends StatefulWidget {
  final void Function(String reason) onSubmit;
  const _DeclineReasonSheet({required this.onSubmit});

  @override
  State<_DeclineReasonSheet> createState() => _DeclineReasonSheetState();
}

class _DeclineReasonSheetState extends State<_DeclineReasonSheet> {
  final c = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Decline approval request', style: robotoBold),
          const SizedBox(height: 10),
          TextField(
            controller: c,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'What should the athlete fix?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            buttonText: 'Submit',
            onPressed: () {
              final reason = c.text.trim();
              if (reason.isEmpty) return;
              Get.back();
              widget.onSubmit(reason);
            },
          ),
        ],
      ),
    );
  }
}

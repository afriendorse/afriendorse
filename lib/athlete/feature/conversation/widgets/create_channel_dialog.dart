import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class CreateChannelDialog extends StatefulWidget {
  final bool isSubBooking;
  const CreateChannelDialog({super.key, required this.isSubBooking});
  @override
  State<CreateChannelDialog> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<CreateChannelDialog> {
  bool _disclaimerAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeDefault,
      ),
      child: GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          BookingDetailsContent? bookingDetails = widget.isSubBooking
              ? bookingDetailsController.subBookingDetails?.content
              : bookingDetailsController.bookingDetails?.content;

          BookingDetailsServiceman? serviceman =
              bookingDetails?.serviceman ??
              bookingDetails?.subBooking?.serviceman;
          Customer? customer =
              bookingDetails?.customer ?? bookingDetails?.subBooking?.customer;

          String titleText = "";

          if (serviceman != null && customer != null) {
            titleText = "make_conversation_with_customer_and_serviceman";
          } else if (serviceman != null) {
            titleText = "make_conversation_with_serviceman";
          } else if (customer != null) {
            titleText = "make_conversation_with_customer";
          }

          return GetBuilder<ConversationController>(
            builder: (conversationController) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: const Padding(
                        padding: EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault,
                        ),
                        child: Icon(Icons.close),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(titleText.tr, style: robotoMedium),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          // ── Chat Disclaimer Card ───────────────────────
                          _buildDisclaimerCard(context),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          // ── Action Buttons ─────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customer != null
                                  ? _buildChatButton(
                                      context: context,
                                      label: "chat_customer".tr,
                                      onPressed: _disclaimerAccepted
                                          ? () {
                                              Get.back();
                                              String? customerId = customer.id;
                                              String? refId =
                                                  bookingDetails?.id;
                                              String? name =
                                                  "${customer.firstName ?? ""}"
                                                  " ${customer.lastName ?? ""}";
                                              String? image =
                                                  customer
                                                      .profileImageFullPath ??
                                                  "";
                                              String? phone =
                                                  customer.phone ?? "";
                                              Get.find<ConversationController>()
                                                  .createChannel(
                                                    userID: customerId,
                                                    referenceID: refId,
                                                    name: name,
                                                    image: image,
                                                    phone: phone.tr,
                                                    userType: "customer",
                                                  );
                                            }
                                          : null,
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(
                                width: Dimensions.paddingSizeLarge,
                              ),
                              serviceman != null
                                  ? _buildChatButton(
                                      context: context,
                                      label: "provider-serviceman".tr,
                                      onPressed: _disclaimerAccepted
                                          ? () {
                                              Get.back();
                                              String? servicemanId =
                                                  serviceman.userId;
                                              String? refId =
                                                  bookingDetails?.id ?? "";
                                              String name =
                                                  "${serviceman.user?.firstName ?? ""}"
                                                  "${serviceman.user?.lastName ?? ""}";
                                              String image =
                                                  serviceman
                                                      .user
                                                      ?.profileImageFullPath ??
                                                  "";
                                              String phone =
                                                  serviceman.user?.phone ?? "";
                                              Get.find<ConversationController>()
                                                  .createChannel(
                                                    userID: servicemanId,
                                                    referenceID: refId,
                                                    name: name,
                                                    image: image,
                                                    phone: phone,
                                                    userType: "serviceman",
                                                  );
                                            }
                                          : null,
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Disclaimer Card ──────────────────────────────────────────────────────

  Widget _buildDisclaimerCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.error;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: primary.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 20, color: primary),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                "stay_safe".tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Body text
          Text(
            "chat_disclaimer_body".tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodySmall?.color,
              height: 1.6,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Bullet points
          _buildBulletPoint(context, "chat_disclaimer_point_1".tr),
          _buildBulletPoint(context, "chat_disclaimer_point_2".tr),
          _buildBulletPoint(context, "chat_disclaimer_point_3".tr),
          _buildBulletPoint(context, "chat_disclaimer_point_4".tr),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Checkbox
          InkWell(
            onTap: () {
              setState(() {
                _disclaimerAccepted = !_disclaimerAccepted;
              });
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _disclaimerAccepted,
                      onChanged: (value) {
                        setState(() {
                          _disclaimerAccepted = value ?? false;
                        });
                      },
                      activeColor: primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      "chat_disclaimer_accept".tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.5,
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

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeExtraSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Text(
              text,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat Button (with disabled state) ──────────────────────────────────

  Widget _buildChatButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final isEnabled = onPressed != null;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isEnabled
            ? primary
            : Theme.of(context).disabledColor.withValues(alpha: 0.2),
        foregroundColor: isEnabled ? Colors.white : Theme.of(context).hintColor,
        minimumSize: const Size(Dimensions.paddingSizeLarge, 44),
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
          horizontal: Dimensions.paddingSizeLarge,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: robotoBold.copyWith(
          color: isEnabled ? Colors.white : Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

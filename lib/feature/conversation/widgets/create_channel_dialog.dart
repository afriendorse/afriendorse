import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class CreateChannelDialog extends StatefulWidget {
  final bool isSubBooking;
  const CreateChannelDialog({super.key, required this.isSubBooking});

  @override
  State<CreateChannelDialog> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<CreateChannelDialog> {
  bool _disclaimerAccepted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: pointerInterceptor(),
      );
    }
    return pointerInterceptor();
  }

  Widget pointerInterceptor() {
    return PointerInterceptor(
      child: GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          BookingDetailsContent? bookingDetails = widget.isSubBooking
              ? bookingDetailsController.subBookingDetailsContent
              : bookingDetailsController.bookingDetailsContent;

          ProviderData? provider = bookingDetails?.provider;
          Serviceman? serviceman = bookingDetails?.serviceman;
          Customer? customer = bookingDetails?.customer;

          return Container(
            width: Dimensions.webMaxWidth,
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isDesktop(context)
                  ? (Dimensions.webMaxWidth) / 3
                  : 0,
            ),
            padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              bottom: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(20),
                topLeft: const Radius.circular(20),
                bottomLeft: ResponsiveHelper.isDesktop(context)
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                bottomRight: ResponsiveHelper.isDesktop(context)
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
              ),
            ),
            child: GetBuilder<ConversationController>(
              builder: (conversationController) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeSmall,
                        ),
                        child: Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white70.withValues(alpha: 0.6),
                            boxShadow: Get.isDarkMode
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.grey[300]!,
                                      blurRadius: 2,
                                      spreadRadius: 1,
                                    ),
                                  ],
                          ),
                          child: InkWell(
                            onTap: () => Get.back(),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: Dimensions.paddingSizeDefault,
                          top: ResponsiveHelper.isDesktop(context)
                              ? 0
                              : Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              provider != null && serviceman != null
                                  ? 'create_channel_with_provider'.tr
                                  : provider != null
                                  ? 'conversation_with_provider'.tr
                                  : serviceman != null
                                  ? 'conversation_with_serviceman'.tr
                                  : "",
                              style: robotoMedium,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            // ── Chat Disclaimer Card ───────────────────
                            _buildDisclaimerCard(context),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (provider != null)
                                  _buildChatButton(
                                    context: context,
                                    label: 'chat_athlete'.tr,
                                    onPressed: _disclaimerAccepted
                                        ? () {
                                            if (provider.chatEligibility ==
                                                true) {
                                              String name =
                                                  provider.companyName!;
                                              String image =
                                                  provider.logoFullPath ?? "";
                                              String phone =
                                                  provider.companyPhone ?? "";
                                              Get.find<ConversationController>()
                                                  .createChannel(
                                                    provider.userId!,
                                                    bookingDetails?.id ?? "",
                                                    name: name,
                                                    image: image,
                                                    fromBookingDetailsPage:
                                                        true,
                                                    phone: phone,
                                                    userType: "provider",
                                                  );
                                            } else {
                                              customSnackBar(
                                                "this_provider_have_not_permission_to_chat"
                                                    .tr,
                                                showDefaultSnackBar: false,
                                              );
                                            }
                                          }
                                        : null,
                                  ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeLarge,
                                ),
                                if (serviceman != null)
                                  _buildChatButton(
                                    context: context,
                                    label: 'service_man'.tr,
                                    onPressed: _disclaimerAccepted
                                        ? () {
                                            String name =
                                                "${serviceman.user?.firstName ?? ""}"
                                                " ${serviceman.user?.lastName ?? ""}";
                                            String phone =
                                                serviceman.user?.phone ?? "";
                                            String image =
                                                serviceman
                                                    .user
                                                    ?.profileImageFullPath ??
                                                "";
                                            Get.find<ConversationController>()
                                                .createChannel(
                                                  serviceman.userId!,
                                                  bookingDetails?.id ?? "",
                                                  name: name,
                                                  image: image,
                                                  fromBookingDetailsPage: true,
                                                  phone: phone,
                                                );
                                          }
                                        : null,
                                  ),
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
            ),
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
        horizontal: Dimensions.paddingSizeDefault,
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
            "brand_chat_disclaimer_body".tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.black,
              height: 1.6,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Bullet points
          _buildBulletPoint(context, "brand_chat_disclaimer_point_1".tr),
          _buildBulletPoint(context, "brand_chat_disclaimer_point_2".tr),
          _buildBulletPoint(context, "brand_chat_disclaimer_point_3".tr),
          _buildBulletPoint(context, "brand_chat_disclaimer_point_4".tr),
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
                color: Colors.black,
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

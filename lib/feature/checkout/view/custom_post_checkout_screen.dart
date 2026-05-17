import 'dart:convert';
import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:afriendorse/feature/checkout/view/custom_booking_payment_method_sheet.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';
import 'package:universal_html/html.dart' as html;

class CustomPostCheckoutScreen extends StatefulWidget {
  final String postId;
  final String providerId;
  final String bidId;
  final String amount;

  const CustomPostCheckoutScreen({
    super.key,
    required this.postId,
    required this.providerId,
    required this.amount,
    required this.bidId,
  });

  @override
  State<CustomPostCheckoutScreen> createState() =>
      _CustomPostCheckoutScreenState();
}

class _CustomPostCheckoutScreenState extends State<CustomPostCheckoutScreen>
    with SingleTickerProviderStateMixin {
  ConfigModel configModel = Get.find<SplashController>().configModel;
  final tooltipController = JustTheController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    Get.find<CheckOutController>().getPostDetails(widget.postId, widget.bidId);
    Get.find<CheckOutController>().changePaymentMethod(shouldUpdate: false);
    Get.find<AuthController>().cancelTermsAndCondition();
    Get.find<CartController>().updateWalletPaymentStatus(
      false,
      shouldUpdate: false,
    );
    Get.find<CheckOutController>().getOfflinePaymentMethod(true);
    Get.find<CheckOutController>().toggleTerms(
      value: false,
      shouldUpdate: false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: _buildAppBar(context),
        body: GetBuilder<CartController>(
          builder: (cartController) {
            return GetBuilder<CheckOutController>(
              builder: (checkoutController) {
                if (checkoutController.postDetails != null) {
                  Get.find<ScheduleController>().updateSelectedDate(
                    checkoutController.postDetails?.bookingSchedule,
                  );
                  Get.find<CheckOutController>().calculateTotalAmount(
                    double.tryParse(widget.amount.toString()) ?? 0,
                  );
                  return _buildContent(checkoutController, cartController);
                } else {
                  return _buildLoadingState();
                }
              },
            );
          },
        ),
        bottomSheet: _buildBottomSheet(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).textTheme.bodyLarge!.color,
            size: 18,
          ),
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.toNamed(RouteHelper.getMainRoute("home"));
          }
        },
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'checkout'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'review_and_confirm'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    CheckOutController checkoutController,
    CartController cartController,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: FooterBaseView(
        isCenter: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              _buildProgressIndicator(),

              const SizedBox(height: 24),

              _buildAnimatedCard(
                child: CustomPostServiceInfo(
                  postDetails: checkoutController.postDetails,
                ),
                delay: 100,
              ),

              _buildAnimatedCard(
                child: DescriptionExpansionTile(
                  title: "descriptionn",
                  subTitle:
                      checkoutController.postDetails?.serviceDescription ?? "",
                ),
                delay: 200,
              ),

              if (checkoutController.postDetails != null &&
                  checkoutController
                      .postDetails!
                      .additionInstructions!
                      .isNotEmpty)
                _buildAnimatedCard(
                  child: DescriptionExpansionTile(
                    title: "additional_instruction",
                    additionalInstruction:
                        checkoutController.postDetails!.additionInstructions,
                  ),
                  delay: 300,
                ),

              const SizedBox(height: 14),

              _buildSectionHeader(
                'booking_schedule'.tr,
                Icons.calendar_today_rounded,
              ),
              _buildAnimatedCard(
                child: const Padding(
                  padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: ServiceSchedule(),
                ),
                delay: 400,
              ),

              const SizedBox(height: 14),

              _buildAnimatedCard(
                child: CustomPostCartSummary(
                  postDetails: checkoutController.postDetails,
                  amount: widget.amount,
                ),
                delay: 600,
              ),

              const SizedBox(height: 14),

              _buildSectionHeader('payment_method'.tr, Icons.payment_rounded),
              _buildAnimatedCard(
                child: PaymentPage(
                  addressId: '',
                  tooltipController: JustTheController(),
                  fromPage: "custom-checkout",
                ),
                delay: 700,
              ),

              _buildAnimatedCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: ConditionCheckBox(
                    checkBoxValue: checkoutController.acceptTerms,
                    onTap: (bool? value) {
                      checkoutController.toggleTerms();
                    },
                  ),
                ),
                delay: 800,
              ),

              if (ResponsiveHelper.isDesktop(context))
                _buildDesktopCheckoutButton(checkoutController, cartController),

              SizedBox(height: ResponsiveHelper.isDesktop(context) ? 70 : 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProgressStep(1, 'details'.tr, true, true),
          _buildProgressLine(true),
          _buildProgressStep(2, 'payment'.tr, true, false),
          _buildProgressLine(false),
          _buildProgressStep(3, 'confirm'.tr, false, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(
    int step,
    String label,
    bool isActive,
    bool isCompleted,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).hintColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).hintColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      '$step',
                      style: robotoBold.copyWith(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).hintColor,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: isActive
                  ? Theme.of(context).textTheme.bodyLarge!.color
                  : Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).hintColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildLoadingState() {
    return FooterBaseView(
      isCenter: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'loading_checkout_details'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'please_wait'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCheckoutButton(
    CheckOutController checkoutController,
    CartController cartController,
  ) {
    double totalAmount = checkoutController.totalAmount;
    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_amount'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  PriceConverter.convertPrice(
                    totalAmount,
                    isShowLongPrice: true,
                  ),
                  style: robotoBold.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: Dimensions.fontSizeExtraLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _makePayment(checkoutController, cartController),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'proceed_to_checkout'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return SafeArea(
      child: GetBuilder<CheckOutController>(
        builder: (checkoutController) {
          double padding = MediaQuery.of(context).padding.bottom;
          return !ResponsiveHelper.isDesktop(context) &&
                  checkoutController.postDetails != null
              ? GetBuilder<CartController>(
                  builder: (cartController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, -5),
                          ),
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: padding + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).hintColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _makePayment(
                                checkoutController,
                                cartController,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'proceed_to_checkout'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const SizedBox();
        },
      ),
    );
  }

  // ── NEW: Shows the wallet-or-online bottom sheet ────────────────────────────

  void _showPaymentMethodSheet({
    required CheckOutController checkoutController,
    required CartController cartController,
    required String digitalUrl,
    required AddressModel addressModel,
    required bool isPartialPayment,
    required double bookingAmount,
    int? selectedOfflinePaymentIndex,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingPaymentMethodSheet(
        amount: checkoutController.totalAmount,

        // ── Wallet path ─────────────────────────────────────────────
        onWalletPayment: () async {
          // Switch the selected method to wallet then re-run _makePayment
          // so it flows through the existing walletMoney branch.
          checkoutController.changePaymentMethod(walletPayment: true);
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) {
            _makePayment(
              checkoutController,
              cartController,
              selectedOfflinePaymentIndex: selectedOfflinePaymentIndex,
            );
          }
        },

        // ── Online payment path ──────────────────────────────────────
        onOnlinePayment: () {
          if (GetPlatform.isWeb) {
            printLog("url_with_digital_payment:$digitalUrl");
            html.window.open(digitalUrl, "_self");
          } else {
            printLog("url_with_digital_payment_mobile:$digitalUrl");
            Get.to(
              () => PaymentScreen(url: digitalUrl, fromPage: "custom-checkout"),
            );
          }
        },
      ),
    );
  }

  // ── Payment handler ─────────────────────────────────────────────────────────

  void _makePayment(
    CheckOutController checkoutController,
    CartController cartController, {
    int? selectedOfflinePaymentIndex,
  }) async {
    AddressModel? addressModel =
        Get.find<LocationController>().selectedAddress ??
        Get.find<LocationController>().getUserAddress();

    bool isPartialPayment =
        Get.find<CheckOutController>().totalAmount >
        Get.find<CartController>().walletBalance;

    double bookingAmount = isPartialPayment
        ? (checkoutController.totalAmount - cartController.walletBalance)
        : checkoutController.totalAmount;

    if (!Get.find<CheckOutController>().acceptTerms) {
      customSnackBar(
        'please_agree_with_terms_conditions'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if ((addressModel?.contactPersonName == "null" ||
            addressModel?.contactPersonName == null ||
            addressModel!.contactPersonName!.isEmpty) ||
        (addressModel.contactPersonNumber == "null" ||
            addressModel.contactPersonNumber == null ||
            addressModel.contactPersonNumber!.isEmpty)) {
      customSnackBar(
        "please_input_contact_person_name_and_phone_number".tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (cartController.walletPaymentStatus &&
        isPartialPayment &&
        checkoutController.selectedPaymentMethod ==
            PaymentMethodName.walletMoney) {
      customSnackBar(
        "select_another_payment_method_to_pay_remaining_bill".tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (checkoutController.selectedPaymentMethod == PaymentMethodName.none) {
      customSnackBar("select_payment_method".tr, type: ToasterMessageType.info);
      return;
    }

    // ── Cash after service ────────────────────────────────────────────────────
    if (checkoutController.selectedPaymentMethod == PaymentMethodName.cos) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      Response response = await Get.find<CreatePostController>()
          .updatePostStatus(
            widget.postId,
            widget.providerId,
            'accept',
            isPartial: isPartialPayment && cartController.walletPaymentStatus
                ? 1
                : 0,
            serviceAddressId:
                (addressModel.id == "null") || (addressModel.id == null)
                ? ""
                : addressModel.id,
            serviceAddress: jsonEncode(addressModel),
          );
      Get.back();
      if (response.statusCode == 200 &&
          response.body['response_code'] == "default_update_200") {
        Get.offNamed(RouteHelper.getOrderSuccessRoute('success'));
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute('failed'));
      }
      return;
    }

    // ── Wallet payment ────────────────────────────────────────────────────────
    if (checkoutController.selectedPaymentMethod ==
        PaymentMethodName.walletMoney) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      Response response = await Get.find<CreatePostController>().makePayment(
        postId: widget.postId,
        providerId: widget.providerId,
        paymentMethod: "wallet_payment",
        isPartial: isPartialPayment && cartController.walletPaymentStatus
            ? 1
            : 0,
      );
      Get.back();

      if (response.statusCode == 200 &&
          response.body['response_code'] == "booking_place_success_200") {
        Get.offNamed(RouteHelper.getOrderSuccessRoute('success'));
      } else {
        customSnackBar(
          response.body['message'].toString().capitalizeFirst ??
              response.statusText,
        );
      }
      return;
    }

    // ── Offline payment ───────────────────────────────────────────────────────
    if (checkoutController.selectedPaymentMethod == PaymentMethodName.offline) {
      if (checkoutController.selectedOfflineMethod == null) {
        customSnackBar(
          "provide_offline_payment_info".tr,
          type: ToasterMessageType.info,
        );
        return;
      }

      Get.dialog(const CustomLoader(), barrierDismissible: false);
      Response response = await Get.find<CreatePostController>().makePayment(
        postId: widget.postId,
        providerId: widget.providerId,
        paymentMethod: "offline_payment",
        offlinePaymentId: checkoutController.selectedOfflineMethod?.id,
        isPartial: isPartialPayment && cartController.walletPaymentStatus
            ? 1
            : 0,
      );
      Get.back();

      if (response.statusCode == 200 &&
          response.body['response_code'] == "booking_place_success_200") {
        String? bookingId = response.body['content']['booking_id'];
        customSnackBar(
          'now_pay_you_bill_using_the_payment_method'.tr,
          toasterTitle: 'your_booking_has_been_placed_successfully'.tr,
          type: ToasterMessageType.success,
          duration: 4,
        );
        Get.offAllNamed(
          RouteHelper.getOfflinePaymentRoute(
            totalAmount: bookingAmount,
            index: selectedOfflinePaymentIndex ?? 0,
            bookingId: bookingId,
            fromPage: "custom-post",
          ),
        );
      } else {
        customSnackBar(
          response.body['message'].toString().capitalizeFirst ??
              response.statusText,
        );
      }
      return;
    }

    // ── Digital / online payment — show wallet-or-online sheet ────────────────
    if (checkoutController.selectedPaymentMethod ==
        PaymentMethodName.digitalPayment) {
      if (checkoutController.selectedDigitalPaymentMethod != null &&
          checkoutController.selectedDigitalPaymentMethod?.gateway ==
              "offline") {
        customSnackBar(
          'select_any_payment_method'.tr,
          type: ToasterMessageType.info,
        );
        return;
      }

      // Build the digital payment URL
      String hostname = html.window.location.hostname!;
      String protocol = html.window.location.protocol;
      String port = html.window.location.port;
      String? path = html.window.location.pathname?.replaceAll(
        RouteHelper.customPostCheckout,
        "",
      );
      String? schedule = Get.find<ScheduleController>().scheduleTime;
      String userId =
          Get.find<UserController>().userInfoModel?.id ??
          Get.find<SplashController>().getGuestId();
      String encodedAddress = base64Encode(
        utf8.encode(jsonEncode(addressModel.toJson())),
      );
      String addressId = (addressModel.id == "null" || addressModel.id == null)
          ? ""
          : addressModel.id ?? "";
      String zoneId =
          Get.find<LocationController>().getUserAddress()?.zoneId ?? "";
      String callbackUrl = GetPlatform.isWeb
          ? "$protocol//$hostname:$port$path${RouteHelper.orderSuccess}"
          : AppConstants.baseUrl;
      int isPartial = cartController.walletPaymentStatus && isPartialPayment
          ? 1
          : 0;
      String platform = ResponsiveHelper.isWeb() ? "web" : "app";

      final digitalUrl =
          '${AppConstants.baseUrl}/payment'
          '?payment_method=${checkoutController.selectedDigitalPaymentMethod?.gateway}'
          '&access_token=${base64Url.encode(utf8.encode(userId))}'
          '&zone_id=$zoneId'
          '&callback=$callbackUrl'
          '&payment_platform=$platform'
          '&service_address=$encodedAddress'
          '&service_address_id=$addressId'
          '&is_partial=$isPartial'
          '&service_schedule=$schedule'
          '&post_id=${widget.postId}'
          '&provider_id=${widget.providerId}'
          '&service_location=customer';

      // ✅ Show wallet-or-online bottom sheet
      _showPaymentMethodSheet(
        checkoutController: checkoutController,
        cartController: cartController,
        digitalUrl: digitalUrl,
        addressModel: addressModel,
        isPartialPayment: isPartialPayment,
        bookingAmount: bookingAmount,
        selectedOfflinePaymentIndex: selectedOfflinePaymentIndex,
      );
    }
  }
}

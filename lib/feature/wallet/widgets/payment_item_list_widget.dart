/*
import 'dart:convert';
import 'package:afriendorse/util/core_export.dart';
import 'package:universal_html/html.dart' as html;
import 'package:get/get.dart';

class PaymentMethodListWidget extends StatefulWidget {
  const PaymentMethodListWidget({super.key});

  @override
  State<PaymentMethodListWidget> createState() =>
      _PaymentMethodListWidgetState();
}

class _PaymentMethodListWidgetState extends State<PaymentMethodListWidget> {
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().isTextFieldEmpty('', isUpdate: false);
    Get.find<WalletController>().changeDigitalPaymentName('', isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    bool isRightSide =
        Get.find<SplashController>()
            .configModel
            .content
            ?.currencySymbolPosition ==
        'right';

    List<DigitalPaymentMethod> paymentMethodList =
        Get.find<SplashController>().configModel.content?.paymentMethodList ??
        [];

    if (paymentMethodList.isNotEmpty && paymentMethodList.length == 1) {
      Get.find<WalletController>().changeDigitalPaymentName(
        paymentMethodList[0].gateway ?? "",
        isUpdate: false,
      );
    }

    return GetBuilder<WalletController>(
      builder: (walletController) {
        return SizedBox(
          width: Dimensions.webMaxWidth / 2,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: ResponsiveHelper.isMobile(context)
                  ? Dimensions.paddingSizeSmall
                  : Dimensions.paddingSizeLarge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  'add_fund_to_wallet'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  'add_fund_form_secured_digital_payment_gateways'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        if (!isRightSide)
                          Text(
                            PriceConverter.getCurrency(),
                            style: robotoBold.copyWith(
                              fontSize: 20,
                              color: isTextFieldEmpty
                                  ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.5)
                                  : Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.8),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: IntrinsicWidth(
                            child: TextField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
                              keyboardType: TextInputType.number,
                              controller: inputAmountController,
                              focusNode: focusNode,
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: "0.0",
                                hintStyle: robotoBold.copyWith(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color!
                                      .withValues(alpha: 0.5),
                                ),
                                contentPadding: const EdgeInsets.only(
                                  bottom: kIsWeb ? 3 : 0,
                                ),
                              ),
                              style: robotoBold.copyWith(
                                fontSize: 20,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.8),
                              ),
                              onChanged: (String value) {
                                walletController.isTextFieldEmpty(value);
                                setState(() {
                                  if (value.isNotEmpty) {
                                    isTextFieldEmpty = false;
                                  } else {
                                    isTextFieldEmpty = true;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        if (isRightSide)
                          Text(
                            PriceConverter.getCurrency(),
                            style: robotoBold.copyWith(
                              fontSize: 20,
                              color: isTextFieldEmpty
                                  ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.5)
                                  : Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withValues(alpha: 0.8),
                            ),
                          ),

                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                walletController.amountEmpty
                    ? Row(
                        children: [
                          Text(
                            'payment_method'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall,
                          ),

                          Expanded(
                            child: Text(
                              'faster_and_secure_way_to_pay_bill'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                walletController.amountEmpty
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: Get.height * 0.4,
                          minHeight: 100,
                        ),
                        child: paymentMethodList.isNotEmpty
                            ? ListView.builder(
                                itemCount: paymentMethodList.length,
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault,
                                ),
                                itemBuilder: (context, index) {
                                  bool isSelected =
                                      paymentMethodList.length == 1 ||
                                      (paymentMethodList[index].gateway ==
                                          walletController.digitalPaymentName);
                                  return InkWell(
                                    onTap: () {
                                      walletController.changeDigitalPaymentName(
                                        paymentMethodList[index].gateway ?? "",
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue.withValues(
                                                alpha: 0.05,
                                              )
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeLarge,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : Theme.of(context).cardColor,
                                              border: Border.all(
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : Colors.transparent,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            width:
                                                Dimensions.paddingSizeDefault,
                                          ),

                                          CustomImage(
                                            height: Dimensions.paddingSizeLarge,
                                            fit: BoxFit.contain,
                                            image:
                                                paymentMethodList[index]
                                                    .gatewayImageFullPath ??
                                                "",
                                          ),

                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),

                                          Text(
                                            paymentMethodList[index].label ??
                                                "",
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeLarge * 2,
                                ),
                                child: Text(
                                  "no_payment_method_available".tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                      )
                    : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                !walletController.isLoading
                    ? CustomButton(
                        buttonText: 'add_fund'.tr,
                        onPressed: () {
                          if (inputAmountController.text.isEmpty) {
                            customSnackBar(
                              'please_provide_transfer_amount'.tr,
                              showDefaultSnackBar: false,
                              type: ToasterMessageType.info,
                            );
                          } else if (walletController.digitalPaymentName ==
                              '') {
                            customSnackBar(
                              'please_select_payment_method'.tr,
                              showDefaultSnackBar: false,
                              type: ToasterMessageType.info,
                            );
                          } else {
                            double? amount = double.tryParse(
                              inputAmountController.text.replaceAll(
                                PriceConverter.getCurrency(),
                                '',
                              ),
                            );

                            if (amount != null && amount > 0) {
                              Get.back();
                              _addFundToWallet(
                                walletController.digitalPaymentName ?? "",
                                amount,
                              );
                            } else if (amount != null && amount <= 0) {
                              customSnackBar(
                                'amount_must_be_greater_than_zero'.tr,
                                showDefaultSnackBar: false,
                                type: ToasterMessageType.info,
                              );
                            } else {
                              customSnackBar(
                                'please_enter_valid_amount'.tr,
                                showDefaultSnackBar: false,
                                type: ToasterMessageType.info,
                              );
                            }
                          }
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addFundToWallet(String paymentGateway, double amount) {
    String url = '';
    String hostname = html.window.location.hostname!;
    String protocol = html.window.location.protocol;
    String port = html.window.location.port;
    String? path = html.window.location.pathname;

    String userId = Get.find<UserController>().userInfoModel?.id ?? "";

    String callbackUrl = GetPlatform.isWeb
        ? "$protocol//$hostname:$port$path"
        : AppConstants.baseUrl;

    String platform = GetPlatform.isWeb ? "web" : "app";

    url =
        '${AppConstants.baseUrl}/payment?payment_method=$paymentGateway&access_token=${base64Url.encode(utf8.encode(userId))}'
        '&callback=$callbackUrl&amount=$amount&payment_platform=$platform&is_add_fund=1';

    if (GetPlatform.isWeb) {
      printLog("url_with_digital_payment:$url");
      html.window.open(url, "_self");
    } else {
      printLog("url_with_digital_payment_mobile:$url");
      Get.to(() => PaymentScreen(url: url, fromPage: "add-fund"));
    }
  }
}

*/

import 'dart:convert';
import 'package:afriendorse/util/core_export.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentMethodListWidget extends StatefulWidget {
  const PaymentMethodListWidget({super.key});

  @override
  State<PaymentMethodListWidget> createState() =>
      _PaymentMethodListWidgetState();
}

class _PaymentMethodListWidgetState extends State<PaymentMethodListWidget> {
  final TextEditingController _displayController = TextEditingController();
  final TextEditingController _rawAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  bool isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().isTextFieldEmpty('', isUpdate: false);
    Get.find<WalletController>().changeDigitalPaymentName('', isUpdate: false);
  }

  @override
  void dispose() {
    _displayController.dispose();
    _rawAmountController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value, WalletController walletController) {
    // Remove all non-numeric characters except decimal point
    String rawValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points
    final parts = rawValue.split('.');
    if (parts.length > 2) {
      rawValue = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Update raw controller (for payment gateway)
    _rawAmountController.text = rawValue;

    // Format for display
    if (rawValue.isEmpty) {
      _displayController.text = '';
      setState(() => isTextFieldEmpty = true);
    } else {
      final number = double.tryParse(rawValue) ?? 0;
      final formatted = _numberFormat.format(number);

      // Preserve cursor position logic
      _displayController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      setState(() => isTextFieldEmpty = false);
    }

    walletController.isTextFieldEmpty(rawValue);
  }

  double? _getRawAmount() {
    final raw = _rawAmountController.text;
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  @override
  Widget build(BuildContext context) {
    bool isRightSide =
        Get.find<SplashController>()
            .configModel
            .content
            ?.currencySymbolPosition ==
        'right';

    List<DigitalPaymentMethod> paymentMethodList =
        Get.find<SplashController>().configModel.content?.paymentMethodList ??
        [];

    if (paymentMethodList.isNotEmpty && paymentMethodList.length == 1) {
      Get.find<WalletController>().changeDigitalPaymentName(
        paymentMethodList[0].gateway ?? "",
        isUpdate: false,
      );
    }

    return GetBuilder<WalletController>(
      builder: (walletController) {
        return SizedBox(
          width: Dimensions.webMaxWidth / 2,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: ResponsiveHelper.isMobile(context)
                  ? Dimensions.paddingSizeSmall
                  : Dimensions.paddingSizeLarge,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                // Header with icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.wallet,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(
                  'add_fund_to_wallet'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  'add_fund_form_secured_digital_payment_gateways'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Amount Input Card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: focusNode.hasFocus
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: focusNode.hasFocus ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusExtraLarge,
                    ),
                    boxShadow: focusNode.hasFocus
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraLarge,
                    vertical: Dimensions.paddingSizeLarge,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'enter_amount'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isRightSide) _buildCurrencySymbol(context),
                          Expanded(
                            child: TextField(
                              controller: _displayController,
                              focusNode: focusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              style: robotoBold.copyWith(
                                fontSize: 36,
                                color: isTextFieldEmpty
                                    ? Theme.of(context).hintColor
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "0.00",
                                hintStyle: robotoBold.copyWith(
                                  fontSize: 36,
                                  color: Theme.of(context).hintColor,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) =>
                                  _onAmountChanged(value, walletController),
                            ),
                          ),
                          if (isRightSide) _buildCurrencySymbol(context),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Quick Amount Chips
                if (walletController.amountEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [500, 1000, 2000, 5000, 10000].map((amount) {
                      return ActionChip(
                        avatar: FaIcon(
                          FontAwesomeIcons.bolt,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          '${isRightSide ? '' : PriceConverter.getCurrency()}'
                          '${_numberFormat.format(amount)}'
                          '${isRightSide ? PriceConverter.getCurrency() : ''}',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        backgroundColor: Theme.of(context).cardColor,
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        onPressed: () {
                          _onAmountChanged(amount.toString(), walletController);
                          _displayController.text = _numberFormat.format(
                            amount,
                          );
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Payment Methods Section
                if (walletController.amountEmpty) ...[
                  /*   Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.shieldHalved,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            'faster_and_secure_way_to_pay_bill'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ), */
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: Get.height * 0.35,
                      minHeight: 100,
                    ),
                    child: paymentMethodList.isNotEmpty
                        ? ListView.separated(
                            itemCount: paymentMethodList.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              bool isSelected =
                                  paymentMethodList.length == 1 ||
                                  (paymentMethodList[index].gateway ==
                                      walletController.digitalPaymentName);
                              return InkWell(
                                onTap: () {
                                  walletController.changeDigitalPaymentName(
                                    paymentMethodList[index].gateway ?? "",
                                  );
                                },
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                              .withOpacity(0.08)
                                        : null,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeDefault,
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: 24,
                                        width: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Theme.of(
                                                    context,
                                                  ).disabledColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeDefault,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CustomImage(
                                          height: 32,
                                          width: 48,
                                          fit: BoxFit.cover,
                                          image:
                                              paymentMethodList[index]
                                                  .gatewayImageFullPath ??
                                              "",
                                        ),
                                      ),
                                      const SizedBox(
                                        width: Dimensions.paddingSizeDefault,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              paymentMethodList[index].label ??
                                                  "",
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                              ),
                                            ),
                                            if (isSelected)
                                              Text(
                                                'selected'.tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        FaIcon(
                                          FontAwesomeIcons.circleCheck,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildEmptyState(context),
                  ),
                ],

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Submit Button
                !walletController.isLoading
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleAddFund(walletController),
                          icon: FaIcon(
                            FontAwesomeIcons.wallet,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            'add_fund'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeDefault,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusExtraLarge,
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySymbol(BuildContext context) {
    return Text(
      PriceConverter.getCurrency(),
      style: robotoBold.copyWith(
        fontSize: 24,
        color: isTextFieldEmpty
            ? Theme.of(context).hintColor
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 48,
            color: Theme.of(context).colorScheme.error.withOpacity(0.5),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            "no_payment_method_available".tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleAddFund(WalletController walletController) {
    final amount = _getRawAmount();

    if (_rawAmountController.text.isEmpty) {
      customSnackBar(
        'please_provide_transfer_amount'.tr,
        showDefaultSnackBar: false,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (walletController.digitalPaymentName == '') {
      customSnackBar(
        'please_select_payment_method'.tr,
        showDefaultSnackBar: false,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (amount == null || amount <= 0) {
      customSnackBar(
        amount == null
            ? 'please_enter_valid_amount'.tr
            : 'amount_must_be_greater_than_zero'.tr,
        showDefaultSnackBar: false,
        type: ToasterMessageType.info,
      );
      return;
    }

    Get.back();
    _addFundToWallet(walletController.digitalPaymentName ?? "", amount);
  }

  void _addFundToWallet(String paymentGateway, double amount) {
    String url = '';
    String hostname = html.window.location.hostname!;
    String protocol = html.window.location.protocol;
    String port = html.window.location.port;
    String? path = html.window.location.pathname;

    String userId = Get.find<UserController>().userInfoModel?.id ?? "";

    String callbackUrl = GetPlatform.isWeb
        ? "$protocol//$hostname:$port$path"
        : AppConstants.baseUrl;

    String platform = GetPlatform.isWeb ? "web" : "app";

    url =
        '${AppConstants.baseUrl}/payment?payment_method=$paymentGateway&access_token=${base64Url.encode(utf8.encode(userId))}'
        '&callback=$callbackUrl&amount=$amount&payment_platform=$platform&is_add_fund=1';

    if (GetPlatform.isWeb) {
      printLog("url_with_digital_payment:$url");
      html.window.open(url, "_self");
    } else {
      printLog("url_with_digital_payment_mobile:$url");
      Get.to(() => PaymentScreen(url: url, fromPage: "add-fund"));
    }
  }
}

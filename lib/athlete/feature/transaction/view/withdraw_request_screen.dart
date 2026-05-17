// lib/athlete/feature/transaction/screens/withdraw_request_screen.dart

import 'dart:convert';
import 'dart:math';
import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:afriendorse/athlete/feature/payement_information/widgets/payment_info_card.dart';
import 'package:afriendorse/athlete/feature/transaction/model/dropdown_method_method.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class WithdrawRequestScreen extends StatefulWidget {
  final double? amount;
  const WithdrawRequestScreen({super.key, this.amount = 0.0});

  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedMethodId = '';
  String _selectedMethodName = '';
  List<MethodField>? _fieldList;
  List<MethodField>? _gridFieldList;
  Map<String, TextEditingController> _textControllers = {};
  final Map<String, FocusNode> _textControllersFocus = {};
  Map<String, TextEditingController> _gridTextController = {};
  final Map<String, FocusNode> _gridTextControllerFocus = {};
  final FocusNode _inputAmountFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;

  // ── Ensure AthleteCurrencyController is available ─────────────────
  AthleteCurrencyController get _currencyCtrl {
    if (!Get.isRegistered<AthleteCurrencyController>()) {
      return Get.put(AthleteCurrencyController());
    }
    return Get.find<AthleteCurrencyController>();
  }

  void setFocus() {
    _inputAmountFocusNode.requestFocus();
    Get.back();
  }

  Future<void> selectPaymentMethodField(
    String id,
    String name,
    TransactionController transactionMoneyController,
  ) async {
    _selectedMethodId = id;
    _selectedMethodName = name;
    _gridFieldList = [];
    _fieldList = [];

    for (var method
        in transactionMoneyController.withdrawModel!.withdrawalMethods!
            .firstWhere((method) => method.id.toString() == id)
            .methodFields!) {
      _gridFieldList!.addIf(
        method.inputName!.toLowerCase().contains('cvv') ||
            method.inputType!.toLowerCase() == 'date',
        method,
      );
    }

    for (var method
        in transactionMoneyController.withdrawModel!.withdrawalMethods!
            .firstWhere((method) => method.id.toString() == id)
            .methodFields!) {
      _fieldList!.addIf(
        !method.inputName!.toLowerCase().contains('cvv') &&
            method.inputType != 'date',
        method,
      );
    }

    _textControllers = {};
    _gridTextController = {};

    for (var method in _fieldList!) {
      _textControllers[method.inputName!] = TextEditingController();
      _textControllersFocus[method.inputName!] = FocusNode();
    }
    for (var method in _gridFieldList!) {
      _gridTextController[method.inputName!] = TextEditingController();
      _gridTextControllerFocus[method.inputName!] = FocusNode();
    }

    transactionMoneyController.update();
  }

  void loadData() async {
    Get.find<TransactionController>().getDropdownMethodList();
    await Get.find<TransactionController>().getWithdrawMethods(isReload: true);
    _selectedMethodId =
        Get.find<TransactionController>().defaultPaymentMethodId!;
    _selectedMethodName =
        Get.find<TransactionController>().defaultPaymentMethodName!;
    selectPaymentMethodField(
      _selectedMethodId,
      _selectedMethodName,
      Get.find<TransactionController>(),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Trigger currency controller init if not already done
    _currencyCtrl;

    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _inputAmountController.dispose();
    _noteController.dispose();
    _inputAmountFocusNode.dispose();
    _textControllers.forEach((_, c) => c.dispose());
    _gridTextController.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context),
      body: GetBuilder<TransactionController>(
        builder: (transactionMoneyController) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildProgressIndicator(context),
                  _buildBalanceCard(context),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _buildAmountSection(context),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _buildPaymentMethodSection(
                    context,
                    transactionMoneyController,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _buildNoteSection(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'withdraw_request'.tr,
        style: robotoBold.copyWith(
          color: Colors.white,
          fontSize: Dimensions.fontSizeLarge,
        ),
      ),
      centerTitle: true,
      actions: [const SizedBox(width: 8)],
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          _buildStepIndicator(context, 1, 'Amount', _currentStep >= 0),
          _buildStepLine(context, _currentStep >= 1),
          _buildStepIndicator(context, 2, 'Method', _currentStep >= 1),
          _buildStepLine(context, _currentStep >= 2),
          _buildStepIndicator(context, 3, 'Confirm', _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    int step,
    String label,
    bool isActive,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? Icon(
                      step <= _currentStep ? Icons.check : Icons.circle,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    )
                  : Text(
                      '$step',
                      style: robotoMedium.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: robotoRegular.copyWith(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(BuildContext context, bool isActive) {
    return Container(
      height: 2,
      width: 40,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  // ── Balance Card (with currency equivalent) ────────────────────────────────
  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: icon + balance ──────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'available_balance'.tr,
                      style: robotoRegular.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ── Primary amount (USD or toggled local) ────────────
                    Obx(() {
                      final ctrl = _currencyCtrl;
                      final showLocal = ctrl.showLocalCurrency.value;
                      final isToggling = ctrl.isToggling.value;

                      final primaryAmount = showLocal && ctrl.hasLocalCurrency
                          ? ctrl.getLocalEquivalent(widget.amount ?? 0)
                          : PriceConverter.convertPrice(widget.amount);

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isToggling
                            ? const SizedBox(
                                key: ValueKey('toggling'),
                                height: 38,
                              )
                            : Text(
                                key: ValueKey('$primaryAmount-$showLocal'),
                                primaryAmount,
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                      );
                    }),

                    // ── Secondary (other currency, smaller) ──────────────
                    Obx(() {
                      final ctrl = _currencyCtrl;
                      if (!ctrl.hasLocalCurrency || ctrl.isLoadingRates.value) {
                        return const SizedBox.shrink();
                      }
                      final showLocal = ctrl.showLocalCurrency.value;
                      final secondary = showLocal
                          ? PriceConverter.convertPrice(widget.amount)
                          : ctrl.getLocalEquivalent(widget.amount ?? 0);
                      final label = showLocal
                          ? '≈ $secondary USD'
                          : '≈ $secondary ${ctrl.localCurrencyCode.value}';

                      return Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          label,
                          style: robotoRegular.copyWith(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Currency Equivalent Strip ────────────────────────────────
          _WithdrawCurrencyStrip(usdAmount: widget.amount ?? 0),

          const SizedBox(height: 16),

          // ── Min / Max info pill ──────────────────────────────────────
          _MinMaxPill(),
        ],
      ),
    );
  }

  // ── Amount Section (unchanged) ─────────────────────────────────────────────
  Widget _buildAmountSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.payments_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'enter_amount'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          InputBoxView(
            inputAmountController: _inputAmountController,
            focusNode: _inputAmountFocusNode,
            amount: widget.amount,
            onAmountChanged: (value) {
              setState(() {
                _currentStep = value.isNotEmpty ? 1 : 0;
              });
            },
          ),

          // ── Live local equivalent as user types ──────────────────────
          _TypingCurrencyHint(inputController: _inputAmountController),
        ],
      ),
    );
  }

  // ── Payment Method Section (unchanged) ────────────────────────────────────
  Widget _buildPaymentMethodSection(
    BuildContext context,
    TransactionController transactionMoneyController,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'select_withdraw_method'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Form(
              key: transactionMoneyController.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMethodSelector(context, transactionMoneyController),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  if (transactionMoneyController.selectedMethod?.type ==
                      MethodType.others) ...[
                    if (_fieldList != null && _fieldList!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _fieldList!.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) => FieldItemView(
                          methodField: _fieldList![index],
                          textControllers: _textControllers,
                          focusNodes: _textControllersFocus,
                        ),
                      ),
                    if (_gridFieldList != null && _gridFieldList!.isNotEmpty)
                      GridView.builder(
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeSmall,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _gridFieldList!.length,
                        itemBuilder: (context, index) => FieldItemView(
                          methodField: _gridFieldList![index],
                          textControllers: _gridTextController,
                          focusNodes: _gridTextControllerFocus,
                          isCompact: true,
                        ),
                      ),
                  ],
                  if (transactionMoneyController.selectedMethod?.type ==
                      MethodType.myMethods)
                    PaymentInfoCard(
                      paymentMethod: transactionMoneyController
                          .selectedMethod
                          ?.paymentMethod,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector(
    BuildContext context,
    TransactionController transactionMoneyController,
  ) {
    return GestureDetector(
      onTap: () => _showMethodBottomSheet(context, transactionMoneyController),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getMethodIcon(
                  transactionMoneyController.selectedMethod?.inputName,
                ),
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transactionMoneyController.selectedMethod?.inputName ??
                        'select_a_method'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (transactionMoneyController.selectedMethod?.isDefault ??
                      false)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'default'.tr,
                        style: robotoRegular.copyWith(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }

  IconData _getMethodIcon(String? methodName) {
    if (methodName == null) return Icons.account_balance;
    final name = methodName.toLowerCase();
    if (name.contains('bank')) return Icons.account_balance;
    if (name.contains('paypal')) return Icons.payment;
    if (name.contains('card')) return Icons.credit_card;
    if (name.contains('wallet')) return Icons.account_balance_wallet;
    return Icons.payment;
  }

  void _showMethodBottomSheet(
    BuildContext context,
    TransactionController transactionMoneyController,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Text(
                      'select_withdraw_method'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  children: [
                    if (transactionMoneyController
                        .savedMethodList
                        .isNotEmpty) ...[
                      _buildSectionHeader(context, 'my_methods'.tr, Icons.star),
                      const SizedBox(height: 12),
                      ...transactionMoneyController.savedMethodList.map(
                        (method) => _buildMethodTile(
                          context,
                          method,
                          transactionMoneyController,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionHeader(context, 'others'.tr, Icons.more_horiz),
                    const SizedBox(height: 12),
                    ...transactionMoneyController.othersMethodList.map(
                      (method) => _buildMethodTile(
                        context,
                        method,
                        transactionMoneyController,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: robotoMedium.copyWith(
            color: Theme.of(context).primaryColor,
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTile(
    BuildContext context,
    DropdownMethodModel method,
    TransactionController transactionMoneyController,
  ) {
    final isSelected =
        transactionMoneyController.selectedMethod?.id == method.id;

    return GestureDetector(
      onTap: () {
        if (method.type == MethodType.others) {
          _selectedMethodName = method.withdrawalMethod!.methodName.toString();
          _selectedMethodId = method.withdrawalMethod!.id.toString();
          selectPaymentMethodField(
            method.withdrawalMethod!.id.toString(),
            method.withdrawalMethod!.methodName.toString(),
            transactionMoneyController,
          );
        }
        transactionMoneyController.onChangeMethod(method);
        setState(() => _currentStep = 2);
        Get.back();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getMethodIcon(method.inputName),
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.inputName ?? '',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (method.isDefault ?? false)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'default'.tr,
                        style: robotoRegular.copyWith(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.note_alt_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'add_note'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const Spacer(),
                Text(
                  'optional'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              maxLength: 255,
              decoration: InputDecoration(
                hintText: 'write_note_your_here'.tr,
                hintStyle: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withOpacity(0.5),
                contentPadding: const EdgeInsets.all(
                  Dimensions.paddingSizeDefault,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar (with currency equivalent on summary row) ──────────────────
  Widget _buildBottomBar(BuildContext context) {
    return GetBuilder<TransactionController>(
      builder: (transactionMoneyController) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Withdrawal Summary with local equivalent ─────────────
                if (_inputAmountController.text.isNotEmpty) ...[
                  _WithdrawalSummaryRow(
                    inputController: _inputAmountController,
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Slide to submit ──────────────────────────────────────
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Transform.rotate(
                    angle: Get.find<LocalizationController>().isLtr
                        ? pi * 2
                        : pi,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: SliderButton(
                        width: Get.width - 40,
                        dismissible: false,
                        action: _handleWithdrawRequest,
                        label: Transform.rotate(
                          angle: Get.find<LocalizationController>().isLtr
                              ? pi * 2
                              : pi,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'slide_to_withdraw'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        alignLabel: Alignment.center,
                        dismissThresholds: 0.5,
                        icon: Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        radius: 14,
                        boxShadow: const BoxShadow(blurRadius: 0.0),
                        buttonColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        baseColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleWithdrawRequest() async {
    final splashController = Get.find<SplashController>();
    final transactionController = Get.find<TransactionController>();

    final minimumWithdrawAmount =
        splashController.configModel.content?.minimumWithdrawAmount ?? 0;
    final maximumWithdrawAmount =
        splashController.configModel.content?.maximumWithdrawAmount ?? 0;

    if (_inputAmountController.text.isEmpty) {
      showCustomSnackBar(
        'please_input_amount'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    final amount = PriceConverter.getAmountFromInputFormatter(
      _inputAmountController.text,
    );

    if (amount < minimumWithdrawAmount) {
      showCustomSnackBar(
        '${'withdraw_amount_grater_than'.tr} ${PriceConverter.convertPrice(minimumWithdrawAmount)}',
        type: ToasterMessageType.info,
      );
      return;
    }

    if (amount > maximumWithdrawAmount) {
      showCustomSnackBar(
        "${'maximum_withdraw_amount_is'.tr} ${PriceConverter.convertPrice(maximumWithdrawAmount)}",
        type: ToasterMessageType.info,
      );
      return;
    }

    if (amount < maximumWithdrawAmount && amount > widget.amount!) {
      showCustomSnackBar(
        'insufficient_balance'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    if (transactionController.selectedMethod?.type == MethodType.myMethods) {
      final withdrawRequestBody = {
        'amount': '$amount',
        'withdrawal_method_id': '${transactionController.selectedMethod?.id}',
        'withdrawal_method_fields': base64Url.encode(
          utf8.encode(
            jsonEncode([transactionController.selectedMethod?.methodInfo]),
          ),
        ),
        'note': _noteController.text,
      };
      showCustomDialog(child: const CustomLoader());
      await transactionController.withDrawRequest(
        placeBody: withdrawRequestBody,
      );
      return;
    }

    if (!transactionController.formKey.currentState!.validate()) return;

    String? validationMessage;
    final withdrawMethod = transactionController
        .withdrawModel!
        .withdrawalMethods!
        .firstWhere((method) => _selectedMethodId == method.id.toString());

    String validationKey = '';
    final methodFieldValue = <Map<String, String>>[];
    final fieldValues = <String, String>{};
    Map<String, String> fieldTypeMap = {};

    for (var method in withdrawMethod.methodFields!) {
      fieldTypeMap['${method.inputName}_is_required'] = method.isRequired
          .toString();
      if (method.inputType == 'email' || method.inputType == 'date') {
        validationKey = method.inputType!;
      }
    }

    _textControllers.forEach((key, textController) {
      fieldValues.addAll({key: textController.text});
      final bool isRequired = fieldTypeMap['${key}_is_required'] == '1';
      if ((validationKey == key) && !GetUtils.isEmail(textController.text)) {
        validationMessage = 'please_provide_valid_email'.tr;
      } else if ((validationKey == key) && textController.text.contains('-')) {
        validationMessage = 'please_provide_valid_date'.tr;
      }
      if (textController.text.isEmpty &&
          validationMessage == null &&
          isRequired) {
        validationMessage = 'please fill ${key.replaceAll('_', ' ')} field';
      }
    });

    _gridTextController.forEach((key, textController) {
      fieldValues.addAll({key: textController.text});
      final bool isRequired = fieldTypeMap['${key}_is_required'] == '1';
      if (validationKey == 'date' && textController.text.contains('-')) {
        validationMessage = 'please_provide_valid_date'.tr;
      }
      if (textController.text.isEmpty &&
          validationMessage == null &&
          isRequired) {
        validationMessage = 'Please fill ${key.replaceAll('_', ' ')} field';
      }
    });

    if (validationMessage != null) {
      showCustomSnackBar(validationMessage);
      return;
    }

    methodFieldValue.add(fieldValues);
    showCustomDialog(child: const CustomLoader());

    final withdrawRequestBody = {
      'amount': '$amount',
      'withdrawal_method_id': '${withdrawMethod.id}',
      'withdrawal_method_fields': base64Url.encode(
        utf8.encode(jsonEncode(methodFieldValue)),
      ),
      'note': _noteController.text,
    };

    await transactionController.withDrawRequest(placeBody: withdrawRequestBody);
  }
}

// ── Withdraw Currency Strip (inside balance card) ─────────────────────────────

class _WithdrawCurrencyStrip extends StatelessWidget {
  final double usdAmount;
  const _WithdrawCurrencyStrip({required this.usdAmount});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();

      if (ctrl.isLoadingRates.value) {
        return _shimmer();
      }

      if (!ctrl.hasLocalCurrency) return const SizedBox.shrink();

      final localAmount = ctrl.getLocalEquivalent(usdAmount);
      final flag = ctrl.localCountryFlag.value;
      final code = ctrl.localCurrencyCode.value;
      final rateLabel = ctrl.rateLabel;
      final showLocal = ctrl.showLocalCurrency.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Flag + amount column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        '$code Equivalent',
                        style: robotoMedium.copyWith(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Live pulse dot
                      _WithdrawPulseDot(isRefreshing: ctrl.isRefreshing.value),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      key: ValueKey(localAmount),
                      localAmount,
                      style: robotoBold.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (rateLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      rateLabel,
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Toggle + refresh column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Toggle button
                GestureDetector(
                  onTap: ctrl.toggleCurrencyDisplay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            key: ValueKey(showLocal),
                            showLocal ? '$code → USD' : 'USD → $code',
                            style: robotoMedium.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: showLocal ? 0.0 : 1.0,
                            end: showLocal ? 1.0 : 0.0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (_, value, __) => Transform.rotate(
                            angle: value * 3.14159,
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Refresh button
                GestureDetector(
                  onTap: ctrl.refreshRates,
                  child: ctrl.isRefreshing.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white54,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white38,
                          size: 14,
                        ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _shimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 75,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Min/Max Pill with local equivalents ───────────────────────────────────────

class _MinMaxPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();
      final splash = Get.find<SplashController>();
      final minAmt = splash.configModel.content?.minimumWithdrawAmount ?? 0;
      final maxAmt = splash.configModel.content?.maximumWithdrawAmount ?? 0;

      final showLocal = ctrl.showLocalCurrency.value;
      final hasLocal = ctrl.hasLocalCurrency && !ctrl.isLoadingRates.value;

      final minDisplay = hasLocal && showLocal
          ? ctrl.getLocalEquivalent(minAmt.toDouble())
          : PriceConverter.convertPrice(minAmt);

      final maxDisplay = hasLocal && showLocal
          ? ctrl.getLocalEquivalent(maxAmt.toDouble())
          : PriceConverter.convertPrice(maxAmt);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white.withOpacity(0.8),
              size: 14,
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                key: ValueKey('$minDisplay-$maxDisplay'),
                '${'min'.tr}: $minDisplay  •  ${'max'.tr}: $maxDisplay',
                style: robotoRegular.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Typing Currency Hint (live local equivalent as user types amount) ─────────

class _TypingCurrencyHint extends StatefulWidget {
  final TextEditingController inputController;
  const _TypingCurrencyHint({required this.inputController});

  @override
  State<_TypingCurrencyHint> createState() => _TypingCurrencyHintState();
}

class _TypingCurrencyHintState extends State<_TypingCurrencyHint> {
  String _localEquivalent = '';

  @override
  void initState() {
    super.initState();
    widget.inputController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    widget.inputController.removeListener(_onAmountChanged);
    super.dispose();
  }

  void _onAmountChanged() {
    final ctrl = Get.find<AthleteCurrencyController>();
    if (!ctrl.hasLocalCurrency) return;

    final raw = widget.inputController.text;
    final amount = PriceConverter.getAmountFromInputFormatter(raw);
    if (amount <= 0) {
      setState(() => _localEquivalent = '');
      return;
    }

    final equivalent = ctrl.getLocalEquivalent(amount);
    setState(
      () => _localEquivalent = '≈ $equivalent ${ctrl.localCurrencyCode.value}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_localEquivalent.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();
      if (!ctrl.hasLocalCurrency) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          0,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
        ),
        child: Row(
          children: [
            Text(
              ctrl.localCountryFlag.value,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                key: ValueKey(_localEquivalent),
                _localEquivalent,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Withdrawal Summary Row (bottom bar) ───────────────────────────────────────

class _WithdrawalSummaryRow extends StatefulWidget {
  final TextEditingController inputController;
  const _WithdrawalSummaryRow({required this.inputController});

  @override
  State<_WithdrawalSummaryRow> createState() => _WithdrawalSummaryRowState();
}

class _WithdrawalSummaryRowState extends State<_WithdrawalSummaryRow> {
  @override
  void initState() {
    super.initState();
    widget.inputController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.inputController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final rawAmount = PriceConverter.getAmountFromInputFormatter(
      widget.inputController.text,
    );
    final usdDisplay = PriceConverter.convertPrice(rawAmount);

    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();
      final hasLocal = ctrl.hasLocalCurrency && !ctrl.isLoadingRates.value;
      final localDisplay = hasLocal ? ctrl.getLocalEquivalent(rawAmount) : null;

      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // USD row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'withdrawal_amount'.tr,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  usdDisplay,
                  style: robotoBold.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ],
            ),

            // Local equivalent row (only when available)
            if (localDisplay != null && rawAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        ctrl.localCountryFlag.value,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ctrl.localCurrencyCode.value} equivalent',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey(localDisplay),
                      localDisplay,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ── Pulse Dot ─────────────────────────────────────────────────────────────────

class _WithdrawPulseDot extends StatefulWidget {
  final bool isRefreshing;
  const _WithdrawPulseDot({required this.isRefreshing});

  @override
  State<_WithdrawPulseDot> createState() => _WithdrawPulseDotState();
}

class _WithdrawPulseDotState extends State<_WithdrawPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isRefreshing
              ? Colors.orange
              : Color.lerp(
                  const Color(0xFF4AE080).withOpacity(0.4),
                  const Color(0xFF4AE080),
                  _pulse.value,
                ),
        ),
      ),
    );
  }
}

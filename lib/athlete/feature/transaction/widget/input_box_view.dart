import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get.dart';

class InputBoxView extends StatefulWidget {
  final TextEditingController? inputAmountController;
  final FocusNode? focusNode;
  final double? amount;
  final Function(String)? onAmountChanged;

  const InputBoxView({
    super.key,
    @required this.inputAmountController,
    this.focusNode,
    this.amount,
    this.onAmountChanged,
  });

  @override
  State<InputBoxView> createState() => _InputBoxViewState();
}

class _InputBoxViewState extends State<InputBoxView>
    with SingleTickerProviderStateMixin {
  bool isTextFieldEmpty = true;
  int? selectedChipIndex;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<double> _getSuggestedAmounts() {
    double maxWithdrawAmount =
        Get.find<SplashController>()
            .configModel
            .content
            ?.maximumWithdrawAmount ??
        double.infinity;
    double minimumWithdrawAmount =
        Get.find<SplashController>()
            .configModel
            .content
            ?.minimumWithdrawAmount ??
        100;

    List<double> suggestions = [];
    List<double> possibleAmounts = [
      minimumWithdrawAmount,
      500,
      1000,
      5000,
      10000,
      20000,
      50000,
      100000,
    ];

    for (var amount in possibleAmounts) {
      if (widget.amount != null &&
          widget.amount! >= amount &&
          amount <= maxWithdrawAmount) {
        suggestions.add(amount);
      }
    }

    // Add max available amount if it's different from the last suggestion
    if (widget.amount != null &&
        widget.amount! <= maxWithdrawAmount &&
        !suggestions.contains(widget.amount)) {
      suggestions.add(widget.amount!);
    }

    suggestions.sort();
    return suggestions.take(6).toList(); // Limit to 6 chips
  }

  @override
  Widget build(BuildContext context) {
    bool isRightSide =
        Get.find<SplashController>()
            .configModel
            .content
            ?.currencySymbolPosition ==
        'right';

    final suggestedAmounts = _getSuggestedAmounts();

    return GetBuilder<TransactionController>(
      builder: (transactionMoneyController) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Amount Input
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isTextFieldEmpty ? _pulseAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => widget.focusNode?.requestFocus(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeLarge,
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.05),
                          Theme.of(context).primaryColor.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isTextFieldEmpty
                            ? Theme.of(context).dividerColor
                            : Theme.of(context).primaryColor,
                        width: isTextFieldEmpty ? 1 : 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (!isRightSide)
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: robotoBold.copyWith(
                                  fontSize: isTextFieldEmpty ? 28 : 36,
                                  color: isTextFieldEmpty
                                      ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withOpacity(0.3)
                                      : Theme.of(context).primaryColor,
                                ),
                                child: Text(PriceConverter.getCurrency()),
                              ),
                            IntrinsicWidth(
                              child: TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                controller: widget.inputAmountController,
                                focusNode: widget.focusNode,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  hintText: "0",
                                  hintStyle: robotoBold.copyWith(
                                    fontSize: 36,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(0.3),
                                  ),
                                ),
                                style: robotoBold.copyWith(
                                  fontSize: 36,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    isTextFieldEmpty = value.isEmpty;
                                    selectedChipIndex = null;
                                  });
                                  widget.onAmountChanged?.call(value);
                                },
                              ),
                            ),
                            if (isRightSide)
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: robotoBold.copyWith(
                                  fontSize: isTextFieldEmpty ? 28 : 36,
                                  color: isTextFieldEmpty
                                      ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color!
                                            .withOpacity(0.3)
                                      : Theme.of(context).primaryColor,
                                ),
                                child: Text(PriceConverter.getCurrency()),
                              ),
                          ],
                        ),
                        if (isTextFieldEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'tap_to_enter_amount'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Quick Amount Selection
              Text(
                'quick_select'.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),

              // Amount Chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(suggestedAmounts.length, (index) {
                  final amount = suggestedAmounts[index];
                  final isSelected = selectedChipIndex == index;
                  final isMax = amount == widget.amount;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedChipIndex = index;
                        isTextFieldEmpty = false;
                      });
                      widget.inputAmountController!.text = amount
                          .toStringAsFixed(amount == amount.toInt() ? 0 : 2);
                      widget.onAmountChanged?.call(amount.toString());
                      transactionMoneyController.setIndex(
                        index,
                        amount.toString(),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isRightSide
                                ? '${amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2)}${PriceConverter.getCurrency()}'
                                : '${PriceConverter.getCurrency()}${amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2)}',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          if (isMax) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'MAX',
                                style: robotoBold.copyWith(
                                  fontSize: 8,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

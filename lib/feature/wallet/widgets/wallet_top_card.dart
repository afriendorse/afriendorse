// lib/features/wallet/widgets/wallet_top_card.dart

import 'package:afriendorse/feature/currency_swapper/currency_controller.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class WalletTopCard extends StatelessWidget {
  final JustTheController tooltipController;
  const WalletTopCard({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    // Ensure CurrencyController is available
    /* if (!Get.isRegistered<CurrencyController>()) {
      Get.put(CurrencyController());
    } */

    return GetBuilder<WalletController>(
      builder: (walletController) {
        final double walletBalance =
            walletController.walletTransactionModel?.content?.walletBalance ??
            0;

        return Container(
          margin: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault + 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              // Background decorative image
              Image.asset(
                Images.walletBackground,
                height: Dimensions.walletTopCardHeight * 0.8,
              ),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Row: Balance + Add Fund Button ──────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Balance display
                        Expanded(
                          child: _BalanceDisplay(
                            walletBalance: walletBalance,
                            tooltipController: tooltipController,
                          ),
                        ),

                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        // Right: Add Fund button
                        _AddFundButton(context: context),
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // ── Bottom: Local Currency Equivalent ───────────────
                    _LocalCurrencyEquivalent(walletBalance: walletBalance),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Balance Display Widget ────────────────────────────────────────────────────

class _BalanceDisplay extends StatelessWidget {
  final double walletBalance;
  final JustTheController tooltipController;

  const _BalanceDisplay({
    required this.walletBalance,
    required this.tooltipController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currencyCtrl = Get.find<CurrencyController>();
      final showLocal = currencyCtrl.showLocalCurrency.value;
      final isToggling = currencyCtrl.isToggling.value;

      // Determine what to show as primary
      final String primaryLabel = showLocal
          ? '${currencyCtrl.localCountryFlag.value} ${currencyCtrl.localCurrencyCode.value} Balance'
          : 'your_balance'.tr;

      final String primaryAmount = showLocal
          ? currencyCtrl.getLocalEquivalent(walletBalance)
          : PriceConverter.convertPrice(walletBalance);

      final String secondaryAmount = showLocal
          ? PriceConverter.convertPrice(walletBalance)
          : currencyCtrl.hasLocalCurrency
          ? currencyCtrl.getLocalEquivalent(walletBalance)
          : '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Text(
                primaryLabel,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),

          // Primary balance amount (animated)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: isToggling
                ? const SizedBox(height: 40)
                : Directionality(
                    key: ValueKey('$primaryAmount-$showLocal'),
                    textDirection: TextDirection.ltr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              primaryAmount,
                              style: robotoBold.copyWith(
                                fontSize: primaryAmount.length > 12
                                    ? Dimensions.fontSizeExtraLarge
                                    : Dimensions.fontSizeOverLarge,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Tooltip info icon
                          if (Get.find<SplashController>()
                                  .configModel
                                  .content
                                  ?.addFundToWallet ==
                              1)
                            JustTheTooltip(
                              backgroundColor: Colors.black87,
                              controller: tooltipController,
                              preferredDirection: AxisDirection.down,
                              tailLength: 14,
                              tailBaseWidth: 20,
                              content: Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                ),
                                child: Text(
                                  "add_fund_instruction".tr,
                                  style: robotoRegular.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                ),
                                child: InkWell(
                                  onTap: () => tooltipController.showTooltip(),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Secondary balance (the "other" currency shown smaller)
          if (secondaryAmount.isNotEmpty && !isToggling)
            AnimatedOpacity(
              opacity: isToggling ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Text(
                showLocal
                    ? '≈ $secondaryAmount USD'
                    : '≈ $secondaryAmount ${currencyCtrl.localCurrencyCode.value}',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      );
    });
  }
}

// ── Local Currency Equivalent Strip ──────────────────────────────────────────

class _LocalCurrencyEquivalent extends StatelessWidget {
  final double walletBalance;
  const _LocalCurrencyEquivalent({required this.walletBalance});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = Get.find<CurrencyController>();

      // Don't show anything if still loading or it's already USD
      if (ctrl.isLoadingRates.value) {
        return _buildLoadingShimmer();
      }

      if (!ctrl.hasLocalCurrency) return const SizedBox.shrink();

      final localAmount = ctrl.getLocalEquivalent(walletBalance);
      final flag = ctrl.localCountryFlag.value;
      final code = ctrl.localCurrencyCode.value;
      final rateLabel = ctrl.rateLabel;
      final showLocal = ctrl.showLocalCurrency.value;

      return Container(
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Flag + currency info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '$code Equivalent',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Live rate indicator dot
                      _LiveDot(isRefreshing: ctrl.isRefreshing.value),
                    ],
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      key: ValueKey(localAmount),
                      localAmount,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (rateLabel.isNotEmpty)
                    Text(
                      rateLabel,
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                ],
              ),
            ),

            // Toggle button USD ⇄ Local
            GestureDetector(
              onTap: ctrl.toggleCurrencyDisplay,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
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
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Refresh button
            const SizedBox(width: 8),
            GestureDetector(
              onTap: ctrl.refreshRates,
              child: Obx(
                () => ctrl.isRefreshing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white60,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white54,
                        size: 16,
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
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

// ── Add Fund Button ───────────────────────────────────────────────────────────

class _AddFundButton extends StatelessWidget {
  final BuildContext context;
  const _AddFundButton({required this.context});

  @override
  Widget build(BuildContext context) {
    final addFundEnabled =
        Get.find<SplashController>().configModel.content?.addFundToWallet == 1;

    if (!addFundEnabled) return const SizedBox.shrink();

    return ResponsiveHelper.isMobile(context)
        ? FloatingActionButton.small(
            backgroundColor: Colors.white70,
            onPressed: _openAddFundDialog,
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
              size: 25,
            ),
          )
        : FloatingActionButton.extended(
            backgroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: _openAddFundDialog,
            label: Text(
              'add_fund'.tr,
              style: robotoBold.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            icon: Icon(
              Icons.add_circle_sharp,
              color: Theme.of(context).colorScheme.primary,
              size: 25,
            ),
          );
  }

  void _openAddFundDialog() {
    showGeneralDialog(
      barrierColor: Colors.black.withValues(alpha: Get.isDarkMode ? 0.8 : 0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: const Stack(
                  alignment: Alignment.topRight,
                  clipBehavior: Clip.none,
                  children: [
                    PaymentMethodListWidget(),
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Icon(Icons.cancel, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: Get.context!,
      pageBuilder: (context, animation1, animation2) => Container(),
    );
  }
}

// ── Live Rate Indicator Dot ───────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  final bool isRefreshing;
  const _LiveDot({required this.isRefreshing});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
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
                  Colors.greenAccent.withValues(alpha: 0.5),
                  Colors.greenAccent,
                  _pulse.value,
                ),
        ),
      ),
    );
  }
}

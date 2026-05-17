// lib/athlete/feature/transaction/screens/transaction_screen.dart

import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:afriendorse/athlete/feature/transaction/widget/withdraw_list_shimmer.dart';
import 'package:afriendorse/athlete/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class TransactionScreen extends StatefulWidget {
  final String? fromNotification;
  const TransactionScreen({super.key, this.fromNotification = ""});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();

    // Ensure currency controller is alive
    if (!Get.isRegistered<AthleteCurrencyController>()) {
      Get.put(AthleteCurrencyController());
    }

    Get.find<TransactionController>().getWithdrawRequestList(
      1,
      false,
      shouldUpdate: widget.fromNotification == "from_notification"
          ? false
          : true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: "withdraw_list".tr,
        onBackPressed: () {
          if (widget.fromNotification == "fromNotification") {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        },
      ),
      body: GetBuilder<TransactionController>(
        builder: (transactionController) {
          final List<TransactionData>? transactionsList =
              transactionController.transactionsList;

          // ── Loading state ──────────────────────────────────────────────
          if (transactionController.isLoading && transactionsList!.isEmpty) {
            return const WithdrawListShimmer();
          }

          // ── Empty state ────────────────────────────────────────────────
          if (transactionController.transactionsList!.isEmpty) {
            return const Center(
              child: NoDataScreen(
                text: "no_withdraw_history",
                type: NoDataType.transaction,
              ),
            );
          }

          // ── List state ─────────────────────────────────────────────────
          return RefreshIndicator(
            color: Theme.of(context).primaryColorLight,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async {
              Get.find<TransactionController>().getWithdrawRequestList(
                1,
                false,
              );
            },
            child: Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: transactionController.scrollController,
                          itemCount: transactionsList!.length,
                          itemBuilder: (context, index) {
                            final tx = transactionsList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeExtraSmall,
                              ),
                              child: Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(context).cardColor.withValues(
                                    alpha: Get.isDarkMode ? 0.5 : 1,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).hintColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeDefault,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Amount row ───────────────────
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'withdrawn_amount'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),

                                          // ── Amount + local equivalent
                                          Flexible(
                                            child: _TransactionAmountCell(
                                              transaction: tx,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),

                                      // ── Date + Status row ────────────
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateConverter.dateMonthYearTime(
                                              DateConverter.isoUtcStringToLocalDate(
                                                tx.createdAt ?? "",
                                              ),
                                            ),
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                            textDirection: TextDirection.ltr,
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall,
                                              vertical: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                              color: context
                                                  .customThemeColors
                                                  .buttonTextColorMap[tx
                                                      .requestStatus]
                                                  ?.withValues(alpha: 0.2),
                                            ),
                                            child: Text(
                                              "${tx.requestStatus}".tr,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color:
                                                    context
                                                        .customThemeColors
                                                        .buttonTextColorMap[tx
                                                        .requestStatus],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),

                                      // ── Updated by row ───────────────
                                      if (tx.requestUpdater?.userType !=
                                          'provider-admin')
                                        Row(
                                          children: [
                                            Text(
                                              '${tx.requestStatus.toString().tr} ${'by'.tr} : ',
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                              ),
                                            ),
                                            Text(
                                              '${tx.requestUpdater!.firstName ?? ""} '
                                              '${tx.requestUpdater!.lastName ?? ""}',
                                              style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ],
                                        ),

                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      // ── Notes expansion ──────────────
                                      if (tx.providerNote != null ||
                                          tx.adminNote != null)
                                        _NoteExpansion(transaction: tx),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Pagination loader ──────────────────────────────
                      if (transactionController.paginationLoading!)
                        CircularProgressIndicator(
                          color: Theme.of(context).hoverColor,
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Transaction Amount Cell
// ─────────────────────────────────────────────────────────────────────────────

class _TransactionAmountCell extends StatelessWidget {
  final TransactionData transaction;
  const _TransactionAmountCell({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final double usdAmount = double.tryParse(transaction.amount ?? '0') ?? 0.0;
    final String usdDisplay = PriceConverter.convertPrice(usdAmount);

    // Guard: if controller not registered fall back gracefully
    if (!Get.isRegistered<AthleteCurrencyController>()) {
      return _FallbackAmountCell(
        usdDisplay: usdDisplay,
        transaction: transaction,
      );
    }

    return Obx(() {
      final ctrl = Get.find<AthleteCurrencyController>();
      final bool hasLocal = ctrl.hasLocalCurrency && !ctrl.isLoadingRates.value;
      final String? localDisplay = hasLocal
          ? ctrl.getLocalEquivalent(usdAmount)
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── USD amount + paid/unpaid badge ─────────────────────────
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Dimensions.paddingSizeExtraSmall,
            children: [
              Text(
                usdDisplay,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
              Text(
                transaction.isPaid == 1 ? "(${'paid'.tr})" : "(${'unpaid'.tr})",
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: transaction.isPaid == 1
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),

          // ── Local currency equivalent (subtle row below) ───────────
          if (localDisplay != null && usdAmount > 0) ...[
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Row(
                key: ValueKey(localDisplay),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ctrl.localCountryFlag.value,
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    localDisplay,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Fallback Amount Cell (when CurrencyController not yet registered)
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackAmountCell extends StatelessWidget {
  final String usdDisplay;
  final TransactionData transaction;

  const _FallbackAmountCell({
    required this.usdDisplay,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Dimensions.paddingSizeExtraSmall,
      children: [
        Text(
          usdDisplay,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        Text(
          transaction.isPaid == 1 ? "(${'paid'.tr})" : "(${'unpaid'.tr})",
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: transaction.isPaid == 1
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Note Expansion Tile
// ─────────────────────────────────────────────────────────────────────────────

class _NoteExpansion extends StatelessWidget {
  final TransactionData transaction;
  const _NoteExpansion({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: CustomBookingDetailsExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              titlePadding: EdgeInsets.zero,
              isShowExpandIcon: false,
              trailingIconSize: Dimensions.paddingSizeExtraLarge * 1.5,
              isShowTrailingExpandIcon: true,
              leading: Image(
                image: AssetImage(Images.note),
                height: Dimensions.paddingSizeExtraLarge,
                width: Dimensions.paddingSizeExtraLarge,
              ),
              bookingTitle: "note".tr,
              bookingTitleColor: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.08),
                    ),

                    // ── Provider note ────────────────────────────────
                    if (transaction.providerNote != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "provider_note".tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                            ),
                            Text(
                              transaction.providerNote ?? "",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Admin note ───────────────────────────────────
                    if (transaction.adminNote != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "admin_note".tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                            ),
                            Text(
                              transaction.adminNote ?? "",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color!
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (transaction.adminNote != null)
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

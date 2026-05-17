// lib/athlete/feature/wallet/screens/wallet_screen.dart

import 'package:afriendorse/athlete/feature/athlete_currency_swappy/athlete_currency_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/wallet/controller/wallet_controller.dart';
import 'package:afriendorse/athlete/feature/wallet/model/wallet_transaction_model.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/wallet_balance_card.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/wallet_filter_bar.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/wallet_transaction_tile.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/wallet_transaction_detail_sheet.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class AthleteWalletScreen extends StatefulWidget {
  const AthleteWalletScreen({super.key});

  @override
  State<AthleteWalletScreen> createState() => _AthleteWalletScreenState();
}

class _AthleteWalletScreenState extends State<AthleteWalletScreen>
    with SingleTickerProviderStateMixin {
  late final WalletController _controller;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController(), permanent: true);

    // Ensure currency controller is alive (binding handles it,
    // but this guards direct screen navigation too)
    if (!Get.isRegistered<AthleteCurrencyController>()) {
      Get.put(AthleteCurrencyController());
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openWithdraw() {
    HapticFeedback.mediumImpact();
    Get.to(
      () => WithdrawRequestScreen(amount: _controller.mergedAvailableBalance),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 350),
    );
  }

  void _openTransactionDetail(WalletTransactionModel tx) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WalletTransactionDetailSheet(transaction: tx),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF045F25),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: RefreshIndicator(
            color: const Color(0xFF045F25),
            backgroundColor: Colors.white,
            onRefresh: _controller.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xFF045F25),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    'My Wallet',
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 0.3,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    Obx(
                      () => _controller.isSyncing.value
                          ? const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: _controller.refresh,
                    ),
                  ],
                ),

                // Balance
                SliverToBoxAdapter(
                  child: GetBuilder<UserProfileController>(
                    builder: (_) => Obx(
                      () => WalletBalanceCard(
                        availableBalance: _controller.mergedAvailableBalance,
                        totalEarned: _controller.mergedTotalEarned,
                        pendingBalance: _controller.pendingBalance,
                        onWithdraw: _openWithdraw,
                      ),
                    ),
                  ),
                ),

                // Header + filter
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transaction History',
                                style: robotoBold.copyWith(
                                  fontSize: 18,
                                  color: const Color(0xFF0A0A0A),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Obx(() {
                                final count =
                                    _controller.filteredTransactions.length;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF045F25,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$count ${count == 1 ? 'entry' : 'entries'}',
                                    style: robotoMedium.copyWith(
                                      fontSize: 12,
                                      color: const Color(0xFF045F25),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => WalletFilterBar(
                            activeFilter: _controller.activeFilter.value,
                            onFilterChanged: _controller.setFilter,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // List
                Obx(() {
                  if (_controller.isLoading.value) {
                    return SliverToBoxAdapter(child: _WalletShimmer());
                  }

                  final txList = _controller.filteredTransactions;

                  if (txList.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        filter: _controller.activeFilter.value,
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final tx = txList[index];
                      final showDateHeader =
                          index == 0 ||
                          !_isSameDay(
                            txList[index - 1].createdAt,
                            tx.createdAt,
                          );

                      return Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              _DateGroupHeader(date: tx.createdAt),
                            WalletTransactionTile(
                              transaction: tx,
                              onTap: () => _openTransactionDetail(tx),
                            ),
                          ],
                        ),
                      );
                    }, childCount: txList.length),
                  );
                }),

                SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: true,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// (Your _DateGroupHeader, _WalletShimmer, _EmptyState remain unchanged)
// ─────────────────────────────────────────────
//  Date Group Header
// ─────────────────────────────────────────────
class _DateGroupHeader extends StatelessWidget {
  final DateTime date;
  const _DateGroupHeader({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateConverter.dateStringMonthYear(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        _label(),
        style: robotoMedium.copyWith(
          fontSize: 12,
          color: Colors.black45,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shimmer placeholder
// ─────────────────────────────────────────────
class _WalletShimmer extends StatefulWidget {
  @override
  State<_WalletShimmer> createState() => _WalletShimmerState();
}

class _WalletShimmerState extends State<_WalletShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final opacity = 0.04 + (_anim.value * 0.08);
          return Column(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(opacity),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(opacity * 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      height: 16,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final WalletFilter filter;
  const _EmptyState({required this.filter});

  String get _message {
    switch (filter) {
      case WalletFilter.deals:
        return 'No completed deals yet.\nAccepted Deals will appear here.';
      case WalletFilter.donations:
        return 'No donations received yet.\nJoin groups to start earning.';
      case WalletFilter.withdrawals:
        return 'No withdrawal requests yet.\nWithdraw your balance above.';
      case WalletFilter.all:
        return 'No transactions yet.\nYour earnings will appear here.';
    }
  }

  IconData get _icon {
    switch (filter) {
      case WalletFilter.deals:
        return Icons.handshake_outlined;
      case WalletFilter.donations:
        return Icons.volunteer_activism_outlined;
      case WalletFilter.withdrawals:
        return Icons.account_balance_outlined;
      case WalletFilter.all:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF045F25).withOpacity(0.07),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _icon,
              size: 38,
              color: const Color(0xFF045F25).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: 14,
              color: Colors.black38,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/athlete/feature/wallet/widgets/wallet_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:afriendorse/athlete/feature/wallet/controller/wallet_controller.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class WalletFilterBar extends StatelessWidget {
  final WalletFilter activeFilter;
  final ValueChanged<WalletFilter> onFilterChanged;

  const WalletFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const _filters = [
    (WalletFilter.all, 'All', Icons.apps_rounded),
    (WalletFilter.deals, 'Deals', Icons.handshake_rounded),
    (WalletFilter.donations, 'Donations', Icons.volunteer_activism_rounded),
    (WalletFilter.withdrawals, 'Withdrawals', Icons.account_balance_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (filter, label, icon) = _filters[i];
          final isActive = activeFilter == filter;
          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF045F25)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isActive ? Colors.white : Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: (isActive ? robotoMedium : robotoRegular).copyWith(
                      fontSize: 13,
                      color: isActive ? Colors.white : Colors.black54,
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
}

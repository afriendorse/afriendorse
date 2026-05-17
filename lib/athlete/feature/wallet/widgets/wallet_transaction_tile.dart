// lib/athlete/feature/wallet/widgets/wallet_transaction_tile.dart

import 'package:flutter/material.dart';
import 'package:afriendorse/athlete/feature/wallet/model/wallet_transaction_model.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class WalletTransactionTile extends StatelessWidget {
  final WalletTransactionModel transaction;
  final VoidCallback onTap;

  const WalletTransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  Color get _iconBg {
    switch (transaction.type) {
      case WalletTransactionType.dealPayment:
        return const Color(0xFFE8F5EE);
      case WalletTransactionType.groupDonation:
        return const Color(0xFFE3F0FF);
      case WalletTransactionType.individualDonation:
        return const Color(0xFFF0E8FF);
      case WalletTransactionType.withdrawal:
        return const Color(0xFFFFF3E0);
      case WalletTransactionType.pointsRedeemed:
        return const Color(0xFFFFF8E1);
    }
  }

  Color get _iconColor {
    switch (transaction.type) {
      case WalletTransactionType.dealPayment:
        return const Color(0xFF045F25);
      case WalletTransactionType.groupDonation:
        return const Color(0xFF1565C0);
      case WalletTransactionType.individualDonation:
        return const Color(0xFF6A1B9A);
      case WalletTransactionType.withdrawal:
        return const Color(0xFFE65100);
      case WalletTransactionType.pointsRedeemed:
        return const Color(0xFFF9A825);
    }
  }

  IconData get _icon {
    switch (transaction.type) {
      case WalletTransactionType.dealPayment:
        return Icons.handshake_rounded;
      case WalletTransactionType.groupDonation:
        return Icons.groups_rounded;
      case WalletTransactionType.individualDonation:
        return Icons.person_rounded;
      case WalletTransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case WalletTransactionType.pointsRedeemed:
        return Icons.stars_rounded;
    }
  }

  Color get _statusColor {
    switch (transaction.status) {
      case WalletTransactionStatus.completed:
      case WalletTransactionStatus.approved:
        return const Color(0xFF2E7D32);
      case WalletTransactionStatus.pending:
        return const Color(0xFFE65100);
      case WalletTransactionStatus.failed:
      case WalletTransactionStatus.denied:
        return const Color(0xFFC62828);
    }
  }

  String get _statusLabel {
    switch (transaction.status) {
      case WalletTransactionStatus.completed:
        return 'Completed';
      case WalletTransactionStatus.approved:
        return 'Approved';
      case WalletTransactionStatus.pending:
        return 'Pending';
      case WalletTransactionStatus.failed:
        return 'Failed';
      case WalletTransactionStatus.denied:
        return 'Denied';
    }
  }

  String get _timeLabel {
    final now = DateTime.now();
    final diff = now.difference(transaction.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateConverter.convert24HourTimeTo12HourTime(transaction.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF045F25).withOpacity(0.04),
      highlightColor: const Color(0xFF045F25).withOpacity(0.02),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),

            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: robotoMedium.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF0A0A0A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel,
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: _statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: robotoRegular.copyWith(
                          fontSize: 10,
                          color: Colors.black26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          transaction.subtitle,
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Amount + time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isCredit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: robotoBold.copyWith(
                    fontSize: 14,
                    color: transaction.isCredit
                        ? const Color(0xFF045F25)
                        : const Color(0xFFB71C1C),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _timeLabel,
                  style: robotoRegular.copyWith(
                    fontSize: 10,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Colors.black12,
            ),
          ],
        ),
      ),
    );
  }
}

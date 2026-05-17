// lib/athlete/feature/wallet/widgets/wallet_transaction_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:afriendorse/athlete/feature/wallet/model/wallet_transaction_model.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class WalletTransactionDetailSheet extends StatelessWidget {
  final WalletTransactionModel transaction;

  const WalletTransactionDetailSheet({super.key, required this.transaction});

  Color get _accentColor {
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
        return Icons.account_balance_rounded;
      case WalletTransactionType.pointsRedeemed:
        return Icons.stars_rounded;
    }
  }

  String _statusLabel(WalletTransactionStatus s) {
    switch (s) {
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

  Color _statusColor(WalletTransactionStatus s) {
    switch (s) {
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

  @override
  Widget build(BuildContext context) {
    final m = transaction.metadata;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(_icon, color: _accentColor, size: 32),
            ),

            const SizedBox(height: 16),

            Text(
              '${transaction.isCredit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: robotoBold.copyWith(
                fontSize: 34,
                color: transaction.isCredit
                    ? const Color(0xFF045F25)
                    : const Color(0xFFB71C1C),
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              transaction.title,
              style: robotoMedium.copyWith(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(transaction.status),
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  color: _statusColor(transaction.status),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _DetailRow(label: 'Type', value: transaction.typeLabel),
                    _Divider(),
                    _DetailRow(
                      label: 'Date',
                      value: DateConverter.dateMonthYearTime(
                        transaction.createdAt,
                      ),
                    ),

                    if (transaction.type == WalletTransactionType.dealPayment)
                      ..._dealFields(m),
                    if (transaction.type == WalletTransactionType.groupDonation)
                      ..._groupDonationFields(m),
                    if (transaction.type == WalletTransactionType.withdrawal)
                      ..._withdrawalFields(m),
                    if (transaction.type ==
                        WalletTransactionType.pointsRedeemed)
                      ..._pointsWithdrawalFields(m),

                    if (transaction.reference != null &&
                        transaction.reference!.isNotEmpty) ...[
                      _Divider(),
                      _DetailRow(
                        label: 'Reference',
                        value: transaction.reference!,
                        canCopy: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF045F25),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: robotoBold.copyWith(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _dealFields(Map<String, dynamic> m) => [
    _Divider(),
    _DetailRow(label: 'Service', value: m['serviceName'] as String? ?? '—'),
    if ((m['paymentMethod'] as String?)?.isNotEmpty == true) ...[
      _Divider(),
      _DetailRow(
        label: 'Payment Via',
        value: (m['paymentMethod'] as String).capitalizeFirst ?? '—',
      ),
    ],
  ];

  List<Widget> _groupDonationFields(Map<String, dynamic> m) => [
    _Divider(),
    _DetailRow(label: 'Group', value: m['groupName'] as String? ?? '—'),
    _Divider(),
    _DetailRow(
      label: 'Donor',
      value: (m['isAnonymous'] as bool? ?? false)
          ? 'Anonymous'
          : (m['donorName'] as String? ?? '—'),
    ),
    if ((m['message'] as String?)?.isNotEmpty == true) ...[
      _Divider(),
      _DetailRow(label: 'Message', value: m['message'] as String),
    ],
  ];

  List<Widget> _withdrawalFields(Map<String, dynamic> m) => [
    _Divider(),
    _DetailRow(
      label: 'Payment Status',
      value: (m['isPaid'] as int? ?? 0) == 1 ? 'Paid' : 'Unpaid',
    ),
    if ((m['providerNote'] as String?)?.isNotEmpty == true) ...[
      _Divider(),
      _DetailRow(label: 'Your Note', value: m['providerNote'] as String),
    ],
    if ((m['adminNote'] as String?)?.isNotEmpty == true) ...[
      _Divider(),
      _DetailRow(label: 'Admin Note', value: m['adminNote'] as String),
    ],
  ];

  List<Widget> _pointsWithdrawalFields(Map<String, dynamic> m) => [
    _Divider(),
    _DetailRow(
      label: 'Points Used',
      value: '${(m['pointsAmount'] as num?)?.toInt() ?? 0} pts',
    ),
    _Divider(),
    _DetailRow(
      label: 'Cash Value',
      value:
          '\$${((m['cashAmount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
    ),
    _Divider(),
    _DetailRow(label: 'Source', value: 'Referral Points'),
  ];
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 1,
    color: Color(0xFFEEEEEE),
    indent: 20,
    endIndent: 20,
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool canCopy;

  const _DetailRow({
    required this.label,
    required this.value,
    this.canCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: 13,
                color: Colors.black45,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: robotoMedium.copyWith(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
          if (canCopy) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                showCustomSnackBar(
                  'Copied to clipboard',
                  type: ToasterMessageType.success,
                );
              },
              child: const Icon(
                Icons.copy_rounded,
                size: 15,
                color: Color(0xFF045F25),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

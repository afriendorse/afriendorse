// lib/feature/referral/widget/referral_history_list.dart

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/referral/repository/referral_tracking_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReferralHistoryList extends StatelessWidget {
  final List<ReferralData> referrals;

  const ReferralHistoryList({super.key, required this.referrals});

  @override
  Widget build(BuildContext context) {
    if (referrals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: Theme.of(context).hintColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'no_referrals_yet'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'start_sharing_code'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemCount: referrals.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: Dimensions.paddingSizeSmall),
      itemBuilder: (context, index) {
        final referral = referrals[index];
        return _ReferralHistoryItem(referral: referral);
      },
    );
  }
}

class _ReferralHistoryItem extends StatelessWidget {
  final ReferralData referral;

  const _ReferralHistoryItem({required this.referral});

  @override
  Widget build(BuildContext context) {
    final isPending = referral.status == 'pending';
    final isCompleted = referral.status == 'completed';

    Color statusColor = Colors.grey;
    if (isCompleted) statusColor = Colors.green;
    if (isPending) statusColor = Colors.orange;

    final userTypeIcon = _getUserTypeIcon(referral.refereeType);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Type Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(userTypeIcon, color: statusColor, size: 24),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getDisplayName(referral.refereeId),
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        referral.status.toUpperCase(),
                        style: robotoMedium.copyWith(
                          fontSize: 10,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 14,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      referral.refereeType.capitalizeFirst ?? '',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                if (referral.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(referral.createdAt!),
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName(String email) {
    try {
      final name = email.split('@').first;
      return name.capitalizeFirst ?? email;
    } catch (e) {
      return email;
    }
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType.toLowerCase()) {
      case 'brand':
        return Icons.business_center_outlined;
      case 'athlete':
        return Icons.sports_outlined;
      case 'fan':
        return Icons.favorite_outline;
      default:
        return Icons.person_outline;
    }
  }
}

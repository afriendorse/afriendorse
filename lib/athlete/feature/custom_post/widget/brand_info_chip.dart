import 'package:afriendorse/feature/auth/repository/firestore_sync_service.dart';
import 'package:flutter/material.dart';

class BrandInfoChip extends StatefulWidget {
  final String? email;

  const BrandInfoChip({super.key, this.email});

  @override
  State<BrandInfoChip> createState() => _BrandInfoChipState();
}

class _BrandInfoChipState extends State<BrandInfoChip> {
  String? _brandName;
  String? _industry;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrandInfo();
  }

  Future<void> _fetchBrandInfo() async {
    if (widget.email == null || widget.email!.trim().isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await FirestoreSyncService.getBrandByEmail(widget.email!);
      if (mounted) {
        setState(() {
          _brandName = data?['brandName']?.toString();
          _industry = data?['industry']?.toString();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 1.8,
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    final hasBrand = _brandName != null && _brandName!.isNotEmpty;
    final hasIndustry = _industry != null && _industry!.isNotEmpty;

    if (!hasBrand && !hasIndustry) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        if (hasBrand)
          _NILPill(
            icon: Icons.business_rounded,
            label: _brandName!,
            isPrimary: true,
          ),
        if (hasIndustry)
          _NILPill(
            icon: Icons.sports_rounded,
            label: _industry!,
            isPrimary: true,
          ),
      ],
    );
  }
}

class _NILPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _NILPill({
    required this.icon,
    required this.label,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary
            ? primary.withOpacity(0.12)
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPrimary
              ? primary.withOpacity(0.35)
              : Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isPrimary
                ? primary
                : Theme.of(context).secondaryHeaderColor.withOpacity(0.7),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w400,
                color: isPrimary
                    ? primary
                    : Theme.of(context).secondaryHeaderColor.withOpacity(0.75),
                letterSpacing: isPrimary ? 0.2 : 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

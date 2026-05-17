import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afriendorse/main.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  static const Color kGreen = Color(0xFF045F25);
  static const Color kBlack = Color(0xFF000000);
  static const Color kWhite = Color(0xFFFFFFFF);

  String? _selectedMode;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White background => dark icons
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: kWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: Stack(
          children: [
            const _PremiumBackgroundLight(),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 52),
                          Hero(
                            tag: 'logo',
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.06),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 28,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: kGreen.withOpacity(0.10),
                                    blurRadius: 40,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/appbar_logo.png',
                                height: 92,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Welcome to AfriEndorse',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kBlack,
                              fontSize: 34,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          // const SizedBox(height: 10),
                          //  const _FeatureGridLight(),
                          const SizedBox(height: 135),
                          Text(
                            'I am here as a(n)',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: kBlack,
                              fontSize: 20,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _GlassPanelLight(
                            child: Column(
                              children: [
                                _ModeOptionTileLight(
                                  title: 'Brand/Fan',
                                  subtitle:
                                      'Discover athletes, book services, manage campaigns',
                                  icon: Icons.business_center_rounded,
                                  accentFill: kBlack,
                                  selected: _selectedMode == 'brand',
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedMode = 'brand');
                                  },
                                ),
                                const SizedBox(height: 12),
                                _ModeOptionTileLight(
                                  title: 'Athlete',
                                  subtitle:
                                      'Manage bookings, track earnings, grow your career',
                                  icon: Icons.sports_handball_rounded,
                                  accentFill: kGreen,
                                  selected: _selectedMode == 'athlete',
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedMode = 'athlete');
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _PrimaryCtaLight(
                            enabled: _selectedMode != null,
                            label: 'Get started',
                            onPressed: _selectedMode == null
                                ? null
                                : () => _confirmSelection(context),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => _showHelpDialog(context),
                            style: TextButton.styleFrom(
                              foregroundColor: kBlack.withOpacity(0.70),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Need help choosing?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSelection(BuildContext context) async {
    final mode = _selectedMode;
    if (mode == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', mode);

    launchApp(mode);
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quick Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogSection(
              'Brand & Fan',
              'For users looking to hire athletes, buy merch, or follow teams.',
              Icons.business_center,
            ),
            const SizedBox(height: 20),
            _buildDialogSection(
              'Athlete',
              'For NIL talent managing their profile, services, and payouts.',
              Icons.sports_handball,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: Color(0xFF045F25),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogSection(String title, String body, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF045F25), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/*
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: const TextStyle(
          color: kBlack,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: TextStyle(
          color: kBlack.withOpacity(0.75),
          fontSize: 14.5,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
        title: const Text('Quick guide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Brand/Fan if you want to:',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text('• Book services\n• Browse content\n• Manage campaigns'),
            SizedBox(height: 14),
            Text(
              'Choose Athlete if you are:',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              '• An athlete or performer\n• Managing your career\n• Offering services',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF045F25),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  } 
} */

class _PrimaryCtaLight extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryCtaLight({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  static const Color kGreen = Color(0xFF045F25);
  static const Color kBlack = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
                )
              : null,
          color: enabled ? null : kBlack.withOpacity(0.06),
          border: Border.all(
            color: enabled
                ? Colors.white.withOpacity(0.22)
                : Colors.black.withOpacity(0.08),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: kGreen.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
            foregroundColor: enabled ? Colors.white : kBlack.withOpacity(0.45),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _ModeOptionTileLight extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentFill;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOptionTileLight({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentFill,
    required this.selected,
    required this.onTap,
  });

  static const Color kGreen = Color(0xFF045F25);
  static const Color kBlack = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    final Color border = selected
        ? kGreen.withOpacity(0.55)
        : Colors.black.withOpacity(0.08);

    final Color bg = selected
        ? kGreen.withOpacity(0.08)
        : kBlack.withOpacity(0.03);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentFill,
                    boxShadow: [
                      BoxShadow(
                        color: accentFill.withOpacity(0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: kBlack.withOpacity(0.68),
                                fontSize: 16.5,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kGreen.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: kGreen.withOpacity(0.30),
                                ),
                              ),
                              child: const Text(
                                'Selected',
                                style: TextStyle(
                                  color: kBlack,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: kBlack.withOpacity(0.68),
                          fontSize: 13.5,
                          height: 1.25,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: kBlack.withOpacity(0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPanelLight extends StatelessWidget {
  final Widget child;
  const _GlassPanelLight({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FeatureGridLight extends StatelessWidget {
  const _FeatureGridLight();

  static const Color kGreen = Color(0xFF045F25);
  static const Color kBlack = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String text, Color dot) {
      return Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dot.withOpacity(0.10),
              border: Border.all(color: dot.withOpacity(0.22)),
            ),
            child: Icon(icon, color: dot, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: kBlack.withOpacity(0.72),
                fontSize: 13.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: item(
                  Icons.payments_rounded,
                  'Bookings & payouts',
                  kGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: item(
                  Icons.groups_2_rounded,
                  'Fans & communities',
                  kBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: item(Icons.campaign_rounded, 'Campaign tools', kGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: item(Icons.storefront_rounded, 'Brand deals', kGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumBackgroundLight extends StatelessWidget {
  const _PremiumBackgroundLight();

  static const Color kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft white gradient (premium vs flat white)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAF8), Color(0xFFFFFFFF)],
            ),
          ),
        ),

        // Green bloom near the top (hero emphasis)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.95),
                radius: 1.15,
                colors: [kGreen.withOpacity(0.16), Colors.transparent],
              ),
            ),
          ),
        ),

        // Subtle geometric lines (texture)
        Positioned.fill(
          child: CustomPaint(
            painter: _LineMeshPainter(color: kGreen.withOpacity(0.10)),
          ),
        ),
      ],
    );
  }
}

class _LineMeshPainter extends CustomPainter {
  final Color color;
  _LineMeshPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.12)
      ..lineTo(size.width * 0.46, size.height * 0.05)
      ..lineTo(size.width * 0.92, size.height * 0.18)
      ..moveTo(size.width * 0.12, size.height * 0.36)
      ..lineTo(size.width * 0.60, size.height * 0.28)
      ..lineTo(size.width * 0.90, size.height * 0.42)
      ..moveTo(size.width * 0.06, size.height * 0.62)
      ..lineTo(size.width * 0.52, size.height * 0.52)
      ..lineTo(size.width * 0.94, size.height * 0.68);

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _LineMeshPainter oldDelegate) =>
      oldDelegate.color != color;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';

class NilMediaKitSection extends StatelessWidget {
  final ProviderData provider;
  const NilMediaKitSection({super.key, required this.provider});

  static const Color kGreen = Color(0xFF045F25);

  DocumentReference<Map<String, dynamic>>? _docRef() {
    final email = provider.owner?.email?.trim();
    if (email == null || email.isEmpty) return null;
    final docId = email.toLowerCase();
    return FirebaseFirestore.instance.collection('athlete_profiles').doc(docId);
  }

  // --- helpers ---
  num? _toNum(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim().replaceAll(',', '');
    if (s.isEmpty) return null;
    return num.tryParse(s);
  }

  String _compact(dynamic v) {
    final n = _toNum(v);
    if (n == null) return '';
    final abs = n.abs();

    String f(num value, String suffix) {
      final d = value.toDouble();
      final fixed = d >= 10 ? d.toStringAsFixed(1) : d.toStringAsFixed(1);
      final cleaned = fixed.endsWith('.0')
          ? fixed.substring(0, fixed.length - 2)
          : fixed;
      return '$cleaned$suffix';
    }

    if (abs >= 1000000000) return f(n / 1000000000, 'B');
    if (abs >= 1000000) return f(n / 1000000, 'M');
    if (abs >= 1000) return f(n / 1000, 'k');
    return n.toStringAsFixed(0);
  }

  String _percent(dynamic v) {
    final n = _toNum(v);
    if (n == null) return '';
    final d = n.toDouble();
    final fixed = d.toStringAsFixed(d >= 10 ? 0 : 1);
    final cleaned = fixed.endsWith('.0')
        ? fixed.substring(0, fixed.length - 2)
        : fixed;
    return '$cleaned%';
  }

  @override
  Widget build(BuildContext context) {
    final ref = _docRef();
    if (ref == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _MediaKitShimmer();
        }
        if (!snap.hasData || !(snap.data?.exists ?? false)) {
          return const SizedBox();
        }

        final data = snap.data!.data() ?? {};
        final bio = (data['bio'] ?? '').toString().trim();
        final school = (data['schoolTeam'] ?? '').toString().trim();
        final position = (data['positionRole'] ?? '').toString().trim();
        final publicLocation = (data['publicLocation'] ?? '').toString().trim();
        final sportName = (data['sportName'] ?? '').toString().trim();

        final completeness =
            int.tryParse('${data['profileCompleteness'] ?? 0}') ?? 0;

        final gallery = ((data['gallery'] ?? []) as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();

        final languages = ((data['languages'] ?? []) as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();

        final interests = ((data['interests'] ?? []) as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();

        final awards = ((data['awards'] ?? []) as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();

        final socials =
            (data['socials'] as Map?)?.cast<String, dynamic>() ?? {};
        String s(String k) => (socials[k] ?? '').toString().trim();

        final socialStats =
            (data['socialStats'] as Map?)?.cast<String, dynamic>() ?? {};
        dynamic st(String k) => socialStats[k];

        final ig = s('instagram');
        final tt = s('tiktok');
        final xx = s('x');
        final yt = s('youtube');
        final web = s('website');
        final hasAnySocial = [ig, tt, xx, yt, web].any((e) => e.isNotEmpty);

        final igFollowers = _compact(st('igFollowers'));
        final ttFollowers = _compact(st('ttFollowers'));
        final xFollowers = _compact(st('xFollowers'));
        final engagementRate = _percent(st('engagementRate'));

        final hasAnyStats = [
          igFollowers,
          ttFollowers,
          xFollowers,
          engagementRate,
        ].any((e) => e.isNotEmpty);

        return Container(
          margin: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            0,
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeDefault,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: kGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        /* Text(
                          'Profile completeness • $completeness%',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.58),
                            fontSize: 12.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ), */
                      ],
                    ),
                  ),
                  if (sportName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kGreen.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: kGreen.withOpacity(0.18)),
                      ),
                      child: Text(
                        sportName,
                        style: const TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Quick identity chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (school.isNotEmpty) _Pill(icon: Icons.group, text: school),
                  if (position.isNotEmpty)
                    _Pill(icon: Icons.sports_rounded, text: position),
                  if (publicLocation.isNotEmpty)
                    _Pill(
                      icon: Icons.location_on_rounded,
                      text: publicLocation,
                    ),
                ],
              ),

              if (bio.isNotEmpty) ...[
                const SizedBox(height: 12),

                const Text(
                  'Bio',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  bio,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.72),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              if (gallery.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Gallery',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: gallery.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () => _openGallery(context, gallery, i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: CustomImage(
                              image: gallery[i],
                              fit: BoxFit.cover,
                              placeholder: Images.userPlaceHolder,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              if (hasAnySocial) ...[
                const SizedBox(height: 14),
                const Text(
                  'Social links',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (ig.isNotEmpty) _LinkChip(label: 'Instagram', value: ig),
                    if (tt.isNotEmpty) _LinkChip(label: 'TikTok', value: tt),
                    if (xx.isNotEmpty) _LinkChip(label: 'X', value: xx),
                    if (yt.isNotEmpty) _LinkChip(label: 'YouTube', value: yt),
                    if (web.isNotEmpty) _LinkChip(label: 'Website', value: web),
                  ],
                ),
              ],

              // ✅ Renamed + upgraded UI
              if (hasAnyStats) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Social stats',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    /* Text(
                      'Self‑reported',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withOpacity(0.45),
                      ),
                    ), */
                  ],
                ),
                const SizedBox(height: 10),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 70,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  children: [
                    if (igFollowers.isNotEmpty)
                      _StatCard(
                        faIcon: FontAwesomeIcons.instagram, // ← changed
                        label: 'Instagram',
                        value: igFollowers,
                      ),
                    if (ttFollowers.isNotEmpty)
                      _StatCard(
                        faIcon: FontAwesomeIcons.tiktok, // ← changed
                        label: 'TikTok',
                        value: ttFollowers,
                      ),
                    if (xFollowers.isNotEmpty)
                      _StatCard(
                        faIcon: FontAwesomeIcons.xTwitter, // ← changed
                        label: 'X',
                        value: xFollowers,
                      ),
                    if (engagementRate.isNotEmpty)
                      _StatCard(
                        faIcon: FontAwesomeIcons.chartLine, // ← changed
                        label: 'Engagement',
                        value: engagementRate,
                      ),
                  ],
                ),
              ],

              if (languages.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Languages',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: languages.map((e) => Chip(label: Text(e))).toList(),
                ),
              ],

              if (interests.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Interests',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map((e) => Chip(label: Text(e))).toList(),
                ),
              ],

              if (awards.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Awards / Accolades',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                ...awards
                    .take(4)
                    .map(
                      (a) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.emoji_events_rounded,
                          color: kGreen,
                        ),
                        title: Text(
                          a,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openGallery(BuildContext context, List<String> images, int startIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      barrierDismissible: true,
      builder: (_) =>
          _FullscreenGalleryViewer(images: images, initialIndex: startIndex),
    );
  }
}

class _FullscreenGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGalleryViewer> createState() =>
      _FullscreenGalleryViewerState();
}

class _FullscreenGalleryViewerState extends State<_FullscreenGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenW * 0.04,
        vertical: screenH * 0.12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // ── Paged zoomable images ───────────────────────────────
              PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, i) {
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        widget.images[i],
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white38,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── Top bar ─────────────────────────────────────────────
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    // Counter pill
                    if (widget.images.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Dot indicators ──────────────────────────────────────
              if (widget.images.length > 1)
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.images.length, (i) {
                      final isActive = i == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 18 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF045F25)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.black.withOpacity(0.78),
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String label;
  final String value;
  const _LinkChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value));
        customSnackBar('$label copied');
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF045F25).withOpacity(0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF045F25).withOpacity(0.22)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF045F25),
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final FaIconData faIcon; // ← changed from IconData icon
  final String label;
  final String value;

  const _StatCard({
    required this.faIcon, // ← changed
    required this.label,
    required this.value,
  });

  static const Color kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: kGreen.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                faIcon,
                color: kGreen,
                size: 16,
              ), // ← FaIcon instead of Icon
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: kGreen,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaKitShimmer extends StatelessWidget {
  const _MediaKitShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        0,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

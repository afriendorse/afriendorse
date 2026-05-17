// lib/athlete/feature/settings/business/widget/athlete_media_kit_tab_item_widget.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/settings/business/controller/athlete_media_kit_controller.dart';

class AthleteMediaKitTabItemWidget extends StatelessWidget {
  const AthleteMediaKitTabItemWidget({super.key});

  static const Color kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AthleteMediaKitController>();

    return GetBuilder<AthleteMediaKitController>(
      builder: (_) {
        if (c.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // ── subtle background tint ──────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kGreen.withOpacity(0.05), Colors.grey.shade50],
                  ),
                ),
              ),
            ),

            // ── main scroll ─────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── inline status banner (replaces old hero) ─
                SliverToBoxAdapter(child: _StatusBanner(controller: c)),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    0,
                    Dimensions.paddingSizeDefault,
                    120, // space for sticky save bar
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── 1. Bio & Identity ─────────────────
                      _SectionCard(
                        step: '01',
                        title: 'Bio & Athletic Identity',
                        subtitle:
                            'First impression brands see — fill every field.',
                        icon: Icons.person_pin_circle_rounded,
                        child: _BioSection(c: c),
                      ),

                      const SizedBox(height: 16),

                      // ── 2. Photo Gallery ──────────────────
                      _SectionCard(
                        step: '02',
                        title: 'Photo Gallery',
                        subtitle:
                            'Upload 3–12 photos · Drag to reorder · Tap to replace',
                        icon: Icons.photo_library_rounded,
                        trailing: _AddPhotosButton(c: c),
                        child: _ReorderableGallery(
                          urls: c.galleryUrls,
                          onReorder: c.reorderGallery,
                          onRemove: c.removeGalleryUrl,
                          onReplace: c.replaceGalleryImage,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 3. Social Links ───────────────────
                      _SectionCard(
                        step: '03',
                        title: 'Social Links',
                        subtitle: 'Helps brands verify reach and audience fit.',
                        icon: Icons.public_rounded,
                        child: _SocialSection(c: c),
                      ),

                      const SizedBox(height: 16),

                      // ── 4. Languages, Interests, Awards ───
                      _SectionCard(
                        step: '04',
                        title: 'Languages, Interests & Awards',
                        subtitle:
                            'Better brand matching and stronger trust signals.',
                        icon: Icons.stars_rounded,
                        child: _TagsSection(c: c),
                      ),
                    ]),
                  ),
                ),
              ],
            ),

            // ── Sticky save bar ─────────────────────────────
            Positioned(left: 0, right: 0, bottom: 0, child: _SaveBar(c: c)),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Banner
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final AthleteMediaKitController controller;
  const _StatusBanner({required this.controller});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    final pct = controller.completenessPercent;
    final isComplete = pct >= 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? kGreen.withOpacity(0.35)
              : Colors.orange.withOpacity(0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isComplete ? kGreen : Colors.orange).withOpacity(0.10),
            ),
            child: Icon(
              isComplete ? Icons.verified_rounded : Icons.edit_note_rounded,
              color: isComplete ? kGreen : Colors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete
                      ? 'Media kit complete — visible to brands!'
                      : 'Complete your NIL media kit',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: isComplete ? kGreen : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: controller.completeness,
                    minHeight: 6,
                    backgroundColor: Colors.black.withOpacity(0.07),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? kGreen : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Percentage badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: (isComplete ? kGreen : Colors.orange).withOpacity(0.10),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(
                color: isComplete ? kGreen : Colors.orange,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatefulWidget {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── header row (tappable to collapse) ──────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Step number + icon combined
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: kGreen, size: 19),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: kGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.step,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.52),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (widget.trailing != null) widget.trailing!,

                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),

          // ── collapsible body ────────────────────────────
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: widget.child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field sections extracted for clarity
// ─────────────────────────────────────────────────────────────────────────────

class _BioSection extends StatelessWidget {
  final AthleteMediaKitController c;
  const _BioSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MkField(
          label: 'School / Team',
          controller: c.schoolTeam,
          hint: 'e.g., University of Lagos · Rangers FC',
        ),
        const SizedBox(height: 14),
        _MkField(
          label: 'Sport',
          controller: TextEditingController(text: c.sportName),
          hint: 'Auto-filled from your profile',
          enabled: false,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MkField(
                label: 'Position / Role',
                controller: c.positionRole,
                hint: 'Forward, QB, Sprinter…',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MkField(
                label: 'Jersey # (optional)',
                controller: c.jerseyNumber,
                hint: 'e.g. 10',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MkField(
                label: 'Grad year (optional)',
                controller: c.classYear,
                hint: 'e.g. 2026',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MkField(
                label: 'Public Location',
                controller: c.publicLocation,
                hint: 'City, State, Country',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MkField(
          label: 'Short Bio (50–300 characters)',
          controller: c.bio,
          hint: 'Your story, values, audience, and ideal brand partnerships…',
          maxLines: 5,
        ),
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  final AthleteMediaKitController c;
  const _SocialSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MkField(
          label: 'Instagram',
          controller: c.instagram,
          hint: '@handle or https://instagram.com/…',
          prefixIcon: Icons.camera_alt_outlined,
        ),
        const SizedBox(height: 14),
        _MkField(
          label: 'TikTok',
          controller: c.tiktok,
          hint: '@handle or https://tiktok.com/@…',
          prefixIcon: Icons.music_note_outlined,
        ),
        const SizedBox(height: 14),
        _MkField(
          label: 'X / Twitter',
          controller: c.xTwitter,
          hint: '@handle or https://x.com/…',
          prefixIcon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 14),
        _MkField(
          label: 'YouTube (optional)',
          controller: c.youtube,
          hint: 'https://youtube.com/…',
          prefixIcon: Icons.play_circle_outline_rounded,
        ),
        const SizedBox(height: 14),
        _MkField(
          label: 'Website (optional)',
          controller: c.website,
          hint: 'https://yoursite.com',
          prefixIcon: Icons.language_rounded,
        ),

        const SizedBox(height: 18),
        _MiniDivider(),
        const SizedBox(height: 6),

        // follower counts sub-header
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Audience Size  (optional — helps brand targeting)',
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _MkField(
                label: 'IG Followers',
                controller: c.igFollowers,
                hint: '12 000',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MkField(
                label: 'TikTok Followers',
                controller: c.ttFollowers,
                hint: '45 000',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MkField(
                label: 'X Followers',
                controller: c.xFollowers,
                hint: '3 000',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MkField(
                label: 'Avg. Engagement %',
                controller: c.engagementRate,
                hint: '3.8',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TagsSection extends StatelessWidget {
  final AthleteMediaKitController c;
  const _TagsSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TagEditor(
          title: 'Languages spoken',
          hint: 'Type a language and tap Add…',
          values: c.languages,
          onAdd: (v) => c.addTag(c.languages, v),
          onRemove: (v) => c.removeTag(c.languages, v),
        ),
        const SizedBox(height: 14),
        _TagEditor(
          title: 'Personal Interests',
          hint: 'fitness, fashion, gaming…',
          values: c.interests,
          onAdd: (v) => c.addTag(c.interests, v),
          onRemove: (v) => c.removeTag(c.interests, v),
        ),
        const SizedBox(height: 14),
        _AwardsEditor(
          values: c.awards,
          onAdd: (v) => c.addTag(c.awards, v),
          onRemove: (v) => c.removeTag(c.awards, v),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Field  — label is ABOVE the box (no floating label illusion)
// ─────────────────────────────────────────────────────────────────────────────

class _MkField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _MkField({
    required this.label,
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.10)),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kGreen, width: 1.6),
    );
    final disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── label above the box ─────────────────────────
        Text(
          label,
          style: TextStyle(
            color: enabled
                ? Colors.black.withOpacity(0.72)
                : Colors.black.withOpacity(0.38),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),

        // ── input box ───────────────────────────────────
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint, // ← hint only, NO labelText
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.28),
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: Colors.black38)
                : null,
            filled: true,
            fillColor: enabled
                ? Colors.grey.shade50
                : Colors.black.withOpacity(0.025),
            border: enabledBorder,
            enabledBorder: enabledBorder,
            disabledBorder: disabledBorder,
            focusedBorder: focusedBorder,
            // removes the floating label behaviour entirely
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: EdgeInsets.symmetric(
              horizontal: prefixIcon != null ? 4 : 14,
              vertical: maxLines > 1 ? 14 : 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add photos button  (isolated so Uploading state rerenders independently)
// ─────────────────────────────────────────────────────────────────────────────

class _AddPhotosButton extends StatelessWidget {
  final AthleteMediaKitController c;
  const _AddPhotosButton({required this.c});

  @override
  Widget build(BuildContext context) {
    final uploading = c.uploadingCount > 0;
    return TextButton.icon(
      onPressed: uploading ? null : c.addGalleryImages,
      icon: Icon(
        uploading
            ? Icons.hourglass_top_rounded
            : Icons.add_photo_alternate_outlined,
        size: 16,
      ),
      label: Text(
        uploading ? 'Uploading ${c.uploadingCount}…' : 'Add photos',
        style: const TextStyle(fontSize: 12.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reorderable gallery
// ─────────────────────────────────────────────────────────────────────────────

class _ReorderableGallery extends StatelessWidget {
  final List<String> urls;
  final void Function(int, int) onReorder;
  final void Function(String) onRemove;
  final Future<void> Function(int) onReplace;

  const _ReorderableGallery({
    required this.urls,
    required this.onReorder,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return GestureDetector(
        // tapping the empty state also triggers add
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withOpacity(0.08),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 36,
                color: Colors.black.withOpacity(0.22),
              ),
              const SizedBox(height: 8),
              Text(
                'No photos yet — tap "Add photos" above',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.42),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload at least 3 action shots or headshots',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.30),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final tiles = List<Widget>.generate(urls.length, (i) {
      return _GalleryTile(
        key: ValueKey(urls[i]),
        url: urls[i],
        index: i,
        isFirst: i == 0,
        onRemove: () => onRemove(urls[i]),
        onReplace: () => onReplace(i),
      );
    });

    return ReorderableWrap(
      spacing: 10,
      runSpacing: 10,
      needsLongPressDraggable: true,
      onReorder: onReorder,
      children: tiles,
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final String url;
  final int index;
  final bool isFirst;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const _GalleryTile({
    super.key,
    required this.url,
    required this.index,
    required this.isFirst,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReplace,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: CustomImage(
                image: url,
                fit: BoxFit.cover,
                placeholder: Images.userPlaceHolder,
              ),
            ),

            // cover / dimming
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.38),
                    ],
                  ),
                ),
              ),
            ),

            // ── "Cover" badge on first photo ───────────
            if (isFirst)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF045F25).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Cover',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

            // ── remove button ─────────────────────────
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),

            // ── drag hint ─────────────────────────────
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.white.withOpacity(0.80),
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Hold to drag',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Tag editor
// ─────────────────────────────────────────────────────────────────────────────

class _TagEditor extends StatefulWidget {
  final String title;
  final String hint;
  final List<String> values;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _TagEditor({
    required this.title,
    required this.hint,
    required this.values,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<_TagEditor> {
  final _ctrl = TextEditingController();

  void _submit() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    widget.onAdd(v);
    _ctrl.clear();
    setState(() {}); // refresh local chip display
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.72),
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),

          // chips or empty hint
          widget.values.isEmpty
              ? Text(
                  'None added yet',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.30),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.values
                      .map(
                        (v) => Chip(
                          label: Text(
                            v,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close_rounded, size: 15),
                          onDeleted: () {
                            widget.onRemove(v);
                            setState(() {});
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),

          const SizedBox(height: 12),

          // input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _submit(),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.28),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF045F25),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF045F25),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Awards editor
// ─────────────────────────────────────────────────────────────────────────────

class _AwardsEditor extends StatefulWidget {
  final List<String> values;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _AwardsEditor({
    required this.values,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_AwardsEditor> createState() => _AwardsEditorState();
}

class _AwardsEditorState extends State<_AwardsEditor> {
  final _ctrl = TextEditingController();

  void _submit() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    widget.onAdd(v);
    _ctrl.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Awards / Accolades',
            style: TextStyle(
              color: Colors.black.withOpacity(0.72),
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),

          widget.values.isEmpty
              ? Text(
                  'No awards added yet',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.30),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: widget.values
                      .map(
                        (a) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.emoji_events_rounded,
                                color: Color(0xFF045F25),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  a,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.onRemove(a);
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.black.withOpacity(0.38),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _submit(),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., MVP 2024, State Champion…',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.28),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF045F25),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF045F25),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky save bar
// ─────────────────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final AthleteMediaKitController c;
  const _SaveBar({required this.c});

  static const kGreen = Color(0xFF045F25);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            12,
            Dimensions.paddingSizeDefault,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            border: Border(
              top: BorderSide(color: Colors.black.withOpacity(0.07)),
            ),
          ),
          child: SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF045F25), Color(0xFF0A7A33)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: kGreen.withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: c.saving ? null : c.save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: c.saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Save Media Kit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _MiniDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: Colors.black.withOpacity(0.06));
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';

class AthleteMediaKitController extends GetxController implements GetxService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fields
  final bio = TextEditingController();
  final schoolTeam = TextEditingController();
  final positionRole = TextEditingController();
  final jerseyNumber = TextEditingController();
  final classYear = TextEditingController();
  final publicLocation = TextEditingController();

  // Socials
  final instagram = TextEditingController();
  final tiktok = TextEditingController();
  final xTwitter = TextEditingController();
  final youtube = TextEditingController();
  final website = TextEditingController();

  // Optional stats
  final igFollowers = TextEditingController();
  final ttFollowers = TextEditingController();
  final xFollowers = TextEditingController();
  final engagementRate = TextEditingController();

  final List<String> languages = [];
  final List<String> interests = [];
  final List<String> awards = [];
  final List<String> galleryUrls = [];

  bool _loading = false;
  bool get loading => _loading;

  bool _saving = false;
  bool get saving => _saving;

  int _uploadingCount = 0;
  int get uploadingCount => _uploadingCount;

  String? _email;
  String? get email => _email;

  String sportId = '';
  String sportName = '';

  // ---------- Profile completeness ----------
  double get completeness => completenessPercent / 100.0;

  int get completenessPercent {
    // Weighted NIL-style completeness
    int score = 0;
    int total = 100;

    final b = bio.text.trim();
    final hasBio = b.length >= 50 && b.length <= 300;
    final hasSchool = schoolTeam.text.trim().isNotEmpty;
    final hasPosition = positionRole.text.trim().isNotEmpty;
    final hasPublicLoc = publicLocation.text.trim().isNotEmpty;

    final hasGallery = galleryUrls.length >= 3; // requirement
    final hasAnySocial = [
      instagram.text.trim(),
      tiktok.text.trim(),
      xTwitter.text.trim(),
      youtube.text.trim(),
      website.text.trim(),
    ].any((e) => e.isNotEmpty);

    final hasLanguages = languages.isNotEmpty;
    final hasInterests = interests.isNotEmpty;
    final hasAwards = awards.isNotEmpty; // optional but boosts

    // Assign weights
    if (hasBio) score += 18;
    if (hasSchool) score += 12;
    if (hasPosition) score += 10;
    if (hasPublicLoc) score += 10;
    if (hasGallery) score += 22;
    if (hasAnySocial) score += 16;
    if (hasLanguages) score += 6;
    if (hasInterests) score += 6;
    if (hasAwards) score += 0; // optional (keep 0 weight or set 4 if you want)

    // Clamp
    if (score > total) score = total;
    return score;
  }

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
    // Live update completeness as user types
    bio.addListener(update);
    schoolTeam.addListener(update);
    positionRole.addListener(update);
    publicLocation.addListener(update);
    instagram.addListener(update);
    tiktok.addListener(update);
    xTwitter.addListener(update);
    youtube.addListener(update);
    website.addListener(update);
  }

  Future<void> _bootstrap() async {
    _loading = true;
    update();

    try {
      final providerInfo = Get.find<UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo;

      _email = providerInfo?.owner?.email?.trim().toLowerCase();
      if (_email == null || _email!.isEmpty) {
        _loading = false;
        update();
        return;
      }

      sportId =
          (await AthleteFirestoreSyncService.getAthleteFieldOfSport(_email!)) ??
          '';
      sportName = sportId;

      if (sportId.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('sports')
            .doc(sportId)
            .get();
        sportName = (snap.data()?['name'] ?? sportId).toString();
      }

      final data = await AthleteFirestoreSyncService.getAthleteProfileByEmail(
        _email!,
      );
      if (data != null) {
        bio.text = (data['bio'] ?? '').toString();
        schoolTeam.text = (data['schoolTeam'] ?? '').toString();
        positionRole.text = (data['positionRole'] ?? '').toString();
        jerseyNumber.text = (data['jerseyNumber'] ?? '').toString();
        classYear.text = (data['classYear'] ?? '').toString();
        publicLocation.text = (data['publicLocation'] ?? '').toString();

        final socials =
            (data['socials'] as Map?)?.cast<String, dynamic>() ?? {};
        instagram.text = (socials['instagram'] ?? '').toString();
        tiktok.text = (socials['tiktok'] ?? '').toString();
        xTwitter.text = (socials['x'] ?? '').toString();
        youtube.text = (socials['youtube'] ?? '').toString();
        website.text = (socials['website'] ?? '').toString();

        final stats =
            (data['socialStats'] as Map?)?.cast<String, dynamic>() ?? {};
        igFollowers.text = (stats['igFollowers'] ?? '').toString();
        ttFollowers.text = (stats['ttFollowers'] ?? '').toString();
        xFollowers.text = (stats['xFollowers'] ?? '').toString();
        engagementRate.text = (stats['engagementRate'] ?? '').toString();

        languages
          ..clear()
          ..addAll(
            ((data['languages'] ?? []) as List)
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty),
          );

        interests
          ..clear()
          ..addAll(
            ((data['interests'] ?? []) as List)
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty),
          );

        awards
          ..clear()
          ..addAll(
            ((data['awards'] ?? []) as List)
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty),
          );

        galleryUrls
          ..clear()
          ..addAll(
            ((data['gallery'] ?? []) as List)
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty),
          );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Media kit bootstrap error: $e');
    }

    _loading = false;
    update();
  }

  String _docId() => (_email ?? '').trim().toLowerCase();

  // ---------- Gallery ----------
  Future<void> addGalleryImages() async {
    if (_email == null || _email!.isEmpty) return;

    final remaining = 12 - galleryUrls.length;
    if (remaining <= 0) {
      showCustomSnackBar('You can upload up to 12 images.');
      return;
    }

    final images = await _picker.pickMultiImage(imageQuality: 75);
    if (images.isEmpty) return;

    final toUpload = images.take(remaining).toList();
    _uploadingCount += toUpload.length;
    update();

    try {
      for (final x in toUpload) {
        final url = await _uploadGalleryFile(File(x.path));
        if (url != null) galleryUrls.add(url);
        _uploadingCount -= 1;
        update();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Gallery upload error: $e');
    }

    update();
  }

  Future<void> replaceGalleryImage(int index) async {
    if (index < 0 || index >= galleryUrls.length) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    _uploadingCount += 1;
    update();

    try {
      final url = await _uploadGalleryFile(File(picked.path));
      if (url != null) galleryUrls[index] = url;
    } catch (e) {
      if (kDebugMode) print('❌ replaceGalleryImage error: $e');
    }

    _uploadingCount -= 1;
    update();
  }

  Future<String?> _uploadGalleryFile(File file) async {
    final id = _docId();
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('athletes/$id/gallery/$name.jpg');

    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  void removeGalleryUrl(String url) {
    galleryUrls.remove(url);
    update();
  }

  void reorderGallery(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final item = galleryUrls.removeAt(oldIndex);
    galleryUrls.insert(newIndex, item);
    update();
  }

  // ---------- Tags ----------
  void addTag(List<String> list, String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    if (list.any((e) => e.toLowerCase() == v.toLowerCase())) return;
    list.add(v);
    update();
  }

  void removeTag(List<String> list, String value) {
    list.remove(value);
    update();
  }

  Future<void> save() async {
    if (_email == null || _email!.isEmpty) return;

    final b = bio.text.trim();
    if (b.isNotEmpty && (b.length < 50 || b.length > 300)) {
      showCustomSnackBar('Bio must be between 50 and 300 characters.');
      return;
    }
    if (galleryUrls.length > 12) {
      showCustomSnackBar('Gallery can have at most 12 images.');
      return;
    }

    _saving = true;
    update();

    try {
      await AthleteFirestoreSyncService.updateAthleteMediaKit(
        email: _email!,
        sportId: sportId,
        sportName: sportName,
        bio: bio.text.trim(),
        schoolTeam: schoolTeam.text.trim(),
        positionRole: positionRole.text.trim(),
        jerseyNumber: jerseyNumber.text.trim(),
        classYear: classYear.text.trim(),
        publicLocation: publicLocation.text.trim(),
        gallery: galleryUrls,
        languages: languages,
        interests: interests,
        awards: awards,
        socials: {
          'instagram': instagram.text.trim(),
          'tiktok': tiktok.text.trim(),
          'x': xTwitter.text.trim(),
          'youtube': youtube.text.trim(),
          'website': website.text.trim(),
        },
        socialStats: {
          'igFollowers': igFollowers.text.trim(),
          'ttFollowers': ttFollowers.text.trim(),
          'xFollowers': xFollowers.text.trim(),
          'engagementRate': engagementRate.text.trim(),
        },
        profileCompleteness: completenessPercent,
      );

      showCustomSnackBar(
        'Media kit updated successfully',
        type: ToasterMessageType.success,
      );
    } catch (e) {
      if (kDebugMode) print('❌ save media kit error: $e');
      showCustomSnackBar('Failed to save. Please try again.');
    }

    _saving = false;
    update();
  }
}

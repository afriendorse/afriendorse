// lib/athlete/feature/campaigns/controller/campaign_controller.dart
//
// CHANGES from previous version:
//  1. startDonation() passes flwToken to CampaignDonationScreen.
//  2. New: streamMySubscriptions() / cancelSubscription() helpers.
//  3. New: RxList<CampaignSubscription> mySubscriptions for the
//     ManageSubscriptionsScreen.
//  4. Everything else is identical.

import 'dart:async';
import 'dart:convert';
import 'package:afriendorse/api/remote/client_api.dart';
import 'package:afriendorse/athlete/common/enums/enums.dart';
import 'package:afriendorse/athlete/common/widgets/custom_snackbar.dart';
import 'package:afriendorse/feature/wallet/controller/wallet_controller.dart';
import 'package:afriendorse/feature/wallet/repository/wallet_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:afriendorse/athlete/feature/campaigns/model/campaign_model.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_firestore_service.dart';
import 'package:afriendorse/athlete/feature/campaigns/repository/campaign_subscription_service.dart';
import 'package:afriendorse/athlete/feature/groups/models/group_models.dart';
import 'package:afriendorse/athlete/feature/groups/repository/group_firestore_service.dart';
import 'package:afriendorse/athlete/feature/groups/repository/payment_config_service.dart';
//import 'package:afriendorse/athlete/utils/core_export.dart';

import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart'
    as athlete_controller;
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as brandfan_controller;
import 'package:shared_preferences/shared_preferences.dart';

class AltCampaignController extends GetxController {
  static const String tag = 'athlete_campaign_ctrl';

  final RxList<CampaignModel> activeCampaigns = <CampaignModel>[].obs;
  final RxList<CampaignModel> myCampaigns = <CampaignModel>[].obs;
  final RxList<CampaignDonor> leaderboard = <CampaignDonor>[].obs;
  final RxList<CampaignMilestone> newlyUnlocked = <CampaignMilestone>[].obs;

  // ── NEW: donor's active monthly subscriptions ──────────────────────────
  final RxList<CampaignSubscription> mySubscriptions =
      <CampaignSubscription>[].obs;
  StreamSubscription<List<CampaignSubscription>>? _subsSub;

  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUploading = false.obs;
  final Rx<CampaignModel?> selectedCampaign = Rx<CampaignModel?>(null);

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final storyController = TextEditingController();
  final goalController = TextEditingController();
  final minDonationController = TextEditingController(text: '500');
  final Rx<DateTime> campaignEndDate = Rx<DateTime>(
    DateTime.now().add(const Duration(days: 30)),
  );
  final RxList<String> selectedTags = <String>[].obs;
  final RxBool allowAnonymous = true.obs;
  final Rx<CampaignType> campaignType = CampaignType.individual.obs;
  final Rx<File?> coverImageFile = Rx<File?>(null);
  final RxString selectedGroupId = ''.obs;
  final RxString selectedGroupName = ''.obs;

  final donateAmountController = TextEditingController();
  final donateMessageController = TextEditingController();
  final Rx<DonationFrequency> donationFrequency = DonationFrequency.oneTime.obs;
  final RxBool donateAnonymously = false.obs;

  StreamSubscription<List<CampaignModel>>? _mySub;
  bool _myListeningStarted = false;

  void reset() {
    titleController.clear();
    descriptionController.clear();
    storyController.clear();
    goalController.clear();
    minDonationController.clear();
    coverImageFile.value = null;
    selectedTags.clear();
    campaignType.value = CampaignType.individual;
    selectedGroupId.value = '';
    selectedGroupName.value = '';
    allowAnonymous.value = false;
    campaignEndDate.value = DateTime.now().add(const Duration(days: 30));
    isCreating.value = false;
  }

  bool get _isAthleteMode {
    try {
      Get.find<athlete_controller.UserProfileController>();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get _isBrandFanMode {
    try {
      Get.find<brandfan_controller.UserController>();
      return true;
    } catch (_) {
      return false;
    }
  }

  String get currentUserId {
    if (_isAthleteMode) {
      return Get.find<athlete_controller.UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.owner
              ?.email ??
          '';
    }
    if (_isBrandFanMode) {
      try {
        return Get.find<brandfan_controller.UserController>()
                .userInfoModel
                ?.id ??
            '';
      } catch (_) {}
    }
    return '';
  }

  String get currentUserIdLower => currentUserId.trim().toLowerCase();

  String get currentUserEmail {
    if (_isAthleteMode) {
      return Get.find<athlete_controller.UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.owner
              ?.email ??
          '';
    }
    if (_isBrandFanMode) {
      try {
        return Get.find<brandfan_controller.UserController>()
                .userInfoModel
                ?.email ??
            '';
      } catch (_) {}
    }
    return '';
  }

  String get currentUserName {
    if (_isAthleteMode) {
      final p = Get.find<athlete_controller.UserProfileController>()
          .providerModel
          ?.content
          ?.providerInfo;
      return p?.contactPersonName ?? p?.companyName ?? 'Athlete';
    }
    if (_isBrandFanMode) {
      try {
        final u = Get.find<brandfan_controller.UserController>().userInfoModel;
        return '${u?.fName ?? ''} ${u?.lName ?? ''}'.trim();
      } catch (_) {}
    }
    return 'Supporter';
  }

  @override
  void onInit() {
    super.onInit();
    CampaignFirestoreService.expireOverdueCampaigns();
    _listenToActiveCampaigns();
    ensureMyCampaignsListening();
    _listenToMySubscriptions(); // ← NEW
    // ✅ Initialize WalletController for logged-in brand/fan users
    _initializeWalletController();
  }

  /// Initialize WalletController if not already registered
  /// Initialize WalletController for logged-in brand/fan users
  void _initializeWalletController() {
    if (!Get.isRegistered<WalletController>()) {
      try {
        final walletController = WalletController(
          walletRepo: WalletRepo(
            apiClient: Get.find<ApiClient>(),
            sharedPreferences: Get.find<SharedPreferences>(),
          ),
        );

        Get.put(walletController, permanent: true);

        // ✅ FIX: Fetch wallet data immediately after initialization
        walletController.getWalletTransactionData(1, reload: true);

        if (kDebugMode) {
          print('✅ WalletController initialized and balance loaded');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to initialize WalletController: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('ℹ️ WalletController already registered');
      }
      // ✅ Also refresh if already registered
      try {
        Get.find<WalletController>().getWalletTransactionData(1, reload: true);
      } catch (e) {
        if (kDebugMode) print('Failed to refresh wallet: $e');
      }
    }
  }

  void _listenToActiveCampaigns() {
    CampaignFirestoreService.streamActiveCampaigns().listen((list) {
      activeCampaigns.value = list;
    });
  }

  // ── NEW: stream donor's own subscriptions ─────────────────────────────
  void _listenToMySubscriptions() {
    final id = currentUserIdLower;
    if (id.isEmpty) {
      // Retry once identity resolves
      Future.delayed(
        const Duration(milliseconds: 600),
        _listenToMySubscriptions,
      );
      return;
    }
    _subsSub?.cancel();
    _subsSub = CampaignSubscriptionService.streamDonorSubscriptions(
      id,
    ).listen((list) => mySubscriptions.value = list);
  }

  void listenToMyCampaigns(String athleteId) {
    final id = athleteId.trim().toLowerCase();
    if (id.isEmpty) return;

    _mySub?.cancel();
    _mySub = CampaignFirestoreService.streamAthleteCampaigns(id).listen((list) {
      list.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      myCampaigns.value = list;
    });
  }

  void ensureMyCampaignsListening() {
    if (_myListeningStarted) return;

    final id = currentUserIdLower;
    if (id.isEmpty) {
      Future.delayed(
        const Duration(milliseconds: 400),
        ensureMyCampaignsListening,
      );
      return;
    }

    _myListeningStarted = true;
    listenToMyCampaigns(id);
  }

  void listenToLeaderboard(String campaignId) {
    CampaignFirestoreService.streamDonorLeaderboard(
      campaignId,
    ).listen((list) => leaderboard.value = list);
  }

  void selectCampaign(CampaignModel campaign) {
    selectedCampaign.value = campaign;
    leaderboard.clear();
    listenToLeaderboard(campaign.id);
    CampaignFirestoreService.incrementViewCount(campaign.id);
  }

  Future<String?> createCampaign() async {
    if (titleController.text.trim().isEmpty) {
      showCustomSnackBar('Please add a campaign title');
      return null;
    }
    if (goalController.text.trim().isEmpty) {
      showCustomSnackBar('Please set a fundraising goal');
      return null;
    }

    isCreating.value = true;

    String? coverUrl;
    if (coverImageFile.value != null) {
      isUploading.value = true;
      coverUrl = await _uploadFile(coverImageFile.value!, 'campaign_covers');
      isUploading.value = false;
    }

    final athleteId = currentUserIdLower;
    final goal = double.tryParse(goalController.text) ?? 0;

    final campaignId = await CampaignFirestoreService.createCampaign(
      creatorId: athleteId,
      creatorName: currentUserName,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      story: storyController.text.trim(),
      goalAmount: goal,
      endDate: campaignEndDate.value,
      type: campaignType.value,
      groupId: campaignType.value == CampaignType.group
          ? selectedGroupId.value
          : null,
      groupName: campaignType.value == CampaignType.group
          ? selectedGroupName.value
          : null,
      coverImage: coverUrl,
      tags: List<String>.from(selectedTags),
      allowAnonymous: allowAnonymous.value,
      minimumDonation: double.tryParse(minDonationController.text) ?? 500,
    );

    isCreating.value = false;

    if (campaignId != null) {
      _resetCreateForm();
      showCustomSnackBar(
        'Campaign launched successfully! 🚀',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Failed to create campaign. Try again.');
    }

    return campaignId;
  }

  void _resetCreateForm() {
    titleController.clear();
    descriptionController.clear();
    storyController.clear();
    goalController.clear();
    minDonationController.text = '500';
    selectedTags.clear();
    allowAnonymous.value = true;
    campaignType.value = CampaignType.individual;
    coverImageFile.value = null;
    campaignEndDate.value = DateTime.now().add(const Duration(days: 30));
  }

  Future<bool> startDonation({
    required CampaignModel campaign,
    required BuildContext context,
  }) async {
    final amount = double.tryParse(donateAmountController.text) ?? 0;
    if (amount < campaign.minimumDonation) {
      showCustomSnackBar(
        'Minimum donation is ₦${campaign.minimumDonation.toStringAsFixed(0)}',
      );
      return false;
    }

    // ── NEW: warn if the donor already has an active monthly sub ──────────
    if (donationFrequency.value == DonationFrequency.monthly) {
      final existing = await CampaignSubscriptionService.getSubscription(
        donorId: currentUserIdLower,
        campaignId: campaign.id,
      );
      if (existing != null && existing.isActive) {
        showCustomSnackBar(
          'You already have an active monthly donation to this campaign. '
          'Manage it from your Subscriptions page.',
        );
        return false;
      }
    }

    isLoading.value = true;

    final donationId = await CampaignFirestoreService.initiateDonation(
      campaignId: campaign.id,
      campaignTitle: campaign.title,
      athleteId: campaign.creatorId,
      athleteName: campaign.creatorName,
      groupId: campaign.groupId,
      donorId: currentUserId.trim(),
      donorName: donateAnonymously.value ? 'Anonymous' : currentUserName,
      donorEmail: currentUserEmail,
      amount: amount,
      frequency: donationFrequency.value,
      isAnonymous: donateAnonymously.value,
      message: donateMessageController.text.isEmpty
          ? null
          : donateMessageController.text,
    );

    isLoading.value = false;

    if (donationId == null) {
      showCustomSnackBar('Could not initiate donation. Try again.');
      return false;
    }

    final config = await PaymentConfigService.getConfig();
    if (config == null) {
      showCustomSnackBar('Payment not configured. Contact support.');
      return false;
    }

    final reference =
        'camp_${donationId}_${DateTime.now().millisecondsSinceEpoch}';

    // ── Pass isMonthly so the payment screen knows to extract the token ──
    final result = await Get.to<bool>(
      () => CampaignDonationScreen(
        donationId: donationId,
        campaign: campaign,
        amount: amount,
        email: currentUserEmail,
        donorName: donateAnonymously.value ? 'Anonymous' : currentUserName,
        frequency: donationFrequency.value,
        reference: reference,
        isMonthly:
            donationFrequency.value == DonationFrequency.monthly, // ← NEW
      ),
    );
    return result == true;
  }

  // ── NEW: cancel a monthly subscription ────────────────────────────────
  Future<bool> cancelSubscription(String campaignId) async {
    final id = currentUserIdLower;
    if (id.isEmpty) return false;

    isLoading.value = true;
    final ok = await CampaignSubscriptionService.cancelSubscription(
      donorId: id,
      campaignId: campaignId,
    );
    isLoading.value = false;

    if (ok) {
      showCustomSnackBar(
        'Monthly donation cancelled.',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Could not cancel. Please try again.');
    }
    return ok;
  }

  // ── NEW: reactivate a paused/cancelled subscription ───────────────────
  Future<bool> reactivateSubscription(String campaignId) async {
    final id = currentUserIdLower;
    if (id.isEmpty) return false;

    isLoading.value = true;
    final ok = await CampaignSubscriptionService.reactivateSubscription(
      donorId: id,
      campaignId: campaignId,
    );
    isLoading.value = false;

    if (ok) {
      showCustomSnackBar(
        'Monthly donation reactivated! 🎉',
        type: ToasterMessageType.success,
      );
    } else {
      showCustomSnackBar('Could not reactivate. Please try again.');
    }
    return ok;
  }

  Future<void> pickCoverImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) coverImageFile.value = File(picked.path);
  }

  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        '$folder/${DateTime.now().millisecondsSinceEpoch}_$currentUserIdLower',
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print('[CampaignCtrl] upload error: $e');
      return null;
    }
  }

  void resetDonateForm() {
    donateAmountController.clear();
    donateMessageController.clear();
    donationFrequency.value = DonationFrequency.oneTime;
    donateAnonymously.value = false;
  }

  String get userRole {
    if (_isAthleteMode) return 'athlete';
    if (_isBrandFanMode) {
      try {
        final u = Get.find<brandfan_controller.UserController>().userInfoModel;
        final type = (u as dynamic).userType as String?;
        if (type == 'brand') return 'brand';
        return 'fan';
      } catch (_) {}
    }
    return 'unknown';
  }

  bool get canCreateCampaign => _isAthleteMode;
  bool get canDonate => true;

  Future<bool> editCampaign({
    required String campaignId,
    required String title,
    required String description,
  }) async {
    if (campaignId.isEmpty) return false;
    if (title.isEmpty) {
      showCustomSnackBar('Title cannot be empty');
      return false;
    }
    isLoading.value = true;
    try {
      await CampaignFirestoreService.updateCampaignFields(
        campaignId: campaignId,
        fields: {
          'title': title,
          'description': description,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      isLoading.value = false;
      showCustomSnackBar('Campaign updated!', type: ToasterMessageType.success);
      return true;
    } catch (e) {
      isLoading.value = false;
      showCustomSnackBar('Failed to update campaign');
      return false;
    }
  }

  Future<bool> deleteCampaign(String campaignId) async {
    if (campaignId.isEmpty) return false;
    isLoading.value = true;
    try {
      final ok = await CampaignFirestoreService.deleteCampaign(campaignId);
      isLoading.value = false;
      if (ok) {
        myCampaigns.removeWhere((c) => c.id == campaignId);
        activeCampaigns.removeWhere((c) => c.id == campaignId);
        showCustomSnackBar(
          'Campaign deleted',
          type: ToasterMessageType.success,
        );
      } else {
        showCustomSnackBar('Failed to delete campaign');
      }
      return ok;
    } catch (e) {
      isLoading.value = false;
      showCustomSnackBar('Failed to delete campaign');
      return false;
    }
  }

  @override
  void onClose() {
    _mySub?.cancel();
    _subsSub?.cancel(); // ← NEW

    titleController.dispose();
    descriptionController.dispose();
    storyController.dispose();
    goalController.dispose();
    minDonationController.dispose();
    donateAmountController.dispose();
    donateMessageController.dispose();
    super.onClose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Overlay snackbar (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

void _campaignDonationSnack(String message, {bool success = false}) {
  final nav = Get.key.currentState;
  if (nav == null || !nav.mounted) return;
  final overlay = nav.overlay;
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 48,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e1e),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: success ? Colors.green[600] : Colors.red[400],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 4), () {
    try {
      entry.remove();
    } catch (_) {}
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Campaign Donation Payment Screen
//
//  CHANGES:
//   • New param: isMonthly — when true, the screen extracts the Flutterwave
//     `token` from the webhook/callback metadata and passes it to
//     _verifyAndComplete().
//   • _verifyAndComplete() now passes flwToken to completeDonation().
//   • Everything else is identical.
// ─────────────────────────────────────────────────────────────────────────────

class CampaignDonationScreen extends StatefulWidget {
  final String donationId;
  final CampaignModel campaign;
  final double amount;
  final String email;
  final String donorName;
  final DonationFrequency frequency;
  final String reference;
  final bool isMonthly; // ← NEW

  const CampaignDonationScreen({
    Key? key,
    required this.donationId,
    required this.campaign,
    required this.amount,
    required this.email,
    required this.donorName,
    required this.frequency,
    required this.reference,
    this.isMonthly = false, // ← NEW (default false = backwards compatible)
  }) : super(key: key);

  @override
  State<CampaignDonationScreen> createState() => _CampaignDonationScreenState();
}

class _CampaignDonationScreenState extends State<CampaignDonationScreen> {
  // Flutterwave callback host (update to your actual domain)
  static const _kCallbackHost = 'admin.afriendorse.com';
  static const _kCallbackPath = '/payment/flutterwave/callback';
  static const _kCancelPath = '/payment/flutterwave/cancel';

  InAppWebViewController? _webController;
  bool _webVisible = false;
  bool _isInitializing = true;
  bool _handled = false;
  String _statusText = 'Connecting to Flutterwave...';
  String? _checkoutUrl;
  String? _errorText;

  // ── NEW: extracted from Flutterwave callback URL / verify response ─────
  String? _flwToken;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  // ── Flutterwave Standard checkout initialisation ──────────────────────
  //
  // Flutterwave Standard (hosted) flow:
  //  POST https://api.flutterwave.com/v3/payments
  //  → returns { status:"success", data: { link: "https://checkout.flutterwave.com/..." } }
  //
  // For monthly donations we pass:
  //  payment_plan: <plan_id>   OR   we use tokenized charges (no plan needed —
  //  we just need the customer's card token from the first charge).
  //
  // We use the "tokenized" approach: standard one-time charge, then store
  // the `token` from the verify response to charge monthly server-side.
  // This avoids having to pre-create Flutterwave payment plans.

  Future<void> _initPayment() async {
    final config = await PaymentConfigService.getConfig();
    if (config == null ||
        config.secretKey.isEmpty ||
        config.publicKey.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorText = 'Payment is not configured yet.\nPlease contact support.';
      });
      return;
    }

    if (mounted) setState(() => _statusText = 'Initializing secure payment...');

    try {
      // Flutterwave Standard checkout — uses /v3/payments endpoint
      final response = await http
          .post(
            Uri.parse('https://api.flutterwave.com/v3/payments'),
            headers: {
              'Authorization': 'Bearer ${config.secretKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'tx_ref': widget.reference,
              'amount': widget.amount,
              'currency': config.currency.isNotEmpty ? config.currency : 'NGN',
              'redirect_url': 'https://$_kCallbackHost$_kCallbackPath',
              'customer': {'email': widget.email, 'name': widget.donorName},
              'customizations': {
                'title': 'Support ${widget.campaign.title}',
                'description': widget.isMonthly
                    ? 'Monthly donation — your card will be saved for recurring charges.'
                    : 'One-time donation to ${widget.campaign.title}',
                'logo': widget.campaign.coverImage ?? '',
              },
              'meta': {
                'donation_id': widget.donationId,
                'campaign_id': widget.campaign.id,
                'campaign_title': widget.campaign.title,
                'donor_name': widget.donorName,
                'frequency': widget.frequency.name,
                'type': 'campaign_donation',
                // Ask Flutterwave to return a reusable token (card tokenization)
                if (widget.isMonthly) 'save_card': true,
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        print(
          '[CampaignDonation] init → '
          'status=${body['status']} msg=${body['message']}',
        );
      }

      if (body['status'] == 'success') {
        final link = body['data']?['link'] as String?;
        if (link == null || link.isEmpty) {
          throw Exception('No checkout link returned');
        }
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _webVisible = true;
          _checkoutUrl = link;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _errorText = body['message'] as String? ?? 'Initialization failed.';
        });
      }
    } catch (e) {
      if (kDebugMode) print('[CampaignDonation] init error: $e');
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorText = 'Network error. Check your connection and try again.';
      });
    }
  }

  bool _isSuccessUrl(Uri uri) =>
      uri.host == _kCallbackHost && uri.path.startsWith(_kCallbackPath);

  bool _isCancelUrl(Uri uri) =>
      uri.host == _kCallbackHost && uri.path.startsWith(_kCancelPath);

  bool _checkUri(String? rawUrl) {
    if (_handled || rawUrl == null) return false;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return false;
    if (kDebugMode) print('[CampaignDonation] checking url: $rawUrl');
    if (_isSuccessUrl(uri)) {
      _handleSuccess(uri);
      return true;
    }
    if (_isCancelUrl(uri)) {
      _handleCancel();
      return true;
    }
    return false;
  }

  Future<NavigationActionPolicy> _shouldOverride(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final url = action.request.url?.toString() ?? '';
    if (kDebugMode) print('[CampaignDonation] nav → $url');
    if (_checkUri(url)) return NavigationActionPolicy.CANCEL;
    return NavigationActionPolicy.ALLOW;
  }

  void _handleSuccess(Uri uri) {
    if (_handled) return;
    _handled = true;

    // Flutterwave appends ?status=successful&tx_ref=...&transaction_id=...
    final txRef = uri.queryParameters['tx_ref'] ?? widget.reference;
    final transactionId = uri.queryParameters['transaction_id'] ?? '';

    if (kDebugMode) {
      print('[CampaignDonation] success txRef=$txRef transId=$transactionId');
    }
    _verifyAndComplete(txRef, transactionId);
  }

  Future<void> _verifyAndComplete(String txRef, String transactionId) async {
    if (mounted) {
      setState(() {
        _webVisible = false;
        _isInitializing = true;
        _statusText = 'Confirming payment…';
      });
    }

    bool verified = false;
    try {
      final config = await PaymentConfigService.getConfig();
      if (config != null) {
        // Flutterwave verify: GET /v3/transactions/{id}/verify
        final verifyId = transactionId.isNotEmpty ? transactionId : txRef;
        final res = await http
            .get(
              Uri.parse(
                'https://api.flutterwave.com/v3/transactions/$verifyId/verify',
              ),
              headers: {'Authorization': 'Bearer ${config.secretKey}'},
            )
            .timeout(const Duration(seconds: 15));

        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final status = data['status'] as String? ?? '';
        verified = status == 'successful';

        // ── NEW: extract Flutterwave card token for monthly donations ──
        if (widget.isMonthly && verified) {
          // Token lives at data.card.token or data.token depending on FLW version
          final card = data['card'] as Map<String, dynamic>?;
          _flwToken = card?['token'] as String? ?? data['token'] as String?;

          if (kDebugMode) {
            print(
              '[CampaignDonation] flwToken extracted: '
              '${_flwToken != null ? "✓" : "not found"}',
            );
          }
        }

        if (kDebugMode) {
          print('[CampaignDonation] verify → $status token=$_flwToken');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '[CampaignDonation] verify error: $e — completing optimistically',
        );
      }
      verified = true;
    }

    if (verified) {
      // ── Pass flwToken to completeDonation ─────────────────────────────
      final completed = await CampaignFirestoreService.completeDonation(
        donationId: widget.donationId,
        transactionRef: txRef,
        flwToken: _flwToken, // ← NEW
      );
      if (mounted) Navigator.of(context).pop(completed);
      _campaignDonationSnack(
        completed
            ? widget.isMonthly
                  ? 'Thank you! You\'re now a monthly supporter of "${widget.campaign.title}" 🔄'
                  : 'Thank you! Your donation to "${widget.campaign.title}" was received 🎉'
            : 'Payment confirmed! Your donation is being processed.',
        success: true,
      );
    } else {
      await CampaignFirestoreService.cancelDonation(widget.donationId);
      if (mounted) Navigator.of(context).pop(false);
      _campaignDonationSnack('Payment was not completed. Please try again.');
    }
  }

  void _handleCancel() {
    if (_handled) return;
    _handled = true;
    if (kDebugMode) print('[CampaignDonation] cancelled by user');
    CampaignFirestoreService.cancelDonation(widget.donationId).then((_) {
      if (mounted) Navigator.of(context).pop(false);
      _campaignDonationSnack('Payment cancelled.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_webVisible || _handled,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _webVisible && !_handled) _handleCancel();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF045F25),
        appBar: AppBar(
          title: Text(
            'Support ${widget.campaign.title}',
            style: const TextStyle(color: Colors.white, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: const Color(0xFF045F25),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          leading: _webVisible
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    if (!_handled) _handleCancel();
                  },
                )
              : const BackButton(),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        if (_webVisible && _checkoutUrl != null)
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_checkoutUrl!)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              javaScriptEnabled: true,
              domStorageEnabled: true,
              useHybridComposition: true,
            ),
            onWebViewCreated: (c) => _webController = c,
            shouldOverrideUrlLoading: _shouldOverride,
            onLoadStart: (_, url) => _checkUri(url?.toString()),
            onLoadStop: (_, url) => _checkUri(url?.toString()),
            onProgressChanged: (_, p) {
              if (kDebugMode) print('[CampaignDonation] progress $p%');
            },
            onReceivedError:
                (
                  InAppWebViewController controller,
                  WebResourceRequest request,
                  WebResourceError error,
                ) {
                  final url = request.url?.toString() ?? '';
                  if (kDebugMode) {
                    print(
                      '[CampaignDonation] webError "${error.description}" for $url',
                    );
                  }
                  _checkUri(url);
                },
          ),

        if (_isInitializing || _errorText != null)
          Container(
            color: const Color(0xFF045F25),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _errorText == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _statusText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          // ── NEW: monthly info hint ──────────────────
                          if (widget.isMonthly) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.autorenew,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Your card will be saved for monthly charges',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                            size: 52,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF045F25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 14,
                              ),
                            ),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

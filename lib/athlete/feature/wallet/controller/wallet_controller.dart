/*
import 'dart:async';
import 'package:afriendorse/athlete/feature/booking_requests/controller/booking_request_controller.dart';
import 'package:afriendorse/athlete/helper/date_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/wallet/model/wallet_transaction_model.dart';
import 'package:afriendorse/athlete/feature/wallet/repository/wallet_firestore_service.dart';
import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart';
import 'package:afriendorse/athlete/feature/transaction/controller/transaction_controller.dart';

enum WalletFilter { all, deals, donations, withdrawals }

class WalletController extends GetxController {
  // ─── Reactive state ──────────────────────────
  final RxList<WalletTransactionModel> transactions =
      <WalletTransactionModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSyncing = false.obs;
  final Rx<WalletFilter> activeFilter = WalletFilter.all.obs;

  StreamSubscription<List<WalletTransactionModel>>? _txSubscription;

  // ─── Derived ─────────────────────────────────

  String get athleteId {
    try {
      return Get.find<UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.owner
              ?.email ??
          '';
    } catch (_) {
      return '';
    }
  }

  double get availableBalance {
    try {
      return double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.accountReceivable ??
                '0',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  double get totalEarned {
    try {
      final withdrawn =
          double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.totalWithdrawn ??
                '0',
          ) ??
          0;
      final received =
          double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.receivedBalance ??
                '0',
          ) ??
          0;
      return withdrawn + received;
    } catch (_) {
      return 0;
    }
  }

  double get pendingBalance {
    try {
      return double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.balancePending ??
                '0',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  List<WalletTransactionModel> get filteredTransactions {
    switch (activeFilter.value) {
      case WalletFilter.all:
        return transactions;
      case WalletFilter.deals:
        return transactions
            .where((t) => t.type == WalletTransactionType.dealPayment)
            .toList();
      case WalletFilter.donations:
        return transactions
            .where(
              (t) =>
                  t.type == WalletTransactionType.groupDonation ||
                  t.type == WalletTransactionType.individualDonation,
            )
            .toList();
      case WalletFilter.withdrawals:
        return transactions
            .where((t) => t.type == WalletTransactionType.withdrawal)
            .toList();
    }
  }

  // ─── Lifecycle ───────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initWallet();
  }

  Future<void> _initWallet() async {
    if (athleteId.isEmpty) {
      isLoading.value = false;
      return;
    }

    // 1. Subscribe to Firestore real-time stream immediately
    _subscribeToTransactions();

    // 2. Sync SQL data (deals + withdrawals) into Firestore in background
    _syncSqlDataToFirestore();

    // 3. Sync group donations from donations collection
    WalletFirestoreService.syncGroupDonationsForAthlete(athleteId: athleteId);
  }

  void _subscribeToTransactions() {
    _txSubscription?.cancel();
    _txSubscription = WalletFirestoreService.streamTransactions(athleteId)
        .listen(
          (txList) {
            transactions.value = txList;
            isLoading.value = false;
          },
          onError: (e) {
            if (kDebugMode) print('[WalletController] stream error: $e');
            isLoading.value = false;
          },
        );
  }

  Future<void> _syncSqlDataToFirestore() async {
    if (isSyncing.value) return;
    isSyncing.value = true;

    try {
      final List<WalletTransactionModel> toSync = [];

      // ── Deals (completed bookings) ────────────
      try {
        final bookingController = Get.find<BookingRequestController>();

        // Fetch completed bookings if not already loaded
        if (bookingController.bookingRequestList == null) {
          await bookingController.getBookingRequestList(
            'completed',
            1,
            reload: true,
            isFirst: true,
          );
        }

        final completedBookings =
            bookingController.bookingRequestList
                ?.where((b) => b.bookingStatus == 'completed' && b.isPaid == 1)
                .toList() ??
            [];

        for (final booking in completedBookings) {
          if (booking.id == null) continue;
          final createdAt = booking.createdAt != null
              ? DateConverter.isoUtcStringToLocalDate(booking.createdAt!)
              : DateTime.now();

          toSync.add(
            WalletTransactionModel.fromDeal(
              bookingId: booking.id!,
              readableId: booking.readableId ?? booking.id!,
              amount: booking.totalBookingAmount ?? 0,
              serviceName: booking.subCategory?.name ?? 'Brand Deal',
              createdAt: createdAt,
              paymentMethod: booking.paymentMethod,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) print('[WalletSync] deals error: $e');
      }

      // ── Withdrawals ───────────────────────────
      try {
        final txController = Get.find<TransactionController>();

        if (txController.transactionsList == null ||
            txController.transactionsList!.isEmpty) {
          await txController.getWithdrawRequestList(
            1,
            false,
            shouldUpdate: false,
          );
        }

        for (final wd in txController.transactionsList ?? []) {
          if (wd.id == null) continue;
          final createdAt = wd.createdAt != null
              ? DateConverter.isoUtcStringToLocalDate(wd.createdAt!)
              : DateTime.now();

          toSync.add(
            WalletTransactionModel.fromWithdrawal(
              withdrawalId: wd.id!,
              amount: double.tryParse(wd.amount ?? '0') ?? 0,
              requestStatus: wd.requestStatus ?? 'pending',
              isPaid: wd.isPaid ?? 0,
              createdAt: createdAt,
              providerNote: wd.providerNote,
              adminNote: wd.adminNote,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) print('[WalletSync] withdrawals error: $e');
      }

      // ── Batch sync ────────────────────────────
      if (toSync.isNotEmpty) {
        await WalletFirestoreService.syncBatch(
          athleteId: athleteId,
          transactions: toSync,
        );
      }
    } catch (e) {
      if (kDebugMode) print('[WalletSync] _syncSqlDataToFirestore error: $e');
    }

    isSyncing.value = false;
  }

  // ─── Public actions ──────────────────────────

  Future<void> refresh() async {
    isLoading.value = true;
    // Refresh SQL balance
    await Get.find<UserProfileController>().getProviderInfo(reload: true);
    // Re-sync SQL transactions
    await _syncSqlDataToFirestore();
    // Re-sync group donations
    await WalletFirestoreService.syncGroupDonationsForAthlete(
      athleteId: athleteId,
    );
    isLoading.value = false;
    update();
  }

  void setFilter(WalletFilter filter) {
    activeFilter.value = filter;
  }

  // ─── Cleanup ─────────────────────────────────

  @override
  void onClose() {
    _txSubscription?.cancel();
    super.onClose();
  }
}

*/

// lib/athlete/feature/wallet/controller/wallet_controller.dart

import 'dart:async';
import 'package:afriendorse/athlete/feature/auth/repository/athlete_firestore_sync_service.dart';
import 'package:afriendorse/athlete/feature/booking_requests/controller/booking_request_controller.dart';
import 'package:afriendorse/athlete/feature/wallet/widgets/athlete_wallet_overlay_service.dart';
import 'package:afriendorse/athlete/helper/date_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/feature/wallet/model/wallet_transaction_model.dart';
import 'package:afriendorse/athlete/feature/wallet/repository/wallet_firestore_service.dart';
import 'package:afriendorse/athlete/feature/profile/controller/user_controller.dart';
import 'package:afriendorse/athlete/feature/transaction/controller/transaction_controller.dart';

enum WalletFilter { all, deals, donations, withdrawals }

class WalletController extends GetxController {
  final RxList<WalletTransactionModel> transactions =
      <WalletTransactionModel>[].obs;
  final RxBool isLoading = true.obs; // only for initial stream load
  final RxBool isSyncing = false.obs;
  final Rx<WalletFilter> activeFilter = WalletFilter.all.obs;

  final RxDouble totalSpent = 0.0.obs;
  StreamSubscription<double>? _spentSub;

  final RxDouble donationOverlayBalance = 0.0.obs;
  final RxString mysqlAthleteId = ''.obs;

  StreamSubscription<List<WalletTransactionModel>>? _txSubscription;
  StreamSubscription<double>? _overlaySub;

  bool _started = false;

  String get athleteId {
    try {
      final email =
          Get.find<UserProfileController>()
              .providerModel
              ?.content
              ?.providerInfo
              ?.owner
              ?.email ??
          '';
      return email.trim().toLowerCase();
    } catch (_) {
      return '';
    }
  }

  double get availableBalance {
    try {
      return double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.accountReceivable ??
                '0',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  double get totalEarned {
    try {
      final withdrawn =
          double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.totalWithdrawn ??
                '0',
          ) ??
          0;
      final received =
          double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.receivedBalance ??
                '0',
          ) ??
          0;
      return withdrawn + received;
    } catch (_) {
      return 0;
    }
  }

  double get pendingBalance {
    try {
      return double.tryParse(
            Get.find<UserProfileController>()
                    .providerModel
                    ?.content
                    ?.providerInfo
                    ?.owner
                    ?.account
                    ?.balancePending ??
                '0',
          ) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  // Replace existing mergedAvailableBalance getter:
  double get mergedAvailableBalance =>
      availableBalance + donationOverlayBalance.value - totalSpent.value;

  double get mergedTotalEarned => totalEarned + donationOverlayBalance.value;

  List<WalletTransactionModel> get filteredTransactions {
    switch (activeFilter.value) {
      case WalletFilter.all:
        return transactions;
      case WalletFilter.deals:
        return transactions
            .where((t) => t.type == WalletTransactionType.dealPayment)
            .toList();
      case WalletFilter.donations:
        return transactions
            .where(
              (t) =>
                  t.type == WalletTransactionType.groupDonation ||
                  t.type == WalletTransactionType.individualDonation,
            )
            .toList();
      case WalletFilter.withdrawals:
        return transactions
            .where((t) => t.type == WalletTransactionType.withdrawal)
            .toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever<double>(donationOverlayBalance, (_) {
      // Only call update() if we're actually in athlete mode
      try {
        Get.find<UserProfileController>();
        update();
      } catch (_) {
        // brand/fan mode — skip
      }
    });

    ever<double>(totalSpent, (_) {
      try {
        Get.find<UserProfileController>();
        update();
      } catch (_) {}
    });
    _initWallet();
  }

  Future<void> _initWallet() async {
    final id = athleteId;

    if (id.isEmpty) {
      Future.delayed(const Duration(milliseconds: 400), _initWallet);
      return;
    }

    if (_started) return;
    _started = true;

    _subscribeToTransactions(id);

    // background sync (won't block UI)
    _syncSqlDataToFirestore();
    WalletFirestoreService.syncGroupDonationsForAthlete(athleteId: id);

    await _initSpendTracking(id);

    await _initDonationOverlay(id);
  }

  // Add new method:
  Future<void> _initSpendTracking(String athleteEmailLower) async {
    try {
      final athlete = await AthleteFirestoreSyncService.getAthleteByEmail(
        athleteEmailLower,
      );
      final mId = (athlete?['mysqlAthleteId'] ?? '').toString().trim();
      if (mId.isEmpty) return;

      _spentSub?.cancel();
      _spentSub = AthleteWalletOverlayService.watchTotalSpent(
        mId,
      ).listen((v) => totalSpent.value = v);
    } catch (e) {
      if (kDebugMode) print('[WalletController] spend tracking init error: $e');
    }
  }

  Future<void> _initDonationOverlay(String athleteEmailLower) async {
    try {
      final athlete = await AthleteFirestoreSyncService.getAthleteByEmail(
        athleteEmailLower,
      );

      mysqlAthleteId.value = (athlete?['mysqlAthleteId'] ?? '')
          .toString()
          .trim();

      if (mysqlAthleteId.value.isEmpty) return;

      _overlaySub?.cancel();
      _overlaySub = AthleteWalletOverlayService.watchDonationBalance(
        mysqlAthleteId.value,
      ).listen((v) => donationOverlayBalance.value = v);
    } catch (e) {
      if (kDebugMode) {
        print('[WalletController] donation overlay init error: $e');
      }
    }
  }

  void _subscribeToTransactions(String athleteEmailLower) {
    _txSubscription?.cancel();

    _txSubscription =
        WalletFirestoreService.streamTransactions(athleteEmailLower).listen(
          (txList) {
            transactions.value = txList;

            // IMPORTANT: stop shimmer once we get the first snapshot (even if empty)
            if (isLoading.value) isLoading.value = false;

            if (kDebugMode) {
              print('[WalletController] stream snapshot: ${txList.length} tx');
            }
          },
          onError: (e) {
            if (kDebugMode) print('[WalletController] stream error: $e');
            isLoading.value = false; // ensure shimmer stops on error too
          },
        );
  }

  Future<void> _syncSqlDataToFirestore() async {
    if (isSyncing.value) return;
    isSyncing.value = true;

    try {
      final id = athleteId;
      if (id.isEmpty) return;

      final List<WalletTransactionModel> toSync = [];

      // Deals
      try {
        final bookingController = Get.find<BookingRequestController>();

        if (bookingController.bookingRequestList == null) {
          await bookingController.getBookingRequestList(
            'completed',
            1,
            reload: true,
            isFirst: true,
          );
        }

        final completedBookings =
            bookingController.bookingRequestList
                ?.where((b) => b.bookingStatus == 'completed' && b.isPaid == 1)
                .toList() ??
            [];

        for (final booking in completedBookings) {
          if (booking.id == null) continue;
          final createdAt = booking.createdAt != null
              ? DateConverter.isoUtcStringToLocalDate(booking.createdAt!)
              : DateTime.now();

          toSync.add(
            WalletTransactionModel.fromDeal(
              bookingId: booking.id!,
              readableId: booking.readableId ?? booking.id!,
              amount: booking.totalBookingAmount ?? 0,
              serviceName: booking.subCategory?.name ?? 'Brand Deal',
              createdAt: createdAt,
              paymentMethod: booking.paymentMethod,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) print('[WalletSync] deals error: $e');
      }

      // Withdrawals
      try {
        final txController = Get.find<TransactionController>();

        await txController.getWithdrawRequestList(
          1,
          false,
          shouldUpdate: false,
        );

        for (final wd in txController.transactionsList ?? []) {
          if (wd.id == null) continue;
          final createdAt = wd.createdAt != null
              ? DateConverter.isoUtcStringToLocalDate(wd.createdAt!)
              : DateTime.now();

          toSync.add(
            WalletTransactionModel.fromWithdrawal(
              withdrawalId: wd.id!,
              amount: double.tryParse(wd.amount ?? '0') ?? 0,
              requestStatus: wd.requestStatus ?? 'pending',
              isPaid: wd.isPaid ?? 0,
              createdAt: createdAt,
              providerNote: wd.providerNote,
              adminNote: wd.adminNote,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) print('[WalletSync] withdrawals error: $e');
      }

      if (toSync.isNotEmpty) {
        await WalletFirestoreService.syncBatch(
          athleteId: id,
          transactions: toSync,
        );
      }
    } catch (e) {
      if (kDebugMode) print('[WalletSync] _syncSqlDataToFirestore error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> refresh() async {
    if (isSyncing.value) return;

    // Guard: this controller is athlete-only.
    // If UserProfileController isn't registered we're in brand/fan mode — skip.
    try {
      Get.find<UserProfileController>();
    } catch (_) {
      return; // not in athlete mode — safe to exit silently
    }

    isSyncing.value = true;
    try {
      await Get.find<UserProfileController>().getProviderInfo(reload: true);
      await _syncSqlDataToFirestore();

      final id = athleteId;
      if (id.isNotEmpty) {
        await WalletFirestoreService.syncGroupDonationsForAthlete(
          athleteId: id,
        );
        await _initDonationOverlay(id);
      }
    } finally {
      isSyncing.value = false;
    }
  }

  void setFilter(WalletFilter filter) => activeFilter.value = filter;

  @override
  void onClose() {
    _txSubscription?.cancel();
    _overlaySub?.cancel();
    _spentSub?.cancel();
    super.onClose();
  }
}

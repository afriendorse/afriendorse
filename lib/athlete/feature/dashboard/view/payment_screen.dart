import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/dashboard/widgets/payment_failed_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

// Brand/Fan controller — imported with alias to avoid name clash
import 'package:afriendorse/feature/profile/controller/user_controller.dart'
    as brandfan_controller;

class PaymentScreen extends StatefulWidget {
  final String url;
  final String fromPage;
  const PaymentScreen({super.key, required this.url, required this.fromPage});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  String? selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;

  // ─── Role helpers ─────────────────────────────────────────────────────────

  /// True only when the athlete UserProfileController is registered in GetX
  bool get _isAthleteSession {
    try {
      Get.find<UserProfileController>();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// True only when the brand/fan UserController is registered in GetX
  bool get _isBrandFanSession {
    try {
      Get.find<brandfan_controller.UserController>();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.url;
    _initData();

    // Only athletes have trialWidgetShow — skip for brand/fan
    if (_isAthleteSession) {
      _loadTrialWidgetShow();
    }
  }

  Future<void> _loadTrialWidgetShow() async {
    try {
      await Get.find<UserProfileController>().trialWidgetShow(
        route: RouteHelper.businessPlan,
      );
    } catch (_) {
      // Controller was disposed between initState and the await — safe to ignore
    }
  }

  void _initData() async {
    browser = MyInAppBrowser(
      fromPage: widget.fromPage,
      mainUrl: widget.url,
      isAthleteSession: _isAthleteSession,
    );

    if (GetPlatform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);

      bool swAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
      );
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
      );

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController =
            ServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(
          ServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              if (kDebugMode) print(request);
              return null;
            },
          ),
        );
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl!)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true,
        ),
        browserSettings: InAppBrowserSettings(
          hideUrlBar: true,
          hideToolbarTop: GetPlatform.isAndroid,
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Only call trialWidgetShow for athletes — brand/fan has no such method
        if (_isAthleteSession) {
          try {
            Get.find<UserProfileController>().trialWidgetShow(route: '');
          } catch (_) {}
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: CustomAppBar(title: 'payment'.tr),
        body: Center(
          child: Stack(
            children: [
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── In-App Browser ──────────────────────────────────────────────────────────

class MyInAppBrowser extends InAppBrowser {
  final String fromPage;
  final String mainUrl;
  final bool isAthleteSession;

  MyInAppBrowser({
    required this.fromPage,
    required this.mainUrl,
    this.isAthleteSession = false,
  });

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) print("\n\nStarted: $url\n\n");
    _pageRedirect(url.toString());
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) print("\n\nStopped: $url\n\n");
    _pageRedirect(url.toString());
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) print("Can't load [$url] Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) pullToRefreshController?.endRefreshing();
    if (kDebugMode) print("Progress: $progress");
  }

  @override
  void onExit() {
    if (_canRedirect) {
      final ctx = Get.context;
      if (ctx != null) {
        showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const PopScope(
              canPop: true,
              child: AlertDialog(
                contentPadding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                content: PaymentFailedDialog(),
              ),
            );
          },
        );
      }
    }
    if (kDebugMode) print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    navigationAction,
  ) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {}

  @override
  void onConsoleMessage(consoleMessage) {}

  void _pageRedirect(String url) async {
    if (!_canRedirect) return;

    final bool isSuccess =
        url.contains('success') && url.contains(AppConstants.baseUrl);
    final bool isFailed =
        url.contains('fail') && url.contains(AppConstants.baseUrl);
    final bool isCancel =
        url.contains('cancel') && url.contains(AppConstants.baseUrl);

    if (isSuccess || isFailed || isCancel) {
      _canRedirect = false;
      close();
    }

    if (isSuccess) {
      if (fromPage == 'signUp') {
        // Athlete sign-up payment flow — unchanged
        Get.offAllNamed(RouteHelper.signIn);
        showCustomBottomSheet(
          child: const WelcomeBottomSheet(fromSignup: true),
        );
      } else if (fromPage == 'group-donation') {
        // Brand/Fan or athlete group donation — just pop back
        // GroupPaymentController._checkDonationStatus handles the confirmation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.context != null) Get.back();
        });
      } else {
        // Standard athlete payment (subscription, etc.)
        // Show snackbar BEFORE Get.back() so context is still mounted
        if (Get.context != null) {
          showCustomSnackBar(
            'paid_successfully'.tr,
            type: ToasterMessageType.success,
          );
        }
        Future.delayed(const Duration(seconds: 1), () {
          if (isAthleteSession) {
            try {
              Get.find<UserProfileController>().getProviderInfo(reload: true);
            } catch (_) {}
          }
          if (Get.context != null) Get.back();
        });
      }
    } else if (isFailed || isCancel) {
      if (Get.context != null) Get.back();

      if (fromPage == 'signUp') {
        Get.offAllNamed(RouteHelper.signIn);
        showCustomBottomSheet(
          child: const WelcomeBottomSheet(
            fromSignup: true,
            isFromTransactionFailed: true,
          ),
        );
      } else if (fromPage == 'group-donation') {
        // Let GroupPaymentController handle the failure snackbar
        // Nothing extra needed here
      } else {
        if (Get.context != null) {
          showCustomSnackBar('transaction_failed'.tr);
        }
      }
    }
  }
}

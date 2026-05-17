import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class CustomPopWidget extends StatefulWidget {
  final Widget child;
  final Function()? onPopInvoked;
  final bool _canShowCloseDialog;
  final bool? isNavigationOnOnPop;

  const CustomPopWidget({
    super.key,
    required this.child,
    this.onPopInvoked,
    bool isExit = false,
    this.isNavigationOnOnPop,
  }) : _canShowCloseDialog = isExit;

  @override
  State<CustomPopWidget> createState() => _CustomPopWidgetState();
}

class _CustomPopWidgetState extends State<CustomPopWidget> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: ResponsiveHelper.isDesktop(context),
      onPopInvokedWithResult: (didPop, result) {
        // ✅ Fix: If onPopInvoked is provided and will handle navigation,
        // defer it to avoid _debugLocked error
        if (widget.onPopInvoked != null) {
          if (widget.isNavigationOnOnPop ?? false) {
            // Defer the navigation callback to next frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onPopInvoked!();
            });
            return; // Stop here, don't execute other logic
          } else {
            // If no navigation, safe to call immediately
            widget.onPopInvoked!();
          }
        }

        if (didPop) {
          return;
        }

        if (_canShowCloseDialog()) {
          if (_canExit) {
            if (!GetPlatform.isWeb) {
              SystemNavigator.pop();
            }
          } else {
            customSnackBar(
              'back_press_again_to_exit'.tr,
              type: ToasterMessageType.info,
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else if (_canGoToInitialRoute()) {
          _goToInitialRoute(context);
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: widget.child,
    );
  }

  void _goToInitialRoute(BuildContext context) {
    // ✅ Fix: Also defer this navigation to avoid potential issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    });
  }

  bool _canShowCloseDialog() =>
      !Navigator.canPop(context) && widget._canShowCloseDialog;
  bool _canGoToInitialRoute() =>
      !Navigator.canPop(context) && !widget._canShowCloseDialog;
}

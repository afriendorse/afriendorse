/* import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class ExistingAccountBottomSheet extends StatefulWidget {
  final UserInfoModel userInfoModel;
  final String socialLoginMedium;
  final String? redirectUrl;

  const ExistingAccountBottomSheet({
    super.key,
    required this.userInfoModel,
    required this.socialLoginMedium,
    this.redirectUrl,
  });

  @override
  State<ExistingAccountBottomSheet> createState() =>
      _ExistingAccountBottomSheetState();
}

class _ExistingAccountBottomSheetState
    extends State<ExistingAccountBottomSheet> {
  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        ),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: pointerInterceptor(),
      );
    }
    return pointerInterceptor();
  }

  Padding pointerInterceptor() {
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveHelper.isWeb() ? 0 : Dimensions.cartDialogPadding,
      ),
      child: PointerInterceptor(
        child: GetBuilder<AuthController>(
          builder: (authProvider) {
            return Container(
              width: ResponsiveHelper.isDesktop(context)
                  ? 550
                  : Dimensions.webMaxWidth,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                borderRadius: ResponsiveHelper.isDesktop(context)
                    ? const BorderRadius.all(Radius.circular(20))
                    : const BorderRadius.vertical(top: Radius.circular(20)),
                color: Get.isDarkMode
                    ? Theme.of(context).cardColor
                    : Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  ResponsiveHelper.isDesktop(context)
                      ? const SizedBox()
                      : Container(
                          height: 5,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.50),
                          ),
                        ),

                  const SizedBox(height: Dimensions.paddingSizeLarge * 1.5),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CustomImage(
                      image: widget.userInfoModel.imageFullPath ?? "",
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    "${widget.userInfoModel.fName} ${widget.userInfoModel.lName}",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Text(
                    'is_it_you'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context)
                          ? size.width * 0.03
                          : size.height * 0.02,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'it_looks_like_the_email'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor,
                            ),
                          ),

                          TextSpan(
                            text:
                                ' ${StringParser.obfuscateMiddle(widget.userInfoModel.email ?? "")} ',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.5),
                              height: 2,
                            ),
                          ),

                          TextSpan(
                            text: 'already_used_existing_account'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? size.height * 0.03
                        : size.height * 0.05,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: CustomButton(
                            backgroundColor: Theme.of(context).hintColor,
                            isLoading: authProvider.isLoading,
                            buttonText: 'no'.tr,
                            onPressed: () {
                              Navigator.pop(context);
                              authProvider.existingAccountCheck(
                                email: widget.userInfoModel.email!,
                                userResponse: 0,
                                medium: widget.socialLoginMedium,
                                redirectUrl: widget.redirectUrl,
                              );
                            },
                          ),
                        ),

                        Expanded(child: Container()),

                        Expanded(
                          flex: 5,
                          child: CustomButton(
                            isLoading: authProvider.isLoading,
                            buttonText: 'yes_its_me'.tr,
                            onPressed: () {
                              Navigator.pop(context);

                              authProvider.existingAccountCheck(
                                email: widget.userInfoModel.email!,
                                userResponse: 1,
                                medium: widget.socialLoginMedium,
                                redirectUrl: widget.redirectUrl,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? size.height * 0.04
                        : Dimensions.paddingSizeLarge,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
*/

import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class ExistingAccountBottomSheet extends StatefulWidget {
  final UserInfoModel userInfoModel;
  final String socialLoginMedium;
  final String? redirectUrl;

  const ExistingAccountBottomSheet({
    super.key,
    required this.userInfoModel,
    required this.socialLoginMedium,
    this.redirectUrl,
  });

  @override
  State<ExistingAccountBottomSheet> createState() =>
      _ExistingAccountBottomSheetState();
}

class _ExistingAccountBottomSheetState extends State<ExistingAccountBottomSheet>
    with SingleTickerProviderStateMixin {
  // Brand colors
  static const Color primaryGreen = Color(0xFF045F25);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF033D18);

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(30),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: pointerInterceptor(),
        ),
      );
    }
    return pointerInterceptor();
  }

  Padding pointerInterceptor() {
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveHelper.isWeb() ? 0 : Dimensions.cartDialogPadding,
      ),
      child: PointerInterceptor(
        child: GetBuilder<AuthController>(
          builder: (authProvider) {
            return Container(
              width: ResponsiveHelper.isDesktop(context)
                  ? 500
                  : Dimensions.webMaxWidth,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar for mobile
                  if (!ResponsiveHelper.isDesktop(context))
                    Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: pureBlack.withOpacity(0.1),
                      ),
                    ),

                  // Profile Image with ring
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryGreen, width: 3),
                    ),
                    child: ClipOval(
                      child: CustomImage(
                        image: widget.userInfoModel.imageFullPath ?? "",
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    "${widget.userInfoModel.fName} ${widget.userInfoModel.lName}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: pureBlack,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Question Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'is_it_you'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description Text
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context)
                          ? size.width * 0.02
                          : 0,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: pureBlack,
                        ),
                        children: [
                          TextSpan(
                            text: 'it_looks_like_the_email'.tr,
                            style: TextStyle(color: pureBlack.withOpacity(0.6)),
                          ),
                          TextSpan(
                            text:
                                ' ${StringParser.obfuscateMiddle(widget.userInfoModel.email ?? "")} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                          TextSpan(
                            text: 'already_used_existing_account'.tr,
                            style: TextStyle(color: pureBlack.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          text: 'no_create_new'.tr,
                          onPressed: () {
                            Navigator.pop(context);
                            authProvider.existingAccountCheck(
                              email: widget.userInfoModel.email!,
                              userResponse: 0,
                              medium: widget.socialLoginMedium,
                              redirectUrl: widget.redirectUrl,
                            );
                          },
                          isLoading: authProvider.isLoading,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPrimaryButton(
                          text: 'yes_its_me'.tr,
                          onPressed: () {
                            Navigator.pop(context);
                            authProvider.existingAccountCheck(
                              email: widget.userInfoModel.email!,
                              userResponse: 1,
                              medium: widget.socialLoginMedium,
                              redirectUrl: widget.redirectUrl,
                            );
                          },
                          isLoading: authProvider.isLoading,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [primaryGreen, darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: pureWhite,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: pureWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: pureWhite,
        border: Border.all(color: primaryGreen.withOpacity(0.3), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

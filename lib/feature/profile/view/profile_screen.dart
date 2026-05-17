import 'package:afriendorse/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:afriendorse/feature/profile/model/profile_cart_item_model.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/common/widgets/address_selection_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthController _auth = Get.find<AuthController>();
  late final UserController _userController = Get.find<UserController>();
  late final LocationController _locationController =
      Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    if (_auth.isLoggedIn()) {
      _userController.getUserInfo(reload: false);
    }
  }

  bool get _hasAddress => _locationController.getUserAddress() != null;

  void _handleSignOut() {
    if (!_auth.isLoggedIn()) {
      Get.toNamed(RouteHelper.getSignInRoute());
      return;
    }
    Get.dialog(
      ConfirmationDialog(
        icon: Images.logoutIcon,
        title: 'are_you_sure_to_logout'.tr,
        // description: 'if_you_logged_out_your_cart_will_be_removed'.tr,
        yesButtonColor: Theme.of(Get.context!).colorScheme.primary,
        onYesPressed: () async {
          _auth.clearSharedData();
          _auth.googleLogout();
          // _auth.signOutWithFacebook();
          Get.offAllNamed(RouteHelper.getInitialRoute());
        },
      ),
      useSafeArea: false,
    );
  }

  void _handleDeleteAccount(UserController userController) {
    Get.dialog(
      ConfirmationDialog(
        icon: Images.deleteProfile,
        title: 'are_you_sure_to_delete_your_account'.tr,
        description: 'it_will_remove_your_all_information'.tr,
        yesButtonText: 'delete',
        noButtonText: 'cancel',
        onYesPressed: () => userController.removeUser(),
      ),
      useSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        // Set scaffold bg to primary so the area behind the
        // appbar and hero is one seamless colour block
        backgroundColor: Theme.of(context).primaryColor,
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer: ResponsiveHelper.isDesktop(context)
            ? const MenuDrawer()
            : null,
        appBar: CustomAppBar(
          title: 'profile'.tr,
          centerTitle: true,
          bgColor: Theme.of(context).primaryColor,
          isBackButtonExist: true,
          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(RouteHelper.getMainRoute('home'));
            }
          },
        ),
        body: GetBuilder<UserController>(
          builder: (userController) {
            if (userController.userInfoModel == null && _auth.isLoggedIn()) {
              return const Center(child: CircularProgressIndicator());
            }
            return FooterBaseView(
              child: WebShadowWrap(
                // Stack fills the entire body area:
                // - Bottom layer: surface colour covering the lower half
                // - Top layer: the scrollable content column
                child: Stack(
                  children: [
                    // Surface colour painted over the bottom half so
                    // it always fills to the bottom regardless of content
                    Positioned.fill(
                      child: Column(
                        children: [
                          // Top half stays primary (hero colour)
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          // Bottom half is surface — guarantees no
                          // primary colour bleed below the white card
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content sits on top
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Purple hero ──────────────────────────────
                          _buildHero(context, userController),

                          // ── White rounded card overlaps hero ─────────
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            transform: Matrix4.translationValues(0, -20, 0),
                            padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeLarge,
                              // Extra bottom padding compensates for
                              // the -20 translation so nothing is clipped
                              bottom: Dimensions.paddingSizeLarge + 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionLabel(label: 'general'.tr),
                                _MenuSection(
                                  children: [
                                    ProfileCardItem(
                                      title: 'notifications'.tr,
                                      leadingIcon: Images.notification,
                                      onTap: () => Get.toNamed(
                                        _hasAddress
                                            ? RouteHelper.getNotificationRoute()
                                            : RouteHelper.getPickMapRoute(
                                                RouteHelper.notification,
                                                true,
                                                'false',
                                                null,
                                                null,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                _SectionLabel(label: 'account'.tr),

                                if (_auth.isLoggedIn())
                                  _MenuSection(
                                    children: [
                                      ProfileCardItem(
                                        title: 'delete_account'.tr,
                                        leadingIcon: Images.accountDelete,
                                        onTap: () => _handleDeleteAccount(
                                          userController,
                                        ),
                                      ),
                                      ProfileCardItem(
                                        title: 'logout'.tr,
                                        leadingIcon: Images.logout,
                                        onTap: _handleSignOut,
                                      ),
                                    ],
                                  ),

                                if (!_auth.isLoggedIn())
                                  _MenuSection(
                                    children: [
                                      ProfileCardItem(
                                        title: 'sign_in'.tr,
                                        leadingIcon: Images.logout,
                                        onTap: () => Get.toNamed(
                                          RouteHelper.getSignInRoute(
                                            redirectUrl: RouteHelper.profile,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 300),

                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, UserController userController) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.only(
        top: Dimensions.paddingSizeSmall,
        bottom: 40,
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
      ),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Avatar
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(150)),
                  child: CustomImage(
                    width: 130,
                    height: 130,
                    image: userController.userInfoModel?.imageFullPath ?? '',
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Name or guest label
                if (!_auth.isLoggedIn())
                  Text(
                    'guest_user'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                if (_auth.isLoggedIn() &&
                    userController.userInfoModel?.fName != null &&
                    userController.userInfoModel?.lName != null)
                  Text(
                    '${userController.userInfoModel!.fName!} '
                    '${userController.userInfoModel!.lName!}',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Colors.white,
                    ),
                  ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Bookings + since joined
                if (_auth.isLoggedIn())
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (userController.userInfoModel?.bookingsCount !=
                          null) ...[
                        _HeroStat(
                          value:
                              '${userController.userInfoModel!.bookingsCount}',
                          label: 'bookings'.tr,
                        ),
                        Container(
                          width: 0.5,
                          height: 32,
                          color: Colors.white.withOpacity(0.3),
                          margin: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                        ),
                      ],
                      _HeroStat(
                        value: Get.find<UserController>().createdAccountAgo.tr,
                        label: 'since_joined'.tr,
                        isTimeAgo: true,
                      ),
                    ],
                  )
                else
                  const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            ),
          ),

          // Edit button top right / left for RTL
          if (_auth.isLoggedIn())
            Positioned(
              right: Get.find<LocalizationController>().isLtr ? 0 : null,
              left: Get.find<LocalizationController>().isLtr ? null : 0,
              top: Dimensions.paddingSizeSmall,
              child: GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.getEditProfileRoute()),
                child: Row(
                  children: [
                    Text(
                      'edit'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: Dimensions.fontSizeExtraLarge,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Hero stat cell ───────────────────────────────────────────────────────────

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    this.isTimeAgo = false,
  });

  final String value;
  final String label;
  final bool isTimeAgo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: isTimeAgo
                  ? Dimensions.fontSizeDefault
                  : Dimensions.fontSizeExtraLarge,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeSmall,
      ),
      child: Text(
        label.toUpperCase(),
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          letterSpacing: 0.8,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

// ─── Menu section card ────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: Get.find<ThemeController>().darkTheme ? null : cardShadow,
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: Dimensions.paddingSizeDefault,
                endIndent: Dimensions.paddingSizeDefault,
                color: Theme.of(context).dividerColor.withOpacity(0.15),
              ),
          ],
        ],
      ),
    );
  }
}

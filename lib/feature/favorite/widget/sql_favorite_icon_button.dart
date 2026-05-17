import 'package:afriendorse/feature/favorite/controller/provider_favorite_state_controller.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class SqlFavoriteIconButton extends StatefulWidget {
  final String providerId; // mysqlAthleteId
  final GlobalKey<CustomShakingWidgetState>? signInShakeKey;

  const SqlFavoriteIconButton({
    super.key,
    required this.providerId,
    this.signInShakeKey,
  });

  @override
  State<SqlFavoriteIconButton> createState() => _SqlFavoriteIconButtonState();
}

class _SqlFavoriteIconButtonState extends State<SqlFavoriteIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bounce() {
    _controller.reverse().then((_) => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProviderFavoriteStateController>(
      builder: (favCtrl) {
        final isFav = favCtrl.isFavorite(widget.providerId);

        return Material(
          color: Colors.white.withOpacity(0.92),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              _bounce();

              if (!Get.find<AuthController>().isLoggedIn()) {
                widget.signInShakeKey?.currentState?.shake();

                customSnackBar(
                  type: ToasterMessageType.info,
                  "please_login_to_add_favorite_list".tr,
                  customWidget: ResponsiveHelper.isDesktop(context)
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info,
                              color: Colors.blueAccent,
                              size: 20,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Flexible(
                              child: Text(
                                "please_login_to_add_favorite_list".tr,
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeLarge),
                            InkWell(
                              onTap: () => Get.toNamed(
                                RouteHelper.getSignInRoute(
                                  redirectUrl: Get.currentRoute,
                                ),
                              ),
                              child: Text(
                                'sign_in'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                );
                return;
              }

              await favCtrl.toggleFavorite(widget.providerId);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ScaleTransition(
                scale: Tween(begin: 0.85, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                ),
                child: Image.asset(
                  isFav ? Images.favorite : Images.unFavorite,
                  width: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

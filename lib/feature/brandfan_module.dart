import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:afriendorse/helper/get_di.dart' as brand_di;

class BrandFanHome extends StatefulWidget {
  const BrandFanHome({super.key});

  @override
  State<BrandFanHome> createState() => _BrandFanHomeState();
}

class _BrandFanHomeState extends State<BrandFanHome> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await brand_di.init();
    _postInit();
    setState(() => _initialized = true);
  }

  void _postInit() {
    Get.find<SplashController>().initSharedData();
    Get.find<SplashController>().getCookiesData();
    Get.find<CartController>().getCartListFromServer();

    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
    }

    if (Get.find<SplashController>().getGuestId().isEmpty) {
      var uuid = const Uuid().v1();
      Get.find<SplashController>().setGuestId(uuid);
    }

    Get.find<SplashController>().getConfigData().then((success) async {
      if (Get.find<LocationController>().getUserAddress() != null) {
        AddressModel addressModel = Get.find<LocationController>()
            .getUserAddress()!;
        ZoneResponseModel responseModel = await Get.find<LocationController>()
            .getZone(
              addressModel.latitude.toString(),
              addressModel.longitude.toString(),
              false,
            );
        addressModel.availableServiceCountInZone =
            responseModel.totalServiceCount;
        Get.find<LocationController>().saveUserAddress(addressModel);
      }
      Get.find<AuthController>().updateToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                // Handle loading states
                if (splashController.configModel.content == null) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Brand/Fan Portal'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.offAllNamed('/select-portal'),
                    ),
                  ),
                  body: Navigator(
                    key: Get.nestedKey(1),
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        builder: (context) => GetMaterialApp(
                          title: AppConstants.appName,
                          debugShowCheckedModeBanner: false,
                          navigatorKey: Get.key,
                          theme: themeController.darkTheme ? dark : light,
                          locale: localizeController.locale,
                          translations: Messages(
                            languages: {},
                          ), // Use actual languages from di
                          initialRoute: RouteHelper.getSplashRoute(null, null),
                          getPages: RouteHelper.routes,
                          builder: (context, widget) => MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(textScaler: const TextScaler.linear(1)),
                            child: widget!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

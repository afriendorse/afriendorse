import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class PickMapScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialAddress;
  final Completer<GoogleMapController>? googleMapController;
  const PickMapScreen({
    super.key,
    this.initialPosition,
    this.initialAddress,
    this.googleMapController,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initialPosition =
        widget.initialPosition ??
        LatLng(
          Get.find<SplashController>()
                  .configModel
                  .content!
                  .defaultLocation!
                  .defaultLocation!
                  .lat ??
              23.777176,
          Get.find<SplashController>()
                  .configModel
                  .content!
                  .defaultLocation!
                  .defaultLocation!
                  .lat ??
              -90.399452,
        );

    if (kDebugMode) {
      print(_initialPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GetBuilder<LocationController>(
            builder: (locationController) {
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition!,
                      zoom: 16,
                    ),
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    onMapCreated: (GoogleMapController mapController) {
                      Future.delayed(const Duration(milliseconds: 600)).then((
                        value,
                      ) {
                        _mapController = mapController;
                        if (_initialPosition == null) {
                          Get.find<LocationController>().getCurrentLocation(
                            false,
                            mapController: mapController,
                          );
                        }
                      });
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    onCameraMove: (CameraPosition cameraPosition) {
                      _cameraPosition = cameraPosition;
                    },
                    onCameraMoveStarted: () {
                      locationController.disableButton();
                    },
                    onCameraIdle: () {
                      try {
                        Get.find<LocationController>().updatePosition(
                          _cameraPosition!,
                        );
                      } catch (e) {
                        if (kDebugMode) {
                          print('');
                        }
                      }
                    },
                  ),

                  Center(
                    child: !locationController.loading
                        ? Image.asset(Images.marker, height: 50, width: 50)
                        : const CircularProgressIndicator(),
                  ),

                  Positioned(
                    top: Dimensions.paddingSizeLarge,
                    left: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeSmall,
                    child: InkWell(
                      onTap: () => showCustomDialog(
                        child: LocationSearchDialog(
                          mapController: _mapController!,
                        ),
                        barrierDismissible: true,
                      ),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 25,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withValues(alpha: .6),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                            Expanded(
                              child: Text(
                                locationController.pickAddress.address != ""
                                    ? (locationController.pickAddress.address ??
                                          "")
                                    : widget.initialAddress ?? "",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Icon(
                              Icons.search,
                              size: 25,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 80,
                    right: Dimensions.paddingSizeSmall,
                    child: FloatingActionButton(
                      hoverColor: Colors.transparent,
                      mini: true,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      onPressed: () => _checkPermission(() {
                        Get.find<LocationController>().getCurrentLocation(
                          false,
                          mapController: _mapController,
                        );
                      }),
                      child: Icon(
                        Icons.my_location,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 30.0,
                    left: Dimensions.paddingSizeSmall,
                    right: Dimensions.paddingSizeSmall,
                    child: CustomButton(
                      fontSize: Dimensions.fontSizeDefault,
                      btnTxt: 'pick_address'.tr,
                      onPressed: (locationController.loading)
                          ? null
                          : () {
                              if (locationController.pickPosition.latitude !=
                                      0 &&
                                  locationController
                                      .pickAddress
                                      .address!
                                      .isNotEmpty) {
                                // if(widget.googleMapController != null) {
                                //   widget.googleMapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
                                //     locationController.pickPosition.latitude, locationController.pickPosition.longitude,
                                //   ), zoom: 16)));
                                //   locationController.setAddAddressData();
                                // }
                                Get.back();
                              } else {
                                showCustomSnackBar(
                                  'pick_an_address'.tr,
                                  type: ToasterMessageType.info,
                                );
                              }
                            },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      showCustomDialog(
        child: const PermissionDialog(),
        barrierDismissible: true,
      );
    } else {
      onTap();
    }
  }
}

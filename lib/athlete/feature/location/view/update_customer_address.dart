import 'package:afriendorse/athlete/feature/location/widget/address_label.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class UpdateCustomerAddress extends StatefulWidget {
  final ServiceAddress address;
  const UpdateCustomerAddress({super.key, required this.address});

  @override
  State<UpdateCustomerAddress> createState() => _UpdateCustomerAddressState();
}

class _UpdateCustomerAddressState extends State<UpdateCustomerAddress> {
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _serviceAddressController =
      TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _serviceAddressNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _countryNode = FocusNode();
  final FocusNode _cityNode = FocusNode();
  final FocusNode _zipNode = FocusNode();
  final FocusNode _streetNode = FocusNode();

  LatLng? _initialPosition;
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _controller = Completer();
  CameraPosition? _cameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "update_customer_address".tr),
      body: SafeArea(
        child: GetBuilder<LocationController>(
          builder: (locationController) {
            return Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Form(
                key: addressFormKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomTextField(
                              title: 'name'.tr,
                              hintText: 'contact_person_name_hint'.tr,
                              inputType: TextInputType.name,
                              controller: _contactPersonNameController,
                              focusNode: _nameNode,
                              nextFocus: _numberNode,
                              capitalization: TextCapitalization.words,
                              onValidate: (value) {
                                return (value == null || value.isEmpty)
                                    ? "enter_contact_person_name".tr
                                    : null;
                              },
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge,
                            ),

                            CustomTextField(
                              onCountryChanged: (CountryCode countryCode) {
                                locationController.countryDialCode =
                                    countryCode.dialCode!;
                              },
                              countryDialCode:
                                  locationController.countryDialCode,
                              title: 'phone_number'.tr,
                              hintText: 'contact_person_number_hint'.tr,
                              inputType: TextInputType.phone,
                              inputAction: TextInputAction.done,
                              focusNode: _numberNode,
                              nextFocus: _serviceAddressNode,
                              controller: _contactPersonNumberController,
                              onValidate: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'phone_number_hint'.tr;
                                } else {
                                  return FormValidationHelper().isValidPhone(
                                    locationController.countryDialCode +
                                        (value),
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeLarge * 1.2,
                            ),

                            Container(
                              height: ResponsiveHelper.isTab(context)
                                  ? 250
                                  : 180,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                border: Border.all(
                                  width: 0.5,
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.5),
                                ),
                              ),
                              padding: const EdgeInsets.all(1),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (_initialPosition != null)
                                      GoogleMap(
                                        minMaxZoomPreference:
                                            const MinMaxZoomPreference(0, 16),

                                        initialCameraPosition: CameraPosition(
                                          target: _initialPosition!,
                                          zoom: 14.4746,
                                        ),
                                        zoomControlsEnabled: false,
                                        onCameraIdle: () {
                                          try {
                                            locationController.updatePosition(
                                              _cameraPosition!,
                                            );
                                          } catch (error) {
                                            if (kDebugMode) {
                                              print('error : $error');
                                            }
                                          }
                                        },
                                        onCameraMove: ((position) =>
                                            _cameraPosition = position),
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                              locationController
                                                  .setMapController(controller);
                                              _controller.complete(controller);
                                            },
                                        myLocationButtonEnabled: false,
                                      ),
                                    locationController.loading
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : const SizedBox(),
                                    Center(
                                      child: !locationController.loading
                                          ? Image.asset(
                                              Images.marker,
                                              height: 40,
                                              width: 40,
                                            )
                                          : const CircularProgressIndicator(),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left:
                                          Get.find<LocalizationController>()
                                              .isLtr
                                          ? null
                                          : Dimensions.paddingSizeSmall,
                                      right:
                                          Get.find<LocalizationController>()
                                              .isLtr
                                          ? 0
                                          : null,
                                      child: InkWell(
                                        onTap: () => _checkPermission(() {
                                          locationController.getCurrentLocation(
                                            true,
                                            mapController: locationController
                                                .mapController,
                                          );
                                        }),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeLarge,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                            color: Theme.of(context)
                                                .primaryColorLight
                                                .withValues(alpha: .5),
                                          ),
                                          child: Icon(
                                            Icons.my_location,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left:
                                          Get.find<LocalizationController>()
                                              .isLtr
                                          ? null
                                          : Dimensions.paddingSizeSmall,
                                      right:
                                          Get.find<LocalizationController>()
                                              .isLtr
                                          ? 0
                                          : null,
                                      child: InkWell(
                                        onTap: () {
                                          Get.to(
                                            () => PickMapScreen(
                                              googleMapController: _controller,
                                              initialPosition:
                                                  _cameraPosition?.target,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeLarge,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                            color: Colors.white.withValues(),
                                          ),
                                          child: Icon(
                                            Icons.fullscreen,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            const AddressLabelWidget(),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            CustomTextField(
                              title: 'service_address'.tr,
                              hintText: 'service_address_hint'.tr,
                              inputType: TextInputType.streetAddress,
                              focusNode: _serviceAddressNode,
                              nextFocus: _houseNode,
                              controller: _serviceAddressController
                                ..text =
                                    locationController.pickAddress.address ??
                                    "",
                              onChanged: (text) => locationController
                                  .setPlaceMark(address: text),
                              onValidate: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'enter_your_address'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    title: 'house'.tr,
                                    hintText: 'enter_house_no'.tr,
                                    inputType: TextInputType.streetAddress,
                                    focusNode: _houseNode,
                                    nextFocus: _floorNode,
                                    controller: _houseController
                                      ..text =
                                          locationController
                                              .pickAddress
                                              .house ??
                                          "",
                                    onChanged: (text) => locationController
                                        .setPlaceMark(house: text),
                                    isRequired: false,
                                  ),
                                ),

                                const SizedBox(
                                  width: Dimensions.paddingSizeLarge,
                                ),

                                Expanded(
                                  child: CustomTextField(
                                    title: 'floor'.tr,
                                    hintText: 'enter_floor_no'.tr,
                                    inputType: TextInputType.streetAddress,
                                    focusNode: _floorNode,
                                    nextFocus: _cityNode,
                                    controller: _floorController
                                      ..text =
                                          locationController
                                              .pickAddress
                                              .floor ??
                                          "",
                                    onChanged: (text) => locationController
                                        .setPlaceMark(floor: text),
                                    isRequired: false,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    title: 'city'.tr,
                                    hintText: 'enter_city'.tr,
                                    inputType: TextInputType.streetAddress,
                                    focusNode: _cityNode,
                                    nextFocus: _countryNode,
                                    controller: _cityController
                                      ..text =
                                          locationController.pickAddress.city ??
                                          "",
                                    onChanged: (text) => locationController
                                        .setPlaceMark(city: text),
                                    isRequired: false,
                                  ),
                                ),

                                const SizedBox(
                                  width: Dimensions.paddingSizeLarge,
                                ),

                                Expanded(
                                  child: CustomTextField(
                                    title: 'country'.tr,
                                    hintText: 'enter_country'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: _countryNode,
                                    inputAction: TextInputAction.next,
                                    nextFocus: _zipNode,
                                    controller: _countryController
                                      ..text =
                                          locationController
                                              .pickAddress
                                              .country ??
                                          "",
                                    onChanged: (text) => locationController
                                        .setPlaceMark(country: text),
                                    isRequired: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    title: 'zip_code'.tr,
                                    hintText: 'enter_zip_code'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: _zipNode,
                                    nextFocus: _streetNode,
                                    controller: _zipController
                                      ..text =
                                          locationController
                                              .pickAddress
                                              .zipCode ??
                                          "",
                                    onChanged: (text) => locationController
                                        .setPlaceMark(zipCode: text),
                                    isRequired: false,
                                  ),
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeDefault,
                                ),
                                Expanded(
                                  child: CustomTextField(
                                    title: 'street'.tr,
                                    hintText: 'enter_street'.tr,
                                    inputType: TextInputType.streetAddress,
                                    focusNode: _streetNode,
                                    inputAction: TextInputAction.done,
                                    controller: _streetController
                                      ..text =
                                          locationController
                                              .pickAddress
                                              .street ??
                                          "",
                                    onChanged: (text) => locationController
                                        .setPlaceMark(street: text),
                                    isRequired: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeExtraMoreLarge,
                            ),
                          ],
                        ),
                      ),
                    ),

                    CustomButton(
                      radius: Dimensions.radiusDefault,
                      fontSize: Dimensions.fontSizeLarge,
                      btnTxt: 'save'.tr,
                      onPressed: () {
                        final isValid = addressFormKey.currentState!.validate();

                        if (isValid) {
                          ServiceAddress address = ServiceAddress(
                            id: widget.address.id,
                            addressType: Address.service.name,
                            addressLabel:
                                locationController.selectedAddressLabel
                                    .toLowerCase()
                                    .contains("hone")
                                ? "home"
                                : locationController.selectedAddressLabel,
                            contactPersonName:
                                _contactPersonNameController.text,
                            contactPersonNumber:
                                locationController.countryDialCode +
                                _contactPersonNumberController.text,
                            address: _serviceAddressController.text,
                            city: _cityController.text,
                            zipCode: _zipController.value.text,
                            country: _countryController.text,
                            house: _houseController.text,
                            floor: _floorController.text,
                            lat: locationController.pickPosition.latitude,
                            lon: locationController.pickPosition.longitude,
                            street: _streetController.text,
                          );
                          Get.find<BookingEditController>()
                              .setPickedServiceAddress(address: address);

                          Get.back();
                        }
                      },
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

  void _initializeData() {
    var location = Get.find<SplashController>()
        .configModel
        .content
        ?.defaultLocation
        ?.defaultLocation;
    _serviceAddressController.text = widget.address.address ?? "";
    _contactPersonNameController.text = widget.address.contactPersonName ?? '';
    _contactPersonNumberController.text =
        ValidationHelper.getValidPhone(
              widget.address.contactPersonNumber ?? "",
            ) !=
            ""
        ? ValidationHelper.getValidPhone(
            widget.address.contactPersonNumber ?? "",
          )
        : "";
    _cityController.text = widget.address.city ?? '';
    _countryController.text = widget.address.country ?? '';
    _streetController.text = widget.address.street ?? "";
    _zipController.text = widget.address.zipCode ?? '';
    _houseController.text = widget.address.house ?? '';
    _floorController.text = widget.address.floor ?? '';

    Get.find<LocationController>().updateAddressLabel(
      addressLabel: widget.address.addressLabel ?? "",
    );
    Get.find<LocationController>().setPlaceMark(addressModel: widget.address);
    Get.find<LocationController>().setUpdateAddress(widget.address);

    _initialPosition = LatLng(
      widget.address.lat ?? location?.lat ?? 23.0000,
      widget.address.lon ?? location?.lon ?? 90.0000,
    );

    String countryCode = ValidationHelper.getValidCountryCode(
      widget.address.contactPersonNumber ?? "",
    );

    Get.find<LocationController>().setPickedLocation(
      address: widget.address,
      shouldUpdate: false,
    );
    Get.find<LocationController>().setCountryCode(
      countryCode: countryCode,
      shouldUpdate: false,
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
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }
}

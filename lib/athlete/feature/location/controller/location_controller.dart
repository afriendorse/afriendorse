import 'dart:ui';
import 'package:afriendorse/athlete/feature/location/model/address_format.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';
import 'package:afriendorse/athlete/feature/location/model/place_details_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

enum Address { service, billing }

class LocationController extends GetxController implements GetxService {
  final LocationRepo locationRepo;
  LocationController({required this.locationRepo});

  Position _position = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );
  Position _pickPosition = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );
  bool _loading = false;
  ServiceAddress _address = ServiceAddress();
  ServiceAddress _pickAddress = ServiceAddress();

  final bool _isLoading = false;
  bool _buttonDisabled = true;

  GoogleMapController? _mapController;
  List<PredictionModel> _predictionList = [];

  bool get buttonDisabled => _buttonDisabled;
  List<PredictionModel> get predictionList => _predictionList;
  bool get isLoading => _isLoading;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  ServiceAddress get address => _address;
  ServiceAddress get pickAddress => _pickAddress;
  GoogleMapController? get mapController => _mapController;

  List<String> addressLabel = ['address_home', 'office', 'others'];
  String _selectedAddressLabel = "address_home";
  String get selectedAddressLabel => _selectedAddressLabel;

  var countryDialCode = "+880";

  Set<Marker> markers = HashSet<Marker>();
  Map<PolylineId, Polyline> polyLines = {};

  @override
  void onInit() {
    super.onInit();
    countryDialCode = CountryCode.fromCountryCode(
      Get.find<SplashController>().configModel.content?.countryCode ?? "BD",
    ).dialCode!;
  }

  Future<void> getCurrentLocation(
    bool fromAddress, {
    GoogleMapController? mapController,
    LatLng? defaultLatLng,
    bool notify = true,
  }) async {
    _loading = true;
    if (notify) {
      update();
    }
    Position myPosition;
    try {
      Geolocator.requestPermission();
      Position newLocalData = await Geolocator.getCurrentPosition();
      myPosition = newLocalData;
    } catch (e) {
      if (defaultLatLng != null) {
        myPosition = Position(
          latitude: defaultLatLng.latitude,
          longitude: defaultLatLng.longitude,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        myPosition = Position(
          latitude:
              Get.find<SplashController>()
                  .configModel
                  .content!
                  .defaultLocation!
                  .defaultLocation
                  ?.lat ??
              0.0,
          longitude:
              Get.find<SplashController>()
                  .configModel
                  .content!
                  .defaultLocation!
                  .defaultLocation
                  ?.lon ??
              0.0,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    }

    if (fromAddress) {
      _position = myPosition;
    } else {
      _pickPosition = myPosition;
    }
    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(myPosition.latitude, myPosition.longitude),
            zoom: 16,
          ),
        ),
      );
    }
    ServiceAddress address = await getAddressFromGeocode(
      LatLng(myPosition.latitude, myPosition.longitude),
    );
    fromAddress ? _address = address : _pickAddress = address;

    _loading = false;
    update();
  }

  void updatePosition(CameraPosition position) async {
    _loading = true;
    update();
    try {
      _pickPosition = Position(
        latitude: position.target.latitude,
        longitude: position.target.longitude,
        timestamp: DateTime.now(),
        heading: 1,
        accuracy: 1,
        altitude: 1,
        speedAccuracy: 1,
        speed: 1,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      ServiceAddress address = await getAddressFromGeocode(
        LatLng(position.target.latitude, position.target.longitude),
      );
      _pickAddress = address;
      Get.find<SignUpController>().setAddressControllerText(
        address.address ?? "",
      );
    } catch (e) {
      if (kDebugMode) {
        print('');
      }
    }

    _loading = false;
    update();
  }

  Future<ServiceAddress> setLocation(
    String placeID,
    String address,
    GoogleMapController? mapController,
  ) async {
    _loading = true;
    update();

    LatLng latLng = const LatLng(0, 0);

    ServiceAddress addressModel = ServiceAddress();
    addressModel.address = address;

    Response response = await locationRepo.getPlaceDetails(placeID);

    if (response.statusCode == 200) {
      PlaceDetailsModel placeDetails = PlaceDetailsModel.fromJson(
        response.body,
      );
      latLng = LatLng(
        placeDetails.content?.location?.latitude ?? 0,
        placeDetails.content?.location?.longitude ?? 0,
      );

      addressModel.lat = latLng.latitude;
      addressModel.lon = latLng.longitude;

      placeDetails.content?.addressComponents?.forEach((element) {
        if (element.types != null) {
          if (element.types!.contains("country")) {
            addressModel.country = element.longName ?? "";
          }
          if (element.types!.contains("locality") &&
              element.types!.contains("political")) {
            addressModel.city = element.longName ?? "";
          }
          if (element.types!.contains("street_number")) {
            addressModel.house = element.longName ?? "";
          }
          if (element.types!.contains("route")) {
            addressModel.street = element.longName ?? "";
          }
          if (element.types!.contains("postal_code")) {
            addressModel.zipCode = element.longName ?? "";
          }
        }
      });
    }

    _pickPosition = Position(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );

    _pickAddress = addressModel;

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 17),
        ),
      );
    }
    _loading = false;
    update();

    return addressModel;
  }

  Future<void> setMapController(GoogleMapController mapController) async {
    _mapController = mapController;
    update();
  }

  Future<ServiceAddress> getAddressFromGeocode(LatLng latLng) async {
    Response response = await locationRepo.getAddressFromGeocode(latLng);
    AddressFormat addressFormat;
    ServiceAddress address = ServiceAddress(address: 'Unknown Location Found');
    if (response.statusCode == 200 &&
        response.body['content']['status'] == 'OK') {
      addressFormat = AddressFormat.fromJson(
        response.body['content']['results'][0],
      );

      addressFormat.addressComponents?.forEach((element) {
        if (element.types != null) {
          if (element.types!.contains("country")) {
            address.country = element.longName ?? "";
          }
          if (element.types!.contains("locality") &&
              element.types!.contains("political")) {
            address.city = element.longName ?? "";
          }
          if (element.types!.contains("street_number")) {
            address.house = element.longName ?? "";
          }
          if (element.types!.contains("route")) {
            address.street = element.longName ?? "";
          }

          if (element.types!.contains("postal_code")) {
            address.zipCode = element.longName ?? "";
          }
        }
      });
      address.address = addressFormat.formattedAddress ?? "";
    }
    return address;
  }

  Future<List<PredictionModel>> searchLocation(
    BuildContext context,
    String text,
  ) async {
    if (text.isNotEmpty) {
      Response response = await locationRepo.searchLocation(text);
      if (response.body['response_code'] == "default_200") {
        _predictionList = [];
        try {
          response.body['content']['suggestions'].forEach(
            (prediction) =>
                _predictionList.add(PredictionModel.fromJson(prediction)),
          );
        } catch (e) {
          showCustomSnackBar(response.body['content']['error']['message']);
        }
      } else {}
    }
    return _predictionList;
  }

  Future<Uint8List> convertAssetToUnit8List(
    String imagePath, {
    int width = 50,
  }) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  void disableButton() {
    _buttonDisabled = true;
    update();
  }

  void setPlaceMark({
    ServiceAddress? addressModel,
    String? address,
    String? house,
    String? floor,
    String? city,
    String? country,
    String? zipCode,
    String? street,
  }) {
    if (addressModel != null) {
      _address = addressModel;
    }

    if (address != null) {
      _address.address = address;
    } else if (house != null) {
      _address.house = house;
    } else if (floor != null) {
      _address.floor = floor;
    } else if (city != null) {
      _address.city = city;
    } else if (country != null) {
      _address.country = country;
    } else if (zipCode != null) {
      _address.zipCode = zipCode;
    } else if (street != null) {
      _address.street = street;
    }
  }

  void setUpdateAddress(ServiceAddress address) {
    _position = Position(
      latitude: address.lat ?? 0,
      longitude: address.lon ?? 0,
      timestamp: DateTime.now(),
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      floor: 1,
      accuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );
    _address.address = address.address!;
  }

  void setPickedLocation({ServiceAddress? address, bool shouldUpdate = true}) {
    if (address != null) {
      _pickAddress = address;
      _pickPosition = Position(
        longitude: address.lon ?? 0,
        latitude: address.lat ?? 0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } else {
      _pickAddress = ServiceAddress();
      _pickPosition = Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    if (shouldUpdate) {
      update();
    }
  }

  void updateAddressLabel({
    required String addressLabel,
    String addressLabelString = '',
  }) {
    if (addressLabel.contains("home")) {
      _selectedAddressLabel = "address_home";
    } else {
      _selectedAddressLabel = addressLabel;
    }
    update();
  }

  void setCountryCode({
    required String countryCode,
    bool shouldUpdate = false,
  }) {
    if (countryCode != "") {
      countryDialCode = countryCode;
    }
    if (shouldUpdate) {
      update();
    }
  }
}

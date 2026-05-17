import 'dart:convert';
import 'dart:ui' as ui;

import 'package:afriendorse/api/local/cache_response.dart';
import 'package:afriendorse/helper/data_sync_helper.dart';
import 'package:afriendorse/util/core_export.dart';
import 'package:get/get.dart';

class ServiceAreaController extends GetxController implements GetxService {
  ServiceAreaRepo serviceAreaRepo;
  ServiceAreaController({required this.serviceAreaRepo});

  List<ZoneModel>? _zoneList;

  Set<Marker> _markers = {};
  Set<Polygon> _polygone = {};

  List<ZoneModel>? get zoneList => _zoneList;
  Set<Marker> get markers => _markers;
  Set<Polygon> get polygone => _polygone;

  Future<void> getZoneList({
    Map<String, GlobalKey>? globalKeyMap,
    bool reload = true,
  }) async {
    LatLng currentLocation = const LatLng(0, 0);

    await DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => serviceAreaRepo.getZoneList<CacheResponseData>(
        source: DataSourceEnum.local,
      ),
      fetchFromClient: () =>
          serviceAreaRepo.getZoneList(source: DataSourceEnum.client),
      onResponse: (data, source) {
        _zoneList = [];

        List<dynamic> zonesList = [];

        // Handle both local (List) and API (Map)
        if (data is List) {
          zonesList = data;
        } else if (data is Map &&
            data.containsKey('content') &&
            data['content'] is Map &&
            data['content'].containsKey('data')) {
          zonesList = data['content']['data'];
        } else {
          debugPrint('Unexpected API structure: $data');
          return;
        }

        // Safely parse zones
        for (var zone in zonesList) {
          try {
            if (zone is String) {
              final decodedZone = jsonDecode(zone);
              _zoneList!.add(ZoneModel.fromJson(decodedZone));
            } else if (zone is Map<String, dynamic>) {
              _zoneList!.add(ZoneModel.fromJson(zone));
            }
          } catch (e) {
            debugPrint('Zone parsing error: $e');
          }
        }

        List<Polygon> polygonList = [];

        for (int index = 0; index < _zoneList!.length; index++) {
          final coordinates = _zoneList![index].formattedCoordinates;

          // 🛑 Skip if coordinates are null or empty
          if (coordinates == null || coordinates.isEmpty) continue;

          List<LatLng> zoneLatLongList = [];

          for (int subIndex = 0; subIndex < coordinates.length; subIndex++) {
            final lat = coordinates[subIndex].latitude ?? 0;
            final lng = coordinates[subIndex].longitude ?? 0;

            zoneLatLongList.add(LatLng(lat, lng));
          }

          if (zoneLatLongList.isEmpty) continue;

          LatLng position = computeCentroid(points: zoneLatLongList);
          currentLocation = LatLng(position.latitude, position.longitude);

          polygonList.add(
            Polygon(
              polygonId: PolygonId('zone$index'),
              points: zoneLatLongList,
              strokeWidth: 2,
              strokeColor: Get.theme.colorScheme.primary,
              fillColor: Get.theme.colorScheme.primary.withValues(alpha: .2),
            ),
          );
        }

        _polygone = HashSet<Polygon>.of(polygonList);
        update();
      },
    );
  }

  Future<void> setMarker(
    List<ZoneModel> zoneList,
    Map<String, GlobalKey> globalKeymap,
  ) async {
    List<Marker> markerList = [];

    for (int index = 0; index < zoneList.length; index++) {
      final coordinates = zoneList[index].formattedCoordinates;

      // 🛑 Skip if coordinates are null or empty
      if (coordinates == null || coordinates.isEmpty) continue;

      List<LatLng> zoneLatLongList = [];

      for (int subIndex = 0; subIndex < coordinates.length; subIndex++) {
        final lat = coordinates[subIndex].latitude ?? 0;
        final lng = coordinates[subIndex].longitude ?? 0;

        zoneLatLongList.add(LatLng(lat, lng));
      }

      if (zoneLatLongList.isEmpty) continue;

      // Safely compute centroid
      final centroid = computeCentroid(points: zoneLatLongList);

      // Safely get marker icon
      BitmapDescriptor icon;

      if (GetPlatform.isWeb || GetPlatform.isIOS) {
        icon = BitmapDescriptor.defaultMarker;
      } else {
        final key = globalKeymap[index.toString()];
        if (key != null) {
          icon = await MarkerIcon.widgetToIcon(key);
        } else {
          icon = BitmapDescriptor.defaultMarker;
        }
      }

      markerList.add(
        Marker(
          markerId: MarkerId('provider$index'),
          position: centroid,
          icon: icon,
          infoWindow: GetPlatform.isWeb || GetPlatform.isIOS
              ? InfoWindow(title: zoneList[index].name ?? '')
              : InfoWindow.noText,
        ),
      );
    }

    _markers = HashSet<Marker>.of(markerList);
    update();
  }

  LatLng computeCentroid({
    List<Coordinates>? coordinates,
    Iterable<LatLng>? points,
  }) {
    double latitude = 0;
    double longitude = 0;
    int n = 1;

    if (points != null) {
      n = points.length;

      for (LatLng point in points) {
        latitude += point.latitude;
        longitude += point.longitude;
      }
    } else if (coordinates != null) {
      n = coordinates.length;

      for (Coordinates point in coordinates) {
        latitude += point.latitude!;
        longitude += point.longitude!;
      }
    } else {
      n = 1;
    }

    return LatLng(latitude / n, longitude / n);
  }

  Future<Uint8List?> convertAssetToUnit8List(
    String imagePath, {
    int width = 50,
  }) async {
    ByteData data = await rootBundle.load(imagePath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))?.buffer.asUint8List();
  }

  void mapBound(GoogleMapController controller) async {
    List<LatLng> latLongList = [];
    for (int index = 0; index < _zoneList!.length; index++) {
      if (_zoneList![index].formattedCoordinates != null) {
        for (
          int subIndex = 0;
          subIndex < _zoneList![index].formattedCoordinates!.length;
          subIndex++
        ) {
          latLongList.add(
            LatLng(
              _zoneList![index].formattedCoordinates![subIndex].latitude!,
              _zoneList![index].formattedCoordinates![subIndex].longitude!,
            ),
          );
        }
      }
    }
    await controller.getVisibleRegion();
    Future.delayed(const Duration(milliseconds: 100), () {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          MapHelper.boundsFromLatLngList(latLongList),
          100.5,
        ),
      );
    });

    update();
  }
}

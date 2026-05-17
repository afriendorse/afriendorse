class GeoCodeAddressModel {
  String? formattedAddress;
  String? placeId;

  GeoCodeAddressModel({this.formattedAddress, this.placeId});

  GeoCodeAddressModel.fromJson(Map<String, dynamic> json) {
    formattedAddress = json['formatted_address'];
    placeId = json['place_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['formatted_address'] = formattedAddress;
    data['place_id'] = placeId;
    return data;
  }
}


class BookingSettingResponseModel {
  String? responseCode;
  String? message;
  Content? content;

  BookingSettingResponseModel(
      {this.responseCode, this.message, this.content, });

  BookingSettingResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? Content.fromJson(json['content']) : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (content != null) {
      data['content'] = content!.toJson();
    }

    return data;
  }
}

class Content {
  List<BookingSettingContent>? settingsList;
  List<String>? serviceLocation;

  Content({this.settingsList, this.serviceLocation});

  Content.fromJson(Map<String, dynamic> json) {
    if (json['provider_serviceman_config'] != null) {
      settingsList = <BookingSettingContent>[];
      json['provider_serviceman_config'].forEach((v) {
        settingsList!.add(BookingSettingContent.fromJson(v));
      });
    }
    serviceLocation = json['service_location'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (settingsList != null) {
      data['provider_serviceman_config'] = settingsList!.map((v) => v.toJson()).toList();
    }
    data['service_location'] = serviceLocation;
    return data;
  }
}

class BookingSettingContent {
  String? keyName;
  int? liveValues;
  int? testValues;
  String? mode;

  BookingSettingContent({this.keyName, this.liveValues, this.testValues, this.mode});

  BookingSettingContent.fromJson(Map<String, dynamic> json) {
    keyName = json['key_name'];
    liveValues = int.tryParse(json['live_values'].toString());
    testValues = int.tryParse(json['test_values'].toString());
    mode = json['mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key_name'] = keyName;
    data['live_values'] = liveValues;
    data['test_values'] = testValues;
    data['mode'] = mode;
    return data;
  }
}

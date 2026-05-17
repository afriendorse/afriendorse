class ServiceAvailabilityModel {
  String? responseCode;
  String? message;
  ServiceAvailabilityModelContent? content;

  ServiceAvailabilityModel(
      {this.responseCode, this.message, this.content});

  ServiceAvailabilityModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? ServiceAvailabilityModelContent.fromJson(json['content']) : null;

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

class ServiceAvailabilityModelContent {
  int? serviceAvailability;
  TimeSchedule? timeSchedule;
  List<String>? weekends;

  ServiceAvailabilityModelContent({this.serviceAvailability, this.timeSchedule, this.weekends});

  ServiceAvailabilityModelContent.fromJson(Map<String, dynamic> json) {
    serviceAvailability = int.tryParse(json['service_availability'].toString());
    timeSchedule = json['time_schedule'] != null
        ? TimeSchedule.fromJson(json['time_schedule'])
        : null;
    weekends = json['weekends'] !=null ? json['weekends'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_availability'] = serviceAvailability;
    if (timeSchedule != null) {
      data['time_schedule'] = timeSchedule!.toJson();
    }
    data['weekends'] = weekends;
    return data;
  }
}

class TimeSchedule {
  String? startTime;
  String? endTime;

  TimeSchedule({this.startTime, this.endTime});

  TimeSchedule.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}

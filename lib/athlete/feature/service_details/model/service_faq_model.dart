// To parse this JSON data, do
//
//     final serviceFaqModel = serviceFaqModelFromJson(jsonString);

import 'dart:convert';

ServiceFaqModel serviceFaqModelFromJson(String str) => ServiceFaqModel.fromJson(json.decode(str));

String serviceFaqModelToJson(ServiceFaqModel data) => json.encode(data.toJson());

class ServiceFaqModel {
  ServiceFaqModel({
    this.responseCode,
    this.message,
    this.content,
  });

  String? responseCode;
  String? message;
  ServiceFAQContent? content;

  factory ServiceFaqModel.fromJson(Map<String, dynamic> json) => ServiceFaqModel(
    responseCode: json["response_code"],
    message: json["message"],
    content: ServiceFAQContent.fromJson(json["content"]),
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "message": message,
    "content": content!.toJson(),
  };
}

class ServiceFAQContent {
  ServiceFAQContent({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  int? currentPage;
  List<ServiceFAQData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  String? nextPageUrl;
  String? path;
  String? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  factory ServiceFAQContent.fromJson(Map<String, dynamic> json) => ServiceFAQContent(
    currentPage: json["current_page"],
    data: List<ServiceFAQData>.from(json["data"].map((x) => ServiceFAQData.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class ServiceFAQData {
  ServiceFAQData({
    this.question,
    this.answer,
    this.serviceId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  String? question;
  String? answer;
  String? serviceId;
  int? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory ServiceFAQData.fromJson(Map<String, dynamic> json) => ServiceFAQData(
    question: json["question"],
    answer: json["answer"],
    serviceId: json["service_id"],
    isActive: json["is_active"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "question": question,
    "answer": answer,
    "service_id": serviceId,
    "is_active": isActive,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}

class Link {
  Link({
    this.url,
    this.label,
    this.active,
  });

  String? url;
  String? label;
  bool? active;

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}

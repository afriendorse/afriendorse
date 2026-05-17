import 'dart:convert';

class ResponseModelApi {
  ResponseModelApi({
    this.responseCode,
    this.message,
    this.content,
    this.errors,
  });

  String? responseCode;
  String? message;
  dynamic content;
  List<dynamic>? errors;

  factory ResponseModelApi.fromRawJson(String str) => ResponseModelApi.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ResponseModelApi.fromJson(Map<String, dynamic> json) => ResponseModelApi(
    responseCode:  json["response_code"] ?? '',
    message: json["message"] ?? '',
    content: json["content"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "message": message,
    "content": content,
    //"errors": List<dynamic>.from(errors.map((x) => x)),
  };
}

ErrorBody errorBodyFromJson(String str) => ErrorBody.fromJson(json.decode(str));

class ErrorBody {
  ErrorBody({
    this.errors,
  });

  List<Error>? errors;

  factory ErrorBody.fromJson(Map<String, dynamic> json) => ErrorBody(
    errors: List<Error>.from(json["errors"].map((x) => Error.fromJson(x))),
  );
}

class Error {
  Error({
    this.message,
  });

  String? message;

  factory Error.fromJson(Map<String, dynamic> json) => Error(
    message: json["message"],
  );

}

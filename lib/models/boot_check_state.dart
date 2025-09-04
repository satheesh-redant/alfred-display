// To parse this JSON data, do
//
//     final bootCheckResponse = bootCheckResponseFromJson(jsonString);

import 'dart:convert';

BootCheckResponse bootCheckResponseFromJson(String str) => BootCheckResponse.fromJson(json.decode(str));

String bootCheckResponseToJson(BootCheckResponse data) => json.encode(data.toJson());

class BootCheckResponse {
  List<Check>? checks;
  String? overallStatus;
  String message;

  BootCheckResponse({
    this.checks,
    this.overallStatus = '',
    this.message = '',
  });

  factory BootCheckResponse.fromJson(Map<String, dynamic> json) => BootCheckResponse(
    checks: json["checks"] == null ? [] : List<Check>.from(json["checks"]!.map((x) => Check.fromJson(x))),
    overallStatus: json["overall_status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "checks": checks == null ? [] : List<dynamic>.from(checks!.map((x) => x.toJson())),
    "overall_status": overallStatus,
    "message": message,
  };
}

class Check {
  String? component;
  String? status;
  String? error;

  Check({
    this.component,
    this.status,
    this.error,
  });

  factory Check.fromJson(Map<String, dynamic> json) => Check(
    component: json["component"],
    status: json["status"],
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "component": component,
    "status": status,
    "error": error,
  };
}

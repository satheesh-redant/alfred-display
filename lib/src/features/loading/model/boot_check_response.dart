import 'dart:convert';

BootCheckResponse bootCheckResponseFromJson(String str) =>
    BootCheckResponse.fromJson(json.decode(str));

String bootCheckResponseToJson(BootCheckResponse data) =>
    json.encode(data.toJson());

class BootCheckResponse {
  String? overallStatus;
  List<SystemCheck>? checks;
  String message;

  BootCheckResponse({
    this.checks,
    this.overallStatus = '',
    this.message = '',
  });

  factory BootCheckResponse.fromJson(Map<String, dynamic> json) =>
      BootCheckResponse(
        checks: json["checks"] == null
            ? []
            : List<SystemCheck>.from(
                json["checks"]!.map((x) => SystemCheck.fromJson(x))),
        overallStatus: json["overall_status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "checks": checks == null
            ? []
            : List<dynamic>.from(checks!.map((x) => x.toJson())),
        "overall_status": overallStatus,
        "message": message,
      };

  bool get isReady => overallStatus?.toUpperCase() == 'OK';

  bool get hasFailed => overallStatus?.toUpperCase() == 'FAIL';

  bool get isLoading => overallStatus?.toUpperCase() == 'NOT READY';
}

class SystemCheck {
  String? component;
  String? status;
  String? error;

  SystemCheck({
    this.component,
    this.status,
    this.error,
  });

  factory SystemCheck.fromJson(Map<String, dynamic> json) => SystemCheck(
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

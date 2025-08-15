class BootCheckResponse {
  final String overallStatus;
  final List<SystemCheck> checks;
  final String message;

  BootCheckResponse({
    required this.overallStatus,
    required this.checks,
    required this.message,
  });

  factory BootCheckResponse.fromJson(Map<String, dynamic> json) {
    return BootCheckResponse(
      overallStatus: json['overall_status'] ?? '',
      message: json['message'] ?? '',
      checks: (json['checks'] as List<dynamic>?)
          ?.map((check) => SystemCheck.fromJson(check))
          .toList() ?? [],
    );
  }

  bool get isReady => overallStatus.toUpperCase() == 'OK';
  bool get hasFailed => overallStatus.toUpperCase() == 'FAIL';
  bool get isLoading => overallStatus.toUpperCase() == 'NOT READY';
}

class SystemCheck {
  final String? status;
  final String? error;

  SystemCheck({this.status, this.error});

  factory SystemCheck.fromJson(Map<String, dynamic> json) {
    return SystemCheck(
      status: json['status'],
      error: json['error'],
    );
  }
}

class BootStatusResponse {
  final bool hardwareOk;
  final bool batteryOk;
  final bool sensorOk;
  final String message;

  BootStatusResponse({
    this.hardwareOk = false,
    this.batteryOk = false,
    this.sensorOk = false,
    this.message = '',
  });

  factory BootStatusResponse.fromJson(Map<String, dynamic> json) {
    return BootStatusResponse(
      hardwareOk: json['hardware_ok'] ?? false,
      batteryOk: json['battery_ok'] ?? false,
      sensorOk: json['sensor_ok'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'hardware_ok': hardwareOk,
    'battery_ok': batteryOk,
    'sensor_ok': sensorOk,
    'message': message,
  };
}
import 'dart:convert';

BatteryStatus batteryStatusFromJson(String str) => BatteryStatus.fromJson(json.decode(str));

String batteryStatusToJson(BatteryStatus data) => json.encode(data.toJson());

class BatteryStatus {
  int? percentage;
  int? state;
  double? voltage;
  double? current;

  BatteryStatus({
    this.percentage,
    this.state,
    this.voltage,
    this.current,
  });

  factory BatteryStatus.fromJson(Map<String, dynamic> json) => BatteryStatus(
    percentage: json["percentage"],
    state: json["state"],
    voltage: json["voltage"]?.toDouble(),
    current: json["current"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "percentage": percentage,
    "state": state,
    "voltage": voltage,
    "current": current,
  };
}

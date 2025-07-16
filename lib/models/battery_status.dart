import 'dart:convert';

import 'package:flutter/material.dart';

BatteryStatus batteryStatusFromJson(String str) =>
    BatteryStatus.fromJson(json.decode(str));

String batteryStatusToJson(BatteryStatus data) => json.encode(data.toJson());

class BatteryStatus {
  double? percentage;
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

  int get batteryPercentage {
    if(percentage == null) {
      return 50;
    }
    return percentage!.toInt();
  }

  BatteryStatusType get batteryStatusType {
    switch (batteryPercentage) {
      case >= 0 && < 20:
        return BatteryStatusType.low; //red
      case >= 20 && < 40:
        return BatteryStatusType.mid; //orange
      case >= 40 && < 90:
        return BatteryStatusType.normal; //green
      case >= 90:
        return BatteryStatusType.full; //green
      default:
        return BatteryStatusType.mid;
    }
  }

  Color get batteryColor {
    if(batteryState == BatteryState.charging) {
      return Colors.green;
    } else {
      switch (batteryStatusType) {
        case BatteryStatusType.low:
          return Colors.red;
        case BatteryStatusType.mid:
          return Colors.orange;
        case BatteryStatusType.normal || BatteryStatusType.full:
          return Colors.green;
      }
    }
  }

  BatteryState get batteryState {
    switch (state) {
      case 1:
        return BatteryState.charging;
      default:
        return BatteryState.discharging;
    }
  }
}

enum BatteryState { charging, discharging }

enum BatteryStatusType { low, mid, normal, full }

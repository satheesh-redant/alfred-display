// battery_state_model.dart
import 'dart:convert';
import 'package:alfred/src/core/configs/alfred_constants.dart';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// ENUMS
// -----------------------------------------------------------------------------
enum BatteryStatus {
  unknown,
  charging,
  discharging,
  notCharging,
  full,
}

enum BatteryHealth {
  unknown,
  good,
  overheat,
  dead,
  overvoltage,
  unspecifiedFailure,
  cold,
  watchdogTimerExpire,
  safetyTimerExpire,
}

enum BatteryTechnology {
  unknown,
  nimh,
  lion,
  lipo,
  life,
  nicd,
  limn,
}

// -----------------------------------------------------------------------------
// MODEL CLASS
// -----------------------------------------------------------------------------
class BatteryState {
  double? voltage;
  double? current;
  double? charge;
  double? capacity;
  double? designCapacity;
  double? percentage;
  int? powerSupplyStatus;
  int? powerSupplyHealth;
  int? powerSupplyTechnology;
  bool? present;
  List<double>? cellVoltage;
  List<double>? cellTemperature;
  String? location;
  String? serialNumber;

  BatteryState({
    this.voltage,
    this.current,
    this.charge,
    this.capacity,
    this.designCapacity,
    this.percentage,
    this.powerSupplyStatus,
    this.powerSupplyHealth,
    this.powerSupplyTechnology,
    this.present,
    this.cellVoltage,
    this.cellTemperature,
    this.location,
    this.serialNumber,
  });

  // ---------------------------------------------------------------------------
  // JSON Parsing
  // ---------------------------------------------------------------------------
  factory BatteryState.fromJson(Map<String, dynamic> json) {
    return BatteryState(
      voltage: _toDouble(json['voltage']),
      current: _toDouble(json['current']),
      charge: _toDouble(json['charge']),
      capacity: _toDouble(json['capacity']),
      designCapacity: _toDouble(json['design_capacity']),
      percentage: _toDouble(json['percentage']),
      powerSupplyStatus: _toInt(json['power_supply_status']),
      powerSupplyHealth: _toInt(json['power_supply_health']),
      powerSupplyTechnology: _toInt(json['power_supply_technology']),
      present: json['present'] is bool
          ? json['present']
          : (json['present'] == 1 || json['present'] == 'true'),
      cellVoltage: (json['cell_voltage'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      cellTemperature: (json['cell_temperature'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      location: json['location'],
      serialNumber: json['serial_number'],
    );
  }

  factory BatteryState.fromString(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return BatteryState.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'voltage': voltage,
      'current': current,
      'charge': charge,
      'capacity': capacity,
      'design_capacity': designCapacity,
      'percentage': percentage,
      'power_supply_status': powerSupplyStatus,
      'power_supply_health': powerSupplyHealth,
      'power_supply_technology': powerSupplyTechnology,
      'present': present,
      'cell_voltage': cellVoltage,
      'cell_temperature': cellTemperature,
      'location': location,
      'serial_number': serialNumber,
    };
  }

  // ---------------------------------------------------------------------------
  // Conversion Functions → Enums
  // ---------------------------------------------------------------------------
  BatteryStatus get statusEnum {
    switch (powerSupplyStatus) {
      case 1:
        return BatteryStatus.charging;
      case 2:
        return BatteryStatus.discharging;
      case 3:
        return BatteryStatus.notCharging;
      case 4:
        return BatteryStatus.full;
      default:
        return BatteryStatus.unknown;
    }
  }

  BatteryHealth get healthEnum {
    switch (powerSupplyHealth) {
      case 1:
        return BatteryHealth.good;
      case 2:
        return BatteryHealth.overheat;
      case 3:
        return BatteryHealth.dead;
      case 4:
        return BatteryHealth.overvoltage;
      case 5:
        return BatteryHealth.unspecifiedFailure;
      case 6:
        return BatteryHealth.cold;
      case 7:
        return BatteryHealth.watchdogTimerExpire;
      case 8:
        return BatteryHealth.safetyTimerExpire;
      default:
        return BatteryHealth.unknown;
    }
  }

  BatteryTechnology get technologyEnum {
    switch (powerSupplyTechnology) {
      case 1:
        return BatteryTechnology.nimh;
      case 2:
        return BatteryTechnology.lion;
      case 3:
        return BatteryTechnology.lipo;
      case 4:
        return BatteryTechnology.life;
      case 5:
        return BatteryTechnology.nicd;
      case 6:
        return BatteryTechnology.limn;
      default:
        return BatteryTechnology.unknown;
    }
  }

  // ---------------------------------------------------------------------------
  // Computed Labels + UI Helpers
  // ---------------------------------------------------------------------------
  String get statusLabel {
    switch (statusEnum) {
      case BatteryStatus.charging:
        return 'Charging';
      case BatteryStatus.discharging:
        return 'Discharging';
      case BatteryStatus.notCharging:
        return 'Idle';
      case BatteryStatus.full:
        return 'Full';
      case BatteryStatus.unknown:
      default:
        return 'Unknown';
    }
  }

  String get healthLabel {
    switch (healthEnum) {
      case BatteryHealth.good:
        return 'Good';
      case BatteryHealth.overheat:
        return 'Overheat';
      case BatteryHealth.dead:
        return 'Dead';
      case BatteryHealth.overvoltage:
        return 'Overvoltage';
      case BatteryHealth.unspecifiedFailure:
        return 'Failure';
      case BatteryHealth.cold:
        return 'Cold';
      case BatteryHealth.watchdogTimerExpire:
        return 'Watchdog Timeout';
      case BatteryHealth.safetyTimerExpire:
        return 'Safety Timeout';
      case BatteryHealth.unknown:
      default:
        return 'Unknown';
    }
  }

  String get technologyLabel {
    switch (technologyEnum) {
      case BatteryTechnology.lion:
        return 'Li-ion';
      case BatteryTechnology.lipo:
        return 'Li-Po';
      case BatteryTechnology.life:
        return 'LiFe';
      case BatteryTechnology.nimh:
        return 'NiMH';
      case BatteryTechnology.nicd:
        return 'NiCd';
      case BatteryTechnology.limn:
        return 'LiMn';
      case BatteryTechnology.unknown:
      default:
        return 'Unknown';
    }
  }

  Color get healthColor {
    switch (healthEnum) {
      case BatteryHealth.good:
        return Colors.green;
      case BatteryHealth.overheat:
      case BatteryHealth.overvoltage:
        return Colors.red;
      case BatteryHealth.cold:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color get percentageColor {
    if (percentage == null) return Colors.grey;
    final value = percentage! * 100; // convert 0–1 to %
    if (value < 10) return AlfredConstants.batteryColorRed; // Red - Critical
    if (value < 20) return AlfredConstants.batteryColorOrange; // Orange - Low
    if (value < 40) return AlfredConstants.batteryColorYellow; // Yellow - Moderate
    if (value <= 100) return AlfredConstants.batteryColorBlack; // Lime Green - Fair
    return Colors.grey;
  }

  double? get averageCellVoltage {
    final list = cellVoltage;
    if (list == null || list.isEmpty) return null;
    return list.reduce((a, b) => a + b) / list.length;
  }

  double? get packPower =>
      (voltage != null && current != null) ? voltage! * current! : null;

  @override
  String toString() =>
      'BatteryStateModel(voltage: $voltage, status: $statusLabel, health: $healthLabel, tech: $technologyLabel)';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}

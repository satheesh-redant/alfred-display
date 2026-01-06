import 'package:alfred/src/features/battery/model/battery_model.dart';

class BatteryState {
  BatteryData? batteryData;

  BatteryState({
    this.batteryData,
  });

  BatteryState copyWith({
    BatteryData? batteryData,
  }) {
    return BatteryState(
      batteryData: batteryData ?? this.batteryData,
    );
  }
}

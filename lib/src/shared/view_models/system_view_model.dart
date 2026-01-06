import 'dart:async';
import 'package:alfred/src/core/base/base_view_model.dart';
import 'package:alfred/src/shared/states/system_state.dart';

import '../../core/services/ros_service.dart';
import '../models/operation_mode.dart';
import '../models/power_off_status.dart';

/// Manages app-wide operations: power-off, mode changes, connection
/// Uses ROSService directly - no repository layer
class SystemViewModel extends BaseViewModel<SystemState> {
  final ROSService _ros;
  StreamSubscription? _powerStatusSub;
  StreamSubscription? _modeSub;
  StreamSubscription? _connectionSub;

  SystemViewModel(this._ros) : super(const SystemState()) {
    _initializeStreams();
  }

  void _initializeStreams() {
    // Listen to power off acknowledgment from ROS
    _powerStatusSub = _ros.powerOffAckStream.listen((ack) {
      final status = PowerStatus.fromRos(ack);
      if (status.isShuttingDown) {
        state = state.copyWith(isPoweringOff: false);
      }
    });

    // Listen to operation mode changes from ROS
    _modeSub = _ros.modeStream.listen((mode) {
      final operationMode = OperationMode.fromString(mode);
      state = state.copyWith(
        currentMode: operationMode,
        isChangingMode: false,
      );
    });

    // Listen to connection status
    _connectionSub = _ros.connectionStream.listen((status) {
      final isConnected = status == ROSConnectionStatus.connected;
      state = state.copyWith(isConnected: isConnected);
    });
  }

  /// Power off robot - shows loading until ROS acknowledges
  Future<void> powerOff() async {
    if (!_ros.isConnected) {
      state = state.copyWith(statusMessage: 'Not connected to robot');
      return;
    }

    // Show loading
    state = state.copyWith(
      isPoweringOff: true,
      statusMessage: null,
    );
    try {
      await _ros.sendPowerOffCommand();
    } catch (e) {
      state = state.copyWith(
        isPoweringOff: false,
        statusMessage: 'Power off failed: $e',
      );
    }
  }

  /// Change operation mode - shows loading until ROS confirms
  Future<void> changeMode(OperationMode mode) async {
    if (!_ros.isConnected) {
      state = state.copyWith(statusMessage: 'Not connected to robot');
      return;
    }

    if (mode == OperationMode.unknown) {
      state = state.copyWith(statusMessage: 'Invalid mode selected');
      return;
    }

    // Show loading
    state = state.copyWith(
      isChangingMode: true,
      statusMessage: null,
    );

    try {
      // Direct call to ROSService
      await _ros.requestModeChange(mode.name);

    } catch (e) {
      state = state.copyWith(
        isChangingMode: false,
        statusMessage: 'Mode change failed: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(statusMessage: null);
  }

  @override
  void onDispose() {
    _powerStatusSub?.cancel();
    _modeSub?.cancel();
    _connectionSub?.cancel();
    super.onDispose();
  }
}

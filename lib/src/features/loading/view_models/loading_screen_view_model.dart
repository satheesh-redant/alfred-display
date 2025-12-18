//retry
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/base/base_view_model.dart';
import '../../../core/services/ros_service.dart';
import '../model/boot_check_response.dart';
import '../states/loading_screen_state.dart';

class LoadingScreenViewModel extends BaseViewModel<LoadingScreenState> {
  final ROSService _rosService;

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _bootCheckSubscription;
  StreamSubscription? _operationsSubscription;

  LoadingScreenViewModel(this._rosService)
      : super(
          LoadingScreenState(
            step: LoadingStep.connecting,
            connectionStatus: ROSConnectionStatus.disconnected,
            statusMessage: 'Initializing connection...',
          ),
        );

  Future<void> startLoadingProcess() async {
    print('Starting loading process');
    _listenToConnectionStatus();
    _attemptConnection();
  }

  void _listenToConnectionStatus() {
    _connectionSubscription = _rosService.connectionStream.listen(
      (connectionStatus) {
        state = state.copyWith(connectionStatus: connectionStatus);

        switch (connectionStatus) {
          case ROSConnectionStatus.connecting:
            state =
                state.copyWith(statusMessage: 'Connecting to ROS WebSocket...');
            break;

          case ROSConnectionStatus.connected:
            print('ROS connected');
            state = state.copyWith(
                statusMessage: 'Connected! Checking system status...');
            _startBootCheck();
            break;

          case ROSConnectionStatus.error:
          case ROSConnectionStatus.disconnected:
            print('ROS disconnected');
            _cleanupTopicSubscriptions();
            break;
        }
      },
    );
  }

  Future<void> _attemptConnection() async {
    try {
      await _rosService.connect();
    } catch (_) {}
  }

  void _startBootCheck() {
    print('Starting boot check');

    state = state.copyWith(
      step: LoadingStep.bootChecking,
      statusMessage: 'Checking system status...',
    );

    _bootCheckSubscription = _rosService.bootCheckStream.listen(
      (rawBootMsg) {
        try {
          if (!rawBootMsg.trim().startsWith("{")) {
            state = state.copyWith(statusMessage: rawBootMsg);
            return;
          }

          var bootStatus = bootCheckResponseFromJson(rawBootMsg);
          if (bootStatus.isLoading) {
            state = state.copyWith(
              statusMessage: bootStatus.message.isEmpty
                  ? "System initializing..."
                  : bootStatus.message,
            );
            return;
          }

          if (bootStatus.isReady) {
            print("System READY");
            state = state.copyWith(
                statusMessage: "System ready! Getting operation mode...",
                bootCheckResponse: bootStatus);
            _startOpsMode();
            return;
          }

          state = state.copyWith(
              statusMessage: "System check failed: $bootStatus.message",
              bootCheckResponse: bootStatus);
          return;
        } catch (e) {
          print("Boot parse error: $e");
          state =
              state.copyWith(statusMessage: "Checking for system status...");
        }
      },
      onError: (error) => print('Boot check error: $error'),
    );

    // TODO This is temporary hack since the boot status implementation is not done yet at ROS side
    Future.delayed(const Duration(seconds: 2), () {
      BootCheckResponse response = BootCheckResponse();
      response.message = 'OK';
      response.overallStatus = 'OK';
      response.checks = [];
      print("System READY (FORCED)");
      state = state.copyWith(
          statusMessage: "System ready! Getting operation mode...",
          bootCheckResponse: response);
      _startOpsMode();
    });
  }

  void _startOpsMode() {
    print('Getting operation mode');

    _bootCheckSubscription?.cancel();

    state = state.copyWith(
      step: LoadingStep.opsMode,
      statusMessage: 'Loading...',
    );

    _operationsSubscription = _rosService.opsModeStream.listen(
      (operationMode) {
        state = state.copyWith(
          operationMode: operationMode,
          step: LoadingStep.navigating,
          statusMessage: "Starting ${operationMode.name} mode...",
        );
      },
      onError: (error) => print('Ops mode error: $error'),
    );
  }

  void _cleanupTopicSubscriptions() {
    _bootCheckSubscription?.cancel();
    _operationsSubscription?.cancel();

    if (state.step != LoadingStep.connecting) {
      state = state.copyWith(
        step: LoadingStep.connecting,
        bootCheckResponse: null,
        operationMode: null,
      );
    }
  }

  @override
  void onDispose() {
    _connectionSubscription?.cancel();
    _bootCheckSubscription?.cancel();
    _operationsSubscription?.cancel();
    super.onDispose();
  }
}

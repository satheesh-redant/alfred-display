import 'dart:async';
import 'package:alfred/src/shared/services/operation_mode_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ros_service.dart';
import '../../../shared/services/boot_check_service.dart';
import '../states/loading_screen_state.dart';

class LoadingScreenViewModel extends StateNotifier<LoadingScreenState> {
  final ROSService _rosService;
  final BootCheckService _bootCheckService;
  final OperationModeService _operationsService;

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _bootCheckSubscription;
  StreamSubscription? _operationsSubscription;
  Timer? _retryTimer;

  static const Duration _retryInterval = Duration(seconds: 5);

  LoadingScreenViewModel(
      this._rosService,
      this._bootCheckService,
      this._operationsService,
      ) : super(LoadingScreenState(
    step: LoadingStep.connecting,
    connectionStatus: ROSConnectionStatus.disconnected,
    statusMessage: 'Initializing connection...',
  ));

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
            state = state.copyWith(statusMessage: 'Connecting to ROS WebSocket...');
            break;

          case ROSConnectionStatus.connected:
            print('ROS connected');
            _stopRetryTimer();
            state = state.copyWith(statusMessage: 'Connected! Checking system status...');
            _startBootCheck();
            break;

          case ROSConnectionStatus.error:
          case ROSConnectionStatus.disconnected:
            print('ROS disconnected - retrying');
            _cleanupTopicSubscriptions();
            _startRetryTimer();
            break;
        }
      },
    );
  }

  Future<void> _attemptConnection() async {
    try {
      await _rosService.connect();
    } catch (e) {
      // Error will be handled by connection stream
    }
  }

  void _startRetryTimer() {
    _stopRetryTimer();

    state = state.copyWith(
      statusMessage: 'Connection failed. Retrying in ${_retryInterval.inSeconds} seconds...',
    );

    _retryTimer = Timer.periodic(_retryInterval, (timer) {
      _attemptConnection();
    });
  }

  void _stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _startBootCheck() {
    print('Starting boot check');

    state = state.copyWith(
      step: LoadingStep.bootChecking,
      statusMessage: 'Checking system status...',
    );

    _bootCheckSubscription = _bootCheckService.subscribeToBootCheck().listen(
          (bootResponse) {
        state = state.copyWith(bootCheckResponse: bootResponse);

        if (bootResponse.isReady) {
          print('System ready');
          state = state.copyWith(statusMessage: 'System ready! Getting operation mode...');
          _startOpsMode();
        } else if (bootResponse.hasFailed) {
          print('Boot check failed: ${bootResponse.message}');
          state = state.copyWith(
            statusMessage: 'System check failed: ${bootResponse.message}. Waiting for system recovery...',
          );
        } else if (bootResponse.isLoading) {
          state = state.copyWith(
            statusMessage: bootResponse.message.isNotEmpty
                ? bootResponse.message
                : 'System is initializing...',
          );
        }
      },
      onError: (error) {
        print('Boot check error: $error');
      },
    );
  }

  void _startOpsMode() {
    print('Getting operation mode');

    _bootCheckSubscription?.cancel();
    _bootCheckService.dispose();

    state = state.copyWith(
      step: LoadingStep.opsMode,
      statusMessage: 'Getting operation mode...',
    );

    _operationsService.subscribeToOpsMode();

    _operationsSubscription = _operationsService.operationStream.listen(
          (operationMode) {
        print('Operation mode: $operationMode');

        state = state.copyWith(
          operationMode: operationMode,
          step: LoadingStep.navigating,
          statusMessage: 'Starting ${operationMode.toString().split('.').last} mode...',
        );
      },
      onError: (error) {
        print('Ops mode error: $error');
      },
    );
  }

  void _cleanupTopicSubscriptions() {
    _bootCheckSubscription?.cancel();
    _operationsSubscription?.cancel();
    _bootCheckService.dispose();

    if (state.step != LoadingStep.connecting) {
      state = state.copyWith(
        step: LoadingStep.connecting,
        bootCheckResponse: null,
        operationMode: null,
      );
    }
  }

  @override
  void dispose() {
    _stopRetryTimer();
    _connectionSubscription?.cancel();
    _bootCheckSubscription?.cancel();
    _operationsSubscription?.cancel();
    _bootCheckService.dispose();
    super.dispose();
  }
}

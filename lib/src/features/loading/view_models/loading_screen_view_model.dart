//retry
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ros_service.dart';
import '../states/loading_screen_state.dart';

class LoadingScreenViewModel extends StateNotifier<LoadingScreenState> {
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

  // void _startBootCheck() {
  //   print('Starting boot check');
  //
  //   state = state.copyWith(
  //     step: LoadingStep.bootChecking,
  //     statusMessage: 'Checking system status...',
  //   );
  //
  //   _bootCheckSubscription = _rosService.bootCheckStream.listen(
  //         (rawBootMsg) {
  //       try {
  //         final Map<String, dynamic> outer = jsonDecode(rawBootMsg);
  //
  //         final String? nested = outer["value"];
  //         if (nested == null || nested.isEmpty) {
  //           state = state.copyWith(statusMessage: "Boot check running...");
  //           return;
  //         }
  //
  //         final Map<String, dynamic> value = jsonDecode(nested);
  //         final String overallStatus = (value["overall_status"] ?? "").toString();
  //         final String msg = (value["message"] ?? "").toString();
  //
  //         if (overallStatus.isEmpty) {
  //           state = state.copyWith(
  //             statusMessage:
  //             msg.isEmpty ? "System initializing..." : msg,
  //           );
  //           return;
  //         }
  //
  //         if (overallStatus == "OK") {
  //           print("System READY");
  //           state = state.copyWith(
  //             statusMessage: "System ready! Getting operation mode...",
  //           );
  //           _startOpsMode();
  //           return;
  //         }
  //
  //         state = state.copyWith(
  //           statusMessage:
  //           "System check failed: $msg. Waiting for system recovery...",
  //         );
  //         return;
  //       } catch (e) {
  //         print("Boot parse error: $e");
  //         state = state.copyWith(statusMessage: "Checking for system status...");
  //       }
  //     },
  //     onError: (error) => print('Boot check error: $error'),
  //   );
  // }


  void _startBootCheck() {
    print('Starting boot check');

    state = state.copyWith(
      step: LoadingStep.bootChecking,
      statusMessage: 'Checking system status...',
    );

    _bootCheckSubscription = _rosService.bootCheckStream.listen(
          (rawBootMsg) {
        try {
          // 🔥 First check if boot msg is NOT json (Success / Failed / Ready etc.)
          if (!rawBootMsg.trim().startsWith("{")) {
            state = state.copyWith(statusMessage: rawBootMsg);
            return;
          }

          final Map<String, dynamic> outer = jsonDecode(rawBootMsg);

          final String? nested = outer["value"];
          if (nested == null || nested.isEmpty) {
            state = state.copyWith(statusMessage: "Boot check running...");
            return;
          }

          final Map<String, dynamic> value = jsonDecode(nested);
          final String overallStatus = (value["overall_status"] ?? "").toString();
          final String msg = (value["message"] ?? "").toString();

          if (overallStatus.isEmpty) {
            state = state.copyWith(
              statusMessage: msg.isEmpty ? "System initializing..." : msg,
            );
            return;
          }

          if (overallStatus == "OK") {
            print("System READY");
            state = state.copyWith(
              statusMessage: "System ready! Getting operation mode...",
            );
            _startOpsMode();
            return;
          }

          state = state.copyWith(
            statusMessage:
            "System check failed: $msg. Waiting for system recovery...",
          );
          return;

        } catch (e) {
          print("Boot parse error: $e");
          state = state.copyWith(statusMessage: "Checking for system status...");
        }
      },
      onError: (error) => print('Boot check error: $error'),
    );
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
        print("Operation mode: $operationMode");
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
  void dispose() {
    _connectionSubscription?.cancel();
    _bootCheckSubscription?.cancel();
    _operationsSubscription?.cancel();
    super.dispose();
  }
}

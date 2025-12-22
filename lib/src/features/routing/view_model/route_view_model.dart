import 'dart:async';
import 'package:alfred/src/core/base/base_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/rosbridge.dart';

import '../../../core/configs/ros_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ros_service.dart';
import '../states/route_state.dart';

class RouteViewModel extends BaseViewModel<RouteState> {
  final ROSService _rosService;

  StreamSubscription? _routeAckSubscription;
  StreamSubscription? _operationsSubscription;

  RouteViewModel(this._rosService) : super(RouteState()) {
    _initializeListeners();
  }

  void _initializeListeners() async {
    _routeAckSubscription = _rosService.routingAckStream.listen((status) {
      if (status.toUpperCase() == ROSConstants.success) {
        safeUpdateState(state.copyWith(isLoading: false, isMarked: true, statusMessage: "Waypoint marked successfully"));
      }
    });

    _operationsSubscription = _rosService.modeStream.listen(
          (operationMode) {
        if (operationMode.name == ROSConstants.mode_navigation) {
          state = state.copyWith(
            isModeChanged: true,
            statusMessage: "Starting ${operationMode.name} mode...",
          );
        }
      },
      onError: (error) => print('Ops mode error: $error'),
    );
  }

  void markWaypoint({required String data}) {
    safeUpdateState(state.copyWith(isLoading: true, isMarked: false, statusMessage: 'Marking waypoint...'));
    _rosService.sendWaypoint(data: data);
  }

  Future<void> changeMode() async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      await _rosService.requestModeChange(ROSConstants.mode_navigation);
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Error saving map: $e',
      );
    }
  }

  @override
  void onDispose() {
    _routeAckSubscription!.cancel();
    _operationsSubscription!.cancel();
    super.onDispose();
  }
}

final routeVMProvider =
    StateNotifierProvider<RouteViewModel, RouteState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final routeVM = RouteViewModel(rosService);
  ref.onDispose(() => routeVM.dispose());
  return routeVM;
});

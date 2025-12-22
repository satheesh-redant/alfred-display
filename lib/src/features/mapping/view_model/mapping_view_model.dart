import 'dart:async';
import 'package:alfred/src/core/base/base_view_model.dart';
import 'package:alfred/src/core/configs/ros_constants.dart';
import 'package:alfred/src/features/mapping/data/mapping_repo.dart';
import '../states/mapping_state.dart';

class MappingViewModel extends BaseViewModel<MappingState> {
  final MappingRepository _repository;

  StreamSubscription? _rosConnectionStream;
  StreamSubscription? _mapSub;
  StreamSubscription? _poseSub;
  StreamSubscription? _mapSaveSub;
  StreamSubscription? _operationsSubscription;

  bool _started = false;

  MappingViewModel(this._repository) : super(MappingState.initial());

  Future<void> initialize() async {
    try {
      await _repository.initialize();

      state = state.copyWith(
        statusMessage: 'Mapping repository initialized',
      );
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Error initializing SLAM: $e',
      );
    }
  }

  Future<void> startMapping() async {
    if (_started) return;
    _started = true;

    state = state.copyWith(
      statusMessage: 'Starting mapping...',
    );

    _mapSub = _repository.mapStream.listen((map) {
      state = state.copyWith(
        map: map,
      );
    });

    _poseSub = _repository.poseStream.listen((pose) {
      state = state.copyWith(
        pose: pose,
      );
    });

    _mapSaveSub = _repository.mapSavedAckStream.listen((msg) {
      if (msg.isEmpty) return;
      bool isSaved = false;
      if (msg.toUpperCase() == ROSConstants.success) {
        isSaved = true;
      }
      state = state.copyWith(
          statusMessage: msg, isSaving: false, mapSaved: isSaved);
    });

    _operationsSubscription = _repository.rosService.modeStream.listen(
      (operationMode) {
        if (operationMode.name == ROSConstants.mode_routing) {
          state = state.copyWith(
            isSaving: false,
            isModeChanged: true,
            statusMessage: "Starting ${operationMode.name} mode...",
          );
        }
      },
      onError: (error) => print('Ops mode error: $error'),
    );

    try {
      await _repository.start();
      state = state.copyWith(
        statusMessage: 'Mapping started - drive Alfred around',
      );
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Error starting mapping: $e',
      );
    }
  }

  Future<void> saveMap() async {
    state = state.copyWith(
      isSaving: true,
      mapSaved: false,
      statusMessage: 'Saving map...',
    );

    try {
      await _repository.saveMap();
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        statusMessage: 'Error saving map: $e',
      );
    }
  }

  Future<void> changeMode() async {
    state = state.copyWith(
      isSaving: true,
    );

    try {
      await _repository.rosService.requestModeChange(ROSConstants.mode_routing);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        statusMessage: 'Error saving map: $e',
      );
    }
  }

  Future<void> stopMapping() async {
    _started = false;
    await _repository.stop();

    await _mapSub?.cancel();
    await _poseSub?.cancel();
    await _mapSaveSub?.cancel();
    await _operationsSubscription?.cancel();

    _mapSub = null;
    _poseSub = null;
    _mapSaveSub = null;

    state = MappingState.initial();
  }

  @override
  void onDispose() {
    stopMapping();
    _repository.dispose();
    super.onDispose();
  }
}


import 'package:alfred/src/features/mapping/model/map_model.dart';
import 'package:alfred/src/features/mapping/model/robot_pose.dart';


class MappingState {
  final MapData? map;
  final RobotPose? pose;
  final String statusMessage;
  final bool isSaving;
  final bool mapSaved;

  const MappingState({
    this.map,
    this.pose,
    this.statusMessage = '',
    this.isSaving = false,
    this.mapSaved = false,
  });

  factory MappingState.initial() {
    return MappingState(
      map: null,
      pose: null,
      statusMessage: 'Initializing...',
      isSaving: false,
      mapSaved: false,
    );
  }

  MappingState copyWith({
    MapData? map,
    RobotPose? pose,
    String? statusMessage,
    bool? isSaving,
    bool? mapSaved,
  }) {
    return MappingState(
      map: map ?? this.map,
      pose: pose ?? this.pose,
      statusMessage: statusMessage ?? this.statusMessage,
      isSaving: isSaving ?? this.isSaving,
      mapSaved: mapSaved ?? this.mapSaved,
    );
  }
}

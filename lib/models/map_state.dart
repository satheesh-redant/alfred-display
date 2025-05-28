class MapState {
  final List<int> mapData;
  final int mapWidth;
  final int mapHeight;

  const MapState({
    this.mapData = const [],
    this.mapWidth = 10,
    this.mapHeight = 10,
  });

  MapState copyWith({
    List<int>? mapData,
    int? mapWidth,
    int? mapHeight,
  }) {
    return MapState(
      mapData: mapData ?? this.mapData,
      mapWidth: mapWidth ?? this.mapWidth,
      mapHeight: mapHeight ?? this.mapHeight,
    );
  }
}

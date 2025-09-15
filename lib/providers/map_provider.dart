import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapData {
  final List<List<int>> occupancyGrid;
  final double resolution;
  final int width;
  final int height;
  final double originX;
  final double originY;
  final DateTime timestamp;

  MapData({
    required this.occupancyGrid,
    required this.resolution,
    required this.width,
    required this.height,
    required this.originX,
    required this.originY,
    required this.timestamp,
  });

  factory MapData.fromJson(Map<String, dynamic> json) {
    final info = json['info'];
    final data = List<int>.from(json['data']);

    final width = (info['width'] as num).toInt();
    final height = (info['height'] as num).toInt();
    final grid = <List<int>>[];

    for (int y = 0; y < height; y++) {
      final row = <int>[];
      for (int x = 0; x < width; x++) {
        row.add(data[y * width + x]);
      }
      grid.add(row);
    }

    return MapData(
      occupancyGrid: grid,
      resolution: (info['resolution'] as num).toDouble(),
      width: width,
      height: height,
      originX: (info['origin']['position']['x'] as num).toDouble(),
      originY: (info['origin']['position']['y'] as num).toDouble(),
      timestamp: DateTime.now(),
    );
  }
}

class MapNotifier extends StateNotifier<MapData?> {
  MapNotifier() : super(null);

  void updateMapData(MapData mapData) {
    state = mapData;
  }

  void clearMap() {
    state = null;
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapData?>((ref) {
  return MapNotifier();
});

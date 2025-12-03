import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapData {
  final int width;
  final int height;
  final double resolution;
  final double originX;
  final double originY;
  final List<List<int>> occupancyGrid;

  MapData({
    required this.width,
    required this.height,
    required this.resolution,
    required this.originX,
    required this.originY,
    required this.occupancyGrid,
  });

  factory MapData.fromJson(Map<dynamic, dynamic> json) {
    final info = json['info'];
    final width = info['width'] as int;
    final height = info['height'] as int;
    final resolution = (info['resolution'] as num).toDouble();

    final origin = info['origin'];
    final originX = (origin['position']['x'] as num).toDouble();
    final originY = (origin['position']['y'] as num).toDouble();

    // ROS OccupancyGrid data format:
    // Row-major order: data[y * width + x]
    // Origin at bottom-left: (0,0)
    // X-axis: left to right (columns)
    // Y-axis: bottom to top (rows)

    final data = (json['data'] as List).cast<int>();

    // Convert flat array to 2D grid [y][x]
    // data[y * width + x] -> grid[y][x]
    final grid = List.generate(
      height,
          (y) => List.generate(
        width,
            (x) => data[y * width + x],
      ),
    );

    print('Map loaded: ${width}x${height}, resolution: ${resolution}m');
    print('Origin: ($originX, $originY)');

    return MapData(
      width: width,
      height: height,
      resolution: resolution,
      originX: originX,
      originY: originY,
      occupancyGrid: grid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MapData &&
              runtimeType == other.runtimeType &&
              width == other.width &&
              height == other.height &&
              resolution == other.resolution;

  @override
  int get hashCode => width.hashCode ^ height.hashCode ^ resolution.hashCode;
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

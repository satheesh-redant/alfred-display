import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/map_state.dart';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/rosbridge.dart';

class MapViewModel extends StateNotifier<MapState> {
  final ROSService _rosService;
  late final Topic mapTopic;

  MapViewModel(this._rosService) : super(const MapState()) {
    _initMap();
  }

  void _initMap() {
    // Use createTopic from ROSService.
    mapTopic = _rosService.createTopic(
      ROSConstants.mapTopic,
      ROSConstants.mapTopicMsg,
      queueSize: 10,
      throttleRate: 500,
    );
    mapTopic.reconnectOnClose = true;
    mapTopic.queueLength = 10;
    mapTopic.subscribe(_mapHandler);
  }

  Future<void> _mapHandler(Map<String, dynamic> message) async {
    final newData = json.encode(message['data']);
    final currentData = json.encode(state.mapData);
    if (newData == currentData) return;
    state = state.copyWith(
      mapData: List<int>.from(message['data']),
      mapWidth: message['info']['width'],
      mapHeight: message['info']['height'],
    );
  }

  Future<ui.Image> generateMapImage(Color fill, Color border) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      _toRGBA(fill: fill, border: border),
      state.mapWidth,
      state.mapHeight,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  Uint8List _toRGBA({required Color border, required Color fill}) {
    final builder = BytesBuilder();
    for (var value in state.mapData) {
      if (value == -1) {
        builder.add([0, 0, 0, 0]);
      } else if (value == 0) {
        builder.add([fill.red, fill.green, fill.blue, fill.alpha]);
      } else {
        builder.add([border.red, border.green, border.blue, border.alpha]);
      }
    }
    return builder.takeBytes();
  }

  @override
  void dispose() {
    mapTopic.unsubscribe();
    super.dispose();
  }
}

final mapVMProvider = StateNotifierProvider<MapViewModel, MapState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return MapViewModel(rosService);
});

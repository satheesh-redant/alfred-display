import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/route_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class RouteViewModel extends StateNotifier<String> {

  final ROSService _rosService;
  Topic? _topicRoute, _topicRouteAck;

  RouteViewModel(this._rosService) : super("");

  Future<void> sendRouteData({required int table, required int route}) async {
    print("Sending route data : $table, $route");
    _topicRoute = _rosService.createTopic(
      ROSConstants.topicRoute,
      ROSConstants.msgString,
    );

    RouteState routeState = RouteState(tableNumber: table, route: route);

    Map<String, dynamic> json = {"data": routeStateToJson(routeState)};
    await _topicRoute!.publish(json);
  }

  Future<void> routeAckStatus() async {
    print('initiating delivery status topic...');
    _topicRouteAck = _rosService.createTopic(
      ROSConstants.topicRouteAck,
      ROSConstants.msgString,
      throttleRate: 500,
    );

    _topicRouteAck!.subscribe(_handlerAck);
  }

  Future<void> _handlerAck(Map<String, dynamic> message) async {
    print(message);
    state = message['data'];
  }

  void unsubscribe() {
    _topicRouteAck!.unsubscribe();
    state = "";
  }

}

final routeVMProvider = StateNotifierProvider<RouteViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return RouteViewModel(rosService);
});

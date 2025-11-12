import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alfred/config/ros_constants.dart';
import 'package:rosbridge/rosbridge.dart';

class ROSService {
  // Using a singleton approach.
  static final ROSService _instance = ROSService._internal();
  factory ROSService() => _instance;

  late final Ros ros;

  ROSService._internal(){
    print('Initializing ROS service... ');
    ros = Ros(url: ROSConstants.rosUrl);
  }

  Future<void> connect() async {
    print('Connecting to ${ROSConstants.rosUrl}');
    await ros.connect();
  }

  /// Helper method to create a topic.
  Topic createTopic(String name, String type,
      {int queueSize = 10, int throttleRate = 0, reconnectOnClose = true}) {
    return Topic(
      ros: ros,
      name: name,
      type: type,
      queueSize: queueSize,
      throttleRate: throttleRate,
      reconnectOnClose: reconnectOnClose
    );
  }
}

final rosServiceProvider = Provider<ROSService>((ref) {
  return ROSService();
});

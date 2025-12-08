class ROSConstants {

  // static const String rosUrl = 'ws://192.168.133.56:9090';
  static const String rosUrl = 'ws://127.0.0.1:9090';
  // static const String rosUrl = 'ws://192.168.0.146:9090';

  /*  GENERIC */
  static const String msgString = 'std_msgs/String';
  static const String stringMessageType = 'std_msgs/String';
  static const String msgInteger = 'std_msgs/Int32';
  static const String msgFloat = 'std_msgs/Float32';
  static const String msgEmpty = 'std_msgs/Empty';
  static const String emptyMessageType = 'std_msgs/Empty';

  // static const String mapTopic = '/map';
  // static const String mapTopicMsg = 'nav_msgs/msg/OccupancyGrid';
  static const String mapTopic = '/map';
  static const String mapTopicMsg = 'nav_msgs/msg/OccupancyGrid';

  static const String odomTopic = '/diff_cont/odom';
  static const String odomTopicMsg = 'nav_msgs/msg/Odometry';

  /*  BOOT STATUS CHECK */
  static const String topicBootCheck = '/boot_check';

  /*  BATTERY */
  static const String topicBattery = '/battery_status';
  static const String batteryTopicType = 'sensor_msgs/msg/BatteryState';
  /*  OPERATIONS  */
  static const String topicSetOpsMode = '/set_mode';
  // static const String topicCurrentMode = '/current_mode';

  /*  TABLES  */
  // static const String topicAddTable = '/add_table';
  static const String topicAddTable = '/save_point';
  static const String topicAddTableAck = '/add_table_ack';
  static const String topicGetTables = '/get_table_list';
  static const String topicTablesList = '/table_list';

  /*  BASE POINT  */
  static const String topicResetBaseLoc = '/reset_base_loc';
  static const String topicResetBaseLocAck = '/reset_base_loc_ack';

  static const String topicReturnToBase = '/return_base';
  static const String topicReturnToBaseAck = '/return_base_ack';

  /*  DELIVERY  */
  // static const String topicMoveTable = '/move_to_table';
  static const String topicMoveTable = '/goto_point';
  static const String topicDeliveryStatus = '/delivery_status';
  static const String topicPowerOff = "/power_off";

  /*  ROUTE */
  static const String topicRoute = '/save_route';
  static const String topicRouteAck = '/save_route_ack';

  static const String success = 'SUCCESS';

  static const String topicSaveMap = '/save_map';
  static const String topicMapSaved = '/map_saved';
}

class ROSConstants {

  static const String rosUrl = 'ws://127.0.0.1:9090';

  /*  GENERIC */
  static const String msgString = 'std_msgs/String';
  static const String msgInteger = 'std_msgs/Int32';
  static const String msgFloat = 'std_msgs/Float32';
  static const String msgEmpty = 'std_msgs/Empty';

  static const String mapTopic = '/map';
  static const String mapTopicMsg = 'nav_msgs/msg/OccupancyGrid';

  static const String tfTopic = '/tf';
  static const String tfTopicMsg = 'tf2_msgs/msg/TFMessage';

  /*  BOOT STATUS CHECK */
  static const String topicBootCheck = '/boot_check';

  /*  BATTERY */
  static const String topicBattery = '/battery_state';
  static const String batteryTopicType = 'sensor_msgs/msg/BatteryState';

  /*  OPERATIONS  */
  static const String topicMode = '/mode';
  static const String topicModeRequested = '/mode_requested';

  /*  TABLES  */
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
  static const String topicMoveTable = '/table_number';
  static const String topicDeliveryStatus = '/delivery_status';

  static const String topicPowerOff = "/power_off";
  static const String topicPowerOffAck = "/power_off_ack";

  /*  ROUTE */
  static const String topicRoute = '/save_wp';
  static const String topicRouteAck = '/save_wp_ack';

  static const String topicSaveMap = '/save_map';
  static const String topicMapSaved = '/map_saved';

  static const String success = 'SUCCESS';

  static const String mode_mapping = 'mapping';
  static const String mode_routing = 'routing';
  static const String mode_navigation = 'navigation';

}

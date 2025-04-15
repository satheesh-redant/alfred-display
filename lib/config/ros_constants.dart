class ROSConstants {
  // static const String rosUrl = 'ws://127.0.0.1:9090';
  static const String rosUrl = 'ws://10.0.2.2:9090'; //emulator

  // static const String rosUrl = 'ws://192.168.1.7:9090'; //emulator

  /*  GENERIC */
  static const String msgString = 'std_msgs/String';
  static const String msgInteger = 'std_msgs/Int32';
  static const String msgFloat = 'std_msgs/Float32';
  static const String msgEmpty = 'std_msgs/Empty';

  static const String mapTopic = '/map';
  static const String mapTopicMsg = 'nav_msgs/msg/OccupancyGrid';

  static const String odomTopic = '/diff_cont/odom';
  static const String odomTopicMsg = 'nav_msgs/msg/Odometry';

  /*  BOOT STATUS CHECK */
  static const String topicBootCheck = '/boot_check';

  /*  BATTERY */
  static const String topicBattery = '/battery_status';

  /*  OPERATIONS  */
  static const String topicSetOpsMode = '/set_mode';
  static const String topicCurrentMode = '/current_mode';

  /*  TABLES  */
  static const String topicAddTable = '/add_table';
  static const String topicGetTables = '/table_list';
  static const String topicMoveTable = '/move_to_table';
  static const String topicReturnToBase = '/return_to_base';

  static const String cmdVelTopic = '/cmd_vel';

  /*  SERVICE */
  // static const String triggerServiceMsg = 'std_srvs/Trigger';
  // static const String bootStatusService = '/check_boot_status';
  // static const String baseResetService = '/reset_base_location';


}

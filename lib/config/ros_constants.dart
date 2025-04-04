class ROSConstants {
  static const String rosUrl = 'ws://127.0.0.1:9090';

  static const String mapTopic = '/map';
  static const String mapTopicMsg = 'nav_msgs/msg/OccupancyGrid';

  static const String odomTopic = '/diff_cont/odom';
  static const String odomTopicMsg = 'nav_msgs/msg/Odometry';

  static const String cmdVelTopic = '/cmd_vel';

  /*  SERVICE */
  static const String triggerServiceMsg = 'std_srvs/Trigger';
  static const String bootStatusService = '/check_boot_status';
  static const String baseResetService = '/reset_base_location';


}

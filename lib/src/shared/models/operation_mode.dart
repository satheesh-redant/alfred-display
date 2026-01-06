enum OperationMode {
  mapping,
  routing,
  navigation,
  charging,
  unknown;

  static OperationMode fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'mapping':
        return OperationMode.mapping;
      case 'routing':
        return OperationMode.routing;
      case 'navigation':
        return OperationMode.navigation;
      case 'charging':
        return OperationMode.navigation;
      default:
        return OperationMode.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case OperationMode.mapping:
        return 'Mapping Mode';
      case OperationMode.routing:
        return 'Routing Mode';
      case OperationMode.navigation:
        return 'Navigation Mode';
      case OperationMode.charging:
        return 'Charging Mode';
      case OperationMode.unknown:
        return 'Unknown';
    }
  }
}

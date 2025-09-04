import 'dart:convert';

class TriggerResponse {
  final bool success;
  final dynamic message;

  TriggerResponse({
    this.success = false,
    this.message = '',
  });

  /// Creates a TriggerResponse from a JSON map.
  /// If the `message` field is a String, it attempts to decode it as JSON.
  factory TriggerResponse.fromJson(Map<String, dynamic> json) {
    dynamic msg = json['message'];
    if (msg is String) {
      try {
        // Try to decode the string as JSON. If it fails, keep the string.
        msg = jsonDecode(msg);
      } catch (e) {
        // Leave msg as the original string if decoding fails.
      }
    }
    return TriggerResponse(
      success: json['success'] as bool? ?? false,
      message: msg,
    );
  }

  /// Converts this TriggerResponse instance to a JSON map.
  /// If message is a JSON object (Map or List), it is returned as is.
  /// Otherwise, it's returned directly.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

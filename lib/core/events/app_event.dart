/// Base class for all application events
/// Follows the Event Bus pattern for loose coupling
/// 
/// Usage:
/// ```dart
/// class DeviceConnectedEvent extends AppEvent {
///   final String deviceId;
///   DeviceConnectedEvent(this.deviceId);
/// }
/// ```
abstract class AppEvent {
  final DateTime timestamp = DateTime.now();
  
  String get eventType => runtimeType.toString();
}

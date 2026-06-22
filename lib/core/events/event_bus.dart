import 'app_event.dart';

/// Signature for event listeners
typedef EventListener = void Function(AppEvent event);

/// Event Bus interface for publish-subscribe communication
/// 
/// Responsibilities:
/// - Register event listeners
/// - Publish events to all subscribers
/// - Unregister listeners
/// - Handle event filtering by type
/// 
/// Principles:
/// - Loose coupling between components
/// - Reactive updates across the app
/// - Single responsibility (only event distribution)
/// 
/// Example usage:
/// ```dart
/// // Register listener
/// eventBus.listen<DeviceConnectedEvent>((event) {
///   print('Device connected: ${event.deviceId}');
/// });
/// 
/// // Publish event
/// eventBus.publish(DeviceConnectedEvent(deviceId));
/// ```
abstract class EventBus {
  /// Register a listener for a specific event type
  /// Returns an unsubscribe function
  Function unsubscribe<T extends AppEvent>(EventListener listener);
  
  /// Listen to a specific event type with type-safe handler
  void listen<T extends AppEvent>(void Function(T event) handler);
  
  /// Publish an event to all listeners
  Future<void> publish(AppEvent event);
  
  /// Clear all listeners (useful for testing)
  void clear();
  
  /// Check if there are listeners for an event type
  bool hasListeners<T extends AppEvent>();
  
  /// Get listener count for debugging
  int getListenerCount();
}

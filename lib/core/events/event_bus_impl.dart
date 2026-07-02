import 'package:logger/logger.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/events/app_event.dart';

/// Logger instance for event bus
final _logger = Logger();

/// Implementation of the Event Bus interface
/// 
/// Provides publish-subscribe functionality for application events.
/// Uses a map of event types to listener lists for efficient event routing.
/// 
/// Features:
/// - Type-safe generic event handling
/// - Multiple subscribers per event type
/// - Unsubscribe functionality via returned function
/// - Event filtering by type
/// - Debug utilities (listener count, hasListeners)
/// 
/// Example:
/// ```dart
/// final eventBus = EventBusImpl();
/// 
/// // Subscribe to protocol added event
/// eventBus.listen<ProtocolAddedEvent>((event) {
///   print('Protocol added: ${event.protocol.name}');
/// });
/// 
/// // Publish event
/// eventBus.publish(ProtocolAddedEvent(protocol));
/// ```
class EventBusImpl implements EventBus {
  final Map<Type, List<EventListener>> _listeners = {};

  @override
  Function listen<T extends AppEvent>(void Function(T event) handler) {
    final key = T;
    
    if (!_listeners.containsKey(key)) {
      _listeners[key] = [];
    }
    
    // Wrap the typed handler in an EventListener
    final listener = (AppEvent event) {
      if (event is T) {
        handler(event);
      }
    };
    
    _listeners[key]!.add(listener);
    
    // Return unsubscribe function
    return () {
      if (_listeners.containsKey(key)) {
        _listeners[key]!.remove(listener);
        if (_listeners[key]!.isEmpty) {
          _listeners.remove(key);
        }
      }
    };
  }

  @override
  Function unsubscribe<T extends AppEvent>(EventListener listener) {
    final key = T;
    
    return () {
      if (_listeners.containsKey(key)) {
        _listeners[key]!.remove(listener);
        if (_listeners[key]!.isEmpty) {
          _listeners.remove(key);
        }
      }
    };
  }

  @override
  Future<void> publish(AppEvent event) async {
    final key = event.runtimeType;
    
    if (_listeners.containsKey(key)) {
      // Publish to all listeners for this event type
      for (final listener in _listeners[key]!) {
        try {
          await Future.microtask(() => listener(event));
        } catch (e) {
          // Log errors but continue processing other listeners
          _logger.e('Error in event listener: $e');
        }
      }
    }
  }

  @override
  void clear() {
    _listeners.clear();
  }

  @override
  bool hasListeners<T extends AppEvent>() {
    return _listeners.containsKey(T) && _listeners[T]!.isNotEmpty;
  }

  @override
  int getListenerCount() {
    return _listeners.values.fold(0, (sum, list) => sum + list.length);
  }
}

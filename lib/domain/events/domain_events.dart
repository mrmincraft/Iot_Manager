import '../../core/events/app_event.dart';
import '../entities/device.dart';

/// Device Connected Event
class DeviceConnectedEvent extends AppEvent {
  final String deviceId;
  final Device device;
  final int signalStrength;
  
  DeviceConnectedEvent({
    required this.deviceId,
    required this.device,
    required this.signalStrength,
  });
}

/// Device Disconnected Event
class DeviceDisconnectedEvent extends AppEvent {
  final String deviceId;
  final String? reason;
  
  DeviceDisconnectedEvent({
    required this.deviceId,
    this.reason,
  });
}

/// Device Added Event
class DeviceAddedEvent extends AppEvent {
  final Device device;
  
  DeviceAddedEvent(this.device);
}

/// Device Updated Event
class DeviceUpdatedEvent extends AppEvent {
  final Device device;
  
  DeviceUpdatedEvent(this.device);
}

/// Device Removed Event
class DeviceRemovedEvent extends AppEvent {
  final String deviceId;
  
  DeviceRemovedEvent(this.deviceId);
}

/// Connection Status Changed Event
class ConnectionStatusChangedEvent extends AppEvent {
  final String deviceId;
  final String previousStatus;
  final String newStatus;
  final int signalStrength;
  
  ConnectionStatusChangedEvent({
    required this.deviceId,
    required this.previousStatus,
    required this.newStatus,
    required this.signalStrength,
  });
}

/// Command Executed Event
class CommandExecutedEvent extends AppEvent {
  final String commandId;
  final String deviceId;
  final String status;
  final String? response;
  
  CommandExecutedEvent({
    required this.commandId,
    required this.deviceId,
    required this.status,
    this.response,
  });
}

/// Error Event
class ErrorEvent extends AppEvent {
  final String message;
  final String? code;
  final Exception? exception;
  
  ErrorEvent({
    required this.message,
    this.code,
    this.exception,
  });
}

import '../../core/events/app_event.dart';
import '../entities/log_entry.dart';

/// Event fired when a new log entry is created
class LogEntryCreatedEvent extends AppEvent {
  final LogEntry logEntry;

  LogEntryCreatedEvent(this.logEntry);
}

/// Event fired when log entries are loaded
class LogEntriesLoadedEvent extends AppEvent {
  final List<LogEntry> logEntries;

  LogEntriesLoadedEvent(this.logEntries);
}

/// Event fired when a log entry is deleted
class LogEntryDeletedEvent extends AppEvent {
  final String logEntryId;
  final LogEntry? deletedLogEntry;

  LogEntryDeletedEvent({
    required this.logEntryId,
    this.deletedLogEntry,
  });
}

/// Event fired when logs are cleared for a connection
class LogsClearedEvent extends AppEvent {
  final String connectionId;
  final int clearedCount;

  LogsClearedEvent({
    required this.connectionId,
    required this.clearedCount,
  });
}

/// Event fired when a critical log entry is created
class CriticalLogEvent extends AppEvent {
  final LogEntry logEntry;
  final String severity;

  CriticalLogEvent({
    required this.logEntry,
    required this.severity,
  });
}

/// Event fired when logs reach maximum size threshold
class LogSizeThresholdReachedEvent extends AppEvent {
  final String connectionId;
  final int currentSize;
  final int maxSize;

  LogSizeThresholdReachedEvent({
    required this.connectionId,
    required this.currentSize,
    required this.maxSize,
  });
}

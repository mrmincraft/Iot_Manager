// Domain Entity: LogEntry
// Représente une entrée de log du système

enum LogSeverity { debug, info, warning, error, critical }
enum LogCategory { connection, message, device, system, security, performance }

class LogEntry {
  final String id;
  final LogSeverity severity;
  final LogCategory category;
  final String message;
  final String? details;
  final String? stackTrace;
  final String? userId;
  final String? connectionId;
  final String? topicId;
  final Map<String, dynamic> metadata;
  final bool isResolved;
  final String? resolutionNotes;
  final DateTime timestamp;
  final DateTime? resolvedAt;

  LogEntry({
    required this.id,
    required this.severity,
    required this.category,
    required this.message,
    this.details,
    this.stackTrace,
    this.userId,
    this.connectionId,
    this.topicId,
    required this.metadata,
    required this.isResolved,
    this.resolutionNotes,
    required this.timestamp,
    this.resolvedAt,
  });

  /// Détermine si c'est un log critique
  bool get isCritical => severity == LogSeverity.critical || severity == LogSeverity.error;

  /// Crée une copie avec propriétés modifiées
  LogEntry copyWith({
    String? id,
    LogSeverity? severity,
    LogCategory? category,
    String? message,
    String? details,
    String? stackTrace,
    String? userId,
    String? connectionId,
    String? topicId,
    Map<String, dynamic>? metadata,
    bool? isResolved,
    String? resolutionNotes,
    DateTime? timestamp,
    DateTime? resolvedAt,
  }) {
    return LogEntry(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      message: message ?? this.message,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      userId: userId ?? this.userId,
      connectionId: connectionId ?? this.connectionId,
      topicId: topicId ?? this.topicId,
      metadata: metadata ?? this.metadata,
      isResolved: isResolved ?? this.isResolved,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      timestamp: timestamp ?? this.timestamp,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LogEntry(id: $id, severity: $severity, category: $category)';
}

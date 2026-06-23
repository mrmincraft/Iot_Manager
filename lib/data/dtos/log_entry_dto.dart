// DTO: LogEntryDTO
// Data Transfer Object pour LogEntry

class LogEntryDTO {
  final String id;
  final String severity;
  final String category;
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

  LogEntryDTO({
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

  factory LogEntryDTO.fromJson(Map<String, dynamic> json) {
    return LogEntryDTO(
      id: json['id'] as String,
      severity: json['severity'] as String,
      category: json['category'] as String,
      message: json['message'] as String,
      details: json['details'] as String?,
      stackTrace: json['stackTrace'] as String?,
      userId: json['userId'] as String?,
      connectionId: json['connectionId'] as String?,
      topicId: json['topicId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      isResolved: json['isResolved'] as bool,
      resolutionNotes: json['resolutionNotes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'severity': severity,
      'category': category,
      'message': message,
      'details': details,
      'stackTrace': stackTrace,
      'userId': userId,
      'connectionId': connectionId,
      'topicId': topicId,
      'metadata': metadata,
      'isResolved': isResolved,
      'resolutionNotes': resolutionNotes,
      'timestamp': timestamp.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'LogEntryDTO(id: $id, severity: $severity, category: $category)';
}

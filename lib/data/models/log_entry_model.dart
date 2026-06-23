// SQLite Model: LogEntryModel
// Modèle de données pour la table log_entries en SQLite

class LogEntryModel {
  final String id;
  final String severity;
  final String category;
  final String message;
  final String? details;
  final String? stackTrace;
  final String? userId;
  final String? connectionId;
  final String? topicId;
  final String metadata; // JSON string
  final bool isResolved;
  final String? resolutionNotes;
  final DateTime timestamp;
  final DateTime? resolvedAt;

  LogEntryModel({
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

  factory LogEntryModel.fromMap(Map<String, dynamic> map) {
    return LogEntryModel(
      id: map['id'] as String,
      severity: map['severity'] as String,
      category: map['category'] as String,
      message: map['message'] as String,
      details: map['details'] as String?,
      stackTrace: map['stackTrace'] as String?,
      userId: map['userId'] as String?,
      connectionId: map['connectionId'] as String?,
      topicId: map['topicId'] as String?,
      metadata: map['metadata'] as String,
      isResolved: (map['isResolved'] as int) == 1,
      resolutionNotes: map['resolutionNotes'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      resolvedAt: map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
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
      'isResolved': isResolved ? 1 : 0,
      'resolutionNotes': resolutionNotes,
      'timestamp': timestamp.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'LogEntryModel(id: $id, severity: $severity, category: $category)';
}

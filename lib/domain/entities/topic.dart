// Domain Entity: Topic
// Représente un topic/sujet de communication dans une connexion

enum TopicQos { atMostOnce, atLeastOnce, exactlyOnce }

class Topic {
  final String id;
  final String connectionId;
  final String name;
  final String path;
  final TopicQos qos;
  final bool retain;
  final bool subscribed;
  final String? description;
  final Map<String, String> metadata;
  final int messageCount;
  final DateTime? lastMessageAt;
  final int messageRatePerSecond;
  final DateTime createdAt;
  final DateTime updatedAt;

  Topic({
    required this.id,
    required this.connectionId,
    required this.name,
    required this.path,
    required this.qos,
    required this.retain,
    required this.subscribed,
    this.description,
    required this.metadata,
    required this.messageCount,
    this.lastMessageAt,
    required this.messageRatePerSecond,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie avec propriétés modifiées
  Topic copyWith({
    String? id,
    String? connectionId,
    String? name,
    String? path,
    TopicQos? qos,
    bool? retain,
    bool? subscribed,
    String? description,
    Map<String, String>? metadata,
    int? messageCount,
    DateTime? lastMessageAt,
    int? messageRatePerSecond,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Topic(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      name: name ?? this.name,
      path: path ?? this.path,
      qos: qos ?? this.qos,
      retain: retain ?? this.retain,
      subscribed: subscribed ?? this.subscribed,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      messageCount: messageCount ?? this.messageCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messageRatePerSecond: messageRatePerSecond ?? this.messageRatePerSecond,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Topic &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Topic(id: $id, path: $path, subscribed: $subscribed)';
}

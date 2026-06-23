// SQLite Model: TopicModel
// Modèle de données pour la table topics en SQLite

class TopicModel {
  final String id;
  final String connectionId;
  final String name;
  final String path;
  final String qos;
  final bool retain;
  final bool subscribed;
  final String? description;
  final String metadata; // JSON string
  final int messageCount;
  final DateTime? lastMessageAt;
  final int messageRatePerSecond;
  final DateTime createdAt;
  final DateTime updatedAt;

  TopicModel({
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

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] as String,
      connectionId: map['connectionId'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
      qos: map['qos'] as String,
      retain: (map['retain'] as int) == 1,
      subscribed: (map['subscribed'] as int) == 1,
      description: map['description'] as String?,
      metadata: map['metadata'] as String,
      messageCount: map['messageCount'] as int,
      lastMessageAt: map['lastMessageAt'] != null ? DateTime.parse(map['lastMessageAt'] as String) : null,
      messageRatePerSecond: map['messageRatePerSecond'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'connectionId': connectionId,
      'name': name,
      'path': path,
      'qos': qos,
      'retain': retain ? 1 : 0,
      'subscribed': subscribed ? 1 : 0,
      'description': description,
      'metadata': metadata,
      'messageCount': messageCount,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'messageRatePerSecond': messageRatePerSecond,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'TopicModel(id: $id, path: $path, subscribed: $subscribed)';
}

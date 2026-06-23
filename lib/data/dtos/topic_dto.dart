// DTO: TopicDTO
// Data Transfer Object pour Topic

class TopicDTO {
  final String id;
  final String connectionId;
  final String name;
  final String path;
  final String qos;
  final bool retain;
  final bool subscribed;
  final String? description;
  final Map<String, String> metadata;
  final int messageCount;
  final DateTime? lastMessageAt;
  final int messageRatePerSecond;
  final DateTime createdAt;
  final DateTime updatedAt;

  TopicDTO({
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

  factory TopicDTO.fromJson(Map<String, dynamic> json) {
    return TopicDTO(
      id: json['id'] as String,
      connectionId: json['connectionId'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      qos: json['qos'] as String,
      retain: json['retain'] as bool,
      subscribed: json['subscribed'] as bool,
      description: json['description'] as String?,
      metadata: Map<String, String>.from(json['metadata'] as Map? ?? {}),
      messageCount: json['messageCount'] as int,
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt'] as String) : null,
      messageRatePerSecond: json['messageRatePerSecond'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'connectionId': connectionId,
      'name': name,
      'path': path,
      'qos': qos,
      'retain': retain,
      'subscribed': subscribed,
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
  String toString() => 'TopicDTO(id: $id, path: $path, subscribed: $subscribed)';
}

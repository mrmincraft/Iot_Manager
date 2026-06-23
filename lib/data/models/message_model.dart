// SQLite Model: MessageModel
// Modèle de données pour la table messages en SQLite

class MessageModel {
  final String id;
  final String topicId;
  final String connectionId;
  final String direction;
  final String type;
  final String payload;
  final int payloadSize;
  final String properties; // JSON string
  final String? senderIdentifier;
  final String? receiverIdentifier;
  final bool processed;
  final String? processingError;
  final DateTime timestamp;
  final DateTime receivedAt;

  MessageModel({
    required this.id,
    required this.topicId,
    required this.connectionId,
    required this.direction,
    required this.type,
    required this.payload,
    required this.payloadSize,
    required this.properties,
    this.senderIdentifier,
    this.receiverIdentifier,
    required this.processed,
    this.processingError,
    required this.timestamp,
    required this.receivedAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      topicId: map['topicId'] as String,
      connectionId: map['connectionId'] as String,
      direction: map['direction'] as String,
      type: map['type'] as String,
      payload: map['payload'] as String,
      payloadSize: map['payloadSize'] as int,
      properties: map['properties'] as String,
      senderIdentifier: map['senderIdentifier'] as String?,
      receiverIdentifier: map['receiverIdentifier'] as String?,
      processed: (map['processed'] as int) == 1,
      processingError: map['processingError'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      receivedAt: DateTime.parse(map['receivedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'connectionId': connectionId,
      'direction': direction,
      'type': type,
      'payload': payload,
      'payloadSize': payloadSize,
      'properties': properties,
      'senderIdentifier': senderIdentifier,
      'receiverIdentifier': receiverIdentifier,
      'processed': processed ? 1 : 0,
      'processingError': processingError,
      'timestamp': timestamp.toIso8601String(),
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'MessageModel(id: $id, direction: $direction, type: $type)';
}

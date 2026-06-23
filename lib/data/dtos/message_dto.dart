// DTO: MessageDTO
// Data Transfer Object pour Message

class MessageDTO {
  final String id;
  final String topicId;
  final String connectionId;
  final String direction;
  final String type;
  final String payload;
  final int payloadSize;
  final Map<String, String> properties;
  final String? senderIdentifier;
  final String? receiverIdentifier;
  final bool processed;
  final String? processingError;
  final DateTime timestamp;
  final DateTime receivedAt;

  MessageDTO({
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

  factory MessageDTO.fromJson(Map<String, dynamic> json) {
    return MessageDTO(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      connectionId: json['connectionId'] as String,
      direction: json['direction'] as String,
      type: json['type'] as String,
      payload: json['payload'] as String,
      payloadSize: json['payloadSize'] as int,
      properties: Map<String, String>.from(json['properties'] as Map? ?? {}),
      senderIdentifier: json['senderIdentifier'] as String?,
      receiverIdentifier: json['receiverIdentifier'] as String?,
      processed: json['processed'] as bool,
      processingError: json['processingError'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
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
      'processed': processed,
      'processingError': processingError,
      'timestamp': timestamp.toIso8601String(),
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'MessageDTO(id: $id, direction: $direction, type: $type)';
}

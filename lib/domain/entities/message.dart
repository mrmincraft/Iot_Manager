// Domain Entity: Message
// Représente un message reçu ou envoyé via une connexion

enum MessageDirection { incoming, outgoing }
enum MessageType { text, json, binary, xml }

class Message {
  final String id;
  final String topicId;
  final String connectionId;
  final MessageDirection direction;
  final MessageType type;
  final String payload;
  final int payloadSize;
  final Map<String, String> properties;
  final String? senderIdentifier;
  final String? receiverIdentifier;
  final bool processed;
  final String? processingError;
  final DateTime timestamp;
  final DateTime receivedAt;

  Message({
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

  /// Crée une copie avec propriétés modifiées
  Message copyWith({
    String? id,
    String? topicId,
    String? connectionId,
    MessageDirection? direction,
    MessageType? type,
    String? payload,
    int? payloadSize,
    Map<String, String>? properties,
    String? senderIdentifier,
    String? receiverIdentifier,
    bool? processed,
    String? processingError,
    DateTime? timestamp,
    DateTime? receivedAt,
  }) {
    return Message(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      connectionId: connectionId ?? this.connectionId,
      direction: direction ?? this.direction,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      payloadSize: payloadSize ?? this.payloadSize,
      properties: properties ?? this.properties,
      senderIdentifier: senderIdentifier ?? this.senderIdentifier,
      receiverIdentifier: receiverIdentifier ?? this.receiverIdentifier,
      processed: processed ?? this.processed,
      processingError: processingError ?? this.processingError,
      timestamp: timestamp ?? this.timestamp,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Message(id: $id, direction: $direction, type: $type)';
}

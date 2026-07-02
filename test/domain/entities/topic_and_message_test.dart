import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/domain/entities/topic.dart';
import 'package:iot_manager/domain/entities/message.dart';

void main() {
  group('Topic Entity Tests', () {
    group('Topic Creation', () {
      test('creates topic with all parameters', () {
        final topic = Topic(
          id: 'topic-001',
          connectionId: 'conn-001',
          name: 'sensors/temperature',
          description: 'Temperature sensor data',
          qos: MessageQoS.atLeastOnce,
          isSubscribed: true,
          metadata: {'unit': 'celsius'},
        );

        expect(topic.id, 'topic-001');
        expect(topic.connectionId, 'conn-001');
        expect(topic.name, 'sensors/temperature');
        expect(topic.qos, MessageQoS.atLeastOnce);
        expect(topic.isSubscribed, true);
      });

      test('validates topic ID is not empty', () {
        expect(
          () => Topic(
            id: '',
            connectionId: 'conn-001',
            name: 'test/topic',
            qos: MessageQoS.atMostOnce,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates topic name is not empty', () {
        expect(
          () => Topic(
            id: 'topic-001',
            connectionId: 'conn-001',
            name: '',
            qos: MessageQoS.atMostOnce,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('MessageQoS Enum', () {
      test('has atMostOnce level', () {
        expect(MessageQoS.atMostOnce, MessageQoS.atMostOnce);
      });

      test('has atLeastOnce level', () {
        expect(MessageQoS.atLeastOnce, MessageQoS.atLeastOnce);
      });

      test('has exactlyOnce level', () {
        expect(MessageQoS.exactlyOnce, MessageQoS.exactlyOnce);
      });
    });

    group('Topic copyWith', () {
      test('creates copy with changed values', () {
        final original = Topic(
          id: 'topic-001',
          connectionId: 'conn-001',
          name: 'original/topic',
          qos: MessageQoS.atMostOnce,
        );

        final updated = original.copyWith(
          name: 'updated/topic',
          isSubscribed: true,
        );

        expect(updated.id, 'topic-001'); // Unchanged
        expect(updated.name, 'updated/topic');
        expect(updated.isSubscribed, true);
      });
    });

    group('Topic Subscription State', () {
      test('topic subscription can be toggled', () {
        final unsubscribed = Topic(
          id: 'topic-001',
          connectionId: 'conn-001',
          name: 'test/topic',
          qos: MessageQoS.atLeastOnce,
          isSubscribed: false,
        );

        final subscribed = unsubscribed.copyWith(isSubscribed: true);

        expect(subscribed.isSubscribed, true);
        expect(unsubscribed.isSubscribed, false); // Original unchanged
      });
    });

    group('Topic Hierarchy', () {
      test('supports topic hierarchies with slashes', () {
        final topics = [
          Topic(
            id: 'topic-1',
            connectionId: 'conn-001',
            name: 'home/living_room/temperature',
            qos: MessageQoS.atLeastOnce,
          ),
          Topic(
            id: 'topic-2',
            connectionId: 'conn-001',
            name: 'home/kitchen/humidity',
            qos: MessageQoS.atLeastOnce,
          ),
          Topic(
            id: 'topic-3',
            connectionId: 'conn-001',
            name: 'home/garden/motion',
            qos: MessageQoS.atLeastOnce,
          ),
        ];

        expect(topics[0].name.split('/').length, 3);
        expect(topics[0].name.contains('home'), true);
      });
    });

    group('Topic Wildcard Patterns', () {
      test('topic supports wildcard subscriptions', () {
        final wildcardTopic = Topic(
          id: 'topic-001',
          connectionId: 'conn-001',
          name: 'home/+/temperature',
          qos: MessageQoS.atLeastOnce,
        );

        expect(wildcardTopic.name.contains('+'), true);
      });

      test('topic supports multi-level wildcard', () {
        final multiWildcard = Topic(
          id: 'topic-001',
          connectionId: 'conn-001',
          name: 'home/#',
          qos: MessageQoS.atLeastOnce,
        );

        expect(multiWildcard.name.endsWith('#'), true);
      });
    });
  });

  group('Message Entity Tests', () {
    group('Message Creation', () {
      test('creates message with all parameters', () {
        final now = DateTime.now();
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Temperature: 25.5°C',
          timestamp: now,
          receivedAt: now,
          metadata: {'source': 'sensor-1'},
        );

        expect(message.id, 'msg-001');
        expect(message.topicId, 'topic-001');
        expect(message.connectionId, 'conn-001');
        expect(message.direction, MessageDirection.incoming);
        expect(message.type, MessageType.text);
        expect(message.payload, 'Temperature: 25.5°C');
      });

      test('validates message ID is not empty', () {
        expect(
          () => Message(
            id: '',
            topicId: 'topic-001',
            connectionId: 'conn-001',
            direction: MessageDirection.incoming,
            type: MessageType.text,
            payload: 'test',
            timestamp: DateTime.now(),
            receivedAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('MessageDirection Enum', () {
      test('has incoming direction', () {
        expect(MessageDirection.incoming, MessageDirection.incoming);
      });

      test('has outgoing direction', () {
        expect(MessageDirection.outgoing, MessageDirection.outgoing);
      });
    });

    group('MessageType Enum', () {
      test('has text type', () {
        expect(MessageType.text, MessageType.text);
      });

      test('has binary type', () {
        expect(MessageType.binary, MessageType.binary);
      });

      test('has json type', () {
        expect(MessageType.json, MessageType.json);
      });
    });

    group('Message Payload', () {
      test('message stores text payload', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Hello World',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.payload, 'Hello World');
      });

      test('message stores JSON payload', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.json,
          payload: '{"temperature": 25.5, "humidity": 60}',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.payload, contains('temperature'));
      });

      test('message stores binary payload as hex string', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.binary,
          payload: '0x48656C6C6F', // "Hello" in hex
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.payload, startsWith('0x'));
      });
    });

    group('Message Direction', () {
      test('incoming message represents received data', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Received',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.direction, MessageDirection.incoming);
      });

      test('outgoing message represents sent data', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.outgoing,
          type: MessageType.text,
          payload: 'Sent',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.direction, MessageDirection.outgoing);
      });
    });

    group('Message Timestamps', () {
      test('message records timestamp', () {
        final now = DateTime.now();
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'test',
          timestamp: now,
          receivedAt: now,
        );

        expect(message.timestamp, now);
        expect(message.receivedAt, now);
      });

      test('message received time can be different from timestamp', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final received = DateTime(2024, 1, 1, 12, 0, 5);

        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'test',
          timestamp: timestamp,
          receivedAt: received,
        );

        expect(message.timestamp, isNot(message.receivedAt));
      });
    });

    group('Message copyWith', () {
      test('creates copy with changed values', () {
        final original = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Original',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        final updated = original.copyWith(payload: 'Updated');

        expect(updated.id, 'msg-001'); // Unchanged
        expect(updated.payload, 'Updated');
        expect(original.payload, 'Original'); // Original unchanged
      });
    });

    group('Message Equality', () {
      test('messages with same values are equal', () {
        final now = DateTime(2024, 1, 1);

        final msg1 = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'test',
          timestamp: now,
          receivedAt: now,
        );

        final msg2 = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'test',
          timestamp: now,
          receivedAt: now,
        );

        expect(msg1, msg2);
      });
    });

    group('Message Metadata', () {
      test('message metadata is optional', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'test',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.metadata, {});
      });

      test('message metadata can store message details', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.json,
          payload: '{}',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
          metadata: {
            'retain': true,
            'qos': 1,
            'sourceId': 'device-123',
            'encrypted': false,
          },
        );

        expect(message.metadata['retain'], true);
        expect(message.metadata['qos'], 1);
        expect(message.metadata['sourceId'], 'device-123');
      });
    });

    group('Message Payload Size', () {
      test('message can store large payloads', () {
        final largePayload = 'A' * 10000;
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: largePayload,
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.payload.length, 10000);
      });

      test('message with empty payload', () {
        final message = Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: '',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        expect(message.payload, isEmpty);
      });
    });

    group('Message Batching', () {
      test('multiple messages can be batched', () {
        final messages = List.generate(
          100,
          (index) => Message(
            id: 'msg-$index',
            topicId: 'topic-001',
            connectionId: 'conn-001',
            direction: MessageDirection.incoming,
            type: MessageType.text,
            payload: 'Message $index',
            timestamp: DateTime.now(),
            receivedAt: DateTime.now(),
          ),
        );

        expect(messages.length, 100);
        expect(messages.first.id, 'msg-0');
        expect(messages.last.id, 'msg-99');
      });

      test('incoming and outgoing messages separated', () {
        final incoming = Message(
          id: 'msg-1',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Received',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        final outgoing = Message(
          id: 'msg-2',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.outgoing,
          type: MessageType.text,
          payload: 'Sent',
          timestamp: DateTime.now(),
          receivedAt: DateTime.now(),
        );

        final all = [incoming, outgoing];
        final incomingOnly = all.where((m) => m.direction == MessageDirection.incoming).toList();
        final outgoingOnly = all.where((m) => m.direction == MessageDirection.outgoing).toList();

        expect(incomingOnly.length, 1);
        expect(outgoingOnly.length, 1);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/core/events/app_event.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/events/event_bus_impl.dart';

// Test event classes
class TestEvent extends AppEvent {
  final String message;
  TestEvent(this.message);
}

class AnotherTestEvent extends AppEvent {
  final int value;
  AnotherTestEvent(this.value);
}

void main() {
  group('EventBus Tests', () {
    late EventBus eventBus;

    setUp(() {
      eventBus = EventBusImpl();
    });

    group('Event Publishing and Listening', () {
      test('listener receives published event', () async {
        TestEvent? receivedEvent;

        eventBus.listen<TestEvent>((event) {
          receivedEvent = event;
        });

        final publishedEvent = TestEvent('test message');
        eventBus.publish(publishedEvent);

        // Give time for async event processing
        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.message, 'test message');
      });

      test('multiple listeners receive same event', () async {
        List<String> messages = [];

        eventBus.listen<TestEvent>((event) {
          messages.add('listener1: ${event.message}');
        });

        eventBus.listen<TestEvent>((event) {
          messages.add('listener2: ${event.message}');
        });

        eventBus.publish(TestEvent('broadcast'));
        await Future.delayed(const Duration(milliseconds: 10));

        expect(messages.length, 2);
        expect(messages, contains('listener1: broadcast'));
        expect(messages, contains('listener2: broadcast'));
      });

      test('listener only receives events of subscribed type', () async {
        List<dynamic> receivedEvents = [];

        eventBus.listen<TestEvent>((event) {
          receivedEvents.add(event);
        });

        eventBus.publish(TestEvent('test1'));
        eventBus.publish(AnotherTestEvent(42));
        eventBus.publish(TestEvent('test2'));

        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 2);
        expect(receivedEvents[0], isA<TestEvent>());
        expect(receivedEvents[1], isA<TestEvent>());
      });
    });

    group('Event Unsubscription', () {
      test('unsubscribe stops receiving events', () async {
        int eventCount = 0;

        final unsubscribe = eventBus.listen<TestEvent>((event) {
          eventCount++;
        });

        eventBus.publish(TestEvent('event1'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(eventCount, 1);

        unsubscribe();

        eventBus.publish(TestEvent('event2'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(eventCount, 1); // Should not increment
      });

      test('unsubscribeAll removes all listeners', () async {
        int count1 = 0;
        int count2 = 0;

        eventBus.listen<TestEvent>((event) => count1++);
        eventBus.listen<TestEvent>((event) => count2++);

        eventBus.publish(TestEvent('test'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(count1, 1);
        expect(count2, 1);

        eventBus.unsubscribeAll<TestEvent>();

        eventBus.publish(TestEvent('test2'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(count1, 1); // Should not change
        expect(count2, 1); // Should not change
      });

      test('unsubscribe returns true if listener was removed', () {
        final unsubscribe = eventBus.listen<TestEvent>((event) {});
        expect(unsubscribe(), true);
        expect(unsubscribe(), false); // Already unsubscribed
      });
    });

    group('Event Type Safety', () {
      test('different event types maintain separate listener lists', () async {
        List<dynamic> received = [];

        eventBus.listen<TestEvent>((event) {
          received.add('TestEvent: ${event.message}');
        });

        eventBus.listen<AnotherTestEvent>((event) {
          received.add('AnotherTestEvent: ${event.value}');
        });

        eventBus.publish(TestEvent('msg1'));
        eventBus.publish(AnotherTestEvent(123));

        await Future.delayed(const Duration(milliseconds: 10));

        expect(received.length, 2);
        expect(received[0], 'TestEvent: msg1');
        expect(received[1], 'AnotherTestEvent: 123');
      });

      test('listener type must match event type', () async {
        AnotherTestEvent? received;

        // This should only receive AnotherTestEvent
        eventBus.listen<AnotherTestEvent>((event) {
          received = event;
        });

        eventBus.publish(TestEvent('should not be received'));
        await Future.delayed(const Duration(milliseconds: 10));

        expect(received, null);
      });
    });

    group('Event Publishing Behavior', () {
      test('publish with no listeners does not throw', () {
        expect(
          () => eventBus.publish(TestEvent('test')),
          returnsNormally,
        );
      });

      test('event data is preserved correctly', () async {
        TestEvent? captured;

        eventBus.listen<TestEvent>((event) {
          captured = event;
        });

        const message = 'preserved message';
        eventBus.publish(TestEvent(message));

        await Future.delayed(const Duration(milliseconds: 10));

        expect(captured!.message, message);
      });

      test('events are published asynchronously', () async {
        List<int> order = [];

        eventBus.listen<TestEvent>((event) {
          order.add(1);
        });

        order.add(0);
        eventBus.publish(TestEvent('async'));
        order.add(2);

        await Future.delayed(const Duration(milliseconds: 10));

        // Event listener should be called after the publish call
        expect(order, [0, 2, 1]);
      });

      test('multiple events can be published in sequence', () async {
        List<String> messages = [];

        eventBus.listen<TestEvent>((event) {
          messages.add(event.message);
        });

        eventBus.publish(TestEvent('msg1'));
        eventBus.publish(TestEvent('msg2'));
        eventBus.publish(TestEvent('msg3'));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(messages.length, 3);
        expect(messages, ['msg1', 'msg2', 'msg3']);
      });
    });

    group('Listener Callbacks', () {
      test('listener is called with correct event data', () async {
        TestEvent? receivedEvent;

        eventBus.listen<TestEvent>((event) {
          receivedEvent = event;
        });

        final originalEvent = TestEvent('callback test');
        eventBus.publish(originalEvent);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.message, 'callback test');
      });

      test('listener can modify local state', () async {
        List<String> values = [];

        eventBus.listen<TestEvent>((event) {
          values.add(event.message);
        });

        eventBus.publish(TestEvent('first'));
        eventBus.publish(TestEvent('second'));

        await Future.delayed(const Duration(milliseconds: 10));

        expect(values, ['first', 'second']);
      });

      test('listener can throw without breaking event bus', () async {
        int safeCount = 0;

        eventBus.listen<TestEvent>((event) {
          throw Exception('listener error');
        });

        eventBus.listen<TestEvent>((event) {
          safeCount++;
        });

        // Publishing should not throw
        expect(
          () {
            eventBus.publish(TestEvent('test'));
          },
          returnsNormally,
        );

        await Future.delayed(const Duration(milliseconds: 10));

        // Other listeners should still be called
        expect(safeCount, 1);
      });
    });

    group('Memory Management', () {
      test('unsubscribed listeners do not receive events', () async {
        int count = 0;

        final unsubscribe = eventBus.listen<TestEvent>((event) {
          count++;
        });

        eventBus.publish(TestEvent('event1'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(count, 1);

        unsubscribe();

        eventBus.publish(TestEvent('event2'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(count, 1);
      });

      test('large number of listeners can coexist', () async {
        int eventCount = 0;
        final listenerCount = 100;

        for (int i = 0; i < listenerCount; i++) {
          eventBus.listen<TestEvent>((event) {
            eventCount++;
          });
        }

        eventBus.publish(TestEvent('test'));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(eventCount, listenerCount);
      });

      test('unsubscribeAll removes all listeners of a type', () async {
        int count = 0;

        for (int i = 0; i < 5; i++) {
          eventBus.listen<TestEvent>((event) {
            count++;
          });
        }

        eventBus.publish(TestEvent('test1'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(count, 5);

        eventBus.unsubscribeAll<TestEvent>();

        eventBus.publish(TestEvent('test2'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(count, 5); // Should not increase
      });
    });

    group('Edge Cases', () {
      test('subscribe and unsubscribe rapidly', () async {
        int count = 0;

        for (int i = 0; i < 10; i++) {
          final unsub = eventBus.listen<TestEvent>((event) => count++);
          unsub();
        }

        eventBus.publish(TestEvent('test'));
        await Future.delayed(const Duration(milliseconds: 10));

        expect(count, 0); // All unsubscribed
      });

      test('publish same event type with different instances', () async {
        List<TestEvent> events = [];

        eventBus.listen<TestEvent>((event) {
          events.add(event);
        });

        final event1 = TestEvent('msg1');
        final event2 = TestEvent('msg2');
        final event3 = TestEvent('msg3');

        eventBus.publish(event1);
        eventBus.publish(event2);
        eventBus.publish(event3);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(events.length, 3);
        expect(events[0].message, 'msg1');
        expect(events[1].message, 'msg2');
        expect(events[2].message, 'msg3');
      });

      test('listener can subscribe to another event type', () async {
        List<Type> eventTypes = [];

        eventBus.listen<TestEvent>((event) {
          eventTypes.add(TestEvent);
          eventBus.listen<AnotherTestEvent>((e) {
            eventTypes.add(AnotherTestEvent);
          });
        });

        eventBus.publish(TestEvent('test'));
        await Future.delayed(const Duration(milliseconds: 20));

        eventBus.publish(AnotherTestEvent(42));
        await Future.delayed(const Duration(milliseconds: 20));

        expect(eventTypes, contains(TestEvent));
        expect(eventTypes, contains(AnotherTestEvent));
      });
    });

    group('EventBus Lifecycle', () {
      test('multiple event bus instances are independent', () async {
        final bus1 = EventBusImpl();
        final bus2 = EventBusImpl();

        int count1 = 0;
        int count2 = 0;

        bus1.listen<TestEvent>((event) => count1++);
        bus2.listen<TestEvent>((event) => count2++);

        bus1.publish(TestEvent('event1'));
        await Future.delayed(const Duration(milliseconds: 10));

        expect(count1, 1);
        expect(count2, 0); // bus2 not affected
      });

      test('event bus can be reused after unsubscribeAll', () async {
        int count = 0;

        eventBus.listen<TestEvent>((event) => count++);
        eventBus.publish(TestEvent('event1'));
        await Future.delayed(const Duration(milliseconds: 10));
        expect(count, 1);

        eventBus.unsubscribeAll<TestEvent>();

        eventBus.listen<TestEvent>((event) => count++);
        eventBus.publish(TestEvent('event2'));
        await Future.delayed(const Duration(milliseconds: 10));

        expect(count, 2);
      });
    });
  });
}

/// Test file demonstrating EventBus usage in ViewModels
/// 
/// This shows the pattern for listening to domain events in ViewModels
/// and updating the UI state reactively.
/// 
/// Integration Test Location: test/integration/event_bus_test.dart

import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/di/setup_service_locator.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/domain/events/protocol_events.dart';
import 'package:iot_manager/domain/events/certificate_events.dart';
import 'package:iot_manager/domain/events/connection_events.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/entities/protocol.dart';

/// Example ViewModel showing EventBus integration
/// 
/// This demonstrates the pub/sub pattern for reactive updates
class ExampleProtocolViewModel extends ChangeNotifier {
  final ProtocolRepository _protocolRepository;
  final EventBus _eventBus;

  List<Protocol> protocols = [];
  String lastEvent = '';

  ExampleProtocolViewModel(
    this._protocolRepository,
    this._eventBus,
  ) {
    // Subscribe to protocol events
    _eventBus.listen<ProtocolAddedEvent>(_onProtocolAdded);
    _eventBus.listen<ProtocolUpdatedEvent>(_onProtocolUpdated);
    _eventBus.listen<ProtocolDeletedEvent>(_onProtocolDeleted);
    _eventBus.listen<ProtocolsLoadedEvent>(_onProtocolsLoaded);
    _eventBus.listen<ProtocolRetrievedEvent>(_onProtocolRetrieved);
  }

  /// Load all protocols
  Future<void> loadProtocols() async {
    final result = await _protocolRepository.getAllProtocols();
    if (result.isSuccess) {
      // Event will be published by repository
      // This method just triggers the load
    }
  }

  /// Event handler: Protocol Added
  void _onProtocolAdded(ProtocolAddedEvent event) {
    lastEvent = 'Protocol Added: ${event.protocol.name}';
    if (!protocols.contains(event.protocol)) {
      protocols.add(event.protocol);
    }
    notifyListeners();
  }

  /// Event handler: Protocol Updated
  void _onProtocolUpdated(ProtocolUpdatedEvent event) {
    lastEvent = 'Protocol Updated: ${event.protocol.name}';
    final index = protocols.indexWhere((p) => p.id == event.protocol.id);
    if (index != -1) {
      protocols[index] = event.protocol;
    }
    notifyListeners();
  }

  /// Event handler: Protocol Deleted
  void _onProtocolDeleted(ProtocolDeletedEvent event) {
    lastEvent = 'Protocol Deleted: ${event.protocolId}';
    protocols.removeWhere((p) => p.id == event.protocolId);
    notifyListeners();
  }

  /// Event handler: Protocols Loaded
  void _onProtocolsLoaded(ProtocolsLoadedEvent event) {
    lastEvent = 'Protocols Loaded: ${event.protocols.length} items';
    protocols = event.protocols;
    notifyListeners();
  }

  /// Event handler: Protocol Retrieved
  void _onProtocolRetrieved(ProtocolRetrievedEvent event) {
    lastEvent = 'Protocol Retrieved: ${event.protocol.name}';
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Integration Test Example
/// 
/// Run with: flutter test test/integration/event_bus_test.dart
void main() {
  group('EventBus Integration Tests', () {
    // This is an example of how to test the EventBus
    // Actual test file should be in test/integration/event_bus_test.dart
    
    /*
    test('EventBus publishes and subscribes to ProtocolAddedEvent', () async {
      await setupServiceLocator();
      
      final eventBus = getIt<EventBus>();
      var eventReceived = false;
      
      // Subscribe
      eventBus.listen<ProtocolAddedEvent>((event) {
        eventReceived = true;
        expect(event.protocol.name, equals('Test Protocol'));
      });
      
      // Create test protocol
      final testProtocol = Protocol(
        id: '1',
        name: 'Test Protocol',
        type: ProtocolType.mqtt,
        description: 'Test',
        defaultPort: 1883,
        requiresAuthentication: false,
        supportedFeatures: [],
      );
      
      // Publish event
      await eventBus.publish(ProtocolAddedEvent(testProtocol));
      
      // Wait for async event
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(eventReceived, isTrue);
    });
    
    test('ProtocolRepository publishes ProtocolAddedEvent on create', () async {
      await setupServiceLocator();
      
      final repository = getIt<ProtocolRepository>();
      final eventBus = getIt<EventBus>();
      
      var eventReceived = false;
      
      eventBus.listen<ProtocolAddedEvent>((event) {
        eventReceived = true;
      });
      
      final testProtocol = Protocol(
        id: '2',
        name: 'MQTT Test',
        type: ProtocolType.mqtt,
        description: 'Test',
        defaultPort: 1883,
        requiresAuthentication: false,
        supportedFeatures: [],
      );
      
      await repository.createProtocol(testProtocol);
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(eventReceived, isTrue);
    });
    
    test('ViewModel listens to repository events', () async {
      await setupServiceLocator();
      
      final repository = getIt<ProtocolRepository>();
      final eventBus = getIt<EventBus>();
      final viewModel = ExampleProtocolViewModel(repository, eventBus);
      
      addTearDown(viewModel.dispose);
      
      expect(viewModel.protocols, isEmpty);
      
      final testProtocol = Protocol(
        id: '3',
        name: 'Test Protocol 3',
        type: ProtocolType.mqtt,
        description: 'Test',
        defaultPort: 1883,
        requiresAuthentication: false,
        supportedFeatures: [],
      );
      
      await repository.createProtocol(testProtocol);
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(viewModel.protocols.length, equals(1));
      expect(viewModel.lastEvent, contains('Protocol Added'));
    });
    */
  });
}

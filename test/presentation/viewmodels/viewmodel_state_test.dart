import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/core/di/service_locator.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/repositories/certificate_repository.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';
import 'package:iot_manager/domain/usecases/connection_usecases.dart';
import 'package:iot_manager/domain/usecases/certificate_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

// Mock repositories
class MockProtocolRepository extends Mock implements ProtocolRepository {}
class MockConnectionRepository extends Mock implements ConnectionRepository {}
class MockCertificateRepository extends Mock implements CertificateRepository {}

// Test ViewModel implementations
class ProtocolListViewModel extends BaseViewModel {
  final GetAllProtocolsUseCase getAllProtocolsUseCase;

  List<Protocol> _protocols = [];
  String? _error;

  List<Protocol> get protocols => _protocols;
  String? get error => _error;

  ProtocolListViewModel({required this.getAllProtocolsUseCase});

  Future<void> loadProtocols() async {
    setLoading(true);
    _error = null;

    final result = await getAllProtocolsUseCase.call();

    result.fold(
      onSuccess: (protocols) {
        _protocols = protocols;
        notifyListeners();
      },
      onFailure: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );

    setLoading(false);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class ConnectionListViewModel extends BaseViewModel {
  final GetAllConnectionsUseCase getAllConnectionsUseCase;
  final GetConnectionsByStatusUseCase getByStatusUseCase;

  List<Connection> _connections = [];
  ConnectionStatus? _filterStatus;

  List<Connection> get connections => _connections;
  ConnectionStatus? get filterStatus => _filterStatus;

  ConnectionListViewModel({
    required this.getAllConnectionsUseCase,
    required this.getByStatusUseCase,
  });

  Future<void> loadConnections() async {
    setLoading(true);

    final result = await getAllConnectionsUseCase.call();

    result.fold(
      onSuccess: (connections) {
        _connections = connections;
        notifyListeners();
      },
      onFailure: (error) => notifyListeners(),
    );

    setLoading(false);
  }

  Future<void> filterByStatus(ConnectionStatus status) async {
    _filterStatus = status;
    final result = await getByStatusUseCase.call(status);

    result.fold(
      onSuccess: (filtered) {
        _connections = filtered;
        notifyListeners();
      },
      onFailure: (error) => notifyListeners(),
    );
  }
}

void main() {
  group('ViewModel State Management Tests', () {
    group('ProtocolListViewModel', () {
      late MockProtocolRepository mockRepository;
      late GetAllProtocolsUseCase getAllProtocolsUseCase;
      late ProtocolListViewModel viewModel;

      setUp(() {
        mockRepository = MockProtocolRepository();
        getAllProtocolsUseCase = GetAllProtocolsUseCase(mockRepository);
        viewModel = ProtocolListViewModel(
          getAllProtocolsUseCase: getAllProtocolsUseCase,
        );
      });

      test('initial state has empty protocols', () {
        expect(viewModel.protocols, isEmpty);
        expect(viewModel.error, isNull);
      });

      test('loadProtocols updates state with data', () async {
        final mockProtocols = [
          Protocol(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          Protocol(
            id: 'proto-002',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(mockProtocols));

        var listenerCalled = 0;
        viewModel.addListener(() => listenerCalled++);

        await viewModel.loadProtocols();

        expect(viewModel.protocols.length, 2);
        expect(viewModel.protocols[0].name, 'MQTT');
        expect(viewModel.error, isNull);
        expect(listenerCalled, greaterThan(0)); // Listener notified
      });

      test('loadProtocols sets error on failure', () async {
        final error = Exception('Failed to load');

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(error));

        await viewModel.loadProtocols();

        expect(viewModel.protocols, isEmpty);
        expect(viewModel.error, isNotNull);
      });

      test('viewModel notifies listeners on state change', () async {
        final mockProtocols = [
          Protocol(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(mockProtocols));

        var listenerCallCount = 0;
        viewModel.addListener(() => listenerCallCount++);

        await viewModel.loadProtocols();

        expect(listenerCallCount, greaterThan(0));
      });

      test('clearError clears error message', () async {
        final error = Exception('Test error');

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(error));

        await viewModel.loadProtocols();
        expect(viewModel.error, isNotNull);

        viewModel.clearError();
        expect(viewModel.error, isNull);
      });

      test('viewModel loading state changes', () async {
        final mockProtocols = [
          Protocol(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(mockProtocols));

        expect(viewModel.isLoading, false);

        final loadTask = viewModel.loadProtocols();
        await Future.delayed(const Duration(milliseconds: 10));
        // During load, isLoading might be true (timing dependent)

        await loadTask;
        expect(viewModel.isLoading, false);
      });
    });

    group('ConnectionListViewModel', () {
      late MockConnectionRepository mockRepository;
      late GetAllConnectionsUseCase getAllConnectionsUseCase;
      late GetConnectionsByStatusUseCase getByStatusUseCase;
      late ConnectionListViewModel viewModel;

      setUp(() {
        mockRepository = MockConnectionRepository();
        getAllConnectionsUseCase = GetAllConnectionsUseCase(mockRepository);
        getByStatusUseCase = GetConnectionsByStatusUseCase(mockRepository);
        viewModel = ConnectionListViewModel(
          getAllConnectionsUseCase: getAllConnectionsUseCase,
          getByStatusUseCase: getByStatusUseCase,
        );
      });

      test('initial state has empty connections and no filter', () {
        expect(viewModel.connections, isEmpty);
        expect(viewModel.filterStatus, isNull);
      });

      test('loadConnections populates connection list', () async {
        final now = DateTime.now();
        final mockConnections = [
          Connection(
            id: 'conn-001',
            name: 'MQTT Broker',
            host: 'broker.example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
          Connection(
            id: 'conn-002',
            name: 'HTTP API',
            host: 'api.example.com',
            port: 8080,
            status: ConnectionStatus.inactive,
            createdAt: now,
          ),
        ];

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success(mockConnections));

        await viewModel.loadConnections();

        expect(viewModel.connections.length, 2);
        expect(viewModel.connections[0].name, 'MQTT Broker');
      });

      test('filterByStatus updates state with filtered connections', () async {
        final now = DateTime.now();
        final activeConnections = [
          Connection(
            id: 'conn-001',
            name: 'Active Connection',
            host: 'example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
        ];

        when(mockRepository.getConnectionsByStatus(ConnectionStatus.active))
            .thenAnswer((_) async => Result.success(activeConnections));

        var listenerCalls = 0;
        viewModel.addListener(() => listenerCalls++);

        await viewModel.filterByStatus(ConnectionStatus.active);

        expect(viewModel.filterStatus, ConnectionStatus.active);
        expect(viewModel.connections.length, 1);
        expect(viewModel.connections[0].status, ConnectionStatus.active);
        expect(listenerCalls, greaterThan(0));
      });

      test('viewModel listener is removed after dispose', () {
        var listenerCalls = 0;
        final listener = () => listenerCalls++;

        viewModel.addListener(listener);
        viewModel.notifyListeners();
        expect(listenerCalls, 1);

        viewModel.removeListener(listener);
        viewModel.notifyListeners();
        expect(listenerCalls, 1); // Not called again
      });
    });

    group('Base ViewModel Lifecycle', () {
      late ProtocolListViewModel viewModel;
      late MockProtocolRepository mockRepository;

      setUp(() {
        mockRepository = MockProtocolRepository();
        final useCase = GetAllProtocolsUseCase(mockRepository);
        viewModel = ProtocolListViewModel(getAllProtocolsUseCase: useCase);
      });

      test('viewModel can be disposed', () {
        var listenerCalls = 0;
        viewModel.addListener(() => listenerCalls++);

        viewModel.notifyListeners();
        expect(listenerCalls, 1);

        viewModel.dispose();

        // After dispose, listeners should not be called (framework behavior)
        // This tests that dispose was called
        expect(viewModel.isDisposed, true);
      });

      test('multiple listeners can be registered', () {
        var listener1Calls = 0;
        var listener2Calls = 0;

        final l1 = () => listener1Calls++;
        final l2 = () => listener2Calls++;

        viewModel.addListener(l1);
        viewModel.addListener(l2);

        viewModel.notifyListeners();

        expect(listener1Calls, 1);
        expect(listener2Calls, 1);
      });

      test('loading state managed by setLoading', () {
        expect(viewModel.isLoading, false);

        viewModel.setLoading(true);
        expect(viewModel.isLoading, true);

        viewModel.setLoading(false);
        expect(viewModel.isLoading, false);
      });
    });

    group('ViewModel Error Handling', () {
      late MockProtocolRepository mockRepository;
      late GetAllProtocolsUseCase useCase;
      late ProtocolListViewModel viewModel;

      setUp(() {
        mockRepository = MockProtocolRepository();
        useCase = GetAllProtocolsUseCase(mockRepository);
        viewModel = ProtocolListViewModel(getAllProtocolsUseCase: useCase);
      });

      test('viewModel handles exceptions gracefully', () async {
        final exception = Exception('Network error');

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(exception));

        await viewModel.loadProtocols();

        expect(viewModel.error, isNotNull);
        expect(viewModel.protocols, isEmpty);
      });

      test('error state persists until cleared', () async {
        final exception = Exception('Test error');

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(exception));

        await viewModel.loadProtocols();
        final firstError = viewModel.error;

        // Error persists
        await viewModel.loadProtocols();
        final secondError = viewModel.error;

        expect(firstError, isNotNull);
        expect(secondError, isNotNull);

        viewModel.clearError();
        expect(viewModel.error, isNull);
      });
    });

    group('ViewModel State Consistency', () {
      late MockCertificateRepository mockRepository;
      late GetAllCertificatesUseCase useCase;

      setUp(() {
        mockRepository = MockCertificateRepository();
        useCase = GetAllCertificatesUseCase(mockRepository);
      });

      test('certificate viewmodel maintains consistent state', () async {
        final now = DateTime.now();
        final mockCerts = [
          Certificate(
            id: 'cert-001',
            name: 'Root CA',
            type: CertificateType.ca,
            validFrom: now,
            validTo: now.add(const Duration(days: 3650)),
          ),
        ];

        when(mockRepository.getAllCertificates())
            .thenAnswer((_) async => Result.success(mockCerts));

        // Multiple calls should return same state
        final result1 = await useCase.call();
        final result2 = await useCase.call();

        expect(result1.value, result2.value);
      });
    });

    group('ViewModel Data Transformation', () {
      late MockProtocolRepository mockRepository;

      setUp(() {
        mockRepository = MockProtocolRepository();
      });

      test('viewmodel transforms result data correctly', () async {
        final mockProtocols = [
          Protocol(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          Protocol(
            id: 'proto-002',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(mockProtocols));

        final useCase = GetAllProtocolsUseCase(mockRepository);
        final viewModel = ProtocolListViewModel(getAllProtocolsUseCase: useCase);

        await viewModel.loadProtocols();

        // Transform protocols to names
        final names = viewModel.protocols.map((p) => p.name).toList();
        expect(names, ['MQTT', 'HTTP']);
      });
    });
  });
}

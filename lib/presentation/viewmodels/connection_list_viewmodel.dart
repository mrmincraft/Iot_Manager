import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/events/connection_events.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/usecases/connection_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for Connection management
class ConnectionListViewModel extends BaseViewModel {
  final ConnectionRepository _connectionRepository;
  final EventBus _eventBus;
  final GetAllConnectionsUseCase _getAllConnectionsUseCase;
  final CreateConnectionUseCase _createConnectionUseCase;
  final UpdateConnectionUseCase _updateConnectionUseCase;
  final DeleteConnectionUseCase _deleteConnectionUseCase;

  /// Observable state
  final ValueNotifier<List<Connection>> connections = ValueNotifier([]);
  final ValueNotifier<Connection?> selectedConnection = ValueNotifier(null);
  final ValueNotifier<int> activeCount = ValueNotifier(0);
  final ValueNotifier<int> inactiveCount = ValueNotifier(0);

  ConnectionListViewModel({
    required ConnectionRepository connectionRepository,
    required EventBus eventBus,
    required GetAllConnectionsUseCase getAllConnectionsUseCase,
    required CreateConnectionUseCase createConnectionUseCase,
    required UpdateConnectionUseCase updateConnectionUseCase,
    required DeleteConnectionUseCase deleteConnectionUseCase,
  })  : _connectionRepository = connectionRepository,
        _eventBus = eventBus,
        _getAllConnectionsUseCase = getAllConnectionsUseCase,
        _createConnectionUseCase = createConnectionUseCase,
        _updateConnectionUseCase = updateConnectionUseCase,
        _deleteConnectionUseCase = deleteConnectionUseCase {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.listen<ConnectionsLoadedEvent>(_onConnectionsLoaded);
    _eventBus.listen<ConnectionCreatedEvent>(_onConnectionCreated);
    _eventBus.listen<ConnectionUpdatedEvent>(_onConnectionUpdated);
    _eventBus.listen<ConnectionDeletedEvent>(_onConnectionDeleted);
    _eventBus.listen<ConnectionStatusChangedEvent>(_onStatusChanged);
    _eventBus.listen<ConnectionEstablishedEvent>(_onConnectionEstablished);
    _eventBus.listen<ConnectionClosedEvent>(_onConnectionClosed);
  }

  Future<void> loadConnections() async {
    isLoading.value = true;
    clearError();

    final result = await _connectionRepository.getAllConnections();

    if (result.isSuccess) {
      final conns = result.value ?? [];
      activeCount.value = conns.where((c) => c.status == ConnectionStatus.active).length;
      inactiveCount.value = conns.where((c) => c.status == ConnectionStatus.inactive).length;
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> createConnection(Connection connection) async {
    isLoading.value = true;
    clearError();

    final result = await _connectionRepository.createConnection(connection);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Connection created: ${connection.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> updateConnection(Connection connection) async {
    isLoading.value = true;
    clearError();

    final result = await _connectionRepository.updateConnection(connection);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Connection updated: ${connection.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> deleteConnection(String connectionId) async {
    isLoading.value = true;
    clearError();

    final result = await _connectionRepository.deleteConnection(connectionId);

    if (result.isFailure) {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  void selectConnection(Connection connection) {
    selectedConnection.value = connection;
    notifyListeners();
  }

  void clearSelection() {
    selectedConnection.value = null;
    notifyListeners();
  }

  void _onConnectionsLoaded(ConnectionsLoadedEvent event) {
    connections.value = event.connections;
    _updateCounts();
    notifyListeners();
  }

  void _onConnectionCreated(ConnectionCreatedEvent event) {
    if (!connections.value.any((c) => c.id == event.connection.id)) {
      connections.value = [...connections.value, event.connection];
      _updateCounts();
      notifyListeners();
    }
  }

  void _onConnectionUpdated(ConnectionUpdatedEvent event) {
    final index = connections.value.indexWhere((c) => c.id == event.connection.id);
    if (index != -1) {
      connections.value = [
        ...connections.value.sublist(0, index),
        event.connection,
        ...connections.value.sublist(index + 1),
      ];
      _updateCounts();
      notifyListeners();
    }
  }

  void _onConnectionDeleted(ConnectionDeletedEvent event) {
    connections.value = connections.value.where((c) => c.id != event.connectionId).toList();
    if (selectedConnection.value?.id == event.connectionId) {
      selectedConnection.value = null;
    }
    _updateCounts();
    notifyListeners();
  }

  void _onStatusChanged(ConnectionStatusChangedEvent event) {
    final index = connections.value.indexWhere((c) => c.id == event.connection.id);
    if (index != -1) {
      connections.value = [
        ...connections.value.sublist(0, index),
        event.connection,
        ...connections.value.sublist(index + 1),
      ];
      _updateCounts();
      setSuccess('Connection status changed: ${event.newStatus}');
      notifyListeners();
    }
  }

  void _onConnectionEstablished(ConnectionEstablishedEvent event) {
    setSuccess('Connection established: ${event.connection.name}');
  }

  void _onConnectionClosed(ConnectionClosedEvent event) {
    setSuccess('Connection closed: ${event.connectionId}');
  }

  void _updateCounts() {
    activeCount.value = connections.value.where((c) => c.status == ConnectionStatus.active).length;
    inactiveCount.value = connections.value.where((c) => c.status == ConnectionStatus.inactive).length;
  }

  @override
  void initialize() {
    loadConnections();
  }

  @override
  void dispose() {
    connections.dispose();
    selectedConnection.dispose();
    activeCount.dispose();
    inactiveCount.dispose();
    super.dispose();
  }
}

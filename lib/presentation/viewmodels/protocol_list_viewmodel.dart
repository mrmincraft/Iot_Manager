import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/events/protocol_events.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for Protocol management
/// 
/// Responsibilities:
/// - Load and manage protocol list
/// - Handle protocol CRUD operations
/// - Subscribe to protocol events
/// - Maintain UI state (loading, error, data)
/// 
/// State Management:
/// - protocols: List of all protocols
/// - selectedProtocol: Currently selected protocol
/// - filterType: Filter by protocol type
/// - isLoading: Operation in progress
/// 
/// Event Subscriptions:
/// - ProtocolsLoadedEvent
/// - ProtocolAddedEvent
/// - ProtocolUpdatedEvent
/// - ProtocolDeletedEvent
class ProtocolListViewModel extends BaseViewModel {
  final ProtocolRepository _protocolRepository;
  final EventBus _eventBus;
  final GetAllProtocolsUseCase _getAllProtocolsUseCase;
  final CreateProtocolUseCase _createProtocolUseCase;
  final UpdateProtocolUseCase _updateProtocolUseCase;
  final DeleteProtocolUseCase _deleteProtocolUseCase;
  final GetProtocolsByTypeUseCase _getProtocolsByTypeUseCase;

  /// Observable state
  final ValueNotifier<List<Protocol>> protocols = ValueNotifier([]);
  final ValueNotifier<Protocol?> selectedProtocol = ValueNotifier(null);
  final ValueNotifier<String?> filterType = ValueNotifier(null);
  final ValueNotifier<int> totalCount = ValueNotifier(0);

  ProtocolListViewModel({
    required ProtocolRepository protocolRepository,
    required EventBus eventBus,
    required GetAllProtocolsUseCase getAllProtocolsUseCase,
    required CreateProtocolUseCase createProtocolUseCase,
    required UpdateProtocolUseCase updateProtocolUseCase,
    required DeleteProtocolUseCase deleteProtocolUseCase,
    required GetProtocolsByTypeUseCase getProtocolsByTypeUseCase,
  })  : _protocolRepository = protocolRepository,
        _eventBus = eventBus,
        _getAllProtocolsUseCase = getAllProtocolsUseCase,
        _createProtocolUseCase = createProtocolUseCase,
        _updateProtocolUseCase = updateProtocolUseCase,
        _deleteProtocolUseCase = deleteProtocolUseCase,
        _getProtocolsByTypeUseCase = getProtocolsByTypeUseCase {
    _setupEventListeners();
  }

  /// Setup event listeners
  void _setupEventListeners() {
    _eventBus.listen<ProtocolsLoadedEvent>(_onProtocolsLoaded);
    _eventBus.listen<ProtocolAddedEvent>(_onProtocolAdded);
    _eventBus.listen<ProtocolUpdatedEvent>(_onProtocolUpdated);
    _eventBus.listen<ProtocolDeletedEvent>(_onProtocolDeleted);
  }

  /// Load all protocols
  Future<void> loadProtocols() async {
    isLoading.value = true;
    clearError();

    final result = await _protocolRepository.getAllProtocols();

    if (result.isSuccess) {
      // Event will be published by repository
      totalCount.value = result.value!.length;
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  /// Load protocols by type
  Future<void> filterByType(ProtocolType type) async {
    filterType.value = type.toString();
    isLoading.value = true;
    clearError();

    final result = await _protocolRepository.getProtocolsByType(type);

    if (result.isSuccess) {
      protocols.value = result.value ?? [];
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  /// Create new protocol
  Future<void> createProtocol(Protocol protocol) async {
    isLoading.value = true;
    clearError();

    final result = await _protocolRepository.createProtocol(protocol);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Protocol created: ${protocol.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  /// Update protocol
  Future<void> updateProtocol(Protocol protocol) async {
    isLoading.value = true;
    clearError();

    final result = await _protocolRepository.updateProtocol(protocol);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Protocol updated: ${protocol.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  /// Delete protocol
  Future<void> deleteProtocol(String protocolId) async {
    isLoading.value = true;
    clearError();

    final result = await _protocolRepository.deleteProtocol(protocolId);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Protocol deleted');
    }

    isLoading.value = false;
    notifyListeners();
  }

  /// Select protocol
  void selectProtocol(Protocol protocol) {
    selectedProtocol.value = protocol;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    selectedProtocol.value = null;
    notifyListeners();
  }

  /// Event handler: Protocols loaded
  void _onProtocolsLoaded(ProtocolsLoadedEvent event) {
    protocols.value = event.protocols;
    totalCount.value = event.protocols.length;
    notifyListeners();
  }

  /// Event handler: Protocol added
  void _onProtocolAdded(ProtocolAddedEvent event) {
    if (!protocols.value.any((p) => p.id == event.protocol.id)) {
      protocols.value = [...protocols.value, event.protocol];
      totalCount.value++;
      setSuccess('Protocol added: ${event.protocol.name}');
      notifyListeners();
    }
  }

  /// Event handler: Protocol updated
  void _onProtocolUpdated(ProtocolUpdatedEvent event) {
    final index = protocols.value.indexWhere((p) => p.id == event.protocol.id);
    if (index != -1) {
      protocols.value = [
        ...protocols.value.sublist(0, index),
        event.protocol,
        ...protocols.value.sublist(index + 1),
      ];
      notifyListeners();
    }
  }

  /// Event handler: Protocol deleted
  void _onProtocolDeleted(ProtocolDeletedEvent event) {
    protocols.value = protocols.value.where((p) => p.id != event.protocolId).toList();
    totalCount.value--;
    if (selectedProtocol.value?.id == event.protocolId) {
      selectedProtocol.value = null;
    }
    notifyListeners();
  }

  @override
  void initialize() {
    loadProtocols();
  }

  @override
  void dispose() {
    protocols.dispose();
    selectedProtocol.dispose();
    filterType.dispose();
    totalCount.dispose();
    super.dispose();
  }
}

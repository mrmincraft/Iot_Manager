import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';
import 'package:iot_manager/domain/events/dashboard_events.dart';
import 'package:iot_manager/domain/events/connection_events.dart';
import 'package:iot_manager/domain/events/message_events.dart';
import 'package:iot_manager/domain/repositories/dashboard_repository.dart';
import 'package:iot_manager/domain/usecases/dashboard_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for Dashboard management and aggregation
class DashboardViewModel extends BaseViewModel {
  final DashboardRepository _dashboardRepository;
  final EventBus _eventBus;
  final GetAllDashboardsUseCase _getAllDashboardsUseCase;
  final CreateDashboardUseCase _createDashboardUseCase;
  final UpdateDashboardUseCase _updateDashboardUseCase;
  final DeleteDashboardUseCase _deleteDashboardUseCase;

  /// Observable state
  final ValueNotifier<List<Dashboard>> dashboards = ValueNotifier([]);
  final ValueNotifier<Dashboard?> selectedDashboard = ValueNotifier(null);
  final ValueNotifier<int> activeConnectionCount = ValueNotifier(0);
  final ValueNotifier<int> totalMessagesCount = ValueNotifier(0);
  final ValueNotifier<int> systemHealthScore = ValueNotifier(100);

  DashboardViewModel({
    required DashboardRepository dashboardRepository,
    required EventBus eventBus,
    required GetAllDashboardsUseCase getAllDashboardsUseCase,
    required CreateDashboardUseCase createDashboardUseCase,
    required UpdateDashboardUseCase updateDashboardUseCase,
    required DeleteDashboardUseCase deleteDashboardUseCase,
  })  : _dashboardRepository = dashboardRepository,
        _eventBus = eventBus,
        _getAllDashboardsUseCase = getAllDashboardsUseCase,
        _createDashboardUseCase = createDashboardUseCase,
        _updateDashboardUseCase = updateDashboardUseCase,
        _deleteDashboardUseCase = deleteDashboardUseCase {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.listen<DashboardsLoadedEvent>(_onDashboardsLoaded);
    _eventBus.listen<DashboardCreatedEvent>(_onDashboardCreated);
    _eventBus.listen<DashboardUpdatedEvent>(_onDashboardUpdated);
    _eventBus.listen<DashboardDeletedEvent>(_onDashboardDeleted);
    _eventBus.listen<DashboardRetrievedEvent>(_onDashboardRetrieved);
    
    // Listen to related events for dashboard updates
    _eventBus.listen<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    _eventBus.listen<MessageReceivedEvent>(_onMessageReceived);
  }

  Future<void> loadDashboards() async {
    isLoading.value = true;
    clearError();

    final result = await _dashboardRepository.getAllDashboards();

    if (result.isSuccess) {
      // Event will be published
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> createDashboard(Dashboard dashboard) async {
    isLoading.value = true;
    clearError();

    final result = await _dashboardRepository.createDashboard(dashboard);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Dashboard created: ${dashboard.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> updateDashboard(Dashboard dashboard) async {
    isLoading.value = true;
    clearError();

    final result = await _dashboardRepository.updateDashboard(dashboard);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Dashboard updated: ${dashboard.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> deleteDashboard(String dashboardId) async {
    isLoading.value = true;
    clearError();

    final result = await _dashboardRepository.deleteDashboard(dashboardId);

    if (result.isFailure) {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  void selectDashboard(Dashboard dashboard) {
    selectedDashboard.value = dashboard;
    notifyListeners();
  }

  void clearSelection() {
    selectedDashboard.value = null;
    notifyListeners();
  }

  void _onDashboardsLoaded(DashboardsLoadedEvent event) {
    dashboards.value = event.dashboards;
    notifyListeners();
  }

  void _onDashboardCreated(DashboardCreatedEvent event) {
    if (!dashboards.value.any((d) => d.id == event.dashboard.id)) {
      dashboards.value = [...dashboards.value, event.dashboard];
      notifyListeners();
    }
  }

  void _onDashboardUpdated(DashboardUpdatedEvent event) {
    final index = dashboards.value.indexWhere((d) => d.id == event.dashboard.id);
    if (index != -1) {
      dashboards.value = [
        ...dashboards.value.sublist(0, index),
        event.dashboard,
        ...dashboards.value.sublist(index + 1),
      ];
      notifyListeners();
    }
  }

  void _onDashboardDeleted(DashboardDeletedEvent event) {
    dashboards.value = dashboards.value.where((d) => d.id != event.dashboardId).toList();
    if (selectedDashboard.value?.id == event.dashboardId) {
      selectedDashboard.value = null;
    }
    notifyListeners();
  }

  void _onDashboardRetrieved(DashboardRetrievedEvent event) {
    selectedDashboard.value = event.dashboard;
    notifyListeners();
  }

  void _onConnectionStatusChanged(ConnectionStatusChangedEvent event) {
    final active = event.newStatus == 'active' ? 1 : -1;
    activeConnectionCount.value = (activeConnectionCount.value + active).clamp(0, 9999);
    _updateSystemHealth();
    notifyListeners();
  }

  void _onMessageReceived(MessageReceivedEvent event) {
    totalMessagesCount.value++;
    notifyListeners();
  }

  void _updateSystemHealth() {
    // Simple health calculation based on active connections
    final healthScore = ((activeConnectionCount.value / 10) * 100).toInt().clamp(0, 100);
    systemHealthScore.value = healthScore;
  }

  @override
  void initialize() {
    loadDashboards();
  }

  @override
  void dispose() {
    dashboards.dispose();
    selectedDashboard.dispose();
    activeConnectionCount.dispose();
    totalMessagesCount.dispose();
    systemHealthScore.dispose();
    super.dispose();
  }
}

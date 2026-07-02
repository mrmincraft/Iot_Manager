import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/log_entry.dart';
import 'package:iot_manager/domain/events/log_events.dart';
import 'package:iot_manager/domain/repositories/log_repository.dart';
import 'package:iot_manager/domain/usecases/log_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for Log management
class LogViewModel extends BaseViewModel {
  final LogRepository _logRepository;
  final EventBus _eventBus;
  final GetAllLogsUseCase _getAllLogsUseCase;
  final DeleteLogUseCase _deleteLogUseCase;
  final ClearLogsUseCase _clearLogsUseCase;
  final GetLogsByLevelUseCase _getLogsByLevelUseCase;

  /// Observable state
  final ValueNotifier<List<LogEntry>> logs = ValueNotifier([]);
  final ValueNotifier<LogEntry?> selectedLog = ValueNotifier(null);
  final ValueNotifier<LogSeverity?> filterSeverity = ValueNotifier(null);
  final ValueNotifier<int> errorCount = ValueNotifier(0);
  final ValueNotifier<int> warningCount = ValueNotifier(0);
  final ValueNotifier<int> infoCount = ValueNotifier(0);
  final ValueNotifier<bool> criticalAlertActive = ValueNotifier(false);

  LogViewModel({
    required LogRepository logRepository,
    required EventBus eventBus,
    required GetAllLogsUseCase getAllLogsUseCase,
    required DeleteLogUseCase deleteLogUseCase,
    required ClearLogsUseCase clearLogsUseCase,
    required GetLogsByLevelUseCase getLogsByLevelUseCase,
  })  : _logRepository = logRepository,
        _eventBus = eventBus,
        _getAllLogsUseCase = getAllLogsUseCase,
        _deleteLogUseCase = deleteLogUseCase,
        _clearLogsUseCase = clearLogsUseCase,
        _getLogsByLevelUseCase = getLogsByLevelUseCase {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.listen<LogEntriesLoadedEvent>(_onLogsLoaded);
    _eventBus.listen<LogEntryCreatedEvent>(_onLogCreated);
    _eventBus.listen<LogEntryDeletedEvent>(_onLogDeleted);
    _eventBus.listen<LogsClearedEvent>(_onLogsCleared);
    _eventBus.listen<CriticalLogEvent>(_onCriticalLog);
    _eventBus.listen<LogSizeThresholdReachedEvent>(_onSizeThresholdReached);
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    clearError();

    final result = await _logRepository.getAllLogs();

    if (result.isSuccess) {
      // Event will be published
      _updateCounts();
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> filterBySeverity(LogSeverity severity) async {
    filterSeverity.value = severity;
    isLoading.value = true;
    clearError();

    final result = await _logRepository.getLogsBySeverity(severity);

    if (result.isSuccess) {
      logs.value = result.value ?? [];
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> clearAllLogs() async {
    isLoading.value = true;
    clearError();

    final result = await _logRepository.clearAllLogs();

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('All logs cleared');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> deleteLog(String logId) async {
    isLoading.value = true;
    clearError();

    final result = await _logRepository.deleteLog(logId);

    if (result.isFailure) {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  void selectLog(LogEntry log) {
    selectedLog.value = log;
    notifyListeners();
  }

  void clearSelection() {
    selectedLog.value = null;
    notifyListeners();
  }

  void _onLogsLoaded(LogEntriesLoadedEvent event) {
    logs.value = event.logs;
    _updateCounts();
    notifyListeners();
  }

  void _onLogCreated(LogEntryCreatedEvent event) {
    if (!logs.value.any((l) => l.id == event.log.id)) {
      logs.value = [event.log, ...logs.value];
      _incrementCount(event.log.severity);
      notifyListeners();
    }
  }

  void _onLogDeleted(LogEntryDeletedEvent event) {
    final log = logs.value.firstWhere((l) => l.id == event.logId, orElse: () => null as dynamic) as LogEntry?;
    if (log != null) {
      logs.value = logs.value.where((l) => l.id != event.logId).toList();
      _decrementCount(log.severity);
      if (selectedLog.value?.id == event.logId) {
        selectedLog.value = null;
      }
      notifyListeners();
    }
  }

  void _onLogsCleared(LogsClearedEvent event) {
    logs.value = [];
    errorCount.value = 0;
    warningCount.value = 0;
    infoCount.value = 0;
    selectedLog.value = null;
    setSuccess('${event.clearedCount} logs cleared');
    notifyListeners();
  }

  void _onCriticalLog(CriticalLogEvent event) {
    criticalAlertActive.value = true;
    setError('CRITICAL: ${event.log.message}');
    
    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      criticalAlertActive.value = false;
      notifyListeners();
    });
  }

  void _onSizeThresholdReached(LogSizeThresholdReachedEvent event) {
    setSuccess('Log size threshold reached: ${event.currentSize}/${event.maxSize} bytes');
    notifyListeners();
  }

  void _updateCounts() {
    errorCount.value = logs.value.where((l) => l.severity == LogSeverity.error).length;
    warningCount.value = logs.value.where((l) => l.severity == LogSeverity.warning).length;
    infoCount.value = logs.value.where((l) => l.severity == LogSeverity.info).length;
  }

  void _incrementCount(LogSeverity severity) {
    if (severity == LogSeverity.error) {
      errorCount.value++;
    } else if (severity == LogSeverity.warning) {
      warningCount.value++;
    } else if (severity == LogSeverity.info) {
      infoCount.value++;
    }
  }

  void _decrementCount(LogSeverity severity) {
    if (severity == LogSeverity.error && errorCount.value > 0) {
      errorCount.value--;
    } else if (severity == LogSeverity.warning && warningCount.value > 0) {
      warningCount.value--;
    } else if (severity == LogSeverity.info && infoCount.value > 0) {
      infoCount.value--;
    }
  }

  @override
  void initialize() {
    loadLogs();
  }

  @override
  void dispose() {
    logs.dispose();
    selectedLog.dispose();
    filterSeverity.dispose();
    errorCount.dispose();
    warningCount.dispose();
    infoCount.dispose();
    criticalAlertActive.dispose();
    super.dispose();
  }
}

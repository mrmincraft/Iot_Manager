// Repository Implementation: LogRepositoryImpl
// Implémentation de la gestion des logs

import 'dart:convert';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/log_local_datasource.dart';
import 'package:iot_manager/data/models/log_entry_model.dart';
import 'package:iot_manager/domain/entities/log_entry.dart';
import 'package:iot_manager/domain/events/log_events.dart';
import 'package:iot_manager/domain/repositories/log_repository.dart';

class LogRepositoryImpl implements LogRepository {
  final LogLocalDataSource _localDataSource;
  final EventBus _eventBus;

  LogRepositoryImpl(this._localDataSource, this._eventBus);

  @override
  Future<Result<List<LogEntry>, Exception>> getAllLogs() async {
    try {
      final models = await _localDataSource.getAllLogs();
      final logs = models.map(_mapModelToEntity).toList();
      await _eventBus.publish(LogEntriesLoadedEvent(logs));
      return Result.success(logs);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<LogEntry, Exception>> getLogById(String id) async {
    try {
      final model = await _localDataSource.getLogById(id);
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<LogEntry, Exception>> addLog(LogEntry logEntry) async {
    try {
      final model = _mapEntityToModel(logEntry);
      await _localDataSource.addLog(model);
      
      // Check if this is a critical log
      if (logEntry.severity.toString().contains('ERROR') ||
          logEntry.severity.toString().contains('CRITICAL')) {
        await _eventBus.publish(CriticalLogEvent(
          logEntry: logEntry,
          severity: logEntry.severity.toString(),
        ));
      }
      
      await _eventBus.publish(LogEntryCreatedEvent(logEntry));
      return Result.success(logEntry);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<LogEntry, Exception>> updateLog(LogEntry logEntry) async {
    try {
      final model = _mapEntityToModel(logEntry);
      await _localDataSource.updateLog(model);
      return Result.success(logEntry);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteLog(String id) async {
    try {
      // Get the log before deletion
      final model = await _localDataSource.getLogById(id);
      final deletedLog = _mapModelToEntity(model);

      await _localDataSource.deleteLog(id);
      await _eventBus.publish(LogEntryDeletedEvent(
        logEntryId: id,
        deletedLogEntry: deletedLog,
      ));
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<LogEntry>, Exception>> getLogsBySeverity(LogSeverity severity) async {
    try {
      final severityStr = severity.toString().split('.').last;
      final models = await _localDataSource.getLogsBySeverity(severityStr);
      final logs = models.map(_mapModelToEntity).toList();
      return Result.success(logs);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<LogEntry>, Exception>> getLogsByCategory(LogCategory category) async {
    try {
      final categoryStr = category.toString().split('.').last;
      final models = await _localDataSource.getLogsByCategory(categoryStr);
      final logs = models.map(_mapModelToEntity).toList();
      return Result.success(logs);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<LogEntry>, Exception>> getUnresolvedLogs() async {
    try {
      final models = await _localDataSource.getUnresolvedLogs();
      final logs = models.map(_mapModelToEntity).toList();
      return Result.success(logs);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<LogEntry>, Exception>> getLogsBetweenDates(DateTime startDate, DateTime endDate) async {
    try {
      final models = await _localDataSource.getLogsBetweenDates(startDate, endDate);
      final logs = models.map(_mapModelToEntity).toList();
      return Result.success(logs);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<LogEntry>, Exception>> getLogsPaginated(int page, int limit) async {
    try {
      final models = await _localDataSource.getLogsPaginated(page, limit);
      final logs = models.map(_mapModelToEntity).toList();
      return Result.success(logs);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<int, Exception>> getLogCount() async {
    try {
      final count = await _localDataSource.getLogCount();
      return Result.success(count);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<LogEntry, Exception>> resolveLog(String logId, String resolutionNotes) async {
    try {
      final log = await getLogById(logId);
      if (log.isFailure) {
        return Result.failure(log.error!);
      }
      final resolved = log.value!.copyWith(
        isResolved: true,
        resolutionNotes: resolutionNotes,
        resolvedAt: DateTime.now(),
      );
      return updateLog(resolved);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteOldLogs(DateTime beforeDate) async {
    try {
      await _localDataSource.deleteOldLogs(beforeDate);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<LogEntry>, Exception>> searchLogsByMessage(String query) async {
    try {
      final models = await _localDataSource.searchLogsByMessage(query);
      final logs = models.map(_mapModelToEntity).toList();
      return Result.success(logs);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  LogEntry _mapModelToEntity(LogEntryModel model) {
    return LogEntry(
      id: model.id,
      severity: LogSeverity.values.firstWhere(
        (e) => e.toString().split('.').last == model.severity,
        orElse: () => LogSeverity.info,
      ),
      category: LogCategory.values.firstWhere(
        (e) => e.toString().split('.').last == model.category,
        orElse: () => LogCategory.system,
      ),
      message: model.message,
      details: model.details,
      stackTrace: model.stackTrace,
      userId: model.userId,
      connectionId: model.connectionId,
      topicId: model.topicId,
      metadata: Map<String, dynamic>.from(jsonDecode(model.metadata) as Map),
      isResolved: model.isResolved,
      resolutionNotes: model.resolutionNotes,
      timestamp: model.timestamp,
      resolvedAt: model.resolvedAt,
    );
  }

  LogEntryModel _mapEntityToModel(LogEntry entity) {
    return LogEntryModel(
      id: entity.id,
      severity: entity.severity.toString().split('.').last,
      category: entity.category.toString().split('.').last,
      message: entity.message,
      details: entity.details,
      stackTrace: entity.stackTrace,
      userId: entity.userId,
      connectionId: entity.connectionId,
      topicId: entity.topicId,
      metadata: jsonEncode(entity.metadata),
      isResolved: entity.isResolved,
      resolutionNotes: entity.resolutionNotes,
      timestamp: entity.timestamp,
      resolvedAt: entity.resolvedAt,
    );
  }
}

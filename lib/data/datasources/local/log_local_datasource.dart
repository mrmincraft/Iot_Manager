// Local DataSource Interface: LogLocalDataSource
// Interface pour les opérations de base de données sur les logs

import 'package:iot_manager/data/models/log_entry_model.dart';

abstract class LogLocalDataSource {
  Future<List<LogEntryModel>> getAllLogs();
  Future<LogEntryModel> getLogById(String id);
  Future<void> addLog(LogEntryModel logEntry);
  Future<void> updateLog(LogEntryModel logEntry);
  Future<void> deleteLog(String id);
  Future<List<LogEntryModel>> getLogsBySeverity(String severity);
  Future<List<LogEntryModel>> getLogsByCategory(String category);
  Future<List<LogEntryModel>> getUnresolvedLogs();
  Future<List<LogEntryModel>> getLogsBetweenDates(DateTime startDate, DateTime endDate);
  Future<List<LogEntryModel>> getLogsPaginated(int page, int limit);
  Future<int> getLogCount();
  Future<void> deleteOldLogs(DateTime beforeDate);
  Future<List<LogEntryModel>> searchLogsByMessage(String query);
}

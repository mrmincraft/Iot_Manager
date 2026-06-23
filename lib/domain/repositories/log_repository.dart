// Domain Repository Interface: LogRepository
// Interface pour la gestion des logs

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/log_entry.dart';

abstract class LogRepository {
  /// Récupère tous les logs
  Future<Result<List<LogEntry>, Exception>> getAllLogs();

  /// Récupère un log par ID
  Future<Result<LogEntry, Exception>> getLogById(String id);

  /// Ajoute un nouveau log
  Future<Result<LogEntry, Exception>> addLog(LogEntry logEntry);

  /// Met à jour un log
  Future<Result<LogEntry, Exception>> updateLog(LogEntry logEntry);

  /// Supprime un log
  Future<Result<void, Exception>> deleteLog(String id);

  /// Récupère les logs d'une certaine sévérité
  Future<Result<List<LogEntry>, Exception>> getLogsBySeverity(LogSeverity severity);

  /// Récupère les logs d'une certaine catégorie
  Future<Result<List<LogEntry>, Exception>> getLogsByCategory(LogCategory category);

  /// Récupère les logs non résolus
  Future<Result<List<LogEntry>, Exception>> getUnresolvedLogs();

  /// Récupère les logs entre deux dates
  Future<Result<List<LogEntry>, Exception>> getLogsBetweenDates(DateTime startDate, DateTime endDate);

  /// Récupère les logs avec pagination
  Future<Result<List<LogEntry>, Exception>> getLogsPaginated(int page, int limit);

  /// Compte le nombre total de logs
  Future<Result<int, Exception>> getLogCount();

  /// Marque un log comme résolu
  Future<Result<LogEntry, Exception>> resolveLog(String logId, String resolutionNotes);

  /// Supprime les anciens logs
  Future<Result<void, Exception>> deleteOldLogs(DateTime beforeDate);

  /// Recherche des logs par message
  Future<Result<List<LogEntry>, Exception>> searchLogsByMessage(String query);
}

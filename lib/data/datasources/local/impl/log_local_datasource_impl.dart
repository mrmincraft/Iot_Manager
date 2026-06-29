import 'package:sqflite/sqflite.dart';
import '../../models/log_entry_model.dart';

/// LocalDataSource pour les Log Entries
class LogLocalDataSourceImpl implements LogLocalDataSource {
  final Database _database;
  
  LogLocalDataSourceImpl(this._database);
  
  @override
  Future<List<LogEntryModel>> getAllLogs() async {
    try {
      final maps = await _database.query(
        'log_entries',
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => LogEntryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching all logs: $e');
    }
  }
  
  @override
  Future<LogEntryModel> getLogById(String id) async {
    try {
      final maps = await _database.query(
        'log_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Log entry with id $id not found');
      }
      
      return LogEntryModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching log by id: $e');
    }
  }
  
  @override
  Future<void> createLog(LogEntryModel log) async {
    try {
      await _database.insert(
        'log_entries',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating log: $e');
    }
  }
  
  @override
  Future<void> updateLog(LogEntryModel log) async {
    try {
      final rowsAffected = await _database.update(
        'log_entries',
        log.toMap(),
        where: 'id = ?',
        whereArgs: [log.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Log entry with id ${log.id} not found');
      }
    } catch (e) {
      throw Exception('Error updating log: $e');
    }
  }
  
  @override
  Future<void> deleteLog(String id) async {
    try {
      final rowsAffected = await _database.delete(
        'log_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Log entry with id $id not found');
      }
    } catch (e) {
      throw Exception('Error deleting log: $e');
    }
  }
  
  @override
  Future<List<LogEntryModel>> getLogsBySeverity(String severity) async {
    try {
      final maps = await _database.query(
        'log_entries',
        where: 'severity = ?',
        whereArgs: [severity],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => LogEntryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching logs by severity: $e');
    }
  }
  
  @override
  Future<List<LogEntryModel>> getLogsByCategory(String category) async {
    try {
      final maps = await _database.query(
        'log_entries',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => LogEntryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching logs by category: $e');
    }
  }
  
  @override
  Future<List<LogEntryModel>> getUnresolvedLogs() async {
    try {
      final maps = await _database.query(
        'log_entries',
        where: 'isResolved = ?',
        whereArgs: [0],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => LogEntryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching unresolved logs: $e');
    }
  }
  
  @override
  Future<List<LogEntryModel>> getLogsByConnection(String connectionId) async {
    try {
      final maps = await _database.query(
        'log_entries',
        where: 'connectionId = ?',
        whereArgs: [connectionId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => LogEntryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching logs by connection: $e');
    }
  }
  
  @override
  Future<List<LogEntryModel>> getRecentLogs(int limit) async {
    try {
      final maps = await _database.query(
        'log_entries',
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return maps.map((map) => LogEntryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching recent logs: $e');
    }
  }
  
  @override
  Future<int> deleteOldLogs(DateTime beforeDate) async {
    try {
      return await _database.delete(
        'log_entries',
        where: 'timestamp < ?',
        whereArgs: [beforeDate.toIso8601String()],
      );
    } catch (e) {
      throw Exception('Error deleting old logs: $e');
    }
  }
  
  @override
  Future<int> resolveLog(String logId, String resolutionNotes) async {
    try {
      return await _database.rawUpdate(
        'UPDATE log_entries SET isResolved = 1, resolutionNotes = ?, resolvedAt = ? WHERE id = ?',
        [resolutionNotes, DateTime.now().toIso8601String(), logId],
      );
    } catch (e) {
      throw Exception('Error resolving log: $e');
    }
  }
}

import '../../domain/entities/command.dart';

/// Command Local DataSource Interface
/// 
/// Contracts for local SQLite database operations on commands
abstract class CommandLocalDataSource {
  /// Insert command
  Future<void> insertCommand(Command command);
  
  /// Get command by ID
  Future<Command?> getCommand(String id);
  
  /// Get all commands
  Future<List<Command>> getAllCommands();
  
  /// Get commands for device
  Future<List<Command>> getCommandsByDevice(String deviceId);
  
  /// Get command history with pagination
  Future<List<Command>> getCommandHistory(
    String deviceId, {
    int limit = 50,
    int offset = 0,
  });
  
  /// Update command
  Future<void> updateCommand(Command command);
  
  /// Get pending commands
  Future<List<Command>> getPendingCommands();
  
  /// Delete command
  Future<void> deleteCommand(String id);
  
  /// Delete commands older than date
  Future<void> deleteOldCommands(DateTime beforeDate);
  
  /// Get command count for device
  Future<int> getCommandCount(String deviceId);
}

import '../entities/command.dart';
import '../../core/utils/result.dart';

/// Command Repository Interface (Contract)
/// 
/// Responsibilities:
/// - Abstract operations for device commands
/// - Manage command execution and history
abstract class CommandRepository {
  /// Send command to device
  Future<Result<Command>> sendCommand(Command command);
  
  /// Get command by ID
  Future<Result<Command>> getCommand(String id);
  
  /// Get all commands
  Future<Result<List<Command>>> getAllCommands();
  
  /// Get commands for device
  Future<Result<List<Command>>> getCommandsByDevice(String deviceId);
  
  /// Get command history with pagination
  Future<Result<List<Command>>> getCommandHistory(
    String deviceId, {
    int limit = 50,
    int offset = 0,
  });
  
  /// Update command status
  Future<Result<Command>> updateCommandStatus(
    String commandId,
    String status, {
    String? response,
    String? error,
  });
  
  /// Get pending commands
  Future<Result<List<Command>>> getPendingCommands();
  
  /// Delete command
  Future<Result<void>> deleteCommand(String id);
}

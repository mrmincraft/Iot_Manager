import '../entities/connection.dart';
import '../../core/utils/result.dart';

/// Connection Repository Interface (Contract)
/// 
/// Responsibilities:
/// - Abstract operations related to device connections
/// - Manage connection state and history
/// 
/// Implementation: ConnectionRepositoryImpl
abstract class ConnectionRepository {
  /// Get current connection for device
  Future<Result<Connection>> getConnection(String deviceId);
  
  /// Get all connections
  Future<Result<List<Connection>>> getAllConnections();
  
  /// Get connection history
  Future<Result<List<Connection>>> getConnectionHistory(
    String deviceId, {
    DateTime? from,
    DateTime? to,
  });
  
  /// Save connection
  Future<Result<Connection>> saveConnection(Connection connection);
  
  /// Update connection
  Future<Result<Connection>> updateConnection(Connection connection);
  
  /// Get active connections
  Future<Result<List<Connection>>> getActiveConnections();
  
  /// Get connection statistics
  Future<Result<Map<String, dynamic>>> getConnectionStats(String deviceId);
}

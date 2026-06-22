import '../../domain/entities/connection.dart';

/// Connection Local DataSource Interface
/// 
/// Contracts for local SQLite database operations on connections
abstract class ConnectionLocalDataSource {
  /// Get current connection for device
  Future<Connection?> getConnection(String deviceId);
  
  /// Get all connections
  Future<List<Connection>> getAllConnections();
  
  /// Get connection history
  Future<List<Connection>> getConnectionHistory(
    String deviceId, {
    DateTime? from,
    DateTime? to,
  });
  
  /// Insert connection
  Future<void> insertConnection(Connection connection);
  
  /// Update connection
  Future<void> updateConnection(Connection connection);
  
  /// Get active connections
  Future<List<Connection>> getActiveConnections();
  
  /// Delete connection
  Future<void> deleteConnection(String id);
  
  /// Delete connections older than date
  Future<void> deleteOldConnections(DateTime beforeDate);
  
  /// Get connection count for device
  Future<int> getConnectionCount(String deviceId);
}

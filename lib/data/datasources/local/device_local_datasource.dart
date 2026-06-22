import '../../domain/entities/device.dart';
import '../../core/utils/result.dart';

/// Device Local DataSource Interface
/// 
/// Contracts for local SQLite database operations
/// Isolates database-specific logic from business logic
/// 
/// Responsibilities:
/// - CRUD operations on SQLite
/// - Type conversion (Model ↔ Entity)
/// - Query building
/// 
/// Implementation: DeviceLocalDataSourceImpl
/// 
/// Principles:
/// - Single responsibility: Only database access
/// - Contract-based: Easy to swap implementations (e.g., for testing)
abstract class DeviceLocalDataSource {
  /// Get all devices from database
  Future<List<Device>> getAllDevices();
  
  /// Get device by ID
  Future<Device?> getDeviceById(String id);
  
  /// Insert new device
  Future<void> insertDevice(Device device);
  
  /// Update device
  Future<void> updateDevice(Device device);
  
  /// Delete device
  Future<void> deleteDevice(String id);
  
  /// Search devices by name or type
  Future<List<Device>> searchDevices(String query);
  
  /// Get devices by type
  Future<List<Device>> getDevicesByType(String type);
  
  /// Check if device exists
  Future<bool> deviceExists(String id);
  
  /// Get device count
  Future<int> getDeviceCount();
}

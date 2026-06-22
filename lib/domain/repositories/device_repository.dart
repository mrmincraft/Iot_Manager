import '../entities/device.dart';
import '../../core/utils/result.dart';

/// Device Repository Interface (Contract)
/// 
/// Responsibilities:
/// - Abstract CRUD operations for devices
/// - No implementation details
/// - Belong to Domain layer
/// 
/// Principles:
/// - Dependency Inversion: DataLayer depends on DomainLayer
/// - Repository pattern: Isolate data access logic
/// - Testability: Easy to mock for testing
/// 
/// Implementation:
/// - DeviceRepositoryImpl in data layer
/// 
/// Usage:
/// ```dart
/// final devices = await deviceRepository.getAllDevices();
/// final device = await deviceRepository.getDeviceById(id);
/// await deviceRepository.addDevice(device);
/// ```
abstract class DeviceRepository {
  /// Get all devices
  Future<Result<List<Device>>> getAllDevices();
  
  /// Get device by ID
  Future<Result<Device>> getDeviceById(String id);
  
  /// Add new device
  Future<Result<Device>> addDevice(Device device);
  
  /// Update existing device
  Future<Result<Device>> updateDevice(Device device);
  
  /// Delete device
  Future<Result<void>> deleteDevice(String id);
  
  /// Search devices by name or type
  Future<Result<List<Device>>> searchDevices(String query);
  
  /// Get devices by type
  Future<Result<List<Device>>> getDevicesByType(String type);
}

import '../../domain/entities/device.dart';
import '../../domain/entities/connection.dart';
import '../../domain/entities/command.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/connection_repository.dart';
import '../../domain/repositories/command_repository.dart';
import '../../core/utils/result.dart';
import '../../core/exceptions/exceptions.dart';
import '../datasources/local/device_local_datasource.dart';
import '../datasources/local/connection_local_datasource.dart';
import '../datasources/local/command_local_datasource.dart';

/// Device Repository Implementation
/// 
/// Coordinates between DataSources and handles:
/// - Error handling
/// - Data transformation
/// - Business logic orchestration
/// 
/// Implements the interface defined in domain layer
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource deviceLocalDataSource;
  
  DeviceRepositoryImpl({
    required this.deviceLocalDataSource,
  });
  
  @override
  Future<Result<List<Device>>> getAllDevices() async {
    try {
      final devices = await deviceLocalDataSource.getAllDevices();
      return Success(devices);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get devices',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get devices',
        code: 'FETCH_DEVICES_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Device>> getDeviceById(String id) async {
    try {
      final device = await deviceLocalDataSource.getDeviceById(id);
      if (device == null) {
        return Failure(
          exception: NotFoundException(message: 'Device not found'),
          message: 'Device with id $id not found',
          code: 'DEVICE_NOT_FOUND',
        );
      }
      return Success(device);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get device',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get device',
        code: 'FETCH_DEVICE_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Device>> addDevice(Device device) async {
    try {
      await deviceLocalDataSource.insertDevice(device);
      return Success(device);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to add device',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to add device',
        code: 'ADD_DEVICE_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Device>> updateDevice(Device device) async {
    try {
      await deviceLocalDataSource.updateDevice(device);
      return Success(device);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to update device',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to update device',
        code: 'UPDATE_DEVICE_ERROR',
      );
    }
  }
  
  @override
  Future<Result<void>> deleteDevice(String id) async {
    try {
      await deviceLocalDataSource.deleteDevice(id);
      return Success(null);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to delete device',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to delete device',
        code: 'DELETE_DEVICE_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Device>>> searchDevices(String query) async {
    try {
      final devices = await deviceLocalDataSource.searchDevices(query);
      return Success(devices);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to search devices',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to search devices',
        code: 'SEARCH_DEVICES_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Device>>> getDevicesByType(String type) async {
    try {
      final devices = await deviceLocalDataSource.getDevicesByType(type);
      return Success(devices);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get devices by type',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get devices by type',
        code: 'FETCH_DEVICES_BY_TYPE_ERROR',
      );
    }
  }
}

/// Connection Repository Implementation
class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionLocalDataSource connectionLocalDataSource;
  
  ConnectionRepositoryImpl({
    required this.connectionLocalDataSource,
  });
  
  @override
  Future<Result<Connection>> getConnection(String deviceId) async {
    try {
      final connection = await connectionLocalDataSource.getConnection(deviceId);
      if (connection == null) {
        return Failure(
          exception: NotFoundException(message: 'Connection not found'),
          message: 'Connection for device $deviceId not found',
          code: 'CONNECTION_NOT_FOUND',
        );
      }
      return Success(connection);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get connection',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get connection',
        code: 'FETCH_CONNECTION_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Connection>>> getAllConnections() async {
    try {
      final connections = await connectionLocalDataSource.getAllConnections();
      return Success(connections);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get connections',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get connections',
        code: 'FETCH_CONNECTIONS_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Connection>>> getConnectionHistory(
    String deviceId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final connections = await connectionLocalDataSource.getConnectionHistory(
        deviceId,
        from: from,
        to: to,
      );
      return Success(connections);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get connection history',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get connection history',
        code: 'FETCH_CONNECTION_HISTORY_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Connection>> saveConnection(Connection connection) async {
    try {
      await connectionLocalDataSource.insertConnection(connection);
      return Success(connection);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to save connection',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to save connection',
        code: 'SAVE_CONNECTION_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Connection>> updateConnection(Connection connection) async {
    try {
      await connectionLocalDataSource.updateConnection(connection);
      return Success(connection);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to update connection',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to update connection',
        code: 'UPDATE_CONNECTION_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Connection>>> getActiveConnections() async {
    try {
      final connections = await connectionLocalDataSource.getActiveConnections();
      return Success(connections);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get active connections',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get active connections',
        code: 'FETCH_ACTIVE_CONNECTIONS_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Map<String, dynamic>>> getConnectionStats(
    String deviceId,
  ) async {
    try {
      final connections = await connectionLocalDataSource.getConnectionHistory(
        deviceId,
      );
      
      // Calculate stats from connections
      final stats = {
        'totalConnections': connections.length,
        'successfulConnections': connections
            .where((c) => c.status == 'connected')
            .length,
        'failedConnections': connections
            .where((c) => c.status == 'error')
            .length,
        'averageSignalStrength': connections.isNotEmpty
            ? connections
                .map((c) => c.signalStrength)
                .reduce((a, b) => a + b) /
                connections.length
            : 0,
      };
      
      return Success(stats);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get connection stats',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get connection stats',
        code: 'FETCH_CONNECTION_STATS_ERROR',
      );
    }
  }
}

/// Command Repository Implementation
class CommandRepositoryImpl implements CommandRepository {
  final CommandLocalDataSource commandLocalDataSource;
  
  CommandRepositoryImpl({
    required this.commandLocalDataSource,
  });
  
  @override
  Future<Result<Command>> sendCommand(Command command) async {
    try {
      await commandLocalDataSource.insertCommand(command);
      return Success(command);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to send command',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to send command',
        code: 'SEND_COMMAND_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Command>> getCommand(String id) async {
    try {
      final command = await commandLocalDataSource.getCommand(id);
      if (command == null) {
        return Failure(
          exception: NotFoundException(message: 'Command not found'),
          message: 'Command with id $id not found',
          code: 'COMMAND_NOT_FOUND',
        );
      }
      return Success(command);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get command',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get command',
        code: 'FETCH_COMMAND_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Command>>> getAllCommands() async {
    try {
      final commands = await commandLocalDataSource.getAllCommands();
      return Success(commands);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get commands',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get commands',
        code: 'FETCH_COMMANDS_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Command>>> getCommandsByDevice(String deviceId) async {
    try {
      final commands = await commandLocalDataSource.getCommandsByDevice(deviceId);
      return Success(commands);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get commands for device',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get commands for device',
        code: 'FETCH_DEVICE_COMMANDS_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Command>>> getCommandHistory(
    String deviceId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final commands = await commandLocalDataSource.getCommandHistory(
        deviceId,
        limit: limit,
        offset: offset,
      );
      return Success(commands);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get command history',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get command history',
        code: 'FETCH_COMMAND_HISTORY_ERROR',
      );
    }
  }
  
  @override
  Future<Result<Command>> updateCommandStatus(
    String commandId,
    String status, {
    String? response,
    String? error,
  }) async {
    try {
      final command = await commandLocalDataSource.getCommand(commandId);
      if (command == null) {
        return Failure(
          exception: NotFoundException(message: 'Command not found'),
          message: 'Command with id $commandId not found',
          code: 'COMMAND_NOT_FOUND',
        );
      }
      
      final updatedCommand = command.copyWith(
        status: status,
        response: response,
        error: error,
        executedAt: DateTime.now(),
      );
      
      await commandLocalDataSource.updateCommand(updatedCommand);
      return Success(updatedCommand);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to update command status',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to update command status',
        code: 'UPDATE_COMMAND_STATUS_ERROR',
      );
    }
  }
  
  @override
  Future<Result<List<Command>>> getPendingCommands() async {
    try {
      final commands = await commandLocalDataSource.getPendingCommands();
      return Success(commands);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to get pending commands',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to get pending commands',
        code: 'FETCH_PENDING_COMMANDS_ERROR',
      );
    }
  }
  
  @override
  Future<Result<void>> deleteCommand(String id) async {
    try {
      await commandLocalDataSource.deleteCommand(id);
      return Success(null);
    } catch (e, stack) {
      return Failure(
        exception: DataException(
          message: 'Failed to delete command',
          originalError: e,
          stackTrace: stack,
        ),
        message: 'Failed to delete command',
        code: 'DELETE_COMMAND_ERROR',
      );
    }
  }
}

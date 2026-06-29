import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET ALL CONNECTIONS
// ============================================================

/// Get All Connections Use Case
class GetAllConnectionsUseCase extends UseCase<List<Connection>, NoParams> {
  final ConnectionRepository _connectionRepository;

  GetAllConnectionsUseCase(this._connectionRepository);

  @override
  Future<Result<List<Connection>>> call(NoParams params) async {
    return _connectionRepository.getAllConnections();
  }
}

// ============================================================
// GET CONNECTION BY ID
// ============================================================

class GetConnectionByIdParams {
  final String id;
  GetConnectionByIdParams({required this.id});
}

/// Get Connection By ID Use Case
class GetConnectionByIdUseCase extends UseCase<Connection, GetConnectionByIdParams> {
  final ConnectionRepository _connectionRepository;

  GetConnectionByIdUseCase(this._connectionRepository);

  @override
  Future<Result<Connection>> call(GetConnectionByIdParams params) async {
    return _connectionRepository.getConnectionById(params.id);
  }
}

// ============================================================
// CREATE CONNECTION
// ============================================================

class CreateConnectionParams {
  final Connection connection;
  CreateConnectionParams({required this.connection});
}

/// Create Connection Use Case
class CreateConnectionUseCase extends UseCase<Connection, CreateConnectionParams> {
  final ConnectionRepository _connectionRepository;

  CreateConnectionUseCase(this._connectionRepository);

  @override
  Future<Result<Connection>> call(CreateConnectionParams params) async {
    return _connectionRepository.createConnection(params.connection);
  }
}

// ============================================================
// UPDATE CONNECTION
// ============================================================

class UpdateConnectionParams {
  final Connection connection;
  UpdateConnectionParams({required this.connection});
}

/// Update Connection Use Case
class UpdateConnectionUseCase extends UseCase<Connection, UpdateConnectionParams> {
  final ConnectionRepository _connectionRepository;

  UpdateConnectionUseCase(this._connectionRepository);

  @override
  Future<Result<Connection>> call(UpdateConnectionParams params) async {
    return _connectionRepository.updateConnection(params.connection);
  }
}

// ============================================================
// DELETE CONNECTION
// ============================================================

class DeleteConnectionParams {
  final String id;
  DeleteConnectionParams({required this.id});
}

/// Delete Connection Use Case
class DeleteConnectionUseCase extends UseCase<void, DeleteConnectionParams> {
  final ConnectionRepository _connectionRepository;

  DeleteConnectionUseCase(this._connectionRepository);

  @override
  Future<Result<void>> call(DeleteConnectionParams params) async {
    return _connectionRepository.deleteConnection(params.id);
  }
}

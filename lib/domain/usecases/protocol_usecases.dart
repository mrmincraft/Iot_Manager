import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET ALL PROTOCOLS
// ============================================================

/// Retrieves all protocols from the repository
class GetAllProtocolsUseCase extends UseCase<List<Protocol>, NoParams> {
  final ProtocolRepository _protocolRepository;

  GetAllProtocolsUseCase(this._protocolRepository);

  @override
  Future<Result<List<Protocol>>> call(NoParams params) async {
    return _protocolRepository.getAllProtocols();
  }
}

// ============================================================
// GET PROTOCOL BY ID
// ============================================================

class GetProtocolByIdParams {
  final String id;
  GetProtocolByIdParams({required this.id});
}

/// Retrieves a protocol by its ID
class GetProtocolByIdUseCase extends UseCase<Protocol, GetProtocolByIdParams> {
  final ProtocolRepository _protocolRepository;

  GetProtocolByIdUseCase(this._protocolRepository);

  @override
  Future<Result<Protocol>> call(GetProtocolByIdParams params) async {
    return _protocolRepository.getProtocolById(params.id);
  }
}

// ============================================================
// CREATE PROTOCOL
// ============================================================

class CreateProtocolParams {
  final Protocol protocol;
  CreateProtocolParams({required this.protocol});
}

/// Creates a new protocol
class CreateProtocolUseCase extends UseCase<Protocol, CreateProtocolParams> {
  final ProtocolRepository _protocolRepository;

  CreateProtocolUseCase(this._protocolRepository);

  @override
  Future<Result<Protocol>> call(CreateProtocolParams params) async {
    return _protocolRepository.createProtocol(params.protocol);
  }
}

// ============================================================
// UPDATE PROTOCOL
// ============================================================

class UpdateProtocolParams {
  final Protocol protocol;
  UpdateProtocolParams({required this.protocol});
}

/// Updates an existing protocol
class UpdateProtocolUseCase extends UseCase<Protocol, UpdateProtocolParams> {
  final ProtocolRepository _protocolRepository;

  UpdateProtocolUseCase(this._protocolRepository);

  @override
  Future<Result<Protocol>> call(UpdateProtocolParams params) async {
    return _protocolRepository.updateProtocol(params.protocol);
  }
}

// ============================================================
// DELETE PROTOCOL
// ============================================================

class DeleteProtocolParams {
  final String id;
  DeleteProtocolParams({required this.id});
}

/// Deletes a protocol by ID
class DeleteProtocolUseCase extends UseCase<void, DeleteProtocolParams> {
  final ProtocolRepository _protocolRepository;

  DeleteProtocolUseCase(this._protocolRepository);

  @override
  Future<Result<void>> call(DeleteProtocolParams params) async {
    return _protocolRepository.deleteProtocol(params.id);
  }
}

// ============================================================
// GET PROTOCOLS BY TYPE
// ============================================================

class GetProtocolsByTypeParams {
  final ProtocolType type;
  GetProtocolsByTypeParams({required this.type});
}

/// Retrieves all protocols of a specific type
class GetProtocolsByTypeUseCase extends UseCase<List<Protocol>, GetProtocolsByTypeParams> {
  final ProtocolRepository _protocolRepository;

  GetProtocolsByTypeUseCase(this._protocolRepository);

  @override
  Future<Result<List<Protocol>>> call(GetProtocolsByTypeParams params) async {
    return _protocolRepository.getProtocolsByType(params.type);
  }
}

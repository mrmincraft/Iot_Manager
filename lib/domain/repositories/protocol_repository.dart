// Domain Repository Interface: ProtocolRepository
// Interface pour la gestion des protocoles

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/protocol.dart';

abstract class ProtocolRepository {
  /// Récupère tous les protocoles
  Future<Result<List<Protocol>, Exception>> getAllProtocols();

  /// Récupère un protocole par ID
  Future<Result<Protocol, Exception>> getProtocolById(String id);

  /// Crée un nouveau protocole
  Future<Result<Protocol, Exception>> createProtocol(Protocol protocol);

  /// Met à jour un protocole
  Future<Result<Protocol, Exception>> updateProtocol(Protocol protocol);

  /// Supprime un protocole
  Future<Result<void, Exception>> deleteProtocol(String id);

  /// Recherche des protocoles par type
  Future<Result<List<Protocol>, Exception>> getProtocolsByType(ProtocolType type);
}

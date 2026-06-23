// Local DataSource Interface: ProtocolLocalDataSource
// Interface pour les opérations de base de données sur les protocoles

import 'package:iot_manager/data/models/protocol_model.dart';

abstract class ProtocolLocalDataSource {
  Future<List<ProtocolModel>> getAllProtocols();
  Future<ProtocolModel> getProtocolById(String id);
  Future<void> createProtocol(ProtocolModel protocol);
  Future<void> updateProtocol(ProtocolModel protocol);
  Future<void> deleteProtocol(String id);
  Future<List<ProtocolModel>> getProtocolsByType(String type);
}

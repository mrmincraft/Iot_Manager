import 'package:sqflite/sqflite.dart';
import '../../models/protocol_model.dart';

/// LocalDataSource pour les Protocoles
/// Gère tous les opérations CRUD sur la table 'protocols'
class ProtocolLocalDataSourceImpl implements ProtocolLocalDataSource {
  final Database _database;
  
  ProtocolLocalDataSourceImpl(this._database);
  
  @override
  Future<List<ProtocolModel>> getAllProtocols() async {
    try {
      final maps = await _database.query('protocols');
      return maps.map((map) => ProtocolModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching all protocols: $e');
    }
  }
  
  @override
  Future<ProtocolModel> getProtocolById(String id) async {
    try {
      final maps = await _database.query(
        'protocols',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Protocol with id $id not found');
      }
      
      return ProtocolModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching protocol by id: $e');
    }
  }
  
  @override
  Future<void> createProtocol(ProtocolModel protocol) async {
    try {
      await _database.insert(
        'protocols',
        protocol.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating protocol: $e');
    }
  }
  
  @override
  Future<void> updateProtocol(ProtocolModel protocol) async {
    try {
      final rowsAffected = await _database.update(
        'protocols',
        protocol.toMap(),
        where: 'id = ?',
        whereArgs: [protocol.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Protocol with id ${protocol.id} not found');
      }
    } catch (e) {
      throw Exception('Error updating protocol: $e');
    }
  }
  
  @override
  Future<void> deleteProtocol(String id) async {
    try {
      final rowsAffected = await _database.delete(
        'protocols',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Protocol with id $id not found');
      }
    } catch (e) {
      throw Exception('Error deleting protocol: $e');
    }
  }
  
  @override
  Future<List<ProtocolModel>> getProtocolsByType(String type) async {
    try {
      final maps = await _database.query(
        'protocols',
        where: 'type = ?',
        whereArgs: [type],
      );
      return maps.map((map) => ProtocolModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching protocols by type: $e');
    }
  }
}

import 'package:sqflite/sqflite.dart';
import '../../models/connection_model.dart';

/// LocalDataSource pour les Connexions
class ConnectionLocalDataSourceImpl implements ConnectionLocalDataSource {
  final Database _database;
  
  ConnectionLocalDataSourceImpl(this._database);
  
  @override
  Future<List<ConnectionModel>> getAllConnections() async {
    try {
      final maps = await _database.query('connections');
      return maps.map((map) => ConnectionModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching all connections: $e');
    }
  }
  
  @override
  Future<ConnectionModel> getConnectionById(String id) async {
    try {
      final maps = await _database.query(
        'connections',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Connection with id $id not found');
      }
      
      return ConnectionModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching connection by id: $e');
    }
  }
  
  @override
  Future<void> createConnection(ConnectionModel connection) async {
    try {
      await _database.insert(
        'connections',
        connection.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating connection: $e');
    }
  }
  
  @override
  Future<void> updateConnection(ConnectionModel connection) async {
    try {
      final rowsAffected = await _database.update(
        'connections',
        connection.toMap(),
        where: 'id = ?',
        whereArgs: [connection.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Connection with id ${connection.id} not found');
      }
    } catch (e) {
      throw Exception('Error updating connection: $e');
    }
  }
  
  @override
  Future<void> deleteConnection(String id) async {
    try {
      final rowsAffected = await _database.delete(
        'connections',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Connection with id $id not found');
      }
    } catch (e) {
      throw Exception('Error deleting connection: $e');
    }
  }
  
  @override
  Future<List<ConnectionModel>> getConnectionsByStatus(String status) async {
    try {
      final maps = await _database.query(
        'connections',
        where: 'status = ?',
        whereArgs: [status],
      );
      return maps.map((map) => ConnectionModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching connections by status: $e');
    }
  }
  
  @override
  Future<List<ConnectionModel>> getEnabledConnections() async {
    try {
      final maps = await _database.query(
        'connections',
        where: 'isEnabled = ?',
        whereArgs: [1],
      );
      return maps.map((map) => ConnectionModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching enabled connections: $e');
    }
  }
  
  @override
  Future<List<ConnectionModel>> getConnectionsByProtocol(String protocolId) async {
    try {
      final maps = await _database.query(
        'connections',
        where: 'protocolId = ?',
        whereArgs: [protocolId],
      );
      return maps.map((map) => ConnectionModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching connections by protocol: $e');
    }
  }
}

import 'package:sqflite/sqflite.dart';
import '../../models/topic_model.dart';

/// LocalDataSource pour les Topics
class TopicLocalDataSourceImpl implements TopicLocalDataSource {
  final Database _database;
  
  TopicLocalDataSourceImpl(this._database);
  
  @override
  Future<List<TopicModel>> getAllTopics() async {
    try {
      final maps = await _database.query('topics');
      return maps.map((map) => TopicModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching all topics: $e');
    }
  }
  
  @override
  Future<TopicModel> getTopicById(String id) async {
    try {
      final maps = await _database.query(
        'topics',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Topic with id $id not found');
      }
      
      return TopicModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching topic by id: $e');
    }
  }
  
  @override
  Future<void> createTopic(TopicModel topic) async {
    try {
      await _database.insert(
        'topics',
        topic.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating topic: $e');
    }
  }
  
  @override
  Future<void> updateTopic(TopicModel topic) async {
    try {
      final rowsAffected = await _database.update(
        'topics',
        topic.toMap(),
        where: 'id = ?',
        whereArgs: [topic.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Topic with id ${topic.id} not found');
      }
    } catch (e) {
      throw Exception('Error updating topic: $e');
    }
  }
  
  @override
  Future<void> deleteTopic(String id) async {
    try {
      final rowsAffected = await _database.delete(
        'topics',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Topic with id $id not found');
      }
    } catch (e) {
      throw Exception('Error deleting topic: $e');
    }
  }
  
  @override
  Future<List<TopicModel>> getTopicsByConnection(String connectionId) async {
    try {
      final maps = await _database.query(
        'topics',
        where: 'connectionId = ?',
        whereArgs: [connectionId],
      );
      return maps.map((map) => TopicModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching topics by connection: $e');
    }
  }
  
  @override
  Future<List<TopicModel>> getSubscribedTopics(String connectionId) async {
    try {
      final maps = await _database.query(
        'topics',
        where: 'connectionId = ? AND subscribed = ?',
        whereArgs: [connectionId, 1],
      );
      return maps.map((map) => TopicModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching subscribed topics: $e');
    }
  }
  
  @override
  Future<TopicModel?> getTopicByPath(String connectionId, String path) async {
    try {
      final maps = await _database.query(
        'topics',
        where: 'connectionId = ? AND path = ?',
        whereArgs: [connectionId, path],
      );
      
      if (maps.isEmpty) return null;
      return TopicModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching topic by path: $e');
    }
  }
}

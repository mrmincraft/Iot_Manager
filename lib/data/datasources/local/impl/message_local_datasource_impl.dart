import 'package:sqflite/sqflite.dart';
import '../../models/message_model.dart';

/// LocalDataSource pour les Messages
class MessageLocalDataSourceImpl implements MessageLocalDataSource {
  final Database _database;
  
  MessageLocalDataSourceImpl(this._database);
  
  @override
  Future<List<MessageModel>> getAllMessages() async {
    try {
      final maps = await _database.query('messages');
      return maps.map((map) => MessageModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching all messages: $e');
    }
  }
  
  @override
  Future<MessageModel> getMessageById(String id) async {
    try {
      final maps = await _database.query(
        'messages',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Message with id $id not found');
      }
      
      return MessageModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching message by id: $e');
    }
  }
  
  @override
  Future<void> createMessage(MessageModel message) async {
    try {
      await _database.insert(
        'messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating message: $e');
    }
  }
  
  @override
  Future<void> updateMessage(MessageModel message) async {
    try {
      final rowsAffected = await _database.update(
        'messages',
        message.toMap(),
        where: 'id = ?',
        whereArgs: [message.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Message with id ${message.id} not found');
      }
    } catch (e) {
      throw Exception('Error updating message: $e');
    }
  }
  
  @override
  Future<void> deleteMessage(String id) async {
    try {
      final rowsAffected = await _database.delete(
        'messages',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Message with id $id not found');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }
  
  @override
  Future<List<MessageModel>> getMessagesByTopic(String topicId) async {
    try {
      final maps = await _database.query(
        'messages',
        where: 'topicId = ?',
        whereArgs: [topicId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => MessageModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching messages by topic: $e');
    }
  }
  
  @override
  Future<List<MessageModel>> getMessagesByConnection(String connectionId) async {
    try {
      final maps = await _database.query(
        'messages',
        where: 'connectionId = ?',
        whereArgs: [connectionId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => MessageModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching messages by connection: $e');
    }
  }
  
  @override
  Future<List<MessageModel>> getUnprocessedMessages() async {
    try {
      final maps = await _database.query(
        'messages',
        where: 'processed = ?',
        whereArgs: [0],
        orderBy: 'timestamp ASC',
      );
      return maps.map((map) => MessageModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching unprocessed messages: $e');
    }
  }
  
  @override
  Future<List<MessageModel>> getRecentMessages(String topicId, int limit) async {
    try {
      final maps = await _database.query(
        'messages',
        where: 'topicId = ?',
        whereArgs: [topicId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return maps.map((map) => MessageModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching recent messages: $e');
    }
  }
  
  @override
  Future<int> deleteOldMessages(String topicId, DateTime beforeDate) async {
    try {
      return await _database.delete(
        'messages',
        where: 'topicId = ? AND timestamp < ?',
        whereArgs: [topicId, beforeDate.toIso8601String()],
      );
    } catch (e) {
      throw Exception('Error deleting old messages: $e');
    }
  }
}

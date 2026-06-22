import '../../domain/entities/command.dart';

/// Command Model - SQLite representation
/// 
/// Database Schema (command table):
/// - id (TEXT, PRIMARY KEY)
/// - device_id (TEXT, FOREIGN KEY)
/// - command_type (TEXT)
/// - parameters (TEXT as JSON)
/// - status (TEXT)
/// - response (TEXT)
/// - sent_at (INTEGER as timestamp)
/// - executed_at (INTEGER as timestamp)
/// - error (TEXT)
class CommandModel {
  final String id;
  final String deviceId;
  final String commandType;
  final String parametersJson; // JSON string
  final String status;
  final String? response;
  final DateTime sentAt;
  final DateTime? executedAt;
  final String? error;
  
  CommandModel({
    required this.id,
    required this.deviceId,
    required this.commandType,
    required this.parametersJson,
    required this.status,
    this.response,
    required this.sentAt,
    this.executedAt,
    this.error,
  });
  
  /// Convert to Domain Entity
  Command toEntity() {
    return Command(
      id: id,
      deviceId: deviceId,
      commandType: commandType,
      parameters: _parseParameters(parametersJson),
      status: status,
      response: response,
      sentAt: sentAt,
      executedAt: executedAt,
      error: error,
    );
  }
  
  /// Create from Domain Entity
  factory CommandModel.fromEntity(Command entity) {
    return CommandModel(
      id: entity.id,
      deviceId: entity.deviceId,
      commandType: entity.commandType,
      parametersJson: _serializeParameters(entity.parameters),
      status: entity.status,
      response: entity.response,
      sentAt: entity.sentAt,
      executedAt: entity.executedAt,
      error: entity.error,
    );
  }
  
  /// Convert to SQLite record
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'command_type': commandType,
      'parameters': parametersJson,
      'status': status,
      'response': response,
      'sent_at': sentAt.millisecondsSinceEpoch,
      'executed_at': executedAt?.millisecondsSinceEpoch,
      'error': error,
    };
  }
  
  /// Create from SQLite record
  factory CommandModel.fromJson(Map<String, dynamic> json) {
    return CommandModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      commandType: json['command_type'] as String,
      parametersJson: json['parameters'] as String? ?? '{}',
      status: json['status'] as String,
      response: json['response'] as String?,
      sentAt: DateTime.fromMillisecondsSinceEpoch(
        json['sent_at'] as int,
      ),
      executedAt: json['executed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['executed_at'] as int,
            )
          : null,
      error: json['error'] as String?,
    );
  }
  
  static Map<String, dynamic> _parseParameters(String json) {
    try {
      // Implement JSON parsing
      return {};
    } catch (e) {
      return {};
    }
  }
  
  static String _serializeParameters(Map<String, dynamic> parameters) {
    try {
      // Implement JSON serialization
      return '{}';
    } catch (e) {
      return '{}';
    }
  }
}

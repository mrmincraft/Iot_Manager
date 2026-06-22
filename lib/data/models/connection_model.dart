import '../../domain/entities/connection.dart';

/// Connection Model - SQLite representation
/// 
/// Database Schema (connection table):
/// - id (TEXT, PRIMARY KEY)
/// - device_id (TEXT, FOREIGN KEY)
/// - status (TEXT)
/// - signal_strength (INTEGER)
/// - connected_at (INTEGER as timestamp)
/// - disconnected_at (INTEGER as timestamp)
/// - last_error (TEXT)
class ConnectionModel {
  final String id;
  final String deviceId;
  final String status;
  final int signalStrength;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final String? lastError;
  
  ConnectionModel({
    required this.id,
    required this.deviceId,
    required this.status,
    required this.signalStrength,
    required this.connectedAt,
    this.disconnectedAt,
    this.lastError,
  });
  
  /// Convert to Domain Entity
  Connection toEntity() {
    return Connection(
      id: id,
      deviceId: deviceId,
      status: status,
      signalStrength: signalStrength,
      connectedAt: connectedAt,
      disconnectedAt: disconnectedAt,
      lastError: lastError,
    );
  }
  
  /// Create from Domain Entity
  factory ConnectionModel.fromEntity(Connection entity) {
    return ConnectionModel(
      id: entity.id,
      deviceId: entity.deviceId,
      status: entity.status,
      signalStrength: entity.signalStrength,
      connectedAt: entity.connectedAt,
      disconnectedAt: entity.disconnectedAt,
      lastError: entity.lastError,
    );
  }
  
  /// Convert to SQLite record
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'status': status,
      'signal_strength': signalStrength,
      'connected_at': connectedAt.millisecondsSinceEpoch,
      'disconnected_at': disconnectedAt?.millisecondsSinceEpoch,
      'last_error': lastError,
    };
  }
  
  /// Create from SQLite record
  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      status: json['status'] as String,
      signalStrength: json['signal_strength'] as int,
      connectedAt: DateTime.fromMillisecondsSinceEpoch(
        json['connected_at'] as int,
      ),
      disconnectedAt: json['disconnected_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['disconnected_at'] as int,
            )
          : null,
      lastError: json['last_error'] as String?,
    );
  }
}

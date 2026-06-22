import '../../domain/entities/device.dart';

/// Device Model - SQLite representation
/// 
/// Extends Entity with database-specific metadata
/// Responsible for:
/// - Serialization/Deserialization to/from SQLite
/// - Converting to Domain Entity
/// 
/// Database Schema (device table):
/// - id (TEXT, PRIMARY KEY)
/// - name (TEXT)
/// - type (TEXT)
/// - address (TEXT)
/// - status (TEXT)
/// - metadata (TEXT as JSON)
/// - created_at (INTEGER as timestamp)
/// - updated_at (INTEGER as timestamp)
class DeviceModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final String status;
  final String metadataJson; // JSON string
  final DateTime createdAt;
  final DateTime updatedAt;
  
  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.status,
    required this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Convert to Domain Entity
  Device toEntity() {
    return Device(
      id: id,
      name: name,
      type: type,
      address: address,
      status: status,
      metadata: _parseMetadata(metadataJson),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  /// Create from Domain Entity
  factory DeviceModel.fromEntity(Device entity) {
    return DeviceModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      address: entity.address,
      status: entity.status,
      metadataJson: _serializeMetadata(entity.metadata),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  /// Convert to SQLite record
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'status': status,
      'metadata': metadataJson,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
  
  /// Create from SQLite record
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      address: json['address'] as String,
      status: json['status'] as String,
      metadataJson: json['metadata'] as String? ?? '{}',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['created_at'] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updated_at'] as int,
      ),
    );
  }
  
  static Map<String, dynamic> _parseMetadata(String json) {
    try {
      // Implement JSON parsing
      return {};
    } catch (e) {
      return {};
    }
  }
  
  static String _serializeMetadata(Map<String, dynamic> metadata) {
    try {
      // Implement JSON serialization
      return '{}';
    } catch (e) {
      return '{}';
    }
  }
}

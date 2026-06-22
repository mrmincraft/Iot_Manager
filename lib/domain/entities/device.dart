/// Device Entity - Pure Business Logic
/// 
/// Represents an IoT device in the system
/// Contains only business-relevant data
/// No framework-specific annotations
/// 
/// Immutable by design (value object pattern)
class Device {
  final String id;
  final String name;
  final String type;
  final String address;
  final String status;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.status,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a copy with modifications
  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

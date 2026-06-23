// DTO: ProtocolDTO
// Data Transfer Object pour Protocol

class ProtocolDTO {
  final String id;
  final String name;
  final String type;
  final String description;
  final int defaultPort;
  final bool requiresAuthentication;
  final List<String> supportedFeatures;
  final String? documentation;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProtocolDTO({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.defaultPort,
    required this.requiresAuthentication,
    required this.supportedFeatures,
    this.documentation,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir depuis JSON
  factory ProtocolDTO.fromJson(Map<String, dynamic> json) {
    return ProtocolDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      defaultPort: json['defaultPort'] as int,
      requiresAuthentication: json['requiresAuthentication'] as bool,
      supportedFeatures: List<String>.from(json['supportedFeatures'] as List),
      documentation: json['documentation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convertir vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'defaultPort': defaultPort,
      'requiresAuthentication': requiresAuthentication,
      'supportedFeatures': supportedFeatures,
      'documentation': documentation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ProtocolDTO(id: $id, name: $name, type: $type)';
}

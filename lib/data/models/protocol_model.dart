// SQLite Model: ProtocolModel
// Modèle de données pour la table protocols en SQLite

class ProtocolModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final int defaultPort;
  final bool requiresAuthentication;
  final String supportedFeatures; // JSON string
  final String? documentation;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProtocolModel({
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

  /// Convertir depuis une ligne SQLite
  factory ProtocolModel.fromMap(Map<String, dynamic> map) {
    return ProtocolModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      defaultPort: map['defaultPort'] as int,
      requiresAuthentication: (map['requiresAuthentication'] as int) == 1,
      supportedFeatures: map['supportedFeatures'] as String,
      documentation: map['documentation'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convertir vers une ligne SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'defaultPort': defaultPort,
      'requiresAuthentication': requiresAuthentication ? 1 : 0,
      'supportedFeatures': supportedFeatures,
      'documentation': documentation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ProtocolModel(id: $id, name: $name, type: $type)';
}

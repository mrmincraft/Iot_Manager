// Domain Entity: Protocol
// Représente un protocole de communication IoT

enum ProtocolType { mqtt, http, coap, modbus, unknown }

class Protocol {
  final String id;
  final String name;
  final ProtocolType type;
  final String description;
  final int defaultPort;
  final bool requiresAuthentication;
  final List<String> supportedFeatures;
  final String? documentation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Protocol({
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

  /// Crée une copie avec propriétés modifiées
  Protocol copyWith({
    String? id,
    String? name,
    ProtocolType? type,
    String? description,
    int? defaultPort,
    bool? requiresAuthentication,
    List<String>? supportedFeatures,
    String? documentation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Protocol(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      defaultPort: defaultPort ?? this.defaultPort,
      requiresAuthentication: requiresAuthentication ?? this.requiresAuthentication,
      supportedFeatures: supportedFeatures ?? this.supportedFeatures,
      documentation: documentation ?? this.documentation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Protocol &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Protocol(id: $id, name: $name, type: $type)';
}

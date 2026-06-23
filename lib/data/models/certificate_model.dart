// SQLite Model: CertificateModel
// Modèle de données pour la table certificates en SQLite

class CertificateModel {
  final String id;
  final String name;
  final String type;
  final String format;
  final String content;
  final String? password;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? thumbprint;
  final bool isValid;
  final String? issuer;
  final String? subject;
  final DateTime createdAt;
  final DateTime updatedAt;

  CertificateModel({
    required this.id,
    required this.name,
    required this.type,
    required this.format,
    required this.content,
    this.password,
    this.validFrom,
    this.validUntil,
    this.thumbprint,
    required this.isValid,
    this.issuer,
    this.subject,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CertificateModel.fromMap(Map<String, dynamic> map) {
    return CertificateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      format: map['format'] as String,
      content: map['content'] as String,
      password: map['password'] as String?,
      validFrom: map['validFrom'] != null ? DateTime.parse(map['validFrom'] as String) : null,
      validUntil: map['validUntil'] != null ? DateTime.parse(map['validUntil'] as String) : null,
      thumbprint: map['thumbprint'] as String?,
      isValid: (map['isValid'] as int) == 1,
      issuer: map['issuer'] as String?,
      subject: map['subject'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'format': format,
      'content': content,
      'password': password,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'thumbprint': thumbprint,
      'isValid': isValid ? 1 : 0,
      'issuer': issuer,
      'subject': subject,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'CertificateModel(id: $id, name: $name, type: $type)';
}

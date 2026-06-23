// DTO: CertificateDTO
// Data Transfer Object pour Certificate

class CertificateDTO {
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

  CertificateDTO({
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

  factory CertificateDTO.fromJson(Map<String, dynamic> json) {
    return CertificateDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      format: json['format'] as String,
      content: json['content'] as String,
      password: json['password'] as String?,
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom'] as String) : null,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil'] as String) : null,
      thumbprint: json['thumbprint'] as String?,
      isValid: json['isValid'] as bool,
      issuer: json['issuer'] as String?,
      subject: json['subject'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
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
      'isValid': isValid,
      'issuer': issuer,
      'subject': subject,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'CertificateDTO(id: $id, name: $name, type: $type)';
}

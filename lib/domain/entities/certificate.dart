// Domain Entity: Certificate
// Représente un certificat SSL/TLS pour les connexions sécurisées

import 'package:iot_manager/core/exceptions/exceptions.dart';

enum CertificateType { ca, client, server }
enum CertificateFormat { pem, der, p12 }

class Certificate {
  final String id;
  final String name;
  final CertificateType type;
  final CertificateFormat format;
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

  Certificate({
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
  }) {
    _validate();
  }

  void _validate() {
    if (name.isEmpty) {
      throw ValidationException('Certificate name cannot be empty');
    }
    if (content.isEmpty) {
      throw ValidationException('Certificate content cannot be empty');
    }
    if (type == CertificateType.client && password == null) {
      throw ValidationException('Client certificate requires a password');
    }
  }

  /// Vérifie si le certificat est expiré
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Vérifie si le certificat est valide et non expiré
  bool get isActiveAndValid => isValid && !isExpired;

  /// Retourne le nombre de jours avant expiration
  int? get daysUntilExpiry {
    if (validUntil == null) return null;
    return validUntil!.difference(DateTime.now()).inDays;
  }

  Certificate copyWith({
    String? id,
    String? name,
    CertificateType? type,
    CertificateFormat? format,
    String? content,
    String? password,
    DateTime? validFrom,
    DateTime? validUntil,
    String? thumbprint,
    bool? isValid,
    String? issuer,
    String? subject,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Certificate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      format: format ?? this.format,
      content: content ?? this.content,
      password: password ?? this.password,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      thumbprint: thumbprint ?? this.thumbprint,
      isValid: isValid ?? this.isValid,
      issuer: issuer ?? this.issuer,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Certificate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Certificate(id: $id, name: $name, type: $type)';
}

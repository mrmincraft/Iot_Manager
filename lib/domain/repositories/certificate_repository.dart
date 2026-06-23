// Domain Repository Interface: CertificateRepository
// Interface pour la gestion des certificats

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/certificate.dart';

abstract class CertificateRepository {
  /// Récupère tous les certificats
  Future<Result<List<Certificate>, Exception>> getAllCertificates();

  /// Récupère un certificat par ID
  Future<Result<Certificate, Exception>> getCertificateById(String id);

  /// Crée un nouveau certificat
  Future<Result<Certificate, Exception>> createCertificate(Certificate certificate);

  /// Met à jour un certificat
  Future<Result<Certificate, Exception>> updateCertificate(Certificate certificate);

  /// Supprime un certificat
  Future<Result<void, Exception>> deleteCertificate(String id);

  /// Récupère les certificats valides
  Future<Result<List<Certificate>, Exception>> getValidCertificates();

  /// Récupère les certificats qui vont expirer bientôt (par défaut 30 jours)
  Future<Result<List<Certificate>, Exception>> getExpiringCertificates({int daysUntilExpiry = 30});

  /// Vérifie si un certificat est valide et non expiré
  Future<Result<bool, Exception>> isCertificateValid(String id);
}

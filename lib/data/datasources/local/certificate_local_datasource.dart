// Local DataSource Interface: CertificateLocalDataSource
// Interface pour les opérations de base de données sur les certificats

import 'package:iot_manager/data/models/certificate_model.dart';

abstract class CertificateLocalDataSource {
  Future<List<CertificateModel>> getAllCertificates();
  Future<CertificateModel> getCertificateById(String id);
  Future<void> createCertificate(CertificateModel certificate);
  Future<void> updateCertificate(CertificateModel certificate);
  Future<void> deleteCertificate(String id);
}

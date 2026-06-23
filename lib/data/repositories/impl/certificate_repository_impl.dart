// Repository Implementation: CertificateRepositoryImpl
// Implémentation de la gestion des certificats

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/certificate_local_datasource.dart';
import 'package:iot_manager/data/models/certificate_model.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/repositories/certificate_repository.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateLocalDataSource _localDataSource;

  CertificateRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Certificate>, Exception>> getAllCertificates() async {
    try {
      final models = await _localDataSource.getAllCertificates();
      final certificates = models.map(_mapModelToEntity).toList();
      return Result.success(certificates);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Certificate, Exception>> getCertificateById(String id) async {
    try {
      final model = await _localDataSource.getCertificateById(id);
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Certificate, Exception>> createCertificate(Certificate certificate) async {
    try {
      final model = _mapEntityToModel(certificate);
      await _localDataSource.createCertificate(model);
      return Result.success(certificate);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Certificate, Exception>> updateCertificate(Certificate certificate) async {
    try {
      final model = _mapEntityToModel(certificate);
      await _localDataSource.updateCertificate(model);
      return Result.success(certificate);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteCertificate(String id) async {
    try {
      await _localDataSource.deleteCertificate(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Certificate>, Exception>> getValidCertificates() async {
    try {
      final models = await _localDataSource.getAllCertificates();
      final now = DateTime.now();
      final certificates = models
          .where((m) => m.isValid && (m.validUntil == null || m.validUntil!.isAfter(now)))
          .map(_mapModelToEntity)
          .toList();
      return Result.success(certificates);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<List<Certificate>, Exception>> getExpiringCertificates({int daysUntilExpiry = 30}) async {
    try {
      final models = await _localDataSource.getAllCertificates();
      final now = DateTime.now();
      final expireDate = now.add(Duration(days: daysUntilExpiry));
      
      final certificates = models
          .where((m) =>
              m.validUntil != null &&
              m.validUntil!.isAfter(now) &&
              m.validUntil!.isBefore(expireDate))
          .map(_mapModelToEntity)
          .toList();
      return Result.success(certificates);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<bool, Exception>> isCertificateValid(String id) async {
    try {
      final result = await getCertificateById(id);
      if (result.isFailure) {
        return Result.failure(result.error!);
      }
      final cert = result.value!;
      final isValid = cert.isActiveAndValid;
      return Result.success(isValid);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  Certificate _mapModelToEntity(CertificateModel model) {
    return Certificate(
      id: model.id,
      name: model.name,
      type: CertificateType.values.firstWhere(
        (e) => e.toString().split('.').last == model.type,
        orElse: () => CertificateType.ca,
      ),
      format: CertificateFormat.values.firstWhere(
        (e) => e.toString().split('.').last == model.format,
        orElse: () => CertificateFormat.pem,
      ),
      content: model.content,
      password: model.password,
      validFrom: model.validFrom,
      validUntil: model.validUntil,
      thumbprint: model.thumbprint,
      isValid: model.isValid,
      issuer: model.issuer,
      subject: model.subject,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  CertificateModel _mapEntityToModel(Certificate entity) {
    return CertificateModel(
      id: entity.id,
      name: entity.name,
      type: entity.type.toString().split('.').last,
      format: entity.format.toString().split('.').last,
      content: entity.content,
      password: entity.password,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
      thumbprint: entity.thumbprint,
      isValid: entity.isValid,
      issuer: entity.issuer,
      subject: entity.subject,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

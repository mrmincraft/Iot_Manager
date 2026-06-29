import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/repositories/certificate_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET ALL CERTIFICATES
// ============================================================

/// Get All Certificates Use Case
class GetAllCertificatesUseCase extends UseCase<List<Certificate>, NoParams> {
  final CertificateRepository _certificateRepository;

  GetAllCertificatesUseCase(this._certificateRepository);

  @override
  Future<Result<List<Certificate>>> call(NoParams params) async {
    return _certificateRepository.getAllCertificates();
  }
}

// ============================================================
// GET CERTIFICATE BY ID
// ============================================================

class GetCertificateByIdParams {
  final String id;
  GetCertificateByIdParams({required this.id});
}

/// Get Certificate By ID Use Case
class GetCertificateByIdUseCase extends UseCase<Certificate, GetCertificateByIdParams> {
  final CertificateRepository _certificateRepository;

  GetCertificateByIdUseCase(this._certificateRepository);

  @override
  Future<Result<Certificate>> call(GetCertificateByIdParams params) async {
    return _certificateRepository.getCertificateById(params.id);
  }
}

// ============================================================
// CREATE CERTIFICATE
// ============================================================

class CreateCertificateParams {
  final Certificate certificate;
  CreateCertificateParams({required this.certificate});
}

/// Create Certificate Use Case
class CreateCertificateUseCase extends UseCase<Certificate, CreateCertificateParams> {
  final CertificateRepository _certificateRepository;

  CreateCertificateUseCase(this._certificateRepository);

  @override
  Future<Result<Certificate>> call(CreateCertificateParams params) async {
    return _certificateRepository.createCertificate(params.certificate);
  }
}

// ============================================================
// UPDATE CERTIFICATE
// ============================================================

class UpdateCertificateParams {
  final Certificate certificate;
  UpdateCertificateParams({required this.certificate});
}

/// Update Certificate Use Case
class UpdateCertificateUseCase extends UseCase<Certificate, UpdateCertificateParams> {
  final CertificateRepository _certificateRepository;

  UpdateCertificateUseCase(this._certificateRepository);

  @override
  Future<Result<Certificate>> call(UpdateCertificateParams params) async {
    return _certificateRepository.updateCertificate(params.certificate);
  }
}

// ============================================================
// DELETE CERTIFICATE
// ============================================================

class DeleteCertificateParams {
  final String id;
  DeleteCertificateParams({required this.id});
}

/// Delete Certificate Use Case
class DeleteCertificateUseCase extends UseCase<void, DeleteCertificateParams> {
  final CertificateRepository _certificateRepository;

  DeleteCertificateUseCase(this._certificateRepository);

  @override
  Future<Result<void>> call(DeleteCertificateParams params) async {
    return _certificateRepository.deleteCertificate(params.id);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/repositories/certificate_repository.dart';
import 'package:iot_manager/domain/usecases/certificate_usecases.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

class MockCertificateRepository extends Mock implements CertificateRepository {}

void main() {
  group('Certificate UseCases Tests', () {
    late MockCertificateRepository mockRepository;

    setUp(() {
      mockRepository = MockCertificateRepository();
    });

    group('GetAllCertificatesUseCase', () {
      test('returns list of certificates on success', () async {
        final now = DateTime.now();
        final mockCerts = [
          Certificate(
            id: 'cert-001',
            name: 'Root CA',
            type: CertificateType.ca,
            validFrom: now,
            validTo: now.add(const Duration(days: 3650)),
          ),
          Certificate(
            id: 'cert-002',
            name: 'Server Cert',
            type: CertificateType.server,
            validFrom: now,
            validTo: now.add(const Duration(days: 365)),
          ),
        ];

        when(mockRepository.getAllCertificates())
            .thenAnswer((_) async => Result.success(mockCerts));

        final useCase = GetAllCertificatesUseCase(mockRepository);
        final result = await useCase.call(NoParams());

        expect(result.isSuccess, true);
        expect(result.value, mockCerts);
        expect(result.value!.length, 2);
        verify(mockRepository.getAllCertificates()).called(1);
      });

      test('returns error on repository failure', () async {
        final error = Exception('Database error');
        when(mockRepository.getAllCertificates())
            .thenAnswer((_) async => Result.failure(error));

        final useCase = GetAllCertificatesUseCase(mockRepository);
        final result = await useCase.call();

        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('GetCertificateByIdUseCase', () {
      test('returns certificate by id on success', () async {
        final now = DateTime.now();
        const certId = 'cert-001';
        final mockCert = Certificate(
          id: certId,
          name: 'Test Cert',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        when(mockRepository.getCertificateById(certId))
            .thenAnswer((_) async => Result.success(mockCert));

        final useCase = GetCertificateByIdUseCase(mockRepository);
        final result = await useCase.call(GetCertificateByIdParams(id: certId));

        expect(result.isSuccess, true);
        expect(result.value, mockCert);
      });
    });

    group('CreateCertificateUseCase', () {
      test('creates certificate successfully', () async {
        final now = DateTime.now();
        final newCert = Certificate(
          id: 'cert-001',
          name: 'New Cert',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        when(mockRepository.createCertificate(newCert))
            .thenAnswer((_) async => Result.success(newCert));

        final useCase = CreateCertificateUseCase(mockRepository);
        final result = await useCase.call(CreateCertificateParams(certificate: newCert));

        expect(result.isSuccess, true);
        expect(result.value, newCert);
        verify(mockRepository.createCertificate(newCert)).called(1);
      });
    });

    group('UpdateCertificateUseCase', () {
      test('updates certificate successfully', () async {
        final now = DateTime.now();
        final updated = Certificate(
          id: 'cert-001',
          name: 'Updated Cert',
          type: CertificateType.ca,
          validFrom: now,
          validTo: now.add(const Duration(days: 3650)),
        );

        when(mockRepository.updateCertificate(updated))
            .thenAnswer((_) async => Result.success(updated));

        final useCase = UpdateCertificateUseCase(mockRepository);
        final result = await useCase.call(UpdateCertificateParams(certificate: updated));

        expect(result.isSuccess, true);
        expect(result.value!.name, 'Updated Cert');
      });
    });

    group('DeleteCertificateUseCase', () {
      test('deletes certificate successfully', () async {
        const certId = 'cert-001';

        when(mockRepository.deleteCertificate(certId))
            .thenAnswer((_) async => Result.success(null));

        final useCase = DeleteCertificateUseCase(mockRepository);
        final result = await useCase.call(DeleteCertificateParams(id: certId));

        expect(result.isSuccess, true);
        verify(mockRepository.deleteCertificate(certId)).called(1);
      });
    });

    group('GetExpiringCertificatesUseCase', () {
      test('returns expiring certificates', () async {
        final now = DateTime.now();
        final expiringCerts = [
          Certificate(
            id: 'cert-001',
            name: 'Expiring Soon',
            type: CertificateType.server,
            validFrom: now.subtract(const Duration(days: 350)),
            validTo: now.add(const Duration(days: 15)), // 15 days left
          ),
        ];

        when(mockRepository.getExpiringCertificates(30))
            .thenAnswer((_) async => Result.success(expiringCerts));

        final useCase = GetExpiringCertificatesUseCase(mockRepository);
        final result = await useCase.call(30);

        expect(result.isSuccess, true);
        expect(result.value!.length, 1);
      });
    });
  });
}

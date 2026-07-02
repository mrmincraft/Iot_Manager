import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/domain/entities/certificate.dart';

void main() {
  group('Certificate Entity Tests', () {
    group('Certificate Creation', () {
      test('creates certificate with all parameters', () {
        final expiryDate = DateTime(2025, 12, 31);
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test Certificate',
          type: CertificateType.ca,
          subject: 'CN=test.example.com',
          issuer: 'CN=Example CA',
          validFrom: DateTime(2024, 1, 1),
          validTo: expiryDate,
          fingerprint: 'ABC123DEF456',
          content: 'cert content here',
          metadata: {'algorithm': 'RSA-2048'},
        );

        expect(certificate.id, 'cert-001');
        expect(certificate.name, 'Test Certificate');
        expect(certificate.type, CertificateType.ca);
        expect(certificate.subject, 'CN=test.example.com');
        expect(certificate.issuer, 'CN=Example CA');
        expect(certificate.validTo, expiryDate);
        expect(certificate.fingerprint, 'ABC123DEF456');
      });

      test('creates certificate with minimal parameters', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Basic Certificate',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        expect(certificate.id, 'cert-001');
        expect(certificate.name, 'Basic Certificate');
        expect(certificate.content, isNull);
        expect(certificate.metadata, {});
      });

      test('validates certificate ID is not empty', () {
        final now = DateTime.now();
        expect(
          () => Certificate(
            id: '',
            name: 'Test',
            type: CertificateType.server,
            validFrom: now,
            validTo: now.add(const Duration(days: 365)),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates certificate name is not empty', () {
        final now = DateTime.now();
        expect(
          () => Certificate(
            id: 'cert-001',
            name: '',
            type: CertificateType.server,
            validFrom: now,
            validTo: now.add(const Duration(days: 365)),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates validTo is after validFrom', () {
        final now = DateTime.now();
        expect(
          () => Certificate(
            id: 'cert-001',
            name: 'Test',
            type: CertificateType.server,
            validFrom: now,
            validTo: now.subtract(const Duration(days: 1)),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('CertificateType Enum', () {
      test('ca type exists', () {
        expect(CertificateType.ca, CertificateType.ca);
      });

      test('server type exists', () {
        expect(CertificateType.server, CertificateType.server);
      });

      test('client type exists', () {
        expect(CertificateType.client, CertificateType.client);
      });

      test('all certificate types are distinct', () {
        final types = {
          CertificateType.ca,
          CertificateType.server,
          CertificateType.client,
        };
        expect(types.length, 3);
      });
    });

    group('Certificate Expiration', () {
      test('certificate is expired when validTo is in past', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Expired',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 365)),
          validTo: now.subtract(const Duration(days: 1)),
        );

        expect(certificate.isExpired, true);
      });

      test('certificate is not expired when validTo is in future', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Valid',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 1)),
          validTo: now.add(const Duration(days: 365)),
        );

        expect(certificate.isExpired, false);
      });

      test('certificate is expiring soon when within 30 days', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Expiring Soon',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 1)),
          validTo: now.add(const Duration(days: 15)),
        );

        expect(certificate.daysUntilExpiry <= 30, true);
      });

      test('days until expiry calculation', () {
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 60));
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: futureDate,
        );

        expect(certificate.daysUntilExpiry, greaterThanOrEqualTo(59));
        expect(certificate.daysUntilExpiry, lessThanOrEqualTo(60));
      });
    });

    group('Certificate copyWith', () {
      test('creates copy with changed values', () {
        final now = DateTime.now();
        final original = Certificate(
          id: 'cert-001',
          name: 'Original',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        final updated = original.copyWith(
          name: 'Updated',
          type: CertificateType.ca,
        );

        expect(updated.id, 'cert-001'); // Unchanged
        expect(updated.name, 'Updated');
        expect(updated.type, CertificateType.ca);
      });

      test('copyWith preserves original object', () {
        final now = DateTime.now();
        final original = Certificate(
          id: 'cert-001',
          name: 'Original',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        original.copyWith(name: 'Updated');

        expect(original.name, 'Original'); // Unchanged
      });
    });

    group('Certificate Equality', () {
      test('certificates with same values are equal', () {
        final now = DateTime(2024, 1, 1);
        final expiry = DateTime(2025, 1, 1);

        final cert1 = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: expiry,
        );

        final cert2 = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: expiry,
        );

        expect(cert1, cert2);
      });

      test('certificates with different values are not equal', () {
        final now = DateTime.now();
        final expiry = now.add(const Duration(days: 365));

        final cert1 = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: expiry,
        );

        final cert2 = Certificate(
          id: 'cert-002', // Different ID
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: expiry,
        );

        expect(cert1, isNot(cert2));
      });

      test('hash codes are equal for equal certificates', () {
        final now = DateTime(2024, 1, 1);
        final expiry = DateTime(2025, 1, 1);

        final cert1 = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: expiry,
        );

        final cert2 = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: expiry,
        );

        expect(cert1.hashCode, cert2.hashCode);
      });
    });

    group('Certificate Content', () {
      test('certificate can store PEM content', () {
        final now = DateTime.now();
        const pemContent = '''-----BEGIN CERTIFICATE-----
MIID...
-----END CERTIFICATE-----''';

        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
          content: pemContent,
        );

        expect(certificate.content, pemContent);
      });

      test('certificate fingerprint is preserved', () {
        final now = DateTime.now();
        const fingerprint = 'DA39A3EE5E6B4B0D3255BFEF95601890AFD80709';

        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
          fingerprint: fingerprint,
        );

        expect(certificate.fingerprint, fingerprint);
      });
    });

    group('Certificate Validation', () {
      test('valid certificate within validity period', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Valid',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 30)),
          validTo: now.add(const Duration(days: 330)),
        );

        expect(certificate.isExpired, false);
        expect(certificate.daysUntilExpiry, greaterThan(0));
      });

      test('certificate just expired', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Expired',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 365)),
          validTo: now.subtract(const Duration(seconds: 1)),
        );

        expect(certificate.isExpired, true);
      });

      test('certificate expiring today', () {
        final now = DateTime.now();
        final todayExpiry = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final certificate = Certificate(
          id: 'cert-001',
          name: 'Expiring Today',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 365)),
          validTo: todayExpiry,
        );

        expect(certificate.daysUntilExpiry, lessThanOrEqualTo(1));
      });
    });

    group('Certificate Subject and Issuer', () {
      test('certificate stores X.509 subject', () {
        final now = DateTime.now();
        const subject = 'CN=test.example.com,O=Example Inc,C=US';

        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          subject: subject,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        expect(certificate.subject, subject);
      });

      test('certificate stores issuer information', () {
        final now = DateTime.now();
        const issuer = 'CN=Example CA,O=Example Inc,C=US';

        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          issuer: issuer,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        expect(certificate.issuer, issuer);
      });
    });

    group('Certificate Metadata', () {
      test('metadata is optional', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        expect(certificate.metadata, {});
      });

      test('metadata can store certificate details', () {
        final now = DateTime.now();
        final certificate = Certificate(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
          metadata: {
            'algorithm': 'RSA-2048',
            'signatureAlgorithm': 'SHA256WithRSA',
            'keyUsage': ['digitalSignature', 'keyEncipherment'],
            'serialNumber': '1234567890ABCDEF',
          },
        );

        expect(certificate.metadata['algorithm'], 'RSA-2048');
        expect(certificate.metadata['keyUsage'], ['digitalSignature', 'keyEncipherment']);
      });
    });
  });
}

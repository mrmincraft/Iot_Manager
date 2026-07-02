import '../../core/events/app_event.dart';
import '../entities/certificate.dart';

/// Event fired when a new certificate is added
class CertificateAddedEvent extends AppEvent {
  final Certificate certificate;

  CertificateAddedEvent(this.certificate);
}

/// Event fired when a certificate is updated
class CertificateUpdatedEvent extends AppEvent {
  final Certificate certificate;
  final Certificate? previousCertificate;

  CertificateUpdatedEvent({
    required this.certificate,
    this.previousCertificate,
  });
}

/// Event fired when a certificate is deleted
class CertificateDeletedEvent extends AppEvent {
  final String certificateId;
  final Certificate? deletedCertificate;

  CertificateDeletedEvent({
    required this.certificateId,
    this.deletedCertificate,
  });
}

/// Event fired when all certificates are loaded
class CertificatesLoadedEvent extends AppEvent {
  final List<Certificate> certificates;

  CertificatesLoadedEvent(this.certificates);
}

/// Event fired when a certificate is retrieved by ID
class CertificateRetrievedEvent extends AppEvent {
  final Certificate certificate;

  CertificateRetrievedEvent(this.certificate);
}

/// Event fired when a certificate expires or is about to expire
class CertificateExpirationWarningEvent extends AppEvent {
  final Certificate certificate;
  final Duration daysUntilExpiry;

  CertificateExpirationWarningEvent({
    required this.certificate,
    required this.daysUntilExpiry,
  });
}

import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/events/certificate_events.dart';
import 'package:iot_manager/domain/repositories/certificate_repository.dart';
import 'package:iot_manager/domain/usecases/certificate_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for Certificate management
class CertificateListViewModel extends BaseViewModel {
  final CertificateRepository _certificateRepository;
  final EventBus _eventBus;
  final GetAllCertificatesUseCase _getAllCertificatesUseCase;
  final CreateCertificateUseCase _createCertificateUseCase;
  final UpdateCertificateUseCase _updateCertificateUseCase;
  final DeleteCertificateUseCase _deleteCertificateUseCase;

  /// Observable state
  final ValueNotifier<List<Certificate>> certificates = ValueNotifier([]);
  final ValueNotifier<Certificate?> selectedCertificate = ValueNotifier(null);
  final ValueNotifier<List<Certificate>> expiringCertificates = ValueNotifier([]);
  final ValueNotifier<int> validCount = ValueNotifier(0);

  CertificateListViewModel({
    required CertificateRepository certificateRepository,
    required EventBus eventBus,
    required GetAllCertificatesUseCase getAllCertificatesUseCase,
    required CreateCertificateUseCase createCertificateUseCase,
    required UpdateCertificateUseCase updateCertificateUseCase,
    required DeleteCertificateUseCase deleteCertificateUseCase,
  })  : _certificateRepository = certificateRepository,
        _eventBus = eventBus,
        _getAllCertificatesUseCase = getAllCertificatesUseCase,
        _createCertificateUseCase = createCertificateUseCase,
        _updateCertificateUseCase = updateCertificateUseCase,
        _deleteCertificateUseCase = deleteCertificateUseCase {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.listen<CertificatesLoadedEvent>(_onCertificatesLoaded);
    _eventBus.listen<CertificateAddedEvent>(_onCertificateAdded);
    _eventBus.listen<CertificateUpdatedEvent>(_onCertificateUpdated);
    _eventBus.listen<CertificateDeletedEvent>(_onCertificateDeleted);
    _eventBus.listen<CertificateExpirationWarningEvent>(_onExpirationWarning);
  }

  Future<void> loadCertificates() async {
    isLoading.value = true;
    clearError();

    final result = await _certificateRepository.getAllCertificates();

    if (result.isSuccess) {
      validCount.value = result.value?.where((c) => c.isActiveAndValid).length ?? 0;
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> checkExpiringCertificates({int daysUntilExpiry = 30}) async {
    final result = await _certificateRepository.getExpiringCertificates(
      daysUntilExpiry: daysUntilExpiry,
    );

    if (result.isSuccess) {
      expiringCertificates.value = result.value ?? [];
      if (expiringCertificates.value.isNotEmpty) {
        setSuccess('${expiringCertificates.value.length} certificate(s) expiring soon');
      }
    }

    notifyListeners();
  }

  Future<void> createCertificate(Certificate certificate) async {
    isLoading.value = true;
    clearError();

    final result = await _certificateRepository.createCertificate(certificate);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Certificate created: ${certificate.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> updateCertificate(Certificate certificate) async {
    isLoading.value = true;
    clearError();

    final result = await _certificateRepository.updateCertificate(certificate);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Certificate updated: ${certificate.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> deleteCertificate(String certificateId) async {
    isLoading.value = true;
    clearError();

    final result = await _certificateRepository.deleteCertificate(certificateId);

    if (result.isFailure) {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  void selectCertificate(Certificate certificate) {
    selectedCertificate.value = certificate;
    notifyListeners();
  }

  void clearSelection() {
    selectedCertificate.value = null;
    notifyListeners();
  }

  void _onCertificatesLoaded(CertificatesLoadedEvent event) {
    certificates.value = event.certificates;
    notifyListeners();
  }

  void _onCertificateAdded(CertificateAddedEvent event) {
    if (!certificates.value.any((c) => c.id == event.certificate.id)) {
      certificates.value = [...certificates.value, event.certificate];
      notifyListeners();
    }
  }

  void _onCertificateUpdated(CertificateUpdatedEvent event) {
    final index = certificates.value.indexWhere((c) => c.id == event.certificate.id);
    if (index != -1) {
      certificates.value = [
        ...certificates.value.sublist(0, index),
        event.certificate,
        ...certificates.value.sublist(index + 1),
      ];
      notifyListeners();
    }
  }

  void _onCertificateDeleted(CertificateDeletedEvent event) {
    certificates.value = certificates.value.where((c) => c.id != event.certificateId).toList();
    if (selectedCertificate.value?.id == event.certificateId) {
      selectedCertificate.value = null;
    }
    notifyListeners();
  }

  void _onExpirationWarning(CertificateExpirationWarningEvent event) {
    setSuccess('Certificate expiring: ${event.certificate.name} in ${event.daysUntilExpiry.inDays} days');
  }

  @override
  void initialize() {
    loadCertificates();
    checkExpiringCertificates();
  }

  @override
  void dispose() {
    certificates.dispose();
    selectedCertificate.dispose();
    expiringCertificates.dispose();
    validCount.dispose();
    super.dispose();
  }
}

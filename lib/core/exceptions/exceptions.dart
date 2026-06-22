import 'app_exception.dart';

/// Exception for data layer errors
/// - Database errors
/// - Data parsing errors
/// - Persistence errors
class DataException extends AppException {
  DataException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'DATA_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Exception for entity not found
class NotFoundException extends DataException {
  NotFoundException({
    required String message,
    String? code,
  }) : super(
    message: message,
    code: code ?? 'NOT_FOUND',
  );
}

/// Exception for validation errors
class ValidationException extends AppException {
  final Map<String, String>? errors;
  
  ValidationException({
    required String message,
    this.errors,
    String? code,
  }) : super(
    message: message,
    code: code ?? 'VALIDATION_ERROR',
  );
}

/// Exception for device-related operations
class DeviceException extends AppException {
  DeviceException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'DEVICE_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

/// Exception for connection-related operations
class ConnectionException extends AppException {
  ConnectionException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'CONNECTION_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

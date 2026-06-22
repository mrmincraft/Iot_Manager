/// Exception base class for application
/// 
/// All exceptions inherit from this to allow
/// catching all app-specific exceptions
/// 
/// Examples:
/// - DataException
/// - NetworkException
/// - ValidationException
/// - NotFoundException
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() => 'AppException: $message (code: $code)';
}

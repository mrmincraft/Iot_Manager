/// Result type for handling success and failure cases
/// Similar to Either type in functional programming
/// 
/// Follows the Result pattern for explicit error handling
/// without throwing exceptions
/// 
/// Example:
/// ```dart
/// final result = await getUserUseCase.call(id);
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (user) => print('Success: ${user.name}'),
/// );
/// ```
abstract class Result<T> {
  /// Transform result with fold pattern
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T success) onSuccess,
  );
  
  /// Convenient getters
  T? getOrNull();
  Failure? getFailureOrNull();
  bool get isSuccess;
  bool get isFailure;
}

/// Success case
class Success<T> extends Result<T> {
  final T data;
  
  Success(this.data);
  
  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T success) onSuccess,
  ) => onSuccess(data);
  
  @override
  T? getOrNull() => data;
  
  @override
  Failure? getFailureOrNull() => null;
  
  @override
  bool get isSuccess => true;
  
  @override
  bool get isFailure => false;
}

/// Failure case
class Failure<T> extends Result<T> {
  final Exception exception;
  final String message;
  final String? code;
  
  Failure({
    required this.exception,
    required this.message,
    this.code,
  });
  
  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T success) onSuccess,
  ) => onFailure(this);
  
  @override
  T? getOrNull() => null;
  
  @override
  Failure? getFailureOrNull() => this;
  
  @override
  bool get isSuccess => false;
  
  @override
  bool get isFailure => true;
}

/// Alias for cleaner type hints
typedef Failure = Failure<dynamic>;

/// Extension to add factory methods for cleaner Result creation
extension ResultFactory<T> on Result<T> {
  /// Factory method for creating a Success result
  static Result<T> success<T>(T data) => Success<T>(data);
  
  /// Factory method for creating a Failure result
  static Result<T> failure<T>(Exception exception, {String? message, String? code}) {
    return Failure<T>(
      exception: exception,
      message: message ?? exception.toString(),
      code: code,
    );
  }
}

/// Alternative: Add as direct static methods on Result if using factory constructors
extension ResultStaticMethods on Result {
  /// Static success factory
  static Result<T> success<T>(T data) => Success<T>(data);
  
  /// Static failure factory
  static Result<T> failure<T>(Exception exception, {String? message, String? code}) {
    return Failure<T>(
      exception: exception,
      message: message ?? exception.toString(),
      code: code,
    );
  }
}

// Add convenience extensions for better API
extension ResultExtensions<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is failure
  bool get isFailure => this is Failure<T>;
  
  /// Get value if success, otherwise null
  T? getOrNull() {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }
}

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
///   onFailure: (error) => print('Error: $error'),
///   onSuccess: (user) => print('Success: ${user.name}'),
/// );
/// ```
abstract class Result<T> {
  /// Transform result with fold pattern
  /// Usage: result.fold(onSuccess: (value) => ..., onFailure: (error) => ...)
  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T success) onSuccess,
  });
  
  /// Convenient getters
  T? getOrNull();
  Failure? getFailureOrNull();
  bool get isSuccess;
  bool get isFailure;
  
  /// Convenience properties for common operations
  T? get value;
  Exception? get error;
}

/// Success case
class Success<T> extends Result<T> {
  final T data;
  
  Success(this.data);
  
  @override
  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T success) onSuccess,
  }) => onSuccess(data);
  
  @override
  T? getOrNull() => data;
  
  @override
  Failure? getFailureOrNull() => null;
  
  @override
  bool get isSuccess => true;
  
  @override
  bool get isFailure => false;
  
  @override
  T? get value => data;
  
  @override
  Exception? get error => null;
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
  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T success) onSuccess,
  }) => onFailure(this);
  
  @override
  T? getOrNull() => null;
  
  @override
  Failure? getFailureOrNull() => this;
  
  @override
  bool get isSuccess => false;
  
  @override
  bool get isFailure => true;
  
  @override
  T? get value => null;
  
  @override
  Exception? get error => exception;
}

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

// Add convenience extensions for better API
extension ResultExtensions<T> on Result<T> {
  /// Map the success value to a new result
  Result<R> map<R>(R Function(T value) transform) {
    if (this is Success<T>) {
      return Success<R>(transform((this as Success<T>).data));
    } else if (this is Failure<T>) {
      final failure = this as Failure<T>;
      return Failure<R>(
        exception: failure.exception,
        message: failure.message,
        code: failure.code,
      );
    }
    throw StateError('Unknown Result type');
  }
  
  /// Map the error to a new error result
  Result<T> mapError(Exception Function(Exception error) transform) {
    if (this is Failure<T>) {
      final failure = this as Failure<T>;
      return Failure<T>(
        exception: transform(failure.exception),
        message: 'Error mapped',
        code: failure.code,
      );
    }
    return this;
  }
  
  /// FlatMap the success value to a new result
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    if (this is Success<T>) {
      return transform((this as Success<T>).data);
    } else if (this is Failure<T>) {
      final failure = this as Failure<T>;
      return Failure<R>(
        exception: failure.exception,
        message: failure.message,
        code: failure.code,
      );
    }
    throw StateError('Unknown Result type');
  }
  
  /// Get value or else compute a default
  T getOrElse(T Function() defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return defaultValue();
  }
  
  /// Recover from error with a computed value
  Result<T> recover(T Function(Exception error) recover) {
    if (this is Failure<T>) {
      return Success<T>(recover((this as Failure<T>).exception));
    }
    return this;
  }
}

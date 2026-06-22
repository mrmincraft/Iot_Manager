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

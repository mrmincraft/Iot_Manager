import '../../core/utils/result.dart';

/// UseCase Base Class
/// 
/// All UseCases inherit from this abstract class
/// Enforces consistent interface for business logic execution
/// 
/// Single responsibility: Execute one business operation
/// 
/// Generic parameters:
/// - [T] = Success return type
/// - [P] = Parameter type
/// 
/// Example:
/// ```dart
/// class GetAllDevicesUseCase extends UseCase<List<Device>, NoParams> {
///   @override
///   Future<Result<List<Device>>> call(NoParams params) {
///     return repository.getAllDevices();
///   }
/// }
/// ```
abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

/// No Parameters marker class
/// Used when UseCase doesn't require parameters
class NoParams {
  const NoParams();
}

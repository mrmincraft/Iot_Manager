/// Service Locator interface for Dependency Injection
/// 
/// Responsibilities:
/// - Register dependencies (singletons, factories)
/// - Retrieve registered instances
/// - Manage service lifecycle
/// 
/// Principles:
/// - Invert control (IoC container)
/// - Lazy initialization
/// - Single source of truth for dependencies
/// 
/// Implementation: Uses GetIt package
/// 
/// Example usage:
/// ```dart
/// // Setup
/// final locator = ServiceLocator();
/// locator.registerSingleton<EventBus>(EventBusImpl());
/// locator.registerFactory<DeviceRepository>(
///   () => DeviceRepositoryImpl(locator.get())
/// );
/// 
/// // Usage
/// final eventBus = locator.get<EventBus>();
/// ```
abstract class ServiceLocator {
  /// Register a singleton (same instance every time)
  void registerSingleton<T>(T instance);
  
  /// Register a factory (new instance every time)
  void registerFactory<T>(T Function() factory);
  
  /// Register a lazy singleton (created on first access)
  void registerLazySingleton<T>(T Function() factory);
  
  /// Get instance of T
  T get<T>();
  
  /// Check if type is registered
  bool isRegistered<T>();
  
  /// Unregister a type
  Future<void> unregister<T>();
  
  /// Reset all registrations (for testing)
  Future<void> reset();
}

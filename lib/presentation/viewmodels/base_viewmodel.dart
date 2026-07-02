import 'package:flutter/foundation.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/app_event.dart';
import '../../core/exceptions/exceptions.dart';

/// Base ViewModel class
/// 
/// Provides reactive state management following MVVM pattern
/// 
/// Responsibilities:
/// - Manage UI state reactively
/// - Handle user interactions
/// - Coordinate with UseCases
/// - Subscribe to domain events
/// 
/// Lifecycle:
/// - Initialization: Load data, setup event listeners
/// - Execution: Handle user actions, update state
/// - Cleanup: Unsubscribe from events
/// 
/// Example:
/// ```dart
/// class DeviceListViewModel extends BaseViewModel {
///   late ValueNotifier<List<Device>> devices;
///   late ValueNotifier<bool> isLoading;
///   
///   @override
///   void initialize() {
///     devices = ValueNotifier([]);
///     isLoading = ValueNotifier(false);
///     loadDevices();
///   }
///   
///   Future<void> loadDevices() async {
///     isLoading.value = true;
///     final result = await getDevicesUseCase.call(NoParams());
///     result.fold(
///       (failure) => setError(failure.message),
///       (data) => devices.value = data,
///     );
///     isLoading.value = false;
///   }
/// }
/// ```
abstract class BaseViewModel extends ChangeNotifier {
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<String?> successNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  
  EventBus? _eventBus;
  final List<Function> _unsubscribers = [];
  
  bool get hasError => errorNotifier.value != null;
  String? get error => errorNotifier.value;
  
  /// Set EventBus for event subscriptions
  /// Should be called before initialize()
  void setEventBus(EventBus eventBus) {
    _eventBus = eventBus;
  }
  
  /// Subscribe to a domain event
  /// Usage: subscribe<ProtocolAddedEvent>((event) { /* handle */ });
  void subscribe<T extends AppEvent>(void Function(T event) handler) {
    if (_eventBus == null) {
      throw Exception('EventBus not set. Call setEventBus() first.');
    }
    // Capture unsubscriber function and store it for cleanup
    final unsubscriber = _eventBus!.listen<T>(handler);
    _unsubscribers.add(unsubscriber);
  }
  
  /// Initialize ViewModel
  /// Called when ViewModel is created
  void initialize();
  
  /// Cleanup resources
  /// Called when ViewModel is disposed
  @override
  void dispose() {
    // Unsubscribe from all events
    for (final unsubscriber in _unsubscribers) {
      unsubscriber();
    }
    _unsubscribers.clear();
    
    errorNotifier.dispose();
    successNotifier.dispose();
    isLoading.dispose();
    super.dispose();
  }
  
  /// Set error message
  void setError(String message) {
    errorNotifier.value = message;
    notifyListeners();
  }
  
  /// Clear error message
  void clearError() {
    errorNotifier.value = null;
    notifyListeners();
  }
  
  /// Set success message
  void setSuccess(String message) {
    successNotifier.value = message;
    notifyListeners();
  }
  
  /// Clear success message
  void clearSuccess() {
    successNotifier.value = null;
    notifyListeners();
  }
  
  /// Handle exceptions
  void handleException(Exception exception) {
    if (exception is AppException) {
      setError(exception.message);
    } else {
      setError('An unexpected error occurred');
    }
  }
}

# Interfaces principales - Contrats et spécifications

## 📋 Vue d'ensemble

Ce document décrit les interfaces principales de l'architecture et les contrats qu'elles définissent.

---

## 🔐 CORE Layer Interfaces

### 1. ServiceLocator Interface

**Fichier:** `lib/core/di/service_locator.dart`

**Responsabilité:** Gérer la création et l'accès aux instances des dépendances.

```dart
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
```

**Contrats:**
- Chaque type doit être enregistré avant accès
- Les singletons retournent la même instance
- Les factories créent une nouvelle instance à chaque appel
- Peut être réinitialisé pour les tests

**Implémentation suggérée:** GetIt package

**Utilisation:**
```dart
// Setup
final locator = getIt;
locator.registerSingleton<EventBus>(EventBusImpl());
locator.registerFactory<DeviceRepository>(
  () => DeviceRepositoryImpl(locator.get())
);

// Usage
final eventBus = locator.get<EventBus>();
final repo = locator.get<DeviceRepository>();
```

---

### 2. EventBus Interface

**Fichier:** `lib/core/events/event_bus.dart`

**Responsabilité:** Implémenter un système de publication/souscription (Pub/Sub) pour les événements.

```dart
abstract class EventBus {
  /// Register a listener for a specific event type
  /// Returns an unsubscribe function
  Function unsubscribe<T extends AppEvent>(EventListener listener);
  
  /// Listen to a specific event type with type-safe handler
  void listen<T extends AppEvent>(void Function(T event) handler);
  
  /// Publish an event to all listeners
  Future<void> publish(AppEvent event);
  
  /// Clear all listeners (useful for testing)
  void clear();
  
  /// Check if there are listeners for an event type
  bool hasListeners<T extends AppEvent>();
  
  /// Get listener count for debugging
  int getListenerCount();
}
```

**Contrats:**
- Les événements sont transmis de manière asynchrone
- Les listeners reçoivent uniquement les événements de leur type
- Les erreurs dans les listeners ne bloquent pas la publication
- L'ordre de livraison n'est pas garanti
- Les listeners peuvent se désabonner à tout moment

**Implémentation suggérée:** Custom implementation with Stream/StreamController

**Utilisation:**
```dart
// Subscribe
eventBus.listen<DeviceConnectedEvent>((event) {
  print('Device connected: ${event.deviceId}');
});

// Publish
await eventBus.publish(DeviceConnectedEvent(
  deviceId: 'device123',
  device: device,
  signalStrength: 85,
));

// Unsubscribe
final unsubscribe = eventBus.unsubscribe<DeviceConnectedEvent>(listener);
unsubscribe();
```

---

### 3. AppEvent Base Class

**Fichier:** `lib/core/events/app_event.dart`

**Responsabilité:** Classe de base pour tous les événements de l'application.

```dart
abstract class AppEvent {
  final DateTime timestamp = DateTime.now();
  String get eventType => runtimeType.toString();
}
```

**Contrats:**
- Tous les événements héritent de cette classe
- Chaque événement a un timestamp automatique
- Le type d'événement est accessible via `eventType`
- Les événements doivent être immuables

**Utilisation:**
```dart
// Créer un événement personnalisé
class DeviceConnectedEvent extends AppEvent {
  final String deviceId;
  final Device device;
  final int signalStrength;
  
  DeviceConnectedEvent({
    required this.deviceId,
    required this.device,
    required this.signalStrength,
  });
}

// Accéder aux propriétés
final event = DeviceConnectedEvent(...);
print(event.timestamp); // DateTime.now() au moment de la création
print(event.eventType); // 'DeviceConnectedEvent'
```

---

### 4. Result Type

**Fichier:** `lib/core/utils/result.dart`

**Responsabilité:** Implémenter le pattern Result (Either) pour gérer succès et erreurs.

```dart
abstract class Result<T> {
  /// Transform result with fold pattern
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T success) onSuccess,
  );
  
  T? getOrNull();
  Failure? getFailureOrNull();
  bool get isSuccess;
  bool get isFailure;
}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
  // ...
}

class Failure<T> extends Result<T> {
  final Exception exception;
  final String message;
  final String? code;
  
  Failure({
    required this.exception,
    required this.message,
    this.code,
  });
  // ...
}
```

**Contrats:**
- Chaque opération retourne un Result
- Success contient les données
- Failure contient l'exception et le message
- Utiliser `fold` pour traiter les deux cas
- Pas d'exceptions levées (contrôle de flux explicite)

**Utilisation:**
```dart
Future<Result<List<Device>>> getAllDevices() async {
  try {
    final devices = await datasource.getAllDevices();
    return Success(devices);
  } catch (e, stack) {
    return Failure(
      exception: DataException(message: 'Failed to fetch'),
      message: 'Failed to fetch devices',
      code: 'FETCH_ERROR',
    );
  }
}

// Usage
final result = await repository.getAllDevices();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (devices) => print('Got ${devices.length} devices'),
);
```

---

### 5. AppException Hierarchy

**Fichier:** `lib/core/exceptions/`

**Responsabilité:** Fournir une hiérarchie d'exceptions typées pour différents scénarios d'erreur.

```dart
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
}

// Specific exceptions
class DataException extends AppException { }
class NotFoundException extends DataException { }
class ValidationException extends AppException { }
class DeviceException extends AppException { }
class ConnectionException extends AppException { }
```

**Contrats:**
- Chaque type d'erreur a sa propre exception
- Les exceptions contiennent le message, le code et la trace
- Les codes d'erreur facilitent la localisation des messages
- Captures automatiques du contexte d'erreur

**Utilisation:**
```dart
try {
  final device = await datasource.getDeviceById(id);
  if (device == null) {
    throw NotFoundException(message: 'Device not found');
  }
} catch (e, stack) {
  throw DataException(
    message: 'Failed to get device',
    code: 'GET_DEVICE_ERROR',
    originalError: e,
    stackTrace: stack,
  );
}
```

---

## 🧠 DOMAIN Layer Interfaces

### 6. DeviceRepository Interface

**Fichier:** `lib/domain/repositories/device_repository.dart`

**Responsabilité:** Définir le contrat pour les opérations sur les appareils.

```dart
abstract class DeviceRepository {
  Future<Result<List<Device>>> getAllDevices();
  Future<Result<Device>> getDeviceById(String id);
  Future<Result<Device>> addDevice(Device device);
  Future<Result<Device>> updateDevice(Device device);
  Future<Result<void>> deleteDevice(String id);
  Future<Result<List<Device>>> searchDevices(String query);
  Future<Result<List<Device>>> getDevicesByType(String type);
}
```

**Contrats:**
- Retourne toujours un Result (succès ou erreur)
- Les opérations sont asynchrones
- Les IDs sont des chaînes de caractères
- La recherche supporte les wildcards
- Les mises à jour remplacent l'entité complète

**Dépendances:**
- Depends on: `Device` entity, `Result` type
- Implémentée par: `DeviceRepositoryImpl` (data layer)
- Utilisée par: UseCases et TestMocks

---

### 7. ConnectionRepository Interface

**Fichier:** `lib/domain/repositories/connection_repository.dart`

**Responsabilité:** Définir le contrat pour les opérations de connexion.

```dart
abstract class ConnectionRepository {
  Future<Result<Connection>> getConnection(String deviceId);
  Future<Result<List<Connection>>> getAllConnections();
  Future<Result<List<Connection>>> getConnectionHistory(
    String deviceId, {
    DateTime? from,
    DateTime? to,
  });
  Future<Result<Connection>> saveConnection(Connection connection);
  Future<Result<Connection>> updateConnection(Connection connection);
  Future<Result<List<Connection>>> getActiveConnections();
  Future<Result<Map<String, dynamic>>> getConnectionStats(String deviceId);
}
```

**Contrats:**
- Supporte le filtrage par date
- Retourne les statistiques de connexion
- Distingue les connexions actives des anciennes
- Chaque connexion a un ID unique

---

### 8. CommandRepository Interface

**Fichier:** `lib/domain/repositories/command_repository.dart`

**Responsabilité:** Définir le contrat pour les opérations sur les commandes.

```dart
abstract class CommandRepository {
  Future<Result<Command>> sendCommand(Command command);
  Future<Result<Command>> getCommand(String id);
  Future<Result<List<Command>>> getAllCommands();
  Future<Result<List<Command>>> getCommandsByDevice(String deviceId);
  Future<Result<List<Command>>> getCommandHistory(
    String deviceId, {
    int limit = 50,
    int offset = 0,
  });
  Future<Result<Command>> updateCommandStatus(
    String commandId,
    String status, {
    String? response,
    String? error,
  });
  Future<Result<List<Command>>> getPendingCommands();
  Future<Result<void>> deleteCommand(String id);
}
```

**Contrats:**
- Supporte la pagination (limit/offset)
- Les commandes ont des statuts bien définis
- Les réponses et erreurs sont optionnelles
- Les commandes en attente sont identifiables

---

### 9. UseCase Base Class

**Fichier:** `lib/domain/usecases/usecase.dart`

**Responsabilité:** Fournir une interface commune pour tous les cas d'usage.

```dart
abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

class NoParams {
  const NoParams();
}
```

**Contrats:**
- Chaque UseCase retourne un Result
- T = type de retour (succès)
- P = type du paramètre (peut être NoParams)
- Pattern `call()` permet une invocation naturelle

**Utilisation:**
```dart
// UseCase avec paramètres
class GetDeviceByIdUseCase extends UseCase<Device, String> {
  @override
  Future<Result<Device>> call(String deviceId) {
    return repository.getDeviceById(deviceId);
  }
}

// UseCase sans paramètres
class GetAllDevicesUseCase extends UseCase<List<Device>, NoParams> {
  @override
  Future<Result<List<Device>>> call(NoParams params) {
    return repository.getAllDevices();
  }
}

// Usage
final device = await getDeviceUseCase.call(deviceId);
final devices = await getAllDevicesUseCase.call(NoParams());
```

---

## 💾 DATA Layer Interfaces

### 10. DeviceLocalDataSource Interface

**Fichier:** `lib/data/datasources/local/device_local_datasource.dart`

**Responsabilité:** Abstraire les opérations SQLite pour les appareils.

```dart
abstract class DeviceLocalDataSource {
  Future<List<Device>> getAllDevices();
  Future<Device?> getDeviceById(String id);
  Future<void> insertDevice(Device device);
  Future<void> updateDevice(Device device);
  Future<void> deleteDevice(String id);
  Future<List<Device>> searchDevices(String query);
  Future<List<Device>> getDevicesByType(String type);
  Future<bool> deviceExists(String id);
  Future<int> getDeviceCount();
}
```

**Contrats:**
- Retourne les Entities (pas les Models)
- Retourne null si non trouvé (pas d'exception)
- Les recherches retournent toujours une liste (vide si aucun résultat)
- Les méthodes directes (insert, update, delete) ne retournent rien en cas de succès
- Conversion Model → Entity automatique

**Implémentation:**
- Utilise SQLite pour la persistance
- Gère les transactions
- Vérifie les contraintes d'intégrité

---

### 11. ConnectionLocalDataSource Interface

**Fichier:** `lib/data/datasources/local/connection_local_datasource.dart`

**Responsabilité:** Abstraire les opérations SQLite pour les connexions.

```dart
abstract class ConnectionLocalDataSource {
  Future<Connection?> getConnection(String deviceId);
  Future<List<Connection>> getAllConnections();
  Future<List<Connection>> getConnectionHistory(
    String deviceId, {
    DateTime? from,
    DateTime? to,
  });
  Future<void> insertConnection(Connection connection);
  Future<void> updateConnection(Connection connection);
  Future<List<Connection>> getActiveConnections();
  Future<void> deleteConnection(String id);
  Future<void> deleteOldConnections(DateTime beforeDate);
  Future<int> getConnectionCount(String deviceId);
}
```

---

### 12. CommandLocalDataSource Interface

**Fichier:** `lib/data/datasources/local/command_local_datasource.dart`

**Responsabilité:** Abstraire les opérations SQLite pour les commandes.

```dart
abstract class CommandLocalDataSource {
  Future<void> insertCommand(Command command);
  Future<Command?> getCommand(String id);
  Future<List<Command>> getAllCommands();
  Future<List<Command>> getCommandsByDevice(String deviceId);
  Future<List<Command>> getCommandHistory(
    String deviceId, {
    int limit = 50,
    int offset = 0,
  });
  Future<void> updateCommand(Command command);
  Future<List<Command>> getPendingCommands();
  Future<void> deleteCommand(String id);
  Future<void> deleteOldCommands(DateTime beforeDate);
  Future<int> getCommandCount(String deviceId);
}
```

---

## 🎨 PRESENTATION Layer Base Classes

### 13. BaseViewModel Class

**Fichier:** `lib/presentation/viewmodels/base_viewmodel.dart`

**Responsabilité:** Fournir une classe de base pour tous les ViewModels.

```dart
abstract class BaseViewModel extends ChangeNotifier {
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<String?> successNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  
  bool get hasError => errorNotifier.value != null;
  String? get error => errorNotifier.value;
  
  void initialize();
  
  @override
  void dispose() {
    errorNotifier.dispose();
    successNotifier.dispose();
    isLoading.dispose();
    super.dispose();
  }
  
  void setError(String message);
  void clearError();
  void setSuccess(String message);
  void clearSuccess();
  void handleException(Exception exception);
}
```

**Contrats:**
- Chaque ViewModel appelle `initialize()` après création
- L'état est géré via ValueNotifier (observable)
- Les erreurs et succès sont affichés via des notifiers
- Le `dispose()` nettoie les ressources
- Les méthodes helper simplifient la gestion d'état

**Implémentation pattern:**
```dart
class DeviceListViewModel extends BaseViewModel {
  late ValueNotifier<List<Device>> devices;
  final GetAllDevicesUseCase getAllDevicesUseCase;
  final EventBus eventBus;
  
  DeviceListViewModel({
    required this.getAllDevicesUseCase,
    required this.eventBus,
  });
  
  @override
  void initialize() {
    devices = ValueNotifier([]);
    eventBus.listen<DeviceAddedEvent>(_onDeviceAdded);
    loadDevices();
  }
  
  Future<void> loadDevices() async {
    isLoading.value = true;
    final result = await getAllDevicesUseCase.call(NoParams());
    result.fold(
      (failure) => setError(failure.message),
      (data) => devices.value = data,
    );
    isLoading.value = false;
  }
  
  void _onDeviceAdded(DeviceAddedEvent event) {
    devices.value = [...devices.value, event.device];
  }
  
  @override
  void dispose() {
    devices.dispose();
    super.dispose();
  }
}
```

---

## 📊 Résumé des relations d'interface

```
Couche CORE
├── ServiceLocator (DI)
├── EventBus (Pub/Sub)
├── AppEvent (Base des événements)
├── Result (Success/Failure)
└── AppException (Hiérarchie d'erreurs)

Couche DOMAIN
├── Repositories (Interfaces abstraites)
│   ├── DeviceRepository
│   ├── ConnectionRepository
│   └── CommandRepository
├── Entities (Valeurs métier)
│   ├── Device
│   ├── Connection
│   └── Command
├── UseCases (Opérations métier)
└── DomainEvents (Événements métier)

Couche DATA
├── DataSources (Interfaces SQL)
│   ├── DeviceLocalDataSource
│   ├── ConnectionLocalDataSource
│   └── CommandLocalDataSource
├── Models (Représentation SQL)
│   ├── DeviceModel
│   ├── ConnectionModel
│   └── CommandModel
└── Repositories (Implémentations)
    ├── DeviceRepositoryImpl
    ├── ConnectionRepositoryImpl
    └── CommandRepositoryImpl

Couche PRESENTATION
├── Pages (Écrans complets)
├── ViewModels (État réactif)
├── Views (Composants d'entité)
└── Widgets (Composants réutilisables)
```


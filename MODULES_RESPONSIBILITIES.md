# Modules et Responsabilités - IoT Connection Manager

## 📚 Vue d'ensemble des modules

L'architecture est organisée en **4 modules principaux** qui respectent la **Clean Architecture** et les principes **SOLID**.

---

## 🎯 1. CORE MODULE (Foundation Layer)

**Chemin:** `lib/core/`

**Responsabilité globale:** Fournir les fondations réutilisables pour toute l'application.

### 1.1 DI Submodule (`di/`)

**Responsabilités:**
- Configuration de la Dependency Injection
- Enregistrement des dépendances au démarrage
- Gestion du cycle de vie des singletons
- Fourniture d'un `ServiceLocator` pour l'accès aux instances

**Interfaces principales:**
```dart
abstract class ServiceLocator {
  void registerSingleton<T>(T instance);
  void registerFactory<T>(T Function() factory);
  T get<T>();
  bool isRegistered<T>();
}
```

**Modules:**
- `service_locator.dart` - Interface ServiceLocator
- `modules/core_module.dart` - Configuration CORE
- `modules/domain_module.dart` - Configuration DOMAIN
- `modules/data_module.dart` - Configuration DATA

### 1.2 Events Submodule (`events/`)

**Responsabilités:**
- Définir le système de publication/souscription
- Implémenter l'Event Bus pattern
- Permettre la communication découplée entre les couches

**Interfaces principales:**
```dart
abstract class EventBus {
  void listen<T extends AppEvent>(void Function(T event) handler);
  Future<void> publish(AppEvent event);
  void clear();
}

abstract class AppEvent {
  DateTime get timestamp;
  String get eventType;
}
```

**Fichiers:**
- `app_event.dart` - Classe de base pour tous les événements
- `event_bus.dart` - Interface du bus d'événements
- `event_listener.dart` - Définition des listeners

### 1.3 Exceptions Submodule (`exceptions/`)

**Responsabilités:**
- Centraliser la gestion des exceptions
- Fournir des types d'exceptions spécifiques
- Améliorer la traçabilité des erreurs

**Hiérarchie des exceptions:**
```
AppException (classe de base)
├── DataException
│   └── NotFoundException
├── ValidationException
├── DeviceException
└── ConnectionException
```

**Fichiers:**
- `app_exception.dart` - Classe de base
- `exceptions.dart` - Exceptions spécifiques

### 1.4 Utils Submodule (`utils/`)

**Responsabilités:**
- Fournir des utilitaires réutilisables
- Implémenter le pattern Result (Either)
- Logger les messages
- Valider les données

**Interfaces/Classes principales:**
```dart
abstract class Result<T> {
  R fold<R>(
    R Function(Failure) onFailure,
    R Function(T) onSuccess,
  );
}

class Success<T> extends Result<T> { ... }
class Failure<T> extends Result<T> { ... }
```

**Fichiers:**
- `result.dart` - Result/Success/Failure
- `logger.dart` - Service de logging
- `validators.dart` - Validateurs

### 1.5 Constants Submodule (`constants/`)

**Responsabilités:**
- Centraliser les constantes d'application
- Éviter les "magic strings"
- Faciliter la maintenance

**Fichiers:**
- `app_constants.dart` - Constantes métier
- `string_constants.dart` - Chaînes de caractères

---

## 🧠 2. DOMAIN MODULE (Business Logic Layer)

**Chemin:** `lib/domain/`

**Responsabilité globale:** Contenir la logique métier pure, indépendante de l'implémentation.

### 2.1 Entities Submodule (`entities/`)

**Responsabilités:**
- Définir les objets métier (Value Objects)
- Encapsuler les données métier
- Être immuables et thread-safe

**Entities principales:**

#### Device
```dart
class Device {
  final String id;
  final String name;
  final String type;
  final String address;
  final String status;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Cas d'usage:**
- Représenter un appareil IoT
- Stocker les informations d'identification
- Gérer les métadonnées personnalisées

#### Connection
```dart
class Connection {
  final String id;
  final String deviceId;
  final String status; // 'connected', 'disconnected', 'error'
  final int signalStrength; // 0-100
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final String? lastError;
}
```

**Cas d'usage:**
- Représenter une session de connexion
- Tracker l'historique des connexions
- Stocker les métriques de signal

#### Command
```dart
class Command {
  final String id;
  final String deviceId;
  final String commandType;
  final Map<String, dynamic> parameters;
  final String status; // 'pending', 'sent', 'executed', 'failed'
  final String? response;
  final DateTime sentAt;
  final DateTime? executedAt;
  final String? error;
}
```

**Cas d'usage:**
- Représenter une commande envoyée à un device
- Tracker l'exécution des commandes
- Stocker l'historique des opérations

### 2.2 Repositories Submodule (`repositories/`)

**Responsabilités:**
- Définir les contrats de repos (interfaces abstraites)
- Isoler l'accès aux données du reste du code
- Permettre l'échange facile d'implémentations

**Repositories principaux:**

#### DeviceRepository
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

#### ConnectionRepository
```dart
abstract class ConnectionRepository {
  Future<Result<Connection>> getConnection(String deviceId);
  Future<Result<List<Connection>>> getAllConnections();
  Future<Result<List<Connection>>> getConnectionHistory(...);
  Future<Result<Connection>> saveConnection(Connection connection);
  Future<Result<List<Connection>>> getActiveConnections();
  Future<Result<Map<String, dynamic>>> getConnectionStats(String deviceId);
}
```

#### CommandRepository
```dart
abstract class CommandRepository {
  Future<Result<Command>> sendCommand(Command command);
  Future<Result<Command>> getCommand(String id);
  Future<Result<List<Command>>> getCommandsByDevice(String deviceId);
  Future<Result<List<Command>>> getCommandHistory(...);
  Future<Result<Command>> updateCommandStatus(...);
  Future<Result<List<Command>>> getPendingCommands();
}
```

### 2.3 UseCases Submodule (`usecases/`)

**Responsabilités:**
- Implémenter les opérations métier
- Orchestrer les repositories et entités
- Publier les événements métier
- Appliquer les règles de validation

**Structure organisationnelle:**
```
usecases/
├── device/
│   ├── get_all_devices_usecase.dart
│   ├── add_device_usecase.dart
│   ├── update_device_usecase.dart
│   └── delete_device_usecase.dart
├── connection/
│   ├── connect_device_usecase.dart
│   ├── disconnect_device_usecase.dart
│   └── get_connection_status_usecase.dart
├── command/
│   ├── send_command_usecase.dart
│   └── get_command_history_usecase.dart
└── usecase.dart
```

**Pattern UseCase:**
```dart
abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

class GetAllDevicesUseCase extends UseCase<List<Device>, NoParams> {
  final DeviceRepository repository;
  final EventBus eventBus;
  
  GetAllDevicesUseCase({
    required this.repository,
    required this.eventBus,
  });
  
  @override
  Future<Result<List<Device>>> call(NoParams params) async {
    return await repository.getAllDevices();
  }
}
```

### 2.4 Events Submodule (`events/`)

**Responsabilités:**
- Définir les événements métier
- Permettre la notification des changements
- Découpler les composants métier

**Événements principaux:**
- `DeviceConnectedEvent` - Appareil connecté
- `DeviceDisconnectedEvent` - Appareil déconnecté
- `DeviceAddedEvent` - Nouvel appareil ajouté
- `DeviceUpdatedEvent` - Appareil modifié
- `DeviceRemovedEvent` - Appareil supprimé
- `ConnectionStatusChangedEvent` - Changement de statut
- `CommandExecutedEvent` - Commande exécutée
- `ErrorEvent` - Erreur survenue

---

## 💾 3. DATA MODULE (Persistence Layer)

**Chemin:** `lib/data/`

**Responsabilité globale:** Implémenter l'accès aux données et persister les informations.

### 3.1 Models Submodule (`models/`)

**Responsabilités:**
- Représenter les données telles qu'elles sont stockées en base
- Implémenter la sérialisation/désérialisation
- Convertir Model ↔ Entity

**Models principales:**

#### DeviceModel
```dart
class DeviceModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final String status;
  final String metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Device toEntity() { ... }
  factory DeviceModel.fromEntity(Device entity) { ... }
  Map<String, dynamic> toJson() { ... }
  factory DeviceModel.fromJson(Map<String, dynamic> json) { ... }
}
```

#### ConnectionModel
```dart
class ConnectionModel {
  final String id;
  final String deviceId;
  final String status;
  final int signalStrength;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final String? lastError;
  
  Connection toEntity() { ... }
  factory ConnectionModel.fromEntity(Connection entity) { ... }
}
```

#### CommandModel
```dart
class CommandModel {
  final String id;
  final String deviceId;
  final String commandType;
  final String parametersJson;
  final String status;
  final String? response;
  final DateTime sentAt;
  final DateTime? executedAt;
  final String? error;
  
  Command toEntity() { ... }
  factory CommandModel.fromEntity(Command entity) { ... }
}
```

### 3.2 DataSources Submodule (`datasources/local/`)

**Responsabilités:**
- Abstraire les opérations SQLite
- Implémenter les contrats d'accès aux données
- Gérer les transactions et les requêtes

**DataSources principales:**

#### DeviceLocalDataSource
```dart
abstract class DeviceLocalDataSource {
  Future<List<Device>> getAllDevices();
  Future<Device?> getDeviceById(String id);
  Future<void> insertDevice(Device device);
  Future<void> updateDevice(Device device);
  Future<void> deleteDevice(String id);
  Future<List<Device>> searchDevices(String query);
  Future<List<Device>> getDevicesByType(String type);
}
```

**Implémentation:**
- Gère les opérations SQLite
- Convertit Model → Entity
- Gère les erreurs de base de données

#### ConnectionLocalDataSource
```dart
abstract class ConnectionLocalDataSource {
  Future<Connection?> getConnection(String deviceId);
  Future<List<Connection>> getAllConnections();
  Future<List<Connection>> getConnectionHistory(...);
  Future<void> insertConnection(Connection connection);
  Future<void> updateConnection(Connection connection);
  Future<List<Connection>> getActiveConnections();
}
```

#### CommandLocalDataSource
```dart
abstract class CommandLocalDataSource {
  Future<void> insertCommand(Command command);
  Future<Command?> getCommand(String id);
  Future<List<Command>> getAllCommands();
  Future<List<Command>> getCommandsByDevice(String deviceId);
  Future<List<Command>> getCommandHistory(...);
  Future<void> updateCommand(Command command);
}
```

### 3.3 Repositories Submodule (`repositories/`)

**Responsabilités:**
- Implémenter les interfaces du Domain
- Coordonner les DataSources
- Gérer la conversion Model ↔ Entity
- Implémenter la logique d'erreur

**Implémentations principales:**

#### DeviceRepositoryImpl
```dart
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource deviceLocalDataSource;
  
  @override
  Future<Result<List<Device>>> getAllDevices() async {
    try {
      final devices = await deviceLocalDataSource.getAllDevices();
      return Success(devices);
    } catch (e, stack) {
      return Failure(
        exception: DataException(...),
        message: 'Failed to get devices',
        code: 'FETCH_DEVICES_ERROR',
      );
    }
  }
}
```

---

## 🎨 4. PRESENTATION MODULE (UI Layer)

**Chemin:** `lib/presentation/`

**Responsabilité globale:** Afficher l'interface utilisateur et gérer l'interaction utilisateur.

### 4.1 Pages Submodule (`pages/`)

**Responsabilités:**
- Représenter les écrans complets de l'application
- Créer les ViewModels associés
- Gérer la navigation et le routing

**Pages principales:**
- `home_page.dart` - Écran d'accueil
- `device_list_page.dart` - Liste des appareils
- `device_detail_page.dart` - Détails d'un appareil
- `add_device_page.dart` - Ajouter un appareil
- `connection_page.dart` - Gestion des connexions
- `settings_page.dart` - Paramètres

**Responsabilités d'une Page:**
```dart
class DeviceListPage extends StatefulWidget {
  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  late DeviceListViewModel viewModel;
  
  @override
  void initState() {
    viewModel = getIt<DeviceListViewModel>();
    viewModel.initialize();
    viewModel.addListener(_onViewModelChanged);
    super.initState();
  }
  
  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Build UI based on ViewModel state
  }
}
```

### 4.2 ViewModels Submodule (`viewmodels/`)

**Responsabilités:**
- Gérer l'état de la page de manière réactive
- Coordonner avec les UseCases
- Publier les changements d'état
- Gérer les événements métier

**ViewModel Pattern:**
```dart
class DeviceListViewModel extends BaseViewModel {
  late ValueNotifier<List<Device>> devices;
  late ValueNotifier<bool> isLoading;
  
  final GetAllDevicesUseCase getAllDevicesUseCase;
  final EventBus eventBus;
  
  @override
  void initialize() {
    devices = ValueNotifier([]);
    isLoading = ValueNotifier(false);
    
    // Subscribe to events
    eventBus.listen<DeviceAddedEvent>((event) {
      _onDeviceAdded(event);
    });
    
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
}
```

### 4.3 Views Submodule (`views/`)

**Responsabilités:**
- Composer des widgets pour des entités
- Afficher les détails d'une entité
- Réutiliser des affichages

**Exemples:**
- `device_view.dart` - Affichage d'un appareil
- `connection_view.dart` - Affichage d'une connexion
- `status_view.dart` - Affichage du statut

### 4.4 Widgets Submodule (`widgets/`)

**Responsabilités:**
- Fournir des composants UI réutilisables
- Encapsuler la logique d'affichage
- Être indépendants et testables

**Widgets principales:**
- `device_card.dart` - Carte d'appareil
- `connection_indicator.dart` - Indicateur de connexion
- `command_button.dart` - Bouton de commande
- `status_badge.dart` - Badge de statut

---

## 🔗 Dépendances entre modules

```
PRESENTATION (Pages, ViewModels, Views, Widgets)
    ↓ depends on
DOMAIN (Entities, UseCases, Repositories [Interfaces], Events)
    ↓ depends on
DATA (Models, DataSources, Repositories [Impl])
    ↓ depends on
CORE (DI, Events, Exceptions, Utils, Constants)
```

### Règles strictes:
- ✅ CORE n'a AUCUNE dépendance externe
- ✅ DOMAIN dépend uniquement de CORE
- ✅ DATA dépend de DOMAIN et CORE
- ✅ PRESENTATION dépend de DOMAIN et CORE
- ❌ PRESENTATION ne dépend JAMAIS directement de DATA
- ❌ Les dépendances ne remontent JAMAIS vers le haut (vers PRESENTATION)

---

## 📊 Flux des données entre modules

```
User Input (UI)
    ↓
ViewModel (PRESENTATION) methods
    ↓
UseCase (DOMAIN) execute
    ↓
Repository (DOMAIN interface)
    ↓
Repository Implementation (DATA)
    ↓
DataSource (DATA)
    ↓
SQLite Database
    ↓
[Return path with Result/Entity]
    ↓
EventBus.publish(Event)
    ↓
ViewModel.onEvent() [via EventBus subscription]
    ↓
Update State (ValueNotifier)
    ↓
Widget rebuild (Listener)
    ↓
Updated UI
```


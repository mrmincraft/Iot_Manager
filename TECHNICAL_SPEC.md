# IoT Manager - Technical Specification

**Version:** 0.1.0-alpha  
**Last Updated:** 2026-07-02  
**Status:** Alpha Release

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Technology Stack](#technology-stack)
3. [Core Components](#core-components)
4. [Data Layer](#data-layer)
5. [Plugin Architecture](#plugin-architecture)
6. [Build & Deployment](#build--deployment)
7. [Performance & Scalability](#performance--scalability)
8. [Security Considerations](#security-considerations)

---

## System Architecture

### Overview

IoT Manager follows a **Clean Architecture** pattern with four distinct layers:

```
┌─────────────────────────────────────────┐
│      PRESENTATION LAYER                 │
│  (Pages, ViewModels, Widgets, UI)      │
├─────────────────────────────────────────┤
│      DOMAIN LAYER                       │
│  (Use Cases, Entities, Repository I/F)  │
├─────────────────────────────────────────┤
│      DATA LAYER                         │
│  (DTOs, Models, Repositories, Sources)  │
├─────────────────────────────────────────┤
│      CORE LAYER                         │
│  (DI, EventBus, Exceptions, Utilities)  │
└─────────────────────────────────────────┘
```

### Design Principles

- **Single Responsibility:** Each class has one reason to change
- **Dependency Injection:** Loose coupling via GetIt service locator
- **Result Pattern:** Functional error handling with `Result<T, E>`
- **Event-Driven:** EventBus for inter-component communication
- **Plugin System:** Extensible architecture for protocol handlers

---

## Technology Stack

### Frontend
- **Framework:** Flutter 3.16+
- **Language:** Dart 3.0+
- **UI Design:** Material Design 3
- **State Management:** ValueNotifier + EventBus (MVVM)

### Backend (Local)
- **Database:** SQLite 3.40+
- **ORM:** sqflite 2.3.0
- **Serialization:** Manual (no json_serializable used)

### Platform Support

| Platform | Status | Build | Runtime |
|----------|--------|-------|---------|
| Linux x64 | ✅ Alpha | CMake 3.10+ | GTK 3.0+ |
| Android | 🔄 Planned | Gradle | Android 10+ |
| iOS | 🔄 Planned | Xcode | iOS 13+ |
| Windows | 🔄 Planned | Visual Studio | Windows 10+ |
| macOS | 🔄 Planned | Xcode | macOS 10.15+ |

### Dependencies

**Production:**
- `get_it: ^7.6.0` - Dependency Injection
- `sqflite: ^2.3.0` - SQLite Database
- `mqtt5_client: ^4.3.0` - MQTT Protocol
- `http: ^1.1.0` - HTTP Client
- `event_bus: ^2.0.0` - Event Bus
- `intl: ^0.19.0` - Internationalization
- `logger: ^2.0.0` - Logging

**Development:**
- `flutter_lints: ^3.0.0` - Code Linting
- `flutter_test: sdk: flutter` - Testing Framework
- `mockito: ^5.4.0` - Mocking Library

---

## Core Components

### 1. Core Layer (`lib/core/`)

#### Dependency Injection
```dart
// Service Locator Setup
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core services
  getIt.registerSingleton<DatabaseService>(...);
  getIt.registerSingleton<EventBus>(...);
  
  // Repositories
  getIt.registerSingleton<DeviceRepository>(...);
  getIt.registerSingleton<ConnectionRepository>(...);
  
  // Use Cases
  getIt.registerSingleton<GetDevicesUseCase>(...);
  getIt.registerSingleton<AddDeviceUseCase>(...);
}
```

#### Event Bus
```dart
// Publish events
eventBus.fire(DeviceAddedEvent(device));

// Subscribe to events
eventBus.on<DeviceAddedEvent>().listen((event) {
  print('Device added: ${event.device.name}');
});
```

#### Result Pattern
```dart
Result<Device, AppException> result = await getDevice(id);

result.fold(
  (device) => print('Success: ${device.name}'),
  (error) => print('Error: ${error.message}'),
);
```

#### Exception Handling
```dart
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  
  AppException({required this.message, this.stackTrace});
}

// Specific exceptions
class DatabaseException extends AppException { }
class NetworkException extends AppException { }
class ValidationException extends AppException { }
```

### 2. Domain Layer (`lib/domain/`)

#### Entities
- **Device:** Represents IoT device metadata
- **Connection:** MQTT connection configuration
- **Message:** Published/received messages
- **Topic:** MQTT topic subscriptions
- **Command:** Device commands
- **Certificate:** SSL/TLS certificates
- **Protocol:** Protocol definitions
- **Dashboard:** UI dashboard configurations
- **LogEntry:** Activity logs
- **UserSettings:** User preferences

#### Use Cases
Each entity has dedicated use case class:

```dart
class GetDevicesUseCase extends UseCase<List<Device>, NoParams> {
  final DeviceRepository repository;
  
  GetDevicesUseCase({required this.repository});
  
  @override
  Future<Result<List<Device>, AppException>> call(NoParams params) async {
    return await repository.getAllDevices();
  }
}
```

#### Repository Interfaces
```dart
abstract class DeviceRepository {
  Future<Result<List<Device>, AppException>> getAllDevices();
  Future<Result<Device, AppException>> getDeviceById(String id);
  Future<Result<void, AppException>> addDevice(Device device);
  Future<Result<void, AppException>> updateDevice(Device device);
  Future<Result<void, AppException>> deleteDevice(String id);
}
```

### 3. Data Layer (`lib/data/`)

#### Data Source Pattern
```dart
// Local Data Source
abstract class DeviceLocalDataSource {
  Future<List<DeviceModel>> getAllDevices();
  Future<DeviceModel> getDeviceById(String id);
  Future<void> addDevice(DeviceModel device);
}

class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final DatabaseService database;
  
  @override
  Future<List<DeviceModel>> getAllDevices() async {
    final rows = await database.query('devices');
    return rows.map((row) => DeviceModel.fromMap(row)).toList();
  }
}
```

#### Repository Implementation
```dart
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource localDataSource;
  
  @override
  Future<Result<List<Device>, AppException>> getAllDevices() async {
    try {
      final models = await localDataSource.getAllDevices();
      final entities = models.map((m) => m.toEntity()).toList();
      return Result.success(entities);
    } on DatabaseException catch (e) {
      return Result.failure(e);
    }
  }
}
```

#### DTOs & Models
```dart
class DeviceModel {
  final String id;
  final String name;
  final String type;
  final bool isOnline;
  
  // Map conversions
  Map<String, dynamic> toMap() => { /* ... */ };
  
  // Entity conversion
  Device toEntity() => Device(
    id: id, name: name, type: type, isOnline: isOnline
  );
}
```

### 4. Presentation Layer (`lib/presentation/`)

#### MVVM Pattern
```dart
class DeviceViewModel extends BaseViewModel {
  final GetDevicesUseCase getDevicesUseCase;
  
  final _devices = ValueNotifier<List<Device>>([]);
  ValueNotifier<List<Device>> get devices => _devices;
  
  Future<void> loadDevices() async {
    setLoading(true);
    final result = await getDevicesUseCase(NoParams());
    
    result.fold(
      (devices) => _devices.value = devices,
      (error) => setError(error.message),
    );
    
    setLoading(false);
  }
}
```

#### Base ViewModel
```dart
abstract class BaseViewModel extends ChangeNotifier {
  final _isLoading = ValueNotifier<bool>(false);
  final _error = ValueNotifier<String?>(null);
  
  ValueNotifier<bool> get isLoading => _isLoading;
  ValueNotifier<String?> get error => _error;
  
  void setLoading(bool value) => _isLoading.value = value;
  void setError(String? value) => _error.value = value;
}
```

---

## Data Layer

### SQLite Schema

**9 Core Tables:**

1. **devices** - Device registry
2. **connections** - MQTT connections
3. **topics** - Topic subscriptions
4. **messages** - Message history
5. **commands** - Device commands
6. **protocols** - Protocol definitions
7. **certificates** - SSL/TLS certificates
8. **dashboards** - UI configurations
9. **log_entries** - Activity logs
10. **user_settings** - User preferences

**Features:**
- Indexes for fast queries
- Foreign key constraints
- Triggers for audit logging
- Timestamps on all records
- Soft delete support

### Database Service
```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  late Database _db;
  
  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'iot_manager.db'),
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
      version: 1,
    );
  }
  
  Future<List<Map<String, dynamic>>> query(String table) async {
    return await _db.query(table);
  }
  
  Future<int> insert(String table, Map<String, dynamic> values) async {
    return await _db.insert(table, values);
  }
}
```

---

## Plugin Architecture

### ProtocolPlugin Interface
```dart
abstract class ProtocolPlugin {
  // Metadata
  String get name;
  String get version;
  String get description;
  
  // Lifecycle
  Future<Result<void, AppException>> initialize(PluginContext context);
  Future<Result<void, AppException>> connect(Connection config);
  Future<Result<void, AppException>> disconnect();
  Future<void> dispose();
  
  // Operations
  Future<Result<void, AppException>> publish(Message message);
  Future<Result<void, AppException>> subscribe(Topic topic);
  Future<Result<void, AppException>> unsubscribe(String topicName);
  
  // Events
  Stream<Message> get onMessageReceived;
  Stream<String> get onConnectionStatusChanged;
}
```

### Plugin Registry
```dart
class PluginRegistry {
  final Map<String, ProtocolPlugin> _plugins = {};
  
  void registerPlugin(String name, ProtocolPlugin plugin) {
    _plugins[name] = plugin;
  }
  
  ProtocolPlugin? getPlugin(String name) => _plugins[name];
  
  List<String> getAvailablePlugins() => _plugins.keys.toList();
}
```

### Plugin Manager
```dart
class PluginManager {
  final PluginRegistry registry;
  final PluginContext context;
  
  Future<Result<void, AppException>> loadPlugin(String name) async {
    final plugin = registry.getPlugin(name);
    if (plugin == null) {
      return Result.failure(PluginException('Plugin not found: $name'));
    }
    
    return await plugin.initialize(context);
  }
}
```

---

## Build & Deployment

### Build Configuration

#### pubspec.yaml
```yaml
name: iot_manager
version: 0.1.0-alpha+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  get_it: ^7.6.0
  sqflite: ^2.3.0
  mqtt5_client: ^4.3.0
  http: ^1.1.0
  event_bus: ^2.0.0
  intl: ^0.19.0
  logger: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
```

#### build.yaml
```yaml
targets:
  $default:
    builders:
      json_serializable:
        generate_for:
          - lib/**
      mockito:
        generate_for:
          - lib/**
```

### Linux Build

#### CMake Configuration
```cmake
cmake_minimum_required(VERSION 3.10)
project(iot_manager)

# Flutter configuration
include(${FLUTTER_SOURCE_DIR}/tools/cmake/flutter.cmake)

# Find Flutter and GTK
find_package(GTK REQUIRED COMPONENTS gtk)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED gtk+-3.0)

# Build Flutter app
flutter_app(iot_manager)

# Link libraries
target_link_libraries(iot_manager
  PRIVATE
  ${GTK_LIBRARIES}
  flutter
)
```

#### Build Script
```bash
#!/bin/bash
# build_linux.sh - Automated Linux build

./build_linux.sh release    # Release build
./build_linux.sh debug      # Debug build
./build_linux.sh clean      # Clean build
```

### GitHub Actions CI/CD
```yaml
name: Linux Build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: ./build_linux.sh release
      - uses: actions/upload-artifact@v3
        with:
          name: iot_manager-linux
          path: build/linux/x64/release/bundle/
```

---

## Performance & Scalability

### Database Optimization
- **Indexes:** Indexed on ID, connection ID, timestamp fields
- **Query Optimization:** Prepared statements, connection pooling
- **Pagination:** Limit 1000 records per query
- **Caching:** In-memory device cache with TTL

### Memory Management
- **ValueNotifier:** Dispose in ViewModel cleanup
- **Streams:** Cancel subscriptions on dispose
- **Cache:** Automatic eviction after 5 minutes
- **Lazy Loading:** Load data on demand

### Network Optimization
- **Message Batching:** Combine updates every 100ms
- **Compression:** Gzip for HTTP requests
- **Retry Logic:** Exponential backoff (1s, 2s, 4s, 8s)
- **Timeout:** 30s default, configurable per request

---

## Security Considerations

### Data Protection
- **SQLite Encryption:** Planned for Phase 13
- **SSL/TLS:** Certificate validation mandatory
- **Password Hashing:** bcrypt for user credentials
- **API Key Storage:** Secure keychain storage

### Communication
- **MQTT over TLS:** Required for production
- **Certificate Pinning:** Pinning for known hosts
- **Auth Tokens:** JWT with 24h expiration
- **Secure Headers:** HSTS, CSP, X-Content-Type-Options

### Input Validation
- **Topic Validation:** MQTT topic name validation
- **Device ID:** UUID format validation
- **Configuration:** Schema validation on load
- **Command Execution:** Whitelist validation

### Logging & Audit
- **Log Levels:** Debug, Info, Warning, Error
- **PII Filtering:** Automatic PII masking in logs
- **Audit Trail:** All state changes logged
- **Log Rotation:** 7-day retention, 100MB max

---

## Development Guidelines

### Code Style
- **Dart Format:** Run `dart format lib/`
- **Lint:** Run `flutter analyze`
- **Naming:** camelCase for variables, PascalCase for classes
- **Documentation:** JSDoc-style comments for public APIs

### Testing Requirements
- **Coverage:** Minimum 80% coverage
- **Unit Tests:** For all business logic
- **Integration Tests:** For data layer
- **Widget Tests:** For UI components
- **E2E Tests:** For critical workflows

### Git Workflow
```bash
git checkout -b feature/name
# Make changes
git commit -m "feat: description"
git push origin feature/name
# Create Pull Request
```

---

**Next Phase:** MQTT Plugin Implementation (Phase 12)

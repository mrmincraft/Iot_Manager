# IoT Manager - Development Guide

**Version:** 0.1.0-alpha  
**Last Updated:** 2026-07-02  
**Target:** Contributors and plugin developers

---

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Project Structure](#project-structure)
3. [Architecture Overview](#architecture-overview)
4. [Development Workflows](#development-workflows)
5. [Writing Code](#writing-code)
6. [Testing](#testing)
7. [Building](#building)
8. [Creating Plugins](#creating-plugins)
9. [Debugging](#debugging)
10. [Contributing](#contributing)

---

## Development Environment Setup

### Prerequisites

**Minimum Requirements:**
- Dart 3.0+
- Flutter 3.16+ (stable channel)
- Git 2.30+
- 10GB disk space
- 8GB RAM

### Linux Setup (Recommended)

```bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"

# Install dependencies (Ubuntu/Debian)
sudo apt-get install -y \
  cmake ninja-build pkg-config \
  libgtk-3-dev libssl-dev

# Verify installation
flutter doctor
```

### macOS Setup

```bash
# Install Flutter via Homebrew
brew install flutter

# Install dependencies
brew install cmake ninja

# Verify installation
flutter doctor
```

### Windows Setup

```powershell
# Install via chocolatey or download from flutter.dev
choco install flutter

# Install Visual Studio Build Tools
choco install visualstudio-buildtools

# Verify installation
flutter doctor
```

### IDE Setup

**VS Code:**
```bash
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
```

**Android Studio:**
- Install Dart and Flutter plugins from plugin marketplace

**IntelliJ IDEA:**
- Install Dart and Flutter plugins from plugin marketplace

---

## Project Structure

```
iot_manager/
├── lib/                           # Application source code
│   ├── core/                      # Core functionality
│   │   ├── di/                    # Dependency Injection
│   │   ├── events/                # Event Bus
│   │   ├── exceptions/            # Exception classes
│   │   └── utils/                 # Utilities
│   ├── domain/                    # Business logic
│   │   ├── entities/              # Domain models
│   │   ├── repositories/          # Repository interfaces
│   │   ├── usecases/              # Use case classes
│   │   └── events/                # Domain events
│   ├── data/                      # Data access layer
│   │   ├── datasources/           # Data sources (local)
│   │   ├── repositories/          # Repository implementations
│   │   ├── models/                # Data models
│   │   └── dtos/                  # Data transfer objects
│   ├── presentation/              # UI layer
│   │   ├── pages/                 # Page widgets
│   │   ├── viewmodels/            # ViewModels
│   │   ├── widgets/               # Reusable widgets
│   │   └── views/                 # View components
│   └── main.dart                  # Application entry point
├── test/                          # Test files
│   ├── core/                      # Core layer tests
│   ├── domain/                    # Domain layer tests
│   ├── data/                      # Data layer tests
│   └── presentation/              # UI tests
├── linux/                         # Linux platform files
│   ├── CMakeLists.txt             # Build configuration
│   ├── flutter/                   # Flutter CMake config
│   ├── main.cc                    # C++ entry point
│   └── my_application.cc/h        # GTK window
├── assets/                        # Static assets
├── pubspec.yaml                   # Dependencies
├── build.yaml                     # Build configuration
├── build_linux.sh                 # Build script
└── TECHNICAL_SPEC.md              # Technical documentation
```

---

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│      PRESENTATION (Flutter UI)          │
│      ViewModels, Pages, Widgets         │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│        DOMAIN (Business Logic)          │
│   Entities, UseCases, Repositories I/F  │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│        DATA (Data Access)               │
│  DTOs, Models, Repositories, DataSources│
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│    CORE (Infrastructure & Utilities)    │
│  DI, EventBus, Exceptions, Utils        │
└─────────────────────────────────────────┘
```

### Key Design Patterns

1. **Clean Architecture** - Separation of concerns
2. **MVVM** - Model-View-ViewModel pattern
3. **Repository Pattern** - Abstract data access
4. **Dependency Injection** - Loose coupling
5. **Result Pattern** - Functional error handling
6. **Event Bus** - Inter-component communication
7. **Plugin Architecture** - Protocol extensibility

---

## Development Workflows

### Adding a New Feature

#### Step 1: Define Entity (Domain)
```dart
// lib/domain/entities/sensor.dart
class Sensor {
  final String id;
  final String name;
  final double value;
  final DateTime timestamp;
  
  Sensor({
    required this.id,
    required this.name,
    required this.value,
    required this.timestamp,
  });
}
```

#### Step 2: Define Repository Interface (Domain)
```dart
// lib/domain/repositories/sensor_repository.dart
abstract class SensorRepository {
  Future<Result<List<Sensor>, AppException>> getAllSensors();
  Future<Result<Sensor, AppException>> getSensorById(String id);
  Future<Result<void, AppException>> addSensor(Sensor sensor);
  Future<Result<void, AppException>> updateSensor(Sensor sensor);
  Future<Result<void, AppException>> deleteSensor(String id);
}
```

#### Step 3: Create Use Cases (Domain)
```dart
// lib/domain/usecases/sensor_usecases.dart
class GetAllSensorsUseCase extends UseCase<List<Sensor>, NoParams> {
  final SensorRepository repository;
  
  GetAllSensorsUseCase({required this.repository});
  
  @override
  Future<Result<List<Sensor>, AppException>> call(NoParams params) async {
    return await repository.getAllSensors();
  }
}
```

#### Step 4: Create Data Models (Data)
```dart
// lib/data/models/sensor_model.dart
class SensorModel {
  final String id;
  final String name;
  final double value;
  final DateTime timestamp;
  
  SensorModel({
    required this.id,
    required this.name,
    required this.value,
    required this.timestamp,
  });
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory SensorModel.fromMap(Map<String, dynamic> map) => SensorModel(
    id: map['id'],
    name: map['name'],
    value: map['value'],
    timestamp: DateTime.parse(map['timestamp']),
  );
  
  Sensor toEntity() => Sensor(
    id: id,
    name: name,
    value: value,
    timestamp: timestamp,
  );
}
```

#### Step 5: Create Data Source (Data)
```dart
// lib/data/datasources/local/sensor_local_datasource.dart
abstract class SensorLocalDataSource {
  Future<List<SensorModel>> getAllSensors();
  Future<SensorModel> getSensorById(String id);
  Future<void> addSensor(SensorModel sensor);
  Future<void> updateSensor(SensorModel sensor);
  Future<void> deleteSensor(String id);
}

class SensorLocalDataSourceImpl implements SensorLocalDataSource {
  final DatabaseService database;
  
  SensorLocalDataSourceImpl({required this.database});
  
  @override
  Future<List<SensorModel>> getAllSensors() async {
    final rows = await database.query('sensors');
    return rows.map((row) => SensorModel.fromMap(row)).toList();
  }
  
  @override
  Future<void> addSensor(SensorModel sensor) async {
    await database.insert('sensors', sensor.toMap());
  }
}
```

#### Step 6: Create Repository Implementation (Data)
```dart
// lib/data/repositories/impl/sensor_repository_impl.dart
class SensorRepositoryImpl implements SensorRepository {
  final SensorLocalDataSource localDataSource;
  
  SensorRepositoryImpl({required this.localDataSource});
  
  @override
  Future<Result<List<Sensor>, AppException>> getAllSensors() async {
    try {
      final models = await localDataSource.getAllSensors();
      final entities = models.map((m) => m.toEntity()).toList();
      return Result.success(entities);
    } on Exception catch (e) {
      return Result.failure(
        DatabaseException(message: 'Failed to fetch sensors: $e')
      );
    }
  }
}
```

#### Step 7: Create ViewModel (Presentation)
```dart
// lib/presentation/viewmodels/sensor_viewmodel.dart
class SensorViewModel extends BaseViewModel {
  final GetAllSensorsUseCase getAllSensorsUseCase;
  
  final _sensors = ValueNotifier<List<Sensor>>([]);
  ValueNotifier<List<Sensor>> get sensors => _sensors;
  
  SensorViewModel({required this.getAllSensorsUseCase});
  
  Future<void> loadSensors() async {
    setLoading(true);
    final result = await getAllSensorsUseCase(NoParams());
    
    result.fold(
      (sensors) => _sensors.value = sensors,
      (error) => setError(error.message),
    );
    
    setLoading(false);
  }
  
  @override
  void dispose() {
    _sensors.dispose();
    super.dispose();
  }
}
```

#### Step 8: Create UI Widget (Presentation)
```dart
// lib/presentation/widgets/sensor_list.dart
class SensorList extends StatefulWidget {
  @override
  State<SensorList> createState() => _SensorListState();
}

class _SensorListState extends State<SensorList> {
  late SensorViewModel viewModel;
  
  @override
  void initState() {
    super.initState();
    viewModel = getIt<SensorViewModel>();
    viewModel.loadSensors();
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Sensor>>(
      valueListenable: viewModel.sensors,
      builder: (context, sensors, _) {
        return ListView.builder(
          itemCount: sensors.length,
          itemBuilder: (context, index) {
            final sensor = sensors[index];
            return ListTile(
              title: Text(sensor.name),
              subtitle: Text('${sensor.value}'),
              trailing: Text(sensor.timestamp.toString()),
            );
          },
        );
      },
    );
  }
  
  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
```

#### Step 9: Register in DI (Core)
```dart
// lib/core/di/setup_service_locator.dart
void setupServiceLocator() {
  // Data sources
  getIt.registerSingleton<SensorLocalDataSource>(
    SensorLocalDataSourceImpl(database: getIt<DatabaseService>()),
  );
  
  // Repositories
  getIt.registerSingleton<SensorRepository>(
    SensorRepositoryImpl(localDataSource: getIt<SensorLocalDataSource>()),
  );
  
  // Use cases
  getIt.registerSingleton<GetAllSensorsUseCase>(
    GetAllSensorsUseCase(repository: getIt<SensorRepository>()),
  );
  
  // View models
  getIt.registerSingleton<SensorViewModel>(
    SensorViewModel(getAllSensorsUseCase: getIt<GetAllSensorsUseCase>()),
  );
}
```

---

## Writing Code

### Code Style Guidelines

**Dart Format:**
```bash
dart format lib/ test/
```

**Linting:**
```bash
flutter analyze
```

**Naming Conventions:**
- Classes: `PascalCase` (e.g., `DeviceViewModel`)
- Methods/Variables: `camelCase` (e.g., `loadDevices()`)
- Constants: `camelCase` (e.g., `const maxDevices = 1000`)
- Private members: Prefix with `_` (e.g., `_devices`)

**Documentation:**
```dart
/// Loads all sensors from the repository.
/// 
/// Returns a [Result] containing the list of [Sensor]s on success,
/// or an [AppException] on failure.
Future<Result<List<Sensor>, AppException>> loadSensors() async {
  // implementation
}
```

### Import Organization
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:io';

// 2. Package imports
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// 3. Relative imports
import '../models/device_model.dart';
import 'device_repository.dart';
```

---

## Testing

### Test Structure

```
test/
├── core/
│   ├── di_test.dart
│   ├── event_bus_test.dart
│   ├── exceptions_test.dart
│   └── result_test.dart
├── domain/
│   ├── entities_test.dart
│   ├── usecases_test.dart
│   └── repositories_test.dart
├── data/
│   ├── datasources_test.dart
│   ├── models_test.dart
│   └── repositories_test.dart
└── presentation/
    ├── viewmodels_test.dart
    └── widgets_test.dart
```

### Unit Test Example

```dart
// test/domain/usecases/get_devices_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/domain/usecases/device_usecases.dart';
import 'package:iot_manager/domain/repositories/device_repository.dart';

void main() {
  group('GetDevicesUseCase', () {
    late GetDevicesUseCase useCase;
    late MockDeviceRepository mockRepository;
    
    setUp(() {
      mockRepository = MockDeviceRepository();
      useCase = GetDevicesUseCase(repository: mockRepository);
    });
    
    test('should return list of devices', () async {
      // Arrange
      final devices = [Device(id: '1', name: 'Device 1')];
      when(mockRepository.getAllDevices())
        .thenAnswer((_) async => Result.success(devices));
      
      // Act
      final result = await useCase(NoParams());
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (devices) => expect(devices.length, 1),
        (error) => fail('Should not have error'),
      );
      
      verify(mockRepository.getAllDevices()).called(1);
    });
  });
}
```

### Widget Test Example

```dart
// test/presentation/widgets/device_list_test.dart
void main() {
  group('DeviceList', () {
    testWidgets('displays devices', (WidgetTester tester) async {
      // Arrange
      final mockViewModel = MockDeviceViewModel();
      when(mockViewModel.devices).thenReturn(
        ValueNotifier<List<Device>>([
          Device(id: '1', name: 'Device 1'),
        ]),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: DeviceList(viewModel: mockViewModel),
        ),
      );
      
      // Assert
      expect(find.text('Device 1'), findsOneWidget);
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/domain/usecases/get_devices_usecase_test.dart

# Run with coverage
flutter test --coverage

# View coverage
lcov --list coverage/lcov.info
```

---

## Building

### Building for Linux

```bash
# Development build
flutter build linux --debug

# Release build
flutter build linux --release

# Using build script
./build_linux.sh release

# With specific variant
./build_linux.sh release
```

### Build Output

```
build/linux/x64/release/bundle/
├── iot_manager          # Executable
├── lib/                 # Shared libraries
├── data/                # Application data
└── ...
```

### Other Platforms

```bash
# Android
flutter build apk --release
flutter build aab --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

---

## Creating Plugins

### Plugin Template

```dart
// lib/plugins/example_plugin/example_protocol_plugin.dart
import 'package:iot_manager/domain/plugins/protocol_plugin.dart';

class ExampleProtocolPlugin implements ProtocolPlugin {
  @override
  String get name => 'Example Protocol';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => 'Example protocol implementation';
  
  final _messageController = StreamController<Message>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  
  @override
  Stream<Message> get onMessageReceived => _messageController.stream;
  
  @override
  Stream<String> get onConnectionStatusChanged => _statusController.stream;
  
  @override
  Future<Result<void, AppException>> initialize(PluginContext context) async {
    // Plugin initialization
    return Result.success(());
  }
  
  @override
  Future<Result<void, AppException>> connect(Connection config) async {
    // Connect to example service
    return Result.success(());
  }
  
  @override
  Future<Result<void, AppException>> disconnect() async {
    // Disconnect
    return Result.success(());
  }
  
  @override
  Future<Result<void, AppException>> publish(Message message) async {
    // Publish message
    return Result.success(());
  }
  
  @override
  Future<Result<void, AppException>> subscribe(Topic topic) async {
    // Subscribe to topic
    return Result.success(());
  }
  
  @override
  Future<Result<void, AppException>> unsubscribe(String topicName) async {
    // Unsubscribe from topic
    return Result.success(());
  }
  
  @override
  Future<void> dispose() async {
    await _messageController.close();
    await _statusController.close();
  }
}
```

### Plugin Registration

```dart
// lib/core/di/setup_service_locator.dart
void setupPlugins() {
  final registry = getIt<PluginRegistry>();
  
  // Register protocol plugins
  registry.registerPlugin(
    'mqtt',
    MQTTProtocolPlugin(),
  );
  registry.registerPlugin(
    'example',
    ExampleProtocolPlugin(),
  );
}
```

---

## Debugging

### Debug Output

```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Flutter Debug Tools

```bash
# Run with debug logging
flutter run -v

# Interactive debugging
flutter run

# Break on exception
flutter run --break-on-exception

# Check device
flutter devices
```

### VS Code Debugging

**.vscode/launch.json:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "IoT Manager",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": []
    }
  ]
}
```

---

## Contributing

### Git Workflow

```bash
# Clone repository
git clone https://github.com/yourusername/iot_manager.git
cd iot_manager

# Create feature branch
git checkout -b feature/new-feature

# Make changes
git add .
git commit -m "feat: add new feature"

# Push to branch
git push origin feature/new-feature

# Create Pull Request on GitHub
```

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

**Example:**
```
feat(device): add device filtering

Added ability to filter devices by type and status.
Implements usecase GetDevicesByTypeUseCase.

Closes #123
```

### Pull Request Checklist

- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Commit history is clean

---

**More Help?** Check TECHNICAL_SPEC.md or open an issue on GitHub.

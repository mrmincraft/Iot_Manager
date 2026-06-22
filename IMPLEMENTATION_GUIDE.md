# 🛠️ Guide d'implémentation - IoT Connection Manager

## 📌 Vue d'ensemble

Ce document fournit un guide pratique pour implémenter la architecture définie. Il couvre les patterns d'implémentation, les dépendances entre composants, et les étapes à suivre.

---

## 📋 Ordre d'implémentation recommandé

### Phase 1: CORE Layer (Fondations)

**1.1 Event Bus Implementation**
```dart
// lib/core/events/event_bus_impl.dart
class EventBusImpl implements EventBus {
  final Map<Type, List<dynamic>> _subscribers = {};
  final StreamController<AppEvent> _controller = StreamController.broadcast();
  
  @override
  void listen<T extends AppEvent>(void Function(T event) handler) {
    _subscribers.putIfAbsent(T, () => []).add(handler);
  }
  
  @override
  Future<void> publish(AppEvent event) async {
    final type = event.runtimeType;
    if (_subscribers.containsKey(type)) {
      for (final listener in _subscribers[type]!) {
        try {
          listener(event);
        } catch (e) {
          // Log error but continue
        }
      }
    }
  }
  
  @override
  void clear() {
    _subscribers.clear();
  }
}
```

**1.2 Service Locator Setup (GetIt)**
```dart
// lib/core/di/service_locator.dart - Implémentation
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core singletons
  getIt.registerSingleton<EventBus>(EventBusImpl());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
  getIt.registerSingleton<Logger>(LoggerImpl());
  
  // Domain repositories implementations
  getIt.registerSingleton<DeviceRepository>(
    DeviceRepositoryImpl(
      deviceLocalDataSource: getIt<DeviceLocalDataSource>(),
    ),
  );
  
  // UseCases factories
  getIt.registerFactory<GetAllDevicesUseCase>(
    () => GetAllDevicesUseCase(
      repository: getIt<DeviceRepository>(),
      eventBus: getIt<EventBus>(),
    ),
  );
  
  // ViewModels factories
  getIt.registerFactory<DeviceListViewModel>(
    () => DeviceListViewModel(
      getAllDevicesUseCase: getIt<GetAllDevicesUseCase>(),
      eventBus: getIt<EventBus>(),
    ),
  );
}
```

**1.3 Database Service**
```dart
// lib/core/services/database_service.dart
class DatabaseService {
  static const _dbName = 'iot_manager.db';
  static const _dbVersion = 1;
  
  late Database _database;
  
  Future<void> initialize() async {
    final path = join(
      await getDatabasesPath(),
      _dbName,
    );
    
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE devices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        address TEXT NOT NULL,
        status TEXT NOT NULL,
        metadata TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE connections (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        status TEXT NOT NULL,
        signal_strength INTEGER NOT NULL,
        connected_at INTEGER NOT NULL,
        disconnected_at INTEGER,
        last_error TEXT,
        FOREIGN KEY(device_id) REFERENCES devices(id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE commands (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        command_type TEXT NOT NULL,
        parameters TEXT NOT NULL,
        status TEXT NOT NULL,
        response TEXT,
        sent_at INTEGER NOT NULL,
        executed_at INTEGER,
        error TEXT,
        FOREIGN KEY(device_id) REFERENCES devices(id)
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
  }
  
  Database get database => _database;
  
  Future<void> close() async {
    await _database.close();
  }
}
```

---

### Phase 2: DATA Layer (Persistance)

**2.1 LocalDataSource Implementations**
```dart
// lib/data/datasources/local/device_local_datasource_impl.dart
class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final DatabaseService databaseService;
  
  DeviceLocalDataSourceImpl({
    required this.databaseService,
  });
  
  @override
  Future<List<Device>> getAllDevices() async {
    final db = databaseService.database;
    final maps = await db.query('devices');
    return maps.map((map) => DeviceModel.fromJson(map).toEntity()).toList();
  }
  
  @override
  Future<Device?> getDeviceById(String id) async {
    final db = databaseService.database;
    final maps = await db.query(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return DeviceModel.fromJson(maps.first).toEntity();
  }
  
  @override
  Future<void> insertDevice(Device device) async {
    final db = databaseService.database;
    final model = DeviceModel.fromEntity(device);
    await db.insert('devices', model.toJson());
  }
  
  @override
  Future<void> updateDevice(Device device) async {
    final db = databaseService.database;
    final model = DeviceModel.fromEntity(device);
    await db.update(
      'devices',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }
  
  // ... autres méthodes similaires
}
```

**2.2 Repository Implementations**
```dart
// lib/data/repositories/device_repository_impl.dart
// Déjà créé dans les fichiers précédents
```

---

### Phase 3: DOMAIN Layer (Logique métier)

**3.1 UseCases Implementations**
```dart
// lib/domain/usecases/device/get_all_devices_usecase.dart
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

// lib/domain/usecases/device/add_device_usecase.dart
class AddDeviceUseCase extends UseCase<Device, Device> {
  final DeviceRepository repository;
  final EventBus eventBus;
  
  AddDeviceUseCase({
    required this.repository,
    required this.eventBus,
  });
  
  @override
  Future<Result<Device>> call(Device device) async {
    final result = await repository.addDevice(device);
    
    // Publish event on success
    result.fold(
      (failure) => null,
      (addedDevice) {
        eventBus.publish(DeviceAddedEvent(addedDevice));
      },
    );
    
    return result;
  }
}

// lib/domain/usecases/device/update_device_usecase.dart
class UpdateDeviceUseCase extends UseCase<Device, Device> {
  final DeviceRepository repository;
  final EventBus eventBus;
  
  UpdateDeviceUseCase({
    required this.repository,
    required this.eventBus,
  });
  
  @override
  Future<Result<Device>> call(Device device) async {
    final result = await repository.updateDevice(device);
    
    result.fold(
      (failure) => null,
      (updatedDevice) {
        eventBus.publish(DeviceUpdatedEvent(updatedDevice));
      },
    );
    
    return result;
  }
}

// lib/domain/usecases/device/delete_device_usecase.dart
class DeleteDeviceUseCase extends UseCase<void, String> {
  final DeviceRepository repository;
  final EventBus eventBus;
  
  DeleteDeviceUseCase({
    required this.repository,
    required this.eventBus,
  });
  
  @override
  Future<Result<void>> call(String deviceId) async {
    final result = await repository.deleteDevice(deviceId);
    
    result.fold(
      (failure) => null,
      (_) {
        eventBus.publish(DeviceRemovedEvent(deviceId));
      },
    );
    
    return result;
  }
}
```

---

### Phase 4: PRESENTATION Layer (UI)

**4.1 ViewModels**
```dart
// lib/presentation/viewmodels/device_list_viewmodel.dart
class DeviceListViewModel extends BaseViewModel {
  late ValueNotifier<List<Device>> devices;
  late ValueNotifier<Device?> selectedDevice;
  
  final GetAllDevicesUseCase getAllDevicesUseCase;
  final AddDeviceUseCase addDeviceUseCase;
  final DeleteDeviceUseCase deleteDeviceUseCase;
  final EventBus eventBus;
  
  DeviceListViewModel({
    required this.getAllDevicesUseCase,
    required this.addDeviceUseCase,
    required this.deleteDeviceUseCase,
    required this.eventBus,
  });
  
  @override
  void initialize() {
    devices = ValueNotifier([]);
    selectedDevice = ValueNotifier(null);
    
    // Subscribe to events
    eventBus.listen<DeviceAddedEvent>(_onDeviceAdded);
    eventBus.listen<DeviceRemovedEvent>(_onDeviceRemoved);
    eventBus.listen<DeviceUpdatedEvent>(_onDeviceUpdated);
    eventBus.listen<ErrorEvent>(_onError);
    
    loadDevices();
  }
  
  Future<void> loadDevices() async {
    isLoading.value = true;
    clearError();
    
    final result = await getAllDevicesUseCase.call(NoParams());
    
    result.fold(
      (failure) {
        setError(failure.message);
      },
      (data) {
        devices.value = data;
        if (data.isEmpty) {
          setSuccess('No devices found');
        }
      },
    );
    
    isLoading.value = false;
  }
  
  Future<void> deleteDevice(String deviceId) async {
    isLoading.value = true;
    final result = await deleteDeviceUseCase.call(deviceId);
    
    result.fold(
      (failure) => setError(failure.message),
      (_) => setSuccess('Device deleted successfully'),
    );
    
    isLoading.value = false;
  }
  
  void selectDevice(Device device) {
    selectedDevice.value = device;
  }
  
  void _onDeviceAdded(DeviceAddedEvent event) {
    devices.value = [...devices.value, event.device];
    setSuccess('Device added successfully');
  }
  
  void _onDeviceRemoved(DeviceRemovedEvent event) {
    devices.value = devices.value
        .where((d) => d.id != event.deviceId)
        .toList();
  }
  
  void _onDeviceUpdated(DeviceUpdatedEvent event) {
    final index = devices.value.indexWhere((d) => d.id == event.device.id);
    if (index != -1) {
      final updated = [...devices.value];
      updated[index] = event.device;
      devices.value = updated;
    }
  }
  
  void _onError(ErrorEvent event) {
    setError(event.message);
  }
  
  @override
  void dispose() {
    devices.dispose();
    selectedDevice.dispose();
    super.dispose();
  }
}
```

**4.2 Pages**
```dart
// lib/presentation/pages/device_list_page.dart
class DeviceListPage extends StatefulWidget {
  const DeviceListPage({Key? key}) : super(key: key);
  
  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  late DeviceListViewModel viewModel;
  
  @override
  void initState() {
    super.initState();
    viewModel = getIt<DeviceListViewModel>();
    viewModel.initialize();
    viewModel.addListener(_onViewModelChanged);
  }
  
  void _onViewModelChanged() {
    setState(() {});
  }
  
  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    viewModel.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: viewModel.devices,
            builder: (context, devices, _) {
              if (viewModel.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (devices.isEmpty) {
                return const Center(child: Text('No devices'));
              }
              
              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return DeviceCard(
                    device: device,
                    onTap: () => viewModel.selectDevice(device),
                    onDelete: () => viewModel.deleteDevice(device.id),
                  );
                },
              );
            },
          ),
          if (viewModel.hasError)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add device page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**4.3 Widgets**
```dart
// lib/presentation/widgets/device_card.dart
class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  const DeviceCard({
    Key? key,
    required this.device,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(device.name),
        subtitle: Text('${device.type} - ${device.address}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
```

---

## 🔧 Points d'intégration clés

### 1. Application Entry Point
```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI and Database
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Connection Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DeviceListPage(),
    );
  }
}
```

### 2. Navigation Pattern
```dart
// Navigation simple avec GetIt
void navigateToDeviceDetail(BuildContext context, Device device) {
  // Créer et initialiser le ViewModel
  final viewModel = getIt<DeviceDetailViewModel>();
  viewModel.initialize(device);
  
  // Naviguer
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DeviceDetailPage(viewModel: viewModel),
    ),
  );
}
```

---

## ✅ Checklist d'implémentation détaillée

### Phase 1: CORE
- [ ] Implémenter EventBusImpl
- [ ] Implémenter ServiceLocator avec GetIt
- [ ] Créer DatabaseService
- [ ] Créer Logger
- [ ] Créer Validators
- [ ] Ajouter Constants

### Phase 2: DATABASE
- [ ] Configurer SQLite
- [ ] Créer tables
- [ ] Ajouter migrations

### Phase 3: DATA
- [ ] Implémenter DeviceLocalDataSourceImpl
- [ ] Implémenter ConnectionLocalDataSourceImpl
- [ ] Implémenter CommandLocalDataSourceImpl
- [ ] Implémenter DeviceRepositoryImpl
- [ ] Implémenter ConnectionRepositoryImpl
- [ ] Implémenter CommandRepositoryImpl

### Phase 4: DOMAIN
- [ ] Implémenter tous les UseCases

### Phase 5: PRESENTATION
- [ ] Implémenter tous les ViewModels
- [ ] Créer toutes les Pages
- [ ] Créer tous les Widgets
- [ ] Configurer la navigation

### Phase 6: TESTS & POLISH
- [ ] Tests unitaires (UseCases, Repositories)
- [ ] Tests d'intégration (E2E)
- [ ] Gestion complète d'erreurs
- [ ] Localisation
- [ ] Documentation

---

## 📦 Dépendances à ajouter

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Dependency Injection
  get_it: ^7.5.0
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.0
  
  # JSON Serialization (optional)
  json_annotation: ^4.8.0
  
  # State Management
  provider: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Testing
  mockito: ^5.4.0
  
  # Code generation
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

---

## 🎓 Bonnes pratiques

1. **Toujours utiliser Result** - Jamais d'exceptions non gérées
2. **Publier des événements** - Permettre aux composants de réagir
3. **Ré-utili DataSources** - Via les Repository Interfaces
4. **Tester en isolation** - Mock les dépendances
5. **Valider les entrées** - Dans les UseCases ou ViewModels
6. **Logging partout** - Pour le débogage et le monitoring
7. **Nommage clair** - Suivre les conventions
8. **Documentation inline** - Documenter les interfaces publiques


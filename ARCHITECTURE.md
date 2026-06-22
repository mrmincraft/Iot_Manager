# IoT Connection Manager - Architecture Documentation

## 📋 Overview

L'application **IoT Connection Manager** est une application multi-plateforme de gestion des connexions IoT, construite suivant une **Clean Architecture** avec les principes **SOLID**, **MVVM**, **Dependency Injection**, et **Event Bus**.

### Caractéristiques principales
- ✅ Fonctionnement 100% local
- ✅ Multi-plateforme (Android, Windows, Linux, macOS)
- ✅ Architecture décentralisée par feature
- ✅ Pas de dépendances externes (excepté Flutter/SQLite)

---

## 🏗️ Architecture en couches

```
┌─────────────────────────────────────────────────────┐
│           PRESENTATION LAYER (UI)                   │
│  (Pages, Views, ViewModels, Widgets)                │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│              DOMAIN LAYER (Business)                 │
│  (Entities, UseCases, Repositories Interfaces)      │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│             DATA LAYER (Persistence)                │
│  (Models, DataSources, Repository Implementations)  │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│              CORE LAYER (Foundation)                │
│  (DI, Events, Exceptions, Utils, Constants)        │
└─────────────────────────────────────────────────────┘
```

---

## 📁 Structure des dossiers

```
lib/
├── core/
│   ├── di/
│   │   ├── service_locator.dart          # Configuration Dependency Injection
│   │   └── modules/
│   │       ├── core_module.dart
│   │       ├── domain_module.dart
│   │       └── data_module.dart
│   ├── events/
│   │   ├── event_bus.dart               # Interface Event Bus
│   │   ├── app_event.dart               # Classe de base des événements
│   │   └── event_listener.dart
│   ├── exceptions/
│   │   ├── app_exception.dart           # Classe de base
│   │   ├── data_exception.dart
│   │   └── network_exception.dart
│   ├── utils/
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   └── result.dart                  # Result<T, E> pattern
│   └── constants/
│       ├── app_constants.dart
│       └── string_constants.dart
│
├── domain/
│   ├── entities/
│   │   ├── device.dart
│   │   ├── connection.dart
│   │   ├── command.dart
│   │   └── device_status.dart
│   ├── repositories/
│   │   ├── device_repository.dart       # Interface abstraite
│   │   ├── connection_repository.dart
│   │   └── command_repository.dart
│   ├── usecases/
│   │   ├── device/
│   │   │   ├── get_all_devices_usecase.dart
│   │   │   ├── add_device_usecase.dart
│   │   │   ├── update_device_usecase.dart
│   │   │   └── delete_device_usecase.dart
│   │   ├── connection/
│   │   │   ├── connect_device_usecase.dart
│   │   │   ├── disconnect_device_usecase.dart
│   │   │   └── get_connection_status_usecase.dart
│   │   └── command/
│   │       ├── send_command_usecase.dart
│   │       └── get_command_history_usecase.dart
│   └── events/
│       ├── device_connected_event.dart
│       ├── device_disconnected_event.dart
│       ├── device_added_event.dart
│       ├── device_removed_event.dart
│       └── command_executed_event.dart
│
├── data/
│   ├── datasources/
│   │   └── local/
│   │       ├── device_local_datasource.dart        # Interface
│   │       ├── device_local_datasource_impl.dart   # Implémentation
│   │       ├── connection_local_datasource.dart
│   │       └── connection_local_datasource_impl.dart
│   ├── models/
│   │   ├── device_model.dart
│   │   ├── connection_model.dart
│   │   ├── command_model.dart
│   │   └── device_status_model.dart
│   └── repositories/
│       ├── device_repository_impl.dart      # Implémentation concrète
│       ├── connection_repository_impl.dart
│       └── command_repository_impl.dart
│
└── presentation/
    ├── pages/
    │   ├── home_page.dart
    │   ├── device_list_page.dart
    │   ├── device_detail_page.dart
    │   ├── add_device_page.dart
    │   ├── connection_page.dart
    │   └── settings_page.dart
    ├── viewmodels/
    │   ├── home_viewmodel.dart
    │   ├── device_list_viewmodel.dart
    │   ├── device_detail_viewmodel.dart
    │   ├── connection_viewmodel.dart
    │   └── settings_viewmodel.dart
    ├── views/
    │   ├── device_view.dart
    │   ├── connection_view.dart
    │   └── status_view.dart
    └── widgets/
        ├── device_card.dart
        ├── connection_indicator.dart
        ├── command_button.dart
        └── status_badge.dart

main.dart                              # Point d'entrée
```

---

## 🔷 Modules principaux

### 1. **Core Module** (Foundation)
**Responsabilités:**
- Gestion de l'injection de dépendances
- Implémentation de l'Event Bus
- Gestion des exceptions globales
- Utilitaires communs (Logger, Validators, Result)
- Constantes d'application

**Interfaces principales:**
- `EventBus`: Publication/souscription aux événements
- `ServiceLocator`: Accès aux dépendances
- `Result<T, E>`: Gestion des résultats avec Either pattern

---

### 2. **Domain Module** (Business Logic)
**Responsabilités:**
- Définition des entités métier
- Interfaces des repositories (contracts)
- UseCases (orchestration métier)
- Événements métier

**Interfaces principales:**
- `DeviceRepository`: Contrats CRUD pour les appareils
- `ConnectionRepository`: Contrats de connexion
- `CommandRepository`: Contrats des commandes

**UseCases:**
- `GetAllDevicesUseCase`
- `AddDeviceUseCase`
- `ConnectDeviceUseCase`
- `SendCommandUseCase`
- etc.

---

### 3. **Data Module** (Persistence)
**Responsabilités:**
- Implémentation des repositories
- DataSources locales (SQLite)
- Conversion Models ↔ Entities

**Composants:**
- `DeviceLocalDataSource`: Accès SQLite pour les appareils
- `DeviceRepositoryImpl`: Implémentation complète
- Models: Représentation SQLite des données

---

### 4. **Presentation Module** (UI/UX)
**Responsabilités:**
- Affichage de l'interface utilisateur
- Gestion de l'état (ViewModels)
- Interaction utilisateur
- Navigation

**Architecture MVVM:**
- `Page`: Écran complet
- `ViewModel`: État + logique (réactif avec ValueNotifier)
- `View/Widget`: Composants réutilisables

---

## 🔌 Dépendances inter-couches

```
PRESENTATION
    ├─→ DOMAIN (UseCases)
    └─→ CORE (DI, Events, Exceptions)

DOMAIN
    └─→ CORE (Exceptions, Events)

DATA
    ├─→ DOMAIN (Repositories)
    └─→ CORE (Exceptions)

CORE
    (Pas de dépendances externes)
```

### Règles strictes:
✅ CORE n'a AUCUNE dépendance  
✅ DOMAIN dépend uniquement de CORE  
✅ DATA dépend de DOMAIN et CORE  
✅ PRESENTATION dépend de DOMAIN et CORE  

---

## 💡 Principes SOLID appliqués

### **S - Single Responsibility Principle**
- Chaque classe a une seule raison de changer
- `DeviceRepositoryImpl` = gestion des appareils
- `DeviceLocalDataSource` = accès SQLite

### **O - Open/Closed Principle**
- Ouvert à l'extension, fermé à la modification
- Interfaces `Repository` extensibles
- Nouveaux usecases sans modifier le code existant

### **L - Liskov Substitution Principle**
- Implémentations interchangeables des interfaces
- `DeviceRepositoryImpl` peut remplacer `DeviceRepository`

### **I - Interface Segregation Principle**
- Interfaces spécifiques et compactes
- `DeviceRepository` séparé de `ConnectionRepository`

### **D - Dependency Inversion Principle**
- Dépendre des abstractions, pas des implémentations
- `Presentation` → `DeviceRepository` (interface)
- Injection via `ServiceLocator`

---

## 📡 Event Bus Architecture

**Flux des événements:**

```
UserAction (UI)
    ↓
ViewModel.handle()
    ↓
UseCase.execute()
    ↓
Repository.operation()
    ↓
EventBus.publish(Event)
    ↓
[Listeners abonnés]
    ↓
ViewModel.onEvent() → Update State
    ↓
UI rebuild
```

**Événements principaux:**
- `DeviceConnectedEvent`
- `DeviceDisconnectedEvent`
- `DeviceAddedEvent`
- `DeviceRemovedEvent`
- `CommandExecutedEvent`
- `ErrorEvent`

---

## 🔐 Dependency Injection Pattern

**Setup au démarrage:**

```dart
// main.dart
void main() async {
  // 1. Init DI
  await setupServiceLocator();
  
  // 2. Init EventBus
  getIt<EventBus>().initialize();
  
  // 3. Init Local Storage
  await getIt<DatabaseService>().initialize();
  
  runApp(MyApp());
}
```

**Enregistrement des dépendances:**

```
ServiceLocator
├── Singletons
│   ├── EventBus
│   ├── DatabaseService
│   └── Logger
├── Repositories
│   ├── DeviceRepository (implémentation)
│   └── ConnectionRepository (implémentation)
├── UseCases
│   ├── GetAllDevicesUseCase
│   └── ...
└── ViewModels
    ├── DeviceListViewModel
    └── ...
```

---

## 🗄️ SQLite Integration

**LocalDataSource Pattern:**

```
ViewModel
    ↓ (appelle)
UseCase
    ↓ (appelle)
Repository (interface)
    ↓ (implémentée par)
RepositoryImpl
    ↓ (appelle)
LocalDataSource (interface)
    ↓ (implémentée par)
LocalDataSourceImpl
    ↓ (utilise)
SQLite Database
```

**Tables principales:**
- `devices` (id, name, type, address, status, metadata)
- `connections` (id, device_id, timestamp, status, signal_strength)
- `commands` (id, device_id, command, response, timestamp)
- `connection_logs` (id, device_id, action, timestamp)

---

## 🎯 ViewModels Architecture

**Pattern Observable:**

```dart
class DeviceListViewModel extends ChangeNotifier {
  // State
  ValueNotifier<List<Device>> devices;
  ValueNotifier<bool> isLoading;
  
  // UseCases
  GetAllDevicesUseCase getAllDevicesUseCase;
  
  // Methods
  Future<void> loadDevices();
  void onDeviceAdded(DeviceAddedEvent event);
}
```

---

## 📊 Dependency Diagram

```
┌─────────────────────────────────────┐
│        PRESENTATION                  │
│  (Pages, ViewModels, Widgets)       │
└──────────────┬──────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────┐
│        DOMAIN                        │
│  (Entities, UseCases, Repositories) │
└──────────────┬──────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────┐
│        DATA                          │
│  (Models, DataSources, Impl)        │
└──────────────┬──────────────────────┘
               │ uses
               ▼
┌─────────────────────────────────────┐
│        CORE                          │
│  (DI, Events, Utils, Exceptions)    │
└─────────────────────────────────────┘
```

---

## ✅ Checklist d'implémentation

- [ ] Configurer la structure des dossiers
- [ ] Créer les interfaces du Core (EventBus, ServiceLocator)
- [ ] Implémenter l'Event Bus
- [ ] Configurer la Dependency Injection
- [ ] Créer les entités Domain
- [ ] Créer les interfaces Repository
- [ ] Créer les UseCases
- [ ] Créer les LocalDataSources
- [ ] Implémenter les Repositories
- [ ] Créer les ViewModels
- [ ] Créer les Pages et Widgets
- [ ] Intégrer SQLite
- [ ] Tests unitaires et d'intégration
- [ ] Gestion des erreurs et logging

---

## 📚 Conventions de nommage

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Interface abstraite | Pas de préfixe | `DeviceRepository` |
| Implémentation | `...Impl` | `DeviceRepositoryImpl` |
| Cas d'usage | `...UseCase` | `GetAllDevicesUseCase` |
| ViewModel | `...ViewModel` | `DeviceListViewModel` |
| Page | `...Page` | `DevicePage` |
| Widget | `...Widget` ou `...Card` | `DeviceCard` |
| Événement | `...Event` | `DeviceConnectedEvent` |
| Exception | `...Exception` | `DeviceNotFoundException` |
| DataSource | `...DataSource` | `DeviceLocalDataSource` |
| Model | `...Model` | `DeviceModel` |

# 🚀 IoT Connection Manager - Architecture Software

## 📖 Vue d'ensemble du projet

**IoT Connection Manager** est une application mobile et desktop multi-plateforme pour la gestion complète des connexions IoT. L'application est construite selon une **Clean Architecture** rigoureuse, en respectant les principes **SOLID**, le pattern **MVVM**, et les meilleures pratiques de développement Flutter/Dart.

---

## ✨ Caractéristiques architecturales

✅ **100% Local** - Pas de serveur distant, fonctionnement complètement autonome  
✅ **Multi-plateforme** - Android, iOS, Windows, Linux, macOS  
✅ **Clean Architecture** - Séparation stricte des responsabilités  
✅ **SOLID Principles** - Code maintenable et extensible  
✅ **MVVM Pattern** - Gestion d'état réactive avec ValueNotifier  
✅ **Dependency Injection** - IoC container pour la gestion des dépendances  
✅ **Event Bus** - Communication découplée via Pub/Sub  
✅ **SQLite Persistence** - Base de données locale native  

---

## 📚 Documentation

Bienvenue dans l'architecture de IoT Connection Manager. Voici les documents clés :

### 1. 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md)
**Commencez ici pour comprendre l'architecture globale.**

Contient:
- Vue d'ensemble des 4 couches (Core, Domain, Data, Presentation)
- Structure complète des dossiers
- Modules principaux et responsabilités
- Principes SOLID appliqués
- Architecture Event Bus
- Pattern de Dependency Injection
- Intégration SQLite
- Architecture MVVM

### 2. 🔗 [DEPENDENCY_DIAGRAMS.md](DEPENDENCY_DIAGRAMS.md)
**Visualisez les relations entre composants avec des diagrammes Mermaid.**

Contient:
- 10 diagrammes complets
- Architecture en couches
- Flux des données (Data Flow)
- Dépendances des UseCases
- Cycle de vie des événements
- Pattern MVVM détaillé
- Injection de dépendances visuelle
- Règles d'architecture
- Event Bus architecture
- Schéma SQLite
- Considérations multi-plateforme

### 3. 📋 [MODULES_RESPONSIBILITIES.md](MODULES_RESPONSIBILITIES.md)
**Comprendre chaque module et ses responsabilités spécifiques.**

Détaille:
- **CORE Module**: DI, Events, Exceptions, Utils, Constants
- **DOMAIN Module**: Entities, Repositories, UseCases, Events
- **DATA Module**: Models, DataSources, Repository Implementations
- **PRESENTATION Module**: Pages, ViewModels, Views, Widgets

Pour chaque module:
- Responsabilités détaillées
- Interfaces principales
- Fichiers et structure
- Patterns et conventions

### 4. 🔐 [INTERFACES_CONTRACTS.md](INTERFACES_CONTRACTS.md)
**Spécifications détaillées de chaque interface.**

Explique:
- **ServiceLocator** - DI container
- **EventBus** - Pub/Sub system
- **AppEvent** - Base event class
- **Result type** - Error handling
- **Exceptions** - Exception hierarchy
- **Repository Interfaces** - Data access contracts
- **LocalDataSource Interfaces** - SQLite contracts
- **BaseViewModel** - MVVM base class

Pour chaque interface:
- Contrats et garanties
- Exemples d'utilisation
- Dépendances
- Implémentation suggérée

---

## 📁 Structure complète des dossiers

```
lib/
├── core/                          # Foundation Layer
│   ├── di/
│   │   ├── service_locator.dart
│   │   └── modules/
│   │       ├── core_module.dart
│   │       ├── domain_module.dart
│   │       └── data_module.dart
│   ├── events/
│   │   ├── app_event.dart
│   │   ├── event_bus.dart
│   │   └── event_listener.dart
│   ├── exceptions/
│   │   ├── app_exception.dart
│   │   └── exceptions.dart
│   ├── utils/
│   │   ├── result.dart
│   │   ├── logger.dart
│   │   └── validators.dart
│   └── constants/
│       ├── app_constants.dart
│       └── string_constants.dart
│
├── domain/                        # Business Logic Layer
│   ├── entities/
│   │   ├── device.dart
│   │   ├── connection.dart
│   │   └── command.dart
│   ├── repositories/
│   │   ├── device_repository.dart
│   │   ├── connection_repository.dart
│   │   └── command_repository.dart
│   ├── usecases/
│   │   ├── usecase.dart
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
│       └── domain_events.dart
│
├── data/                          # Persistence Layer
│   ├── datasources/
│   │   └── local/
│   │       ├── device_local_datasource.dart
│   │       ├── device_local_datasource_impl.dart
│   │       ├── connection_local_datasource.dart
│   │       ├── connection_local_datasource_impl.dart
│   │       ├── command_local_datasource.dart
│   │       └── command_local_datasource_impl.dart
│   ├── models/
│   │   ├── device_model.dart
│   │   ├── connection_model.dart
│   │   └── command_model.dart
│   └── repositories/
│       ├── device_repository_impl.dart
│       ├── connection_repository_impl.dart
│       └── command_repository_impl.dart
│
└── presentation/                  # UI Layer
    ├── pages/
    │   ├── home_page.dart
    │   ├── device_list_page.dart
    │   ├── device_detail_page.dart
    │   ├── add_device_page.dart
    │   ├── connection_page.dart
    │   └── settings_page.dart
    ├── viewmodels/
    │   ├── base_viewmodel.dart
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

main.dart                           # Application entry point
```

---

## 🎯 Principes architecturaux clés

### 1. **Séparation des couches**
Chaque couche a une responsabilité unique et bien définie:
- **CORE**: Fondations réutilisables
- **DOMAIN**: Logique métier pure
- **DATA**: Accès et persistance des données
- **PRESENTATION**: Interface utilisateur

### 2. **Flux unidirectionnel**
```
PRESENTATION → DOMAIN → DATA → CORE
```
Les dépendances ne remontent JAMAIS vers le haut.

### 3. **Inversion de contrôle (DI)**
Toutes les dépendances sont injectées via le `ServiceLocator`, jamais créées directement.

### 4. **Event Bus pour le découplage**
Les composants communiquent via événements plutôt que via des références directes.

### 5. **Pattern Result pour la gestion d'erreur**
Au lieu de lever des exceptions, les opérations retournent `Success<T>` ou `Failure<T>`.

### 6. **MVVM pour la réactivité**
Les ViewModels gèrent l'état via `ValueNotifier` et notifient les changements aux Views.

---

## 🔄 Flux de données typique

```
1. User clicks button in UI
   ↓
2. ViewModel.method() is called
   ↓
3. ViewModel sets isLoading = true
   ↓
4. UseCase.call(params) is executed
   ↓
5. UseCase calls Repository.method()
   ↓
6. Repository calls DataSource.query()
   ↓
7. DataSource queries SQLite
   ↓
8. Model is returned and converted to Entity
   ↓
9. Result<Entity> is returned through layers
   ↓
10. UseCase publishes Event via EventBus
   ↓
11. ViewModel receives Event
   ↓
12. ViewModel updates state (ValueNotifier)
   ↓
13. View observes state and rebuilds
   ↓
14. UI displays updated data
```

---

## 📝 Conventions de nommage

| Element | Convention | Example |
|---------|-----------|---------|
| Classe abstraite | Pas de préfixe | `DeviceRepository` |
| Implémentation | `...Impl` | `DeviceRepositoryImpl` |
| UseCase | `...UseCase` | `GetAllDevicesUseCase` |
| ViewModel | `...ViewModel` | `DeviceListViewModel` |
| Page | `...Page` | `DeviceListPage` |
| Widget réutilisable | `...Widget` ou `...Card` | `DeviceCard` |
| Événement | `...Event` | `DeviceConnectedEvent` |
| Exception | `...Exception` | `DeviceNotFoundException` |
| DataSource | `...DataSource` | `DeviceLocalDataSource` |
| Model | `...Model` | `DeviceModel` |

---

## 🗄️ Entités principales

### Device
Représente un appareil IoT connecté.
- Propriétés: id, name, type, address, status, metadata
- Opérations: Ajouter, mettre à jour, supprimer, rechercher

### Connection
Représente une session de connexion.
- Propriétés: id, deviceId, status, signalStrength, timestamps
- Opérations: Établir, interrompre, logger l'historique

### Command
Représente une commande envoyée à un device.
- Propriétés: id, deviceId, commandType, parameters, status
- Opérations: Envoyer, tracker l'exécution, logger

---

## 🔧 Décisions d'architecture

### Pourquoi Clean Architecture?
- Indépendance par rapport aux frameworks
- Testabilité maximale
- Maintenabilité à long terme
- Évolutivité facile

### Pourquoi Event Bus?
- Découplage entre composants
- Communication réactive
- Facilite la diffusion des changements
- Permet les interactions cross-module

### Pourquoi MVVM?
- Séparation claire entre logique et UI
- Réactivité naturelle avec Flutter
- État centralisé et observable
- Testabilité de la logique

### Pourquoi Result Pattern?
- Gestion explicite des erreurs
- Pas d'exceptions non gérées
- Code plus prédictible
- Facilite la localisation des messages d'erreur

### Pourquoi SQLite local?
- Fonctionnement complètement offline
- Pas de dépendance à un serveur
- Performance optimale
- Confidentialité des données

---

## ✅ Checklist pour démarrer l'implémentation

- [ ] Configurer les dossiers selon la structure
- [ ] Implémenter les interfaces CORE
- [ ] Implémenter l'Event Bus
- [ ] Configurer la Dependency Injection
- [ ] Créer les Entities
- [ ] Créer les Repository Interfaces
- [ ] Créer les UseCases
- [ ] Créer les LocalDataSources
- [ ] Implémenter les Repositories
- [ ] Intégrer SQLite
- [ ] Créer les ViewModels
- [ ] Créer les Pages et Widgets
- [ ] Implémenter la navigation
- [ ] Ajouter la gestion d'erreur complète
- [ ] Ajouter la validation
- [ ] Tests unitaires
- [ ] Tests d'intérogration
- [ ] Documentation du code

---

## 🔗 Dépendances suggérées

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # DI Container
  get_it: ^latest
  
  # SQLite
  sqflite: ^latest
  
  # JSON Serialization
  json_annotation: ^latest
  
  # State Management (optional, for testing)
  provider: ^latest

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^latest
  build_runner: ^latest
  json_serializable: ^latest
```

---

## 📞 Support et questions

Pour des questions spécifiques:
1. Consultez le document pertinent dans la documentation
2. Cherchez le diagramme Mermaid correspondant
3. Vérifiez les exemples d'utilisation dans INTERFACES_CONTRACTS.md

---

## 📈 Évolution future

L'architecture est conçue pour supporter:
- Ajout de nouvelles features sans modification du core
- Échange des implementations (ex: DataBase change)
- Ajout de nouvelles platforms
- Augmentation de la complexité métier

---

**Dernier mis à jour:** 2026-06-22  
**Version:** 1.0.0  
**Architecture:** Clean Architecture + MVVM + SOLID  


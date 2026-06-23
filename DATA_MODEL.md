# Data Model Documentation - IoT Manager

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture en couches](#architecture-en-couches)
3. [Entités métier](#entités-métier)
4. [Relationships](#relationships)
5. [DTOs et Mappage](#dtos-et-mappage)
6. [Modèles SQLite](#modèles-sqlite)
7. [Repositories](#repositories)
8. [Flux de données](#flux-de-données)
9. [Bonnes pratiques](#bonnes-pratiques)

---

## Vue d'ensemble

Le modèle de données IoT Manager est construit selon une **architecture en couches** (Clean Architecture) avec séparation claire entre :
- **Entités métier** (Domain Layer)
- **DTOs** (Presentation Layer)
- **Modèles SQLite** (Data Layer)
- **Repositories** (Abstraction Layer)

### Entités Principales

| Entité | Description | Relations |
|--------|-------------|-----------|
| **Protocol** | Définition des protocoles IoT | 1-to-N avec Connection |
| **Certificate** | Certificats SSL/TLS | 1-to-N avec Connection |
| **Connection** | Connexion IoT active | 1-to-N avec Topic, Message |
| **Topic** | Sujet/Canal de communication | 1-to-N avec Message |
| **Message** | Message reçu/envoyé | N-to-1 avec Topic |
| **UserSettings** | Paramètres utilisateur | 1-to-1 par utilisateur |
| **Dashboard** | Tableau de bord monitoring | 1-to-N avec DashboardWidget |
| **LogEntry** | Entrée de log/événement | Relations optionnelles |

---

## Architecture en couches

```
┌─────────────────────────────────────────────────────┐
│ PRESENTATION LAYER (DTOs)                           │
│ - ProtocolDTO, ConnectionDTO, etc.                  │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│ DOMAIN LAYER (Entities)                             │
│ - Protocol, Connection, Topic, Message, etc.        │
│ - Repository Interfaces                             │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│ DATA LAYER (Models & Repositories)                  │
│ - ProtocolModel, ConnectionModel, etc. (SQLite)     │
│ - Repository Implementations                        │
│ - LocalDataSources                                  │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│ DATABASE LAYER (SQLite)                             │
│ - Tables, Indexes, Triggers, Views                  │
└─────────────────────────────────────────────────────┘
```

---

## Entités métier

### 1. Protocol (Entité racine)

**Responsabilité:** Définir les protocoles de communication disponibles (MQTT, HTTP, CoAP, Modbus)

```dart
class Protocol {
  final String id;
  final String name;
  final ProtocolType type;
  final String description;
  final int defaultPort;
  final bool requiresAuthentication;
  final List<String> supportedFeatures;
  final String? documentation;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum ProtocolType { mqtt, http, coap, modbus, unknown }
```

**Invariants métier:**
- Le nom doit être unique
- Le port doit être entre 1 et 65535
- Le type doit être parmi les protocoles supportés

---

### 2. Certificate (Entité racine)

**Responsabilité:** Gérer les certificats SSL/TLS pour les connexions sécurisées

```dart
class Certificate {
  final String id;
  final String name;
  final CertificateType type;
  final CertificateFormat format;
  final String content;
  final String? password;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? thumbprint;
  final bool isValid;
  final String? issuer;
  final String? subject;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum CertificateType { ca, client, server }
enum CertificateFormat { pem, der, p12 }
```

**Propriétés calculées:**
- `isExpired`: Vérifie si le certificat est expiré
- `isActiveAndValid`: Vérifie si valide et non expiré
- `daysUntilExpiry`: Nombre de jours avant expiration

---

### 3. Connection (Entité racine)

**Responsabilité:** Représenter une connexion IoT active

```dart
class Connection {
  final String id;
  final String name;
  final String protocolId;
  final String host;
  final int port;
  final ConnectionStatus status;
  final bool useTLS;
  final String? certificateId;
  final String? username;
  final String? password;
  final Map<String, String> customSettings;
  final int reconnectAttempts;
  final int reconnectIntervalSeconds;
  final bool autoReconnect;
  final String? lastError;
  final DateTime? lastConnectedAt;
  final DateTime? lastDisconnectedAt;
  final int connectionDurationSeconds;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum ConnectionStatus { active, inactive, connecting, error, disconnected }
```

**Relations:**
- ⟵ N `Topics`
- ⟵ N `Messages`
- ⟶ 1 `Protocol` (FK)
- ⟶ 1 `Certificate` (FK, nullable)

---

### 4. Topic (Entité dépendante)

**Responsabilité:** Représenter un topic/canal de communication

```dart
class Topic {
  final String id;
  final String connectionId;
  final String name;
  final String path;
  final TopicQos qos;
  final bool retain;
  final bool subscribed;
  final String? description;
  final Map<String, String> metadata;
  final int messageCount;
  final DateTime? lastMessageAt;
  final int messageRatePerSecond;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum TopicQos { atMostOnce, atLeastOnce, exactlyOnce }
```

**Relations:**
- ⟵ N `Messages`
- ⟶ 1 `Connection` (FK)

**Contrainte unique:** (connectionId, path)

---

### 5. Message (Entité dépendante)

**Responsabilité:** Représenter les messages reçus/envoyés

```dart
class Message {
  final String id;
  final String topicId;
  final String connectionId;
  final MessageDirection direction;
  final MessageType type;
  final String payload;
  final int payloadSize;
  final Map<String, String> properties;
  final String? senderIdentifier;
  final String? receiverIdentifier;
  final bool processed;
  final String? processingError;
  final DateTime timestamp;
  final DateTime receivedAt;
}

enum MessageDirection { incoming, outgoing }
enum MessageType { text, json, binary, xml }
```

**Relations:**
- ⟶ 1 `Topic` (FK)
- ⟶ 1 `Connection` (FK)

---

### 6. UserSettings (Entité de configuration)

**Responsabilité:** Stocker les préférences utilisateur

```dart
class UserSettings {
  final String id;
  final String userId;
  final ThemeMode themeMode;
  final String language;
  final bool enableNotifications;
  final bool enableAutoStart;
  final bool enableErrorReporting;
  final LogLevel logLevel;
  final int logRetentionDays;
  final bool enableLocalEncryption;
  final String? encryptionKey;
  final int messageHistoryLimit;
  final bool enableMessageFiltering;
  final Map<String, dynamic> uiPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum ThemeMode { light, dark, system }
enum LogLevel { debug, info, warning, error, critical }
```

---

### 7. Dashboard (Entité de présentation)

**Responsabilité:** Gérer les tableaux de bord personnalisés

```dart
class DashboardWidget {
  final String id;
  final WidgetType type;
  final String title;
  final String? connectionId;
  final String? topicId;
  final int position;
  final int width;
  final int height;
  final Map<String, dynamic> configuration;
}

class Dashboard {
  final String id;
  final String name;
  final String? description;
  final DashboardLayout layout;
  final List<DashboardWidget> widgets;
  final bool isDefault;
  final bool isActive;
  final int refreshIntervalSeconds;
  final Map<String, dynamic> layoutSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum WidgetType { chart, gauge, table, log, status, custom }
enum DashboardLayout { grid, list, custom }
```

**Relations:**
- ⟵ N `DashboardWidget`

---

### 8. LogEntry (Entité de log)

**Responsabilité:** Enregistrer les événements système

```dart
class LogEntry {
  final String id;
  final LogSeverity severity;
  final LogCategory category;
  final String message;
  final String? details;
  final String? stackTrace;
  final String? userId;
  final String? connectionId;
  final String? topicId;
  final Map<String, dynamic> metadata;
  final bool isResolved;
  final String? resolutionNotes;
  final DateTime timestamp;
  final DateTime? resolvedAt;
}

enum LogSeverity { debug, info, warning, error, critical }
enum LogCategory { connection, message, device, system, security, performance }
```

---

## Relationships

### Diagramme des relations

```
┌──────────────┐
│  Protocols   │
└──────┬───────┘
       │ 1
       │ (protocolId)
       │ N
┌──────▼────────────┐         ┌──────────────────┐
│  Connections      │◄────────┤  Certificates    │
└──────┬─────┬──────┘         └──────────────────┘
       │     │1-N                   1-N
       │     │                       (certificateId)
       │     │ N
       │     └──────────┐
       │                │
┌──────▼───────────┐    │    ┌──────────────────┐
│  Topics           │    │    │  Dashboard       │
│  (connectionId)   │    │    └──────┬───────────┘
└──────┬───────────┘    │           │
       │                │           │ 1-N
       │ 1-N            │           │
       │                │    ┌──────▼──────────┐
┌──────▼───────────┐    │    │DashboardWidgets │
│  Messages         │    │    └──────────────────┘
│  (topicId)        │    │
│  (connectionId)   │    │
└───────────────────┘    │
                         │
                    ┌────▼────────────┐
                    │  UserSettings   │
                    └─────────────────┘

                    ┌──────────────────┐
                    │  LogEntries      │
                    │  (optional refs) │
                    └──────────────────┘
```

### Contraintes de référence

| De | À | Type | Comportement |
|----|---|------|--------------|
| Connection | Protocol | N-to-1 | RESTRICT (ne pas supprimer les protocoles actifs) |
| Connection | Certificate | N-to-1 | SET NULL |
| Topic | Connection | N-to-1 | CASCADE |
| Message | Topic | N-to-1 | CASCADE |
| Message | Connection | N-to-1 | CASCADE |
| DashboardWidget | Dashboard | N-to-1 | CASCADE |
| DashboardWidget | Connection | N-to-1 | SET NULL |
| DashboardWidget | Topic | N-to-1 | SET NULL |
| LogEntry | Connection | N-to-1 | SET NULL |
| LogEntry | Topic | N-to-1 | SET NULL |

---

## DTOs et Mappage

### Objectif des DTOs

Les DTOs (Data Transfer Objects) servent à transférer les données entre les couches:
- **De la BD vers la Présentation**: Conversion Model → Entity → DTO
- **De la Présentation vers la BD**: Conversion DTO → Entity → Model

### Exemple: ProtocolDTO

```dart
class ProtocolDTO {
  final String id;
  final String name;
  final String type; // String au lieu d'enum
  final String description;
  // ... autres champs
  
  factory ProtocolDTO.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### Flux de conversion

```
API JSON
    ↓
ProtocolDTO.fromJson()
    ↓
MapperToEntity()
    ↓
Protocol (Entity)
    ↓
Repository (business logic)
    ↓
MapperToModel()
    ↓
ProtocolModel (SQLite)
    ↓
Database
```

---

## Modèles SQLite

### Stockage des données complexes

Les types complexes (List, Map, enums) sont sérialisés en JSON:

```dart
// Entity
Protocol(
  supportedFeatures: ['publish', 'subscribe', 'retain'],
  // ...
)

// Model (stored in DB)
ProtocolModel(
  supportedFeatures: '["publish", "subscribe", "retain"]',
  // ...
)
```

### Conversion booléenne

SQLite n'a pas de type booléen; les booléens sont stockés comme:
- `0` = false
- `1` = true

```dart
// Model
model.requiresAuthentication = true;

// Database
requiresAuthentication = 1;

// Conversion
bool value = (databaseValue as int) == 1;
```

---

## Repositories

### Pattern Repository

```
┌─ Repository Interface (Domain Layer)
│  abstract class ProtocolRepository {
│    Future<Result<Protocol, Exception>> getProtocolById(String id);
│  }
│
├─ Repository Implementation (Data Layer)
│  class ProtocolRepositoryImpl implements ProtocolRepository {
│    Future<Result<Protocol, Exception>> getProtocolById(String id) async {
│      try {
│        final model = await _localDataSource.getProtocolById(id);
│        return Result.success(_mapModelToEntity(model));
│      } catch (e) {
│        return Result.failure(e);
│      }
│    }
│  }
│
└─ LocalDataSource (Data Layer)
   abstract class ProtocolLocalDataSource {
     Future<ProtocolModel> getProtocolById(String id);
   }
```

### Result Pattern

Utilisé pour le error handling:

```dart
// Success
Result<Protocol, Exception>.success(protocol)
// ou
result.value (si success)

// Failure
Result<Protocol, Exception>.failure(exception)
// ou
result.error (si failure)

// Check
if (result.isSuccess) { ... }
if (result.isFailure) { ... }
```

---

## Flux de données

### Exemple: Récupérer une connexion

```
1. Presentation Layer (ViewModel)
   └─> connectionRepository.getConnectionById(id)

2. Domain Layer (Repository Interface)
   └─> ConnectionRepository.getConnectionById(id)

3. Data Layer (Repository Implementation)
   └─> connectionLocalDataSource.getConnectionById(id)

4. Data Layer (SQLite)
   SELECT * FROM connections WHERE id = ?

5. Conversion (Model → Entity)
   ConnectionModel → Connection

6. Return Result<Connection, Exception>
```

### Cas d'erreur

```
Database Error
    ↓
LocalDataSource (re-throws)
    ↓
Repository catches Exception
    ↓
Result.failure(exception)
    ↓
ViewModel handles error
```

---

## Bonnes pratiques

### ✅ À faire

1. **Toujours utiliser le Result pattern**
   ```dart
   Future<Result<Protocol, Exception>> getProtocol(String id) async {
     try {
       final model = await _dataSource.getProtocolById(id);
       return Result.success(_mapModelToEntity(model));
     } catch (e) {
       return Result.failure(e as Exception);
     }
   }
   ```

2. **Valider les données au niveau entity**
   ```dart
   class Connection {
     Connection({...}) {
       _validate(); // Lance ValidationException si invalide
     }
   }
   ```

3. **Utiliser copyWith pour les modifications**
   ```dart
   final updated = connection.copyWith(status: ConnectionStatus.active);
   ```

4. **Implémenter == et hashCode**
   ```dart
   @override
   bool operator ==(Object other) =>
       identical(this, other) ||
       other is Connection && runtimeType == other.runtimeType && id == other.id;

   @override
   int get hashCode => id.hashCode;
   ```

### ❌ À éviter

1. **Ne pas bypasser les repositories**
   - Toujours passer par le repository, même pour une lecture simple

2. **Ne pas mélanger les couches**
   - Ne pas utiliser les Models dans le Domain Layer
   - Ne pas utiliser les Entities directement en BD

3. **Ne pas oublier de mapper**
   - Toujours convertir entre Model ↔ Entity

4. **Ne pas stocker les secrets en clair**
   - Chiffrer les mots de passe et clés avant stockage

---

## Schéma SQL

Voir le fichier `SQL_SCHEMA.sql` pour le schéma complet avec:
- Définitions de toutes les tables
- Indexes pour performance
- Contraintes d'intégrité
- Triggers pour cascade
- Vues utiles pour les requêtes complexes

---

## Évolution future

### Prochaines étapes

1. **Versionning**: Ajouter des migrations de schéma
2. **Encryption**: Chiffrement des données sensibles
3. **Sync**: Synchronisation avec serveur distant
4. **Offline mode**: Gestion du mode hors ligne
5. **Audit**: Piste d'audit des modifications

---

**Document généré**: 2026-06-22
**Version du modèle**: 1.0

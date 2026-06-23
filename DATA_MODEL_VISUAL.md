# IoT Manager - Data Model Visual Reference

## 🏗️ Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION                             │
│  ViewModels, Pages, Widgets (Consume DTOs & Results)       │
└─────────────────────────────────────────────────────────────┘
                           ↓ / ↑
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN                                 │
│  Entities (business logic, validation, invariants)         │
│  Repository Interfaces (contracts)                         │
│  Use Cases                                                 │
└─────────────────────────────────────────────────────────────┘
                           ↓ / ↑
┌─────────────────────────────────────────────────────────────┐
│                       DATA                                  │
│  DTOs (JSON serialization)                                 │
│  Repository Implementations                                │
│  LocalDataSource Interfaces                               │
│  Models (SQLite conversion)                                │
└─────────────────────────────────────────────────────────────┘
                           ↓ / ↑
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE                                 │
│  SQLite (Tables, Indexes, Triggers, Views)                │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Data Flow Examples

### Create Connection Flow

```
ViewModel/Page
    │ 
    ├─ Create: Connection(name, protocolId, host, port, ...)
    │          [Validation happens in Entity constructor]
    │
    └─→ connectionRepository.createConnection(connection)
        │
        ├─→ ConnectionRepositoryImpl
        │   │
        │   ├─ Map: Connection → ConnectionModel
        │   │   [Convert enums to strings, collections to JSON]
        │   │
        │   └─→ connectionLocalDataSource.createConnection(model)
        │       │
        │       └─→ INSERT INTO connections VALUES (...)
        │           [SQLite stores strings, ints, bools as 0/1]
        │
        └─← Result.success(connection)
            [Or Result.failure(exception)]
```

### Fetch with Related Data

```
Topic (with Connection, Message)
    │
    └─→ topicRepository.getTopicById(topicId)
        │
        ├─→ topicLocalDataSource.getTopicById(topicId)
        │   └─→ SELECT * FROM topics WHERE id = ?
        │       [Returns TopicModel with JSON metadata]
        │
        ├─ Map TopicModel → Topic Entity
        │   [Parse JSON, convert enums]
        │
        ├─→ Also fetch: Connection, related Messages
        │   [Separate queries or JOIN based on datasource)
        │
        └─← Result.success(Topic with enriched data)
```

---

## 🗂️ File Organization

```
lib/
├── domain/
│   ├── entities/
│   │   ├── protocol.dart           ← Enum: ProtocolType
│   │   ├── certificate.dart        ← Enums: CertificateType, Format
│   │   ├── connection.dart         ← Enum: ConnectionStatus
│   │   ├── topic.dart              ← Enum: TopicQos
│   │   ├── message.dart            ← Enums: MessageDirection, Type
│   │   ├── user_settings.dart      ← Enums: ThemeMode, LogLevel
│   │   ├── dashboard.dart          ← Enums: WidgetType, DashboardLayout
│   │   └── log_entry.dart          ← Enums: LogSeverity, LogCategory
│   │
│   └── repositories/
│       ├── protocol_repository.dart
│       ├── certificate_repository.dart
│       ├── topic_repository.dart
│       ├── message_repository.dart
│       ├── user_settings_repository.dart
│       ├── dashboard_repository.dart
│       └── log_repository.dart
│
├── data/
│   ├── dtos/
│   │   ├── protocol_dto.dart
│   │   ├── certificate_dto.dart
│   │   ├── topic_dto.dart
│   │   ├── message_dto.dart
│   │   ├── user_settings_dto.dart
│   │   ├── dashboard_dto.dart
│   │   └── log_entry_dto.dart
│   │
│   ├── models/
│   │   ├── protocol_model.dart
│   │   ├── certificate_model.dart
│   │   ├── topic_model.dart
│   │   ├── message_model.dart
│   │   ├── user_settings_model.dart
│   │   ├── dashboard_model.dart
│   │   └── log_entry_model.dart
│   │
│   ├── datasources/
│   │   └── local/
│   │       ├── protocol_local_datasource.dart
│   │       ├── certificate_local_datasource.dart
│   │       ├── topic_local_datasource.dart
│   │       ├── message_local_datasource.dart
│   │       ├── user_settings_local_datasource.dart
│   │       ├── dashboard_local_datasource.dart
│   │       └── log_local_datasource.dart
│   │
│   └── repositories/
│       └── impl/
│           ├── protocol_repository_impl.dart
│           ├── certificate_repository_impl.dart
│           ├── topic_repository_impl.dart
│           ├── message_repository_impl.dart
│           ├── user_settings_repository_impl.dart
│           ├── dashboard_repository_impl.dart
│           └── log_repository_impl.dart
│
└── SQL_SCHEMA.sql, DATA_MODEL.md, DATA_MODEL_INDEX.md
```

---

## 🔑 Entity Details

### 1️⃣ Protocol

```dart
class Protocol {
  final String id;
  final String name;                          // Unique
  final ProtocolType type;                    // mqtt|http|coap|modbus|unknown
  final String description;
  final int defaultPort;                      // 1-65535
  final bool requiresAuthentication;
  final List<String> supportedFeatures;       // JSON array
  final String? documentation;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Relations**: 1 → N Connections

---

### 2️⃣ Certificate

```dart
class Certificate {
  final String id;
  final String name;                          // Unique
  final CertificateType type;                 // ca|client|server
  final CertificateFormat format;             // pem|der|p12
  final String content;
  final String? password;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? thumbprint;                   // Unique
  final bool isValid;
  
  // Computed properties
  bool get isExpired { ... }
  bool get isActiveAndValid { ... }
  int? get daysUntilExpiry { ... }
}
```

**Relations**: 1 → N Connections

---

### 3️⃣ Connection

```dart
class Connection {
  final String id;
  final String name;                          // Unique
  final String protocolId;                    // FK → Protocol
  final String host;
  final int port;                             // 1-65535
  final ConnectionStatus status;              // active|inactive|connecting|error|disconnected
  final bool useTLS;
  final String? certificateId;                // FK → Certificate (nullable)
  final String? username;
  final String? password;
  final Map<String, String> customSettings;   // JSON
  final int reconnectAttempts;                // ≥ 0
  final int reconnectIntervalSeconds;         // ≥ 1
  final bool autoReconnect;
  final String? lastError;
  final DateTime? lastConnectedAt;
  final DateTime? lastDisconnectedAt;
  final int connectionDurationSeconds;        // ≥ 0
  final bool isEnabled;
  
  // Computed properties
  bool get isActive { ... }
  bool get isConnecting { ... }
}
```

**Relations**: N ← Protocol, N ← Certificate, 1 → N Topics, 1 → N Messages

---

### 4️⃣ Topic

```dart
class Topic {
  final String id;
  final String connectionId;                  // FK → Connection
  final String name;
  final String path;                          // Unique per connection
  final TopicQos qos;                         // atMostOnce|atLeastOnce|exactlyOnce
  final bool retain;
  final bool subscribed;
  final String? description;
  final Map<String, String> metadata;         // JSON
  final int messageCount;                     // ≥ 0
  final DateTime? lastMessageAt;
  final int messageRatePerSecond;
  
  // Unique constraint: (connectionId, path)
}
```

**Relations**: N ← Connection, 1 → N Messages

---

### 5️⃣ Message

```dart
class Message {
  final String id;
  final String topicId;                       // FK → Topic
  final String connectionId;                  // FK → Connection
  final MessageDirection direction;           // incoming|outgoing
  final MessageType type;                     // text|json|binary|xml
  final String payload;
  final int payloadSize;                      // ≥ 0
  final Map<String, String> properties;       // JSON
  final String? senderIdentifier;
  final String? receiverIdentifier;
  final bool processed;
  final String? processingError;
  final DateTime timestamp;
  final DateTime receivedAt;
}
```

**Relations**: N ← Topic, N ← Connection

---

### 6️⃣ UserSettings

```dart
class UserSettings {
  final String id;
  final String userId;                        // Unique
  final ThemeMode themeMode;                  // light|dark|system
  final String language;
  final bool enableNotifications;
  final bool enableAutoStart;
  final bool enableErrorReporting;
  final LogLevel logLevel;                    // debug|info|warning|error|critical
  final int logRetentionDays;                 // ≥ 1
  final bool enableLocalEncryption;
  final String? encryptionKey;
  final int messageHistoryLimit;              // ≥ 100
  final bool enableMessageFiltering;
  final Map<String, dynamic> uiPreferences;   // JSON
}
```

**Relations**: 1 per userId

---

### 7️⃣ Dashboard

```dart
class DashboardWidget {
  final String id;
  final WidgetType type;                      // chart|gauge|table|log|status|custom
  final String title;
  final String? connectionId;                 // FK → Connection (nullable)
  final String? topicId;                      // FK → Topic (nullable)
  final int position;                         // ≥ 0
  final int width;                            // > 0
  final int height;                           // > 0
  final Map<String, dynamic> configuration;   // JSON
}

class Dashboard {
  final String id;
  final String name;                          // Unique
  final String? description;
  final DashboardLayout layout;               // grid|list|custom
  final List<DashboardWidget> widgets;
  final bool isDefault;
  final bool isActive;
  final int refreshIntervalSeconds;           // ≥ 1
  final Map<String, dynamic> layoutSettings;  // JSON
}
```

**Relations**: 1 → N DashboardWidgets, N ← Connection (optional), N ← Topic (optional)

---

### 8️⃣ LogEntry

```dart
class LogEntry {
  final String id;
  final LogSeverity severity;                 // debug|info|warning|error|critical
  final LogCategory category;                 // connection|message|device|system|security|performance
  final String message;
  final String? details;
  final String? stackTrace;
  final String? userId;
  final String? connectionId;                 // FK → Connection (optional)
  final String? topicId;                      // FK → Topic (optional)
  final Map<String, dynamic> metadata;        // JSON
  final bool isResolved;
  final String? resolutionNotes;
  final DateTime timestamp;
  final DateTime? resolvedAt;
  
  // Computed property
  bool get isCritical { ... }
}
```

**Relations**: Optional references to Connection and Topic

---

## 📊 Database Schema Overview

### Tables (9 total)

| # | Table | Rows | Purpose |
|---|-------|------|---------|
| 1 | protocols | ~10 | Configuration statique |
| 2 | certificates | ~50 | Stockage persistant |
| 3 | connections | ~100 | Connexions actives |
| 4 | topics | ~1000 | Topics par connexion |
| 5 | messages | ~100000 | Messages (purgeable) |
| 6 | user_settings | ~1 | Paramètres utilisateur |
| 7 | dashboards | ~5 | Tableaux de bord |
| 8 | dashboard_widgets | ~50 | Widgets des dashboards |
| 9 | log_entries | ~50000 | Logs (purgeable) |

### Indexes (20+)

Optimisent les requêtes fréquentes:
- Clés étrangères
- Colonnes de filtrage (status, severity, qos, etc.)
- Colonnes de tri (timestamp, lastMessageAt, etc.)
- Recherche (path, name)

### Triggers (4)

Maintiennent la cohérence:
- Mise à jour de `updatedAt` automatique
- Cascade delete en cascade

### Vues (4)

Facilitent les requêtes complexes:
- Connexions actives avec stats
- Topics avec dernier message
- Logs non résolus
- Statistiques par catégorie

---

## 🔄 Conversion Examples

### Entity → Model → JSON

```
Protocol Entity
├─ id: "proto-1"
├─ name: "MQTT"
├─ type: ProtocolType.mqtt
└─ supportedFeatures: ["publish", "subscribe"]

         ↓ (toMap)

ProtocolModel
├─ id: "proto-1"
├─ name: "MQTT"
├─ type: "mqtt"        ← String
└─ supportedFeatures: "[\"publish\", \"subscribe\"]"  ← JSON string

         ↓ (SQLite)

Database
├─ id: 'proto-1'
├─ name: 'MQTT'
├─ type: 'mqtt'
└─ supportedFeatures: '["publish", "subscribe"]'

         ↓ (fromJson)

DTO
├─ id: "proto-1"
├─ name: "MQTT"
├─ type: "mqtt"
└─ supportedFeatures: ["publish", "subscribe"]
```

---

## ✨ Special Features

### Computed Properties

```dart
// Certificate
certificate.isExpired              // true if validUntil < now
certificate.isActiveAndValid       // true if valid && !isExpired
certificate.daysUntilExpiry        // 30

// Connection
connection.isActive                // status == active
connection.isConnecting            // status == connecting

// LogEntry
logEntry.isCritical                // severity == error || critical
```

### Copy Methods

All entities have `copyWith()` for immutable updates:

```dart
final updated = connection.copyWith(
  status: ConnectionStatus.active,
  lastConnectedAt: DateTime.now(),
);
```

### Equality & Hash

All entities implement `==` and `hashCode` for collections:

```dart
connections.contains(connection)   // Works correctly
Set<Connection>                     // Can be used in sets
Map<String, Connection>             // Can be used as map keys
```

---

## 🎓 Best Practices Implemented

✅ **Clean Architecture** - Strict layer separation
✅ **Repository Pattern** - Abstract data access
✅ **DTO Pattern** - Safe serialization
✅ **Result Pattern** - Functional error handling
✅ **Mapper Pattern** - Type conversions
✅ **Immutability** - copyWith for updates
✅ **Validation** - Entity constructor validation
✅ **Type Safety** - Enums instead of strings
✅ **Database Integrity** - Constraints, indexes, triggers
✅ **Performance** - Strategic indexes and views

---

## 📖 Reading Guide

1. Start with **DATA_MODEL.md** for conceptual understanding
2. Review **DATA_MODEL_INDEX.md** for file structure
3. Check **SQL_SCHEMA.sql** for database design
4. Reference entity files for implementation details
5. Study repository implementations for patterns

---

**Created**: 2026-06-22  
**Model Version**: 1.0  
**Status**: Ready for LocalDataSource Implementation

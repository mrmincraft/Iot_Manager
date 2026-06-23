# IoT Manager - Modèle de Données Complet

## 📌 Résumé de la conception

Ce document fournit un index complet du modèle de données implémenté pour l'application IoT Manager.

---

## 📁 Structure des fichiers créés

### Domain Layer - Entités métier

```
lib/domain/entities/
├── protocol.dart              # Protocoles IoT (MQTT, HTTP, CoAP, Modbus)
├── certificate.dart           # Certificats SSL/TLS
├── connection.dart            # Connexions IoT (déjà existant)
├── topic.dart                 # Topics/Canaux de communication
├── message.dart               # Messages reçus/envoyés
├── user_settings.dart         # Paramètres utilisateur
├── dashboard.dart             # Tableaux de bord + widgets
└── log_entry.dart            # Entrées de log système
```

### Domain Layer - Repository Interfaces

```
lib/domain/repositories/
├── protocol_repository.dart
├── certificate_repository.dart
├── connection_repository.dart   # (peut être existant)
├── topic_repository.dart
├── message_repository.dart
├── user_settings_repository.dart
├── dashboard_repository.dart
└── log_repository.dart
```

### Data Layer - DTOs

```
lib/data/dtos/
├── protocol_dto.dart
├── certificate_dto.dart
├── connection_dto.dart
├── topic_dto.dart
├── message_dto.dart
├── user_settings_dto.dart
├── dashboard_dto.dart
└── log_entry_dto.dart
```

### Data Layer - SQLite Models

```
lib/data/models/
├── protocol_model.dart
├── certificate_model.dart
├── connection_model.dart        # (peut être existant)
├── topic_model.dart
├── message_model.dart
├── user_settings_model.dart
├── dashboard_model.dart
└── log_entry_model.dart
```

### Data Layer - LocalDataSource Interfaces

```
lib/data/datasources/local/
├── protocol_local_datasource.dart
├── certificate_local_datasource.dart
├── connection_local_datasource.dart  # (peut être existant)
├── topic_local_datasource.dart
├── message_local_datasource.dart
├── user_settings_local_datasource.dart
├── dashboard_local_datasource.dart
└── log_local_datasource.dart
```

### Data Layer - Repository Implementations

```
lib/data/repositories/impl/
├── protocol_repository_impl.dart
├── certificate_repository_impl.dart
├── connection_repository_impl.dart    # (peut être existant)
├── topic_repository_impl.dart
├── message_repository_impl.dart
├── user_settings_repository_impl.dart
├── dashboard_repository_impl.dart
└── log_repository_impl.dart
```

### Database Schema

```
/
├── SQL_SCHEMA.sql               # Schéma SQLite complet
└── DATA_MODEL.md                # Documentation du modèle
```

---

## 📊 Entités et relations

### Entités principales

| Entité | Type | Clé primaire | Relations |
|--------|------|--------------|-----------|
| **Protocol** | Racine | id (TEXT) | 1-to-N Connection |
| **Certificate** | Racine | id (TEXT) | 1-to-N Connection |
| **Connection** | Racine | id (TEXT) | 1-to-N Topic, 1-to-N Message |
| **Topic** | Dépendante | id (TEXT) | 1-to-N Message, N-to-1 Connection |
| **Message** | Dépendante | id (TEXT) | N-to-1 Topic, N-to-1 Connection |
| **UserSettings** | Config | id (TEXT) | 1-to-1 User |
| **Dashboard** | Présentation | id (TEXT) | 1-to-N DashboardWidget |
| **LogEntry** | Log | id (TEXT) | Relations optionnelles |

### Cardinalité

```
Protocol        1 ──────────── N    Connection
                                        │
Certificate     1 ──────────── N    Connection ──── N    Topic
                                        │                   │
                                        └──────────────── N Message

Dashboard      1 ──────────── N    DashboardWidget

UserSettings   1:1 per User

LogEntry       Many per System
```

---

## 🗄️ Tables SQLite

### Tables créées

1. **protocols** - Définition des protocoles
2. **certificates** - Certificats SSL/TLS
3. **connections** - Connexions IoT
4. **topics** - Topics/Canaux
5. **messages** - Messages reçus/envoyés
6. **user_settings** - Paramètres utilisateur
7. **dashboards** - Tableaux de bord
8. **dashboard_widgets** - Widgets des dashboards
9. **log_entries** - Logs du système

### Indexes

Total de **20+ indexes** pour optimiser les requêtes fréquentes:
- Index sur clés étrangères
- Index sur colonnes de filtrage
- Index composites pour recherches complexes

### Triggers

- `tr_connections_update_timestamp` - Mise à jour du timestamp
- `tr_topics_update_timestamp` - Mise à jour du timestamp
- `tr_topics_delete_cascade` - Suppression en cascade
- `tr_connections_delete_cascade` - Suppression en cascade

### Vues

- `v_active_connections_stats` - Connexions actives avec stats
- `v_topics_with_last_message` - Topics avec dernier message
- `v_unresolved_logs` - Logs non résolus
- `v_log_statistics_by_category` - Stats par catégorie

---

## 🔄 Flux de données

### Couches et responsabilités

```
┌─ PRESENTATION (DTOs)
│  - Serialization/Deserialization JSON
│  - Validation basique
│
├─ DOMAIN (Entities)
│  - Logique métier pure
│  - Validation métier
│  - Interfaces Repository
│
├─ DATA (Models & Repositories)
│  - Mapping Entity ↔ Model
│  - Implémentation des repositories
│  - Accès aux LocalDataSources
│
└─ DATABASE (SQLite)
   - Stockage persistant
   - Indexes et constraints
```

### Exemple: Créer une connexion

```dart
1. ViewModel reçoit les données utilisateur
   ↓
2. Crée une entité Connection
   connection = Connection(...);
   
3. Appelle le repository
   result = await connectionRepository.createConnection(connection);
   
4. Repository mappe vers Model
   model = _mapEntityToModel(connection);
   
5. Repository appelle LocalDataSource
   await localDataSource.createConnection(model);
   
6. LocalDataSource insère en BD
   INSERT INTO connections VALUES (...)
   
7. Retour du résultat
   Result.success(connection)
```

---

## 🔐 Validations et contraintes

### Validations Entity

```dart
class Connection {
  Connection({...}) {
    if (name.isEmpty) throw ValidationException('...');
    if (port <= 0 || port > 65535) throw ValidationException('...');
    if (reconnectIntervalSeconds < 1) throw ValidationException('...');
  }
}
```

### Contraintes BD

- **PRIMARY KEY**: Identification unique
- **UNIQUE**: Colonnes uniques (name, thumbprint, etc.)
- **CHECK**: Validations de plage (port, reconnectAttempts, etc.)
- **FOREIGN KEY**: Intégrité référentielle
- **NOT NULL**: Champs obligatoires

---

## 📝 Mapping et Conversion

### Entity ↔ Model

```dart
// Entity → Model
ProtocolModel _mapEntityToModel(Protocol entity) {
  return ProtocolModel(
    // ... conversion
  );
}

// Model → Entity
Protocol _mapModelToEntity(ProtocolModel model) {
  return Protocol(
    // ... conversion
  );
}
```

### DTO ↔ JSON

```dart
// JSON → DTO
factory ProtocolDTO.fromJson(Map<String, dynamic> json) { ... }

// DTO → JSON
Map<String, dynamic> toJson() { ... }
```

### Types complexes

- **Enums**: String dans BD, enum en Entity
- **Lists**: JSON dans BD, List en Entity
- **Maps**: JSON dans BD, Map en Entity
- **DateTime**: ISO 8601 dans BD, DateTime en Entity
- **Boolean**: 0/1 dans BD, bool en Entity

---

## 🚀 Utilisation des repositories

### Pattern Result

```dart
final result = await connectionRepository.getConnectionById('conn-1');

if (result.isSuccess) {
  final connection = result.value!;
  // Utiliser la connexion
} else {
  final error = result.error!;
  // Gérer l'erreur
}
```

### Méthodes courantes

```dart
// CRUD
await repo.getById(id);
await repo.getAllItems();
await repo.createItem(item);
await repo.updateItem(item);
await repo.deleteItem(id);

// Requêtes spécifiques
await connectionRepository.getTopicsByConnectionId(connId);
await messageRepository.getMessagesPaginated(page, limit);
await certificateRepository.getExpiringCertificates(daysUntilExpiry: 30);
await logRepository.getLogsBySeverity(LogSeverity.error);
```

---

## 🔍 Requêtes fréquentes

### Connexions actives

```sql
SELECT * FROM connections WHERE status = 'active' AND isEnabled = 1;
```

### Topics d'une connexion

```sql
SELECT * FROM topics WHERE connectionId = ? ORDER BY path;
```

### Messages non traités

```sql
SELECT * FROM messages WHERE processed = 0 ORDER BY receivedAt DESC;
```

### Certificats expirant bientôt

```sql
SELECT * FROM certificates 
WHERE validUntil IS NOT NULL 
AND validUntil > datetime('now') 
AND validUntil <= datetime('now', '+30 days');
```

### Logs non résolus

```sql
SELECT * FROM log_entries WHERE isResolved = 0 ORDER BY timestamp DESC;
```

---

## 📚 Fichiers de référence

### Documentation

- **DATA_MODEL.md** - Documentation complète du modèle
- **SQL_SCHEMA.sql** - Schéma SQL complet
- **ARCHITECTURE.md** - Architecture générale (existant)
- **INTERFACES_CONTRACTS.md** - Contrats (existant)

### Code

- Toutes les entités dans `lib/domain/entities/`
- Tous les repositories dans `lib/domain/repositories/`
- Toutes les implémentations dans `lib/data/repositories/impl/`
- Tous les DTOs dans `lib/data/dtos/`
- Tous les modèles dans `lib/data/models/`

---

## ✅ Checklist d'implémentation

### LocalDataSource Implementations

- [ ] ProtocolLocalDataSourceImpl
- [ ] CertificateLocalDataSourceImpl
- [ ] ConnectionLocalDataSourceImpl
- [ ] TopicLocalDataSourceImpl
- [ ] MessageLocalDataSourceImpl
- [ ] UserSettingsLocalDataSourceImpl
- [ ] DashboardLocalDataSourceImpl
- [ ] LogLocalDataSourceImpl

### Dependency Injection

- [ ] Enregistrer tous les repositories dans ServiceLocator
- [ ] Enregistrer tous les LocalDataSources
- [ ] Configurer les modules (core_module, data_module, domain_module)

### Tests

- [ ] Unit tests pour les repositories
- [ ] Unit tests pour le mapping Entity ↔ Model
- [ ] Integration tests avec SQLite
- [ ] Tests de validation métier

### Database Migration

- [ ] Script d'initialisation de la BD
- [ ] Script d'insertion des protocoles par défaut
- [ ] Script de migration si évolution du schéma

---

## 🎯 Points clés à retenir

1. **Clean Architecture**: Séparation claire entre les couches
2. **Result Pattern**: Gestion d'erreurs avec Result<T, E>
3. **Mapping**: Toujours convertir entre Entity ↔ Model
4. **Validation**: Valider au niveau Entity
5. **Repositories**: Interface dans Domain, Impl dans Data
6. **DTOs**: Utiliser pour la sérialisation API/JSON
7. **SQLite**: Schéma bien structuré avec indexes et contraintes
8. **Triggers**: Automatiser les tâches de maintenance BD
9. **Vues**: Faciliter les requêtes complexes
10. **Enums**: Utiliser pour les valeurs énumérées

---

**Modèle créé**: 2026-06-22
**Version**: 1.0
**Statut**: Prêt pour implémentation LocalDataSource

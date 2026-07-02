# IoT Manager - Functional Specification

**Version:** 0.1.0-alpha  
**Last Updated:** 2026-07-02  
**Target Users:** IoT developers, system integrators, device management teams

---

## Table of Contents

1. [Product Overview](#product-overview)
2. [Core Features](#core-features)
3. [Use Cases](#use-cases)
4. [User Workflows](#user-workflows)
5. [Data Management](#data-management)
6. [Connectivity](#connectivity)
7. [User Interface](#user-interface)
8. [Integration Points](#integration-points)
9. [Limitations & Roadmap](#limitations--roadmap)

---

## Product Overview

### What is IoT Manager?

IoT Manager is a **lightweight, offline-first desktop application** for managing IoT devices and MQTT connections. It provides a centralized hub for:

- 🔌 **Device Management:** Register, configure, monitor IoT devices
- 📡 **MQTT Connectivity:** Connect to MQTT brokers, publish/subscribe topics
- 📊 **Message Monitoring:** View message history and analytics
- ⚙️ **Configuration Management:** Store and manage device configurations
- 🔐 **Security:** Handle SSL/TLS certificates and authentication
- 🎯 **Automation:** Send commands to devices, automation rules

### Key Characteristics

| Feature | Detail |
|---------|--------|
| **Deployment** | Standalone desktop application (100% offline) |
| **Database** | Local SQLite (no cloud sync) |
| **Architecture** | Clean Architecture + Plugin system |
| **Extensibility** | Protocol plugins for device types |
| **Performance** | Real-time message handling, optimized for 1000+ devices |
| **User Base** | Single user per installation |
| **License** | Open source (TBD) |

---

## Core Features

### 1. Device Management

#### Feature Set
- ✅ **Device Registry:** Add, edit, delete devices
- ✅ **Device Metadata:** Name, type, description, tags
- ✅ **Online Status:** Real-time online/offline tracking
- ✅ **Device Groups:** Organize devices by location/type
- ✅ **Device History:** Track device configuration changes
- 🔄 **Device Templates:** Pre-configured device types (Planned)

#### Workflow
```
Register Device
    ↓
Configure Properties
    ↓
Add to Group (optional)
    ↓
Connect via Protocol
    ↓
Monitor Status
```

#### Data Structure
```dart
Device {
  id: String (UUID)
  name: String
  type: String (e.g., "Sensor", "Actuator")
  description: String
  manufacturer: String
  model: String
  serialNumber: String
  macAddress: String
  ipAddress: String
  location: String
  tags: List<String>
  isOnline: bool
  lastSeen: DateTime
  metadata: Map<String, dynamic>
  createdAt: DateTime
  updatedAt: DateTime
}
```

### 2. MQTT Connectivity

#### Connection Management
- ✅ **Multiple Connections:** Manage multiple MQTT brokers
- ✅ **Connection Profiles:** Save/load connection configurations
- ✅ **Authentication:** Username/password, certificate-based
- ✅ **SSL/TLS:** Full certificate support
- ✅ **Connection Status:** Live connection indicators
- ✅ **Auto-Reconnect:** Exponential backoff reconnection strategy

#### Supported MQTT Features
- ✅ **QoS Levels:** 0 (At Most Once), 1 (At Least Once), 2 (Exactly Once)
- ✅ **Topic Wildcards:** `+` (single level), `#` (multi-level)
- ✅ **Last Will & Testament:** LWT configuration
- ✅ **Retained Messages:** Query retained message history
- ✅ **Message Persistence:** Store all messages locally

#### Connection Configuration
```dart
Connection {
  id: String (UUID)
  name: String
  brokerAddress: String (e.g., mqtt.broker.com)
  port: int (default: 1883)
  useTLS: bool
  username: String?
  password: String?
  clientId: String
  keepAlive: int (seconds, default: 60)
  automaticReconnect: bool
  certificateIds: List<String>
  lastWill: {
    topic: String,
    message: String,
    qos: int,
    retain: bool
  }?
  createdAt: DateTime
  updatedAt: DateTime
}
```

### 3. Topic & Subscription Management

#### Topic Operations
- ✅ **Subscribe:** Subscribe to topics with QoS selection
- ✅ **Unsubscribe:** Remove topic subscriptions
- ✅ **Publish:** Send messages to topics
- ✅ **Topic History:** View subscription history
- ✅ **Bulk Operations:** Subscribe/unsubscribe multiple topics

#### Topic Configuration
```dart
Topic {
  id: String (UUID)
  connectionId: String (foreign key)
  name: String (e.g., "home/sensors/temperature")
  qos: int (0, 1, or 2)
  isActive: bool
  messageCount: int
  lastMessage: String?
  lastMessageTime: DateTime?
  isRetained: bool
  createdAt: DateTime
  updatedAt: DateTime
}
```

### 4. Message Management

#### Message Monitoring
- ✅ **Real-time Display:** View incoming messages in real-time
- ✅ **Message History:** Query historical messages
- ✅ **Message Search:** Filter by topic, time range, content
- ✅ **Message Statistics:** Count, frequency, size analytics
- ✅ **Message Replay:** Replay historical messages

#### Message Features
- ✅ **Timestamp Tracking:** All messages timestamped
- ✅ **Metadata Capture:** Capture QoS, retain flag, source
- ✅ **Payload Display:** Show raw and formatted payloads
- ✅ **Payload Preview:** Syntax highlighting for JSON/XML
- ✅ **Message Filtering:** Filter by payload pattern

#### Message Structure
```dart
Message {
  id: String (UUID)
  topicId: String (foreign key)
  topic: String
  payload: String
  payloadSize: int (bytes)
  qos: int
  retained: bool
  isDuplicate: bool
  isIncoming: bool
  timestamp: DateTime
  receivedAt: DateTime
}
```

### 5. Command Execution

#### Device Commands
- ✅ **Command Queue:** Queue commands for execution
- ✅ **Command Status:** Track command delivery status
- ✅ **Command History:** View past command executions
- ✅ **Batch Commands:** Send same command to multiple devices
- ✅ **Scheduled Commands:** Schedule commands for future execution

#### Command Structure
```dart
Command {
  id: String (UUID)
  deviceId: String (foreign key)
  topicId: String (foreign key)
  commandName: String
  parameters: Map<String, dynamic>
  payload: String
  expectedResponse: String?
  status: String ("pending", "sent", "acknowledged", "failed")
  executedAt: DateTime?
  completedAt: DateTime?
  error: String?
  createdAt: DateTime
}
```

### 6. Certificate Management

#### Certificate Operations
- ✅ **Upload Certificates:** Add CA, client certificates
- ✅ **Certificate Validation:** Validate certificate expiry
- ✅ **Certificate Info:** View certificate details
- ✅ **Certificate Usage:** Track which connections use each cert
- ✅ **Expiry Alerts:** Notification when cert expires soon

#### Supported Formats
- PEM (`.pem`, `.crt`, `.key`)
- DER (`.der`, `.cer`)
- PKCS12 (`.p12`, `.pfx`)

#### Certificate Structure
```dart
Certificate {
  id: String (UUID)
  name: String
  certificateType: String ("ca", "client", "server")
  format: String ("pem", "der", "pkcs12")
  commonName: String
  issuer: String
  subject: String
  notBefore: DateTime
  notAfter: DateTime
  fingerprint: String
  keySize: int
  signatureAlgorithm: String
  certificateData: String (base64)
  createdAt: DateTime
  uploadedAt: DateTime
}
```

### 7. Activity Logging

#### Log Features
- ✅ **Event Logging:** All significant events logged
- ✅ **Debug Logging:** Detailed debug information
- ✅ **Log Filtering:** Filter by level, source, time range
- ✅ **Log Export:** Export logs as CSV/JSON
- ✅ **Log Retention:** Automatic cleanup (7-day retention)

#### Log Entry Structure
```dart
LogEntry {
  id: String (UUID)
  level: String ("DEBUG", "INFO", "WARNING", "ERROR")
  source: String
  message: String
  details: String?
  deviceId: String?
  connectionId: String?
  topicId: String?
  timestamp: DateTime
}
```

### 8. Dashboard & Visualization

#### Dashboard Features
- ✅ **Device Overview:** Quick view of all devices
- ✅ **Connection Status:** Visual indicators for connections
- ✅ **Message Feed:** Real-time message stream
- ✅ **Statistics:** Message counts, frequency graphs
- ✅ **Custom Widgets:** Customizable dashboard widgets
- ✅ **Widget Configuration:** Save dashboard layouts

#### Widget Types
- Device List (sortable, filterable)
- Connection Status Panel
- Topic Subscription View
- Message Stream (real-time)
- Statistics Charts
- Command Queue View
- Certificate Status

---

## Use Cases

### Use Case 1: Device Monitoring

**Actor:** IoT Manager  
**Preconditions:** Device connected to network, connection configured  
**Main Flow:**

1. User adds device to registry
2. User subscribes to device status topic
3. Application receives status messages in real-time
4. Application displays device status in UI
5. User views device history and statistics

**Alternate Flows:**
- Device goes offline → Application shows offline status, logs event
- Message arrives with error → Application logs error, alerts user

---

### Use Case 2: Configuration Backup

**Actor:** System Administrator  
**Preconditions:** Devices and connections configured  
**Main Flow:**

1. User exports device configuration
2. User exports connection profiles
3. User downloads SQLite database
4. User stores backup in safe location

**Alternative:** User imports backup to restore configuration

---

### Use Case 3: Certificate Installation

**Actor:** Security Administrator  
**Preconditions:** Have certificate files (CA, client)  
**Main Flow:**

1. User opens Certificate Manager
2. User uploads CA certificate
3. User uploads client certificate
4. User validates certificate information
5. User links certificate to connection
6. Application uses certificate for TLS

---

### Use Case 4: Protocol Extension

**Actor:** Developer  
**Preconditions:** New protocol plugin ready  
**Main Flow:**

1. Developer implements ProtocolPlugin interface
2. Developer registers plugin with PluginRegistry
3. Plugin loads during application startup
4. Plugin appears in connection creation dialog
5. User can select protocol for new connection

---

## User Workflows

### Workflow 1: Initial Setup

```
┌─────────────────────────────────────┐
│ 1. Create First Connection           │
│    - Enter broker address/port       │
│    - Configure authentication        │
│    - Test connection                 │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ 2. Register Devices                  │
│    - Add device name & type         │
│    - Configure properties           │
│    - Set device location            │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ 3. Subscribe to Topics               │
│    - Select connection               │
│    - Enter topic name                │
│    - Choose QoS level                │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│ 4. Monitor Messages                  │
│    - View message feed               │
│    - Set up filters                  │
│    - Create alerts                   │
└─────────────────────────────────────┘
```

### Workflow 2: Send Device Command

```
1. Select Device → 2. Choose Command → 3. Set Parameters → 
4. Review Payload → 5. Send Command → 6. Track Status
```

### Workflow 3: Troubleshoot Connection

```
1. Check Connection Status
   ↓
2. View Recent Messages
   ↓
3. Check Logs for Errors
   ↓
4. Validate Certificate
   ↓
5. Test Publish/Subscribe
   ↓
6. Verify Network Connectivity
```

---

## Data Management

### Data Import

- **Devices:** Import from CSV with device details
- **Connections:** Import from JSON configuration
- **Topics:** Import subscription list from file
- **Database:** Restore from SQLite backup

### Data Export

- **Devices:** Export as CSV or JSON
- **Connections:** Export as JSON with or without credentials
- **Messages:** Export message history as CSV/JSON
- **Logs:** Export logs as CSV or JSON
- **Database:** Export full SQLite database

### Data Retention

| Data Type | Retention | Cleanup |
|-----------|-----------|---------|
| Messages | 90 days | Automatic |
| Logs | 7 days | Automatic |
| Commands | 30 days | Automatic |
| Devices | Indefinite | Manual |
| Connections | Indefinite | Manual |

---

## Connectivity

### Connection Lifecycle

```
DISCONNECTED
    ↓ (connect requested)
CONNECTING
    ↓ (successful)
CONNECTED
    ↓ (network error)
RECONNECTING
    ↓ (successful)
CONNECTED
    ↓ (user disconnect)
DISCONNECTING
    ↓ (disconnected)
DISCONNECTED
```

### Reconnection Strategy

**Exponential Backoff:**
- Attempt 1: 1 second delay
- Attempt 2: 2 second delay
- Attempt 3: 4 second delay
- Attempt 4: 8 second delay
- Attempt 5+: 30 second delay (max)

**Max Reconnection Attempts:** 10 (configurable)

---

## User Interface

### Main Screens

1. **Dashboard**
   - Overview of all connections and devices
   - Real-time message feed
   - Quick statistics

2. **Devices**
   - List all registered devices
   - Device details panel
   - Device actions (edit, delete, commands)

3. **Connections**
   - List all MQTT connections
   - Connection status indicators
   - Connection configuration

4. **Topics**
   - Subscribed topics list
   - Topic details and statistics
   - Subscribe/unsubscribe UI

5. **Messages**
   - Real-time message viewer
   - Message search and filtering
   - Message replay

6. **Certificates**
   - Certificate inventory
   - Upload/delete certificates
   - Expiry status

7. **Logs**
   - Event log viewer
   - Log filtering and search
   - Export logs

8. **Settings**
   - General preferences
   - Database management
   - Export/Import data

---

## Integration Points

### REST API (Planned - Phase 10)
- REST endpoints for device management
- REST endpoints for message operations
- Webhook support for events

### Plugin System (Phase 11 - Implemented)
- Custom protocol handlers
- Device type plugins
- Notification plugins
- Data processing plugins

### Third-Party Integration (Planned)
- Home Assistant integration
- Node-RED integration
- Grafana data source
- InfluxDB metrics

---

## Limitations & Roadmap

### Current Limitations (v0.1.0-alpha)

❌ **Not Supported:**
- Cloud synchronization
- Multi-user access
- Web interface
- Mobile app
- Advanced analytics
- Clustering/HA

✅ **Supported:**
- Single-user desktop
- Local SQLite database
- Single platform (Linux alpha)
- Basic device management
- MQTT connectivity

### Roadmap

| Phase | Feature | Status | ETA |
|-------|---------|--------|-----|
| 12 | MQTT Plugin Implementation | 🔄 Next | Q3 2026 |
| 13 | Database Encryption | 🔄 Planned | Q3 2026 |
| 14 | Advanced Analytics | 🔄 Planned | Q4 2026 |
| 15 | Web Interface | 🔄 Planned | Q4 2026 |
| 16 | Android App | 🔄 Planned | 2027 |
| 17 | iOS App | 🔄 Planned | 2027 |
| 18 | Windows Build | 🔄 Planned | 2027 |
| 19 | macOS Build | 🔄 Planned | 2027 |
| 20 | Cloud Sync | 🔄 Planned | 2027+ |

---

**Questions?** Refer to TECHNICAL_SPEC.md for implementation details or DEVELOPMENT_GUIDE.md for extension information.

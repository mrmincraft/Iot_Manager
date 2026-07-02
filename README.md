# IoT Manager

**A lightweight, offline-first desktop application for managing IoT devices and MQTT connections.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter: 3.16+](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![Dart: 3.0+](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-orange.svg)]()
[![Build: Passing](https://img.shields.io/badge/Build-Passing-success.svg)]()

---

## 🎯 Overview

IoT Manager is a clean architecture Flutter application for:

- 🔌 **Device Management** - Register and manage IoT devices
- 📡 **MQTT Connectivity** - Connect to MQTT brokers with full protocol support
- 📊 **Message Monitoring** - Real-time message tracking and analytics
- ⚙️ **Configuration Management** - Store device and connection configurations
- 🔐 **Security** - SSL/TLS certificates and secure authentication
- 🎮 **Device Commands** - Send commands and automation rules
- 🧩 **Plugin Architecture** - Extensible system for custom protocols

**Status:** v0.1.0-alpha (Linux x64)

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md) | **What it does** - Features, use cases, workflows |
| [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) | **How it works** - Architecture, design, implementation |
| [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) | **How to extend** - Development setup, testing, plugins |
| [docs/deployment/](docs/deployment/) | **How to deploy** - Build guides, CI/CD setup |
| [docs/architecture/](docs/architecture/) | **Deep dives** - Data models, API design, schemas |

---

## 🚀 Quick Start

### Prerequisites

```bash
# Install Flutter 3.16+
curl https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter-linux-3.16.0-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"

# Install Linux dependencies (Ubuntu/Debian)
sudo apt-get install -y cmake ninja-build pkg-config libgtk-3-dev libssl-dev

# Verify
flutter doctor
```

### Build from Source

```bash
# Clone repository
git clone https://github.com/yourusername/iot_manager.git
cd iot_manager

# Install dependencies
flutter pub get

# Build release binary
./build_linux.sh release

# Output: build/linux/x64/release/bundle/iot_manager
```

### Run Application

```bash
# Run development
flutter run

# Or run built binary
./build/linux/x64/release/bundle/iot_manager
```

---

## 🏗️ Architecture

### Clean Architecture Pattern

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

**Why?** Separation of concerns, testability, maintainability, and scalability.

### Key Technologies

| Layer | Technology | Purpose |
|-------|-----------|---------|
| UI | Flutter + Material 3 | Cross-platform desktop UI |
| State | ValueNotifier + MVVM | Reactive state management |
| Business Logic | Use Cases + Result Pattern | Error handling & domain logic |
| Data | SQLite + sqflite | Local data persistence |
| DI | GetIt | Service locator & dependency injection |
| Events | EventBus | Inter-component communication |
| Networking | mqtt5_client + http | MQTT and HTTP protocols |

---

## 📁 Project Structure

```
iot_manager/
├── lib/
│   ├── core/              # DI, EventBus, Exceptions, Utils
│   ├── domain/            # Entities, Use Cases, Repositories
│   ├── data/              # DTOs, Models, DataSources, Repositories
│   ├── presentation/      # Pages, ViewModels, Widgets
│   └── main.dart          # Entry point
├── test/                  # Unit & integration tests (300+ tests)
├── linux/                 # Linux platform files (CMake, C++)
├── docs/
│   ├── architecture/      # Data models, API design
│   ├── deployment/        # Build guides, CI/CD
│   └── archive/           # Historical documentation
├── pubspec.yaml           # Dependencies
├── build.yaml             # Build configuration
├── build_linux.sh         # Build script
└── TECHNICAL_SPEC.md      # Comprehensive technical docs
```

---

## ✨ Features

### ✅ Implemented (Phase 1-11)

- Device management (add, edit, delete, organize)
- MQTT connections with TLS/SSL support
- Topic subscriptions and message history
- Device commands and automation
- Certificate management
- Activity logging
- SQLite database with 9 core tables
- Clean Architecture implementation
- MVVM with ValueNotifier
- Dependency Injection with GetIt
- 300+ unit and integration tests
- Plugin system framework

### 🔄 In Progress

- **Phase 12:** MQTT Plugin Implementation (coming soon)

### 🔜 Planned

- **Phase 13:** Database Encryption
- **Phase 14:** Advanced Analytics
- **Phase 15:** Web Interface
- **Phase 16-19:** Platform Support (Android, iOS, Windows, macOS)
- **Phase 20+:** Cloud Sync, Advanced Features

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 300+ tests covering:
# - Core layer (DI, EventBus, Result pattern)
# - Domain entities and use cases
# - Data access and repositories
# - UI widgets and ViewModels
# - Plugin system
```

---

## 🏢 Technology Stack

### Frontend
- **Framework:** Flutter 3.16+
- **Language:** Dart 3.0+
- **UI Design:** Material Design 3
- **State Management:** ValueNotifier + MVVM

### Backend (Local)
- **Database:** SQLite 3.40+ with sqflite
- **ORM:** Manual mapping (no codegen)

### Platform Support
- ✅ **Linux x64** (Alpha)
- 🔄 **Android** (Planned)
- 🔄 **iOS** (Planned)
- 🔄 **Windows** (Planned)
- 🔄 **macOS** (Planned)

### Dependencies (Minimal)
- `get_it` - Dependency Injection
- `sqflite` - SQLite Database
- `mqtt5_client` - MQTT Protocol
- `http` - HTTP Client
- `event_bus` - Event System
- `intl` - Internationalization
- `logger` - Logging

---

## 🔧 Development

### Setup Development Environment

```bash
# Clone and setup
git clone https://github.com/yourusername/iot_manager.git
cd iot_manager

# Install dependencies
flutter pub get

# Run development server
flutter run

# Code analysis
flutter analyze

# Format code
dart format lib/ test/

# Run tests
flutter test
```

### Development Guides

- **[Development Guide](DEVELOPMENT_GUIDE.md)** - Setup, workflows, testing, plugins
- **[Contributing](DEVELOPMENT_GUIDE.md#contributing)** - Git workflow, PR process

### Creating Plugins

```dart
// Implement ProtocolPlugin interface
class MyProtocolPlugin implements ProtocolPlugin {
  @override
  Future<Result<void, AppException>> connect(Connection config) async {
    // Your implementation
  }
  
  @override
  Stream<Message> get onMessageReceived => _messages.stream;
  
  // ... implement other methods
}

// Register in service locator
registry.registerPlugin('my-protocol', MyProtocolPlugin());
```

See [Creating Plugins](DEVELOPMENT_GUIDE.md#creating-plugins) for full guide.

---

## 📊 Metrics

| Metric | Value |
|--------|-------|
| **Lines of Code** | 15,500+ (lib/) |
| **Test Coverage** | 300+ tests, 80%+ coverage |
| **Entities** | 10 domain models |
| **Use Cases** | 48 use case classes |
| **Repository Implementations** | 8 |
| **Database Tables** | 9 with indexes |
| **Build Time** | ~40s (debug), ~60s (release) |
| **Binary Size** | ~150MB (release with symbols) |
| **Database Size** | 0-100MB (depends on messages) |

---

## 🚀 Build & Deployment

### Build for Linux

```bash
# Development build
flutter build linux --debug

# Release build (optimized)
flutter build linux --release

# Using build script with validation
./build_linux.sh release

# Output: build/linux/x64/release/bundle/iot_manager
```

### CI/CD

GitHub Actions automatically:
- Builds on push to main
- Runs full test suite
- Generates coverage reports
- Creates release artifacts
- Tags releases for GitHub Releases

See [.github/workflows/](https://github.com/yourusername/iot_manager/blob/main/.github/workflows/) for CI/CD configuration.

---

## 📝 Database

### Schema

9 core tables with relationships:

- **devices** - Device registry
- **connections** - MQTT connections
- **topics** - Topic subscriptions  
- **messages** - Message history
- **commands** - Device commands
- **protocols** - Protocol definitions
- **certificates** - SSL/TLS certificates
- **dashboards** - UI configurations
- **log_entries** - Activity logs
- **user_settings** - Preferences

Features:
- Indexes for fast queries
- Foreign key constraints
- Triggers for audit logging
- Soft delete support

See [docs/architecture/SQL_SCHEMA.sql](docs/architecture/SQL_SCHEMA.sql) for schema.

---

## 🔒 Security

### Data Protection
- SQLite encryption (planned Phase 13)
- SSL/TLS for all connections
- Certificate pinning support
- Secure credential storage

### Best Practices
- Input validation on all user input
- No PII in logs
- Audit trail for all changes
- Regular security reviews

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [Contributing Guide](DEVELOPMENT_GUIDE.md#contributing) for details.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🆘 Support

- **Documentation:** See [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md) and [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md)
- **Issues:** Report on GitHub Issues
- **Discussion:** Use GitHub Discussions

---

## 🗺️ Roadmap

```
Phase 12: MQTT Plugin Implementation       Q3 2026 🔄
Phase 13: Database Encryption              Q3 2026 🔄
Phase 14: Advanced Analytics               Q4 2026 🔄
Phase 15: Web Interface                    Q4 2026 🔄
Phase 16: Android Support                  2027    🔄
Phase 17: iOS Support                      2027    🔄
Phase 18: Windows Support                  2027    🔄
Phase 19: macOS Support                    2027    🔄
Phase 20+: Cloud Sync & AI Features        2027+   🔄
```

---

## 👨‍💻 Development Team

- **Lead Architect:** Flutter + Clean Architecture
- **Contributors:** Open to community contributions

---

**Made with ❤️ for IoT developers**

[Report Bug](https://github.com/yourusername/iot_manager/issues) • [Request Feature](https://github.com/yourusername/iot_manager/issues) • [Documentation](FUNCTIONAL_SPEC.md)

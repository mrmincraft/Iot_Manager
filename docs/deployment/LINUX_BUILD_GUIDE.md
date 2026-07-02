# IoT Manager - Linux Alpha Build Setup Guide

## Current Status
- ✅ Flutter project structure configured (pubspec.yaml created)
- ✅ Linux platform files generated (CMake configuration, C++ entry points)
- ✅ Version: 0.1.0-alpha+1
- ⏳ Ready for Flutter SDK installation and build

## Prerequisites for Linux Build

### Required Tools
1. **Flutter SDK** (channel: stable or master)
2. **Dart SDK** (included with Flutter)
3. **CMake** (version 3.10+)
4. **Linux build tools** (gcc, g++, make)
5. **GTK development libraries** (GTK 3.0+)

### System Requirements
- Linux kernel: 4.4+
- RAM: 4GB minimum (8GB recommended)
- Disk space: 5GB+ available
- Display: X11 or Wayland

## Installation Steps

### Step 1: Install Flutter SDK

```bash
# Download Flutter (replace channel as needed)
cd ~/
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# For permanent setup, add to ~/.bashrc or ~/.zshrc:
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter --version
```

### Step 2: Install Linux Build Dependencies

**For Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  git \
  pkg-config \
  libgtk-3-dev \
  libxss-dev \
  libgconf-2-4
```

**For Fedora/RHEL:**
```bash
sudo dnf install -y \
  @development-tools \
  cmake \
  git \
  pkgconfig \
  gtk3-devel \
  libxss-devel
```

**For Arch Linux:**
```bash
sudo pacman -S \
  base-devel \
  cmake \
  gtk3
```

### Step 3: Setup Flutter for Linux Development

```bash
cd /path/to/Iot_Manager

# Enable Linux support
flutter config --enable-linux-desktop

# Run Flutter doctor to verify setup
flutter doctor -v

# Expected output: Linux toolchain installed successfully
```

### Step 4: Get Dependencies

```bash
cd /path/to/Iot_Manager

# Fetch all pub dependencies
flutter pub get

# Generate code (if needed for code generation)
flutter pub run build_runner build
```

## Building for Linux

### Development Build
```bash
cd /path/to/Iot_Manager

# Build debug version (fastest, largest size)
flutter build linux --debug
```

### Alpha Release Build
```bash
cd /path/to/Iot_Manager

# Build release version (optimized, smaller size)
flutter build linux --release

# Output location:
# build/linux/x64/release/bundle/iot_manager
```

## Run the Application

### From Source
```bash
# During development
flutter run -d linux

# With release build
flutter run -d linux --release
```

### From Built Binary
```bash
# After build
./build/linux/x64/release/bundle/iot_manager
```

## Creating Distribution Packages

### AppImage Package
```bash
# Requires: appimagetool
cd /path/to/Iot_Manager/build/linux/x64/release/bundle

# Create AppImage (output: iot_manager-0.1.0-x86_64.AppImage)
appimagetool iot_manager iot_manager-0.1.0-alpha-x86_64.AppImage
```

### Tarball Package
```bash
cd /path/to/Iot_Manager/build/linux/x64/release

# Create compressed archive
tar -czf iot_manager-0.1.0-alpha-linux-x64.tar.gz bundle/

# For distribution:
# - iot_manager-0.1.0-alpha-linux-x64.tar.gz (40-60MB typical)
```

### Snap Package (optional)
```bash
# Requires: snapcraft
cd /path/to/Iot_Manager

# Build snap
snapcraft

# Install locally
sudo snap install iot_manager_0.1.0_amd64.snap --dangerous
```

## Troubleshooting

### Issue: "Flutter SDK not found"
```bash
# Verify PATH includes Flutter bin
echo $PATH | grep flutter

# If not, add to ~/.bashrc
export PATH="$PATH:$HOME/flutter/bin"
source ~/.bashrc
```

### Issue: "CMake not found"
```bash
# Install CMake (Ubuntu example)
sudo apt-get install cmake
```

### Issue: "GTK not found"
```bash
# Install GTK development files
sudo apt-get install libgtk-3-dev libxss-dev libgconf-2-4
```

### Issue: Build fails with permissions
```bash
# Run Flutter commands with appropriate permissions
# Usually no sudo needed, but check file permissions:
ls -la ~/flutter/
```

## Build Output Structure

```
build/linux/x64/release/
├── bundle/
│   ├── iot_manager                    # Main executable
│   ├── lib/                           # Flutter runtime libraries
│   ├── data/
│   │   └── flutter_assets/            # Assets (compiled into binary)
│   └── icudtl.dat                    # ICU data
└── [other Flutter files]
```

## Performance Benchmarks (Expected)

| Operation | Time | Notes |
|-----------|------|-------|
| Clean build | 3-5 min | First time, downloads all deps |
| Incremental build | 30-60 sec | After code changes |
| Release build | 2-3 min | Optimized, no debug info |
| App startup | <2 sec | From binary launch |
| Memory (idle) | 60-100 MB | Typical usage |
| Database (1000 items) | <500ms | SQLite operations |

## Distribution Checklist

For alpha release distribution:
- [ ] Run `flutter clean` before final build
- [ ] Build with `--release` flag
- [ ] Test on clean Ubuntu 20.04+ system
- [ ] Verify all features work offline
- [ ] Check database initialization
- [ ] Test MQTT connections (if broker available)
- [ ] Create changelog (CHANGELOG.md)
- [ ] Version bump in pubspec.yaml: 0.1.0-alpha+1
- [ ] Create GitHub release with binary attachments
- [ ] Document known issues and limitations

## Next Steps

After successful build:
1. **Testing**: Run comprehensive test suite
2. **Optimization**: Profile performance on target hardware
3. **Packaging**: Distribute as AppImage or tarball
4. **Feedback**: Gather user feedback for Phase 2
5. **Updates**: Plan Phase 2 based on feedback

## Helpful Resources

- Flutter Linux Desktop Documentation: https://flutter.dev/desktop
- Flutter Linux Plugin Development: https://flutter.dev/docs/development/packages-and-plugins/developing-packages
- GTK Documentation: https://developer.gnome.org/gtk3/
- CMake Documentation: https://cmake.org/

## Current Project Statistics

- **Dart Code**: 15,500+ lines
- **Tests**: 23 test files, 10,400+ lines
- **Database**: 9 tables with indexes and triggers
- **Architecture**: Clean architecture (4 layers)
- **Plugins**: Plugin framework ready for MQTT integration

## Version History

- **0.1.0-alpha+1**: Initial alpha release
  - Foundation (database, DI, core services)
  - Domain entities and business logic
  - Data layer with SQLite
  - Presentation layer (pages, viewmodels, widgets)
  - Comprehensive test coverage
  - Plugin architecture framework

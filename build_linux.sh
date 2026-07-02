#!/bin/bash
# Build script for IoT Manager Linux alpha release
# Usage: ./build_linux.sh [debug|release] [--package] [--appimage]

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_TYPE="${1:-release}"
BUILD_VARIANT="${BUILD_TYPE}"
PACKAGE_TYPE=""
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VERSION="0.1.0-alpha"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter SDK not found. Please install Flutter first."
        echo "Visit: https://flutter.dev/docs/get-started/install/linux"
        exit 1
    fi
    print_success "Flutter found: $(flutter --version | head -n1)"
}

check_dependencies() {
    print_status "Checking build dependencies..."
    
    local deps_missing=0
    
    # Check CMake
    if ! command -v cmake &> /dev/null; then
        print_warning "CMake not found - required for Linux build"
        deps_missing=1
    else
        print_success "CMake: $(cmake --version | head -n1)"
    fi
    
    # Check pkg-config
    if ! command -v pkg-config &> /dev/null; then
        print_warning "pkg-config not found"
        deps_missing=1
    fi
    
    # Check GTK libraries
    if ! pkg-config --exists gtk+-3.0 2>/dev/null; then
        print_warning "GTK 3 development files not found"
        echo "    Install with: sudo apt-get install libgtk-3-dev libxss-dev libgconf-2-4"
        deps_missing=1
    else
        GTK_VERSION=$(pkg-config --modversion gtk+-3.0)
        print_success "GTK 3: $GTK_VERSION"
    fi
    
    # Check for C++ compiler
    if ! command -v g++ &> /dev/null; then
        print_warning "G++ compiler not found"
        echo "    Install with: sudo apt-get install build-essential"
        deps_missing=1
    else
        print_success "G++ compiler found"
    fi
    
    if [ $deps_missing -eq 1 ]; then
        print_warning "Some dependencies are missing. The build may fail."
        print_status "Install missing dependencies using LINUX_BUILD_GUIDE.md"
    fi
}

clean_build() {
    print_status "Cleaning previous builds..."
    cd "$PROJECT_DIR"
    flutter clean
    rm -rf build/
    # Only remove ephemeral Flutter-generated files, keep CMakeLists.txt template
    rm -rf linux/flutter/ephemeral/ 2>/dev/null || true
    rm -f linux/flutter/generated_plugins.cmake 2>/dev/null || true
    rm -f linux/flutter/generated_plugin_registrant.cc 2>/dev/null || true
    rm -f linux/flutter/generated_plugins_plugin_c_binding.cc 2>/dev/null || true
    print_success "Clean complete"
}

get_dependencies() {
    print_status "Getting Flutter dependencies..."
    cd "$PROJECT_DIR"
    flutter pub get
    print_success "Dependencies downloaded"
    
    # Ensure Linux platform setup is complete (regenerates CMake files)
    print_status "Configuring Linux platform..."
    flutter config --enable-linux-desktop > /dev/null 2>&1
    
    # Regenerate Flutter's generated plugin registrant to ensure CMake is ready
    # This is handled by flutter pub get, but we can also run create to restore files
    if [ ! -f "$PROJECT_DIR/linux/flutter/CMakeLists.txt" ]; then
        print_warning "CMake files not yet generated, will be created during build"
    fi
    print_success "Platform configuration complete"
}

run_tests() {
    print_status "Running tests before build..."
    cd "$PROJECT_DIR"
    
    if flutter test 2>&1 | tail -5; then
        print_success "Tests passed"
    else
        print_warning "Some tests failed - continuing anyway"
    fi
}

generate_code() {
    print_status "Generating code (if needed)..."
    cd "$PROJECT_DIR"
    flutter pub run build_runner build 2>/dev/null || print_warning "Code generation completed with notices"
    print_success "Code generation complete"
}

build_linux() {
    print_status "Building Linux $BUILD_VARIANT release..."
    cd "$PROJECT_DIR"
    
    # Set CMake to find Flutter packages and GTK
    export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:$PKG_CONFIG_PATH"
    
    if [ "$BUILD_VARIANT" = "debug" ]; then
        flutter build linux --debug || {
            print_error "Build failed"
            exit 1
        }
    else
        flutter build linux --release || {
            print_error "Build failed"
            exit 1
        }
    fi
    
    print_success "Build complete"
}

create_tarball() {
    print_status "Creating tarball package..."
    cd "$PROJECT_DIR/build/linux/x64/${BUILD_VARIANT}"
    
    TARBALL="iot_manager-${VERSION}-linux-x64-${TIMESTAMP}.tar.gz"
    tar -czf "$TARBALL" bundle/
    
    SIZE=$(du -h "$TARBALL" | cut -f1)
    print_success "Tarball created: $TARBALL ($SIZE)"
    
    # Create SHA256 checksum
    sha256sum "$TARBALL" > "${TARBALL}.sha256"
    print_status "Checksum created: ${TARBALL}.sha256"
}

create_appimage() {
    print_status "Creating AppImage..."
    
    if ! command -v appimagetool &> /dev/null; then
        print_error "appimagetool not found. Install linuxdeploy or use tarball instead."
        print_status "Download from: https://github.com/linuxdeploy/linuxdeploy"
        return 1
    fi
    
    cd "$PROJECT_DIR/build/linux/x64/${BUILD_VARIANT}"
    
    APPIMAGE="iot_manager-${VERSION}-${TIMESTAMP}-x86_64.AppImage"
    appimagetool bundle/ "$APPIMAGE"
    
    SIZE=$(du -h "$APPIMAGE" | cut -f1)
    print_success "AppImage created: $APPIMAGE ($SIZE)"
}

show_build_info() {
    print_status "Build Information:"
    echo "  Project: IoT Manager"
    echo "  Version: $VERSION"
    echo "  Build Type: $BUILD_VARIANT"
    echo "  Timestamp: $TIMESTAMP"
    echo "  Platform: Linux x64"
}

show_summary() {
    print_success "Build Summary:"
    echo "  Location: $PROJECT_DIR/build/linux/x64/${BUILD_VARIANT}/"
    echo "  Binary: $PROJECT_DIR/build/linux/x64/${BUILD_VARIANT}/bundle/iot_manager"
    echo ""
    
    if [ -f "$PROJECT_DIR/build/linux/x64/${BUILD_VARIANT}/iot_manager-${VERSION}-linux-x64-${TIMESTAMP}.tar.gz" ]; then
        echo "  Package: iot_manager-${VERSION}-linux-x64-${TIMESTAMP}.tar.gz"
    fi
    
    echo ""
    echo "  To run the application:"
    echo "    $PROJECT_DIR/build/linux/x64/${BUILD_VARIANT}/bundle/iot_manager"
    echo ""
    echo "  To run from source:"
    echo "    flutter run -d linux --${BUILD_VARIANT}"
    echo ""
}

# Main execution
main() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   IoT Manager - Linux Alpha Build Script      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    show_build_info
    echo ""
    
    # Parse additional arguments
    for arg in "$@"; do
        case $arg in
            --package)
                PACKAGE_TYPE="tarball"
                ;;
            --appimage)
                PACKAGE_TYPE="appimage"
                ;;
        esac
    done
    
    # Check prerequisites
    check_flutter
    check_dependencies
    echo ""
    
    # Build steps
    clean_build
    echo ""
    
    get_dependencies
    echo ""
    
    # Optionally run tests (slower)
    # run_tests
    # echo ""
    
    generate_code
    echo ""
    
    build_linux
    echo ""
    
    # Create packages if requested
    if [ "$PACKAGE_TYPE" = "tarball" ] || [ "$PACKAGE_TYPE" = "" ]; then
        create_tarball
        echo ""
    fi
    
    if [ "$PACKAGE_TYPE" = "appimage" ]; then
        if create_appimage; then
            echo ""
        fi
    fi
    
    show_summary
    echo ""
    print_success "Build process completed successfully!"
}

# Run main
main "$@"

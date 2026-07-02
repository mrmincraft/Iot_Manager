# Project-level configuration file for Flutter apps.
#
# This file specifies Flutter-specific build settings and dependencies.
# Run "flutter pub get" followed by "flutter run" or "flutter build" to use this config.

project(iot_manager)

# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin packages to fail on older machines.
cmake_minimum_required(VERSION 3.10)

# Enable finding Flutter CMake modules
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

# Project-level settings applied to all build types.
if(DEFINED custom_dart_flags)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${custom_dart_flags}")
endif(DEFINED custom_dart_flags)

# You can pass -DTARGET_PLATFORM=<platform> to cmake to specify the target
# platform type, which will be passed in to the Dart VM.
# If not specified, the default is to auto-detect the platform.
if(NOT DEFINED TARGET_PLATFORM)
  execute_process(COMMAND uname -m OUTPUT_VARIABLE TARGET_PLATFORM OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
set(BINARY_NAME "iot_manager")

# Ensure Flutter CMake configuration exists
set(FLUTTER_CMAKE_FILE "${FLUTTER_MANAGED_DIR}/CMakeLists.txt")
if(NOT EXISTS "${FLUTTER_CMAKE_FILE}")
  message(FATAL_ERROR 
    "Flutter CMake configuration not found at: ${FLUTTER_CMAKE_FILE}\n"
    "Please ensure Flutter pub get has been run:\n"
    "  flutter config --enable-linux-desktop\n"
    "  flutter pub get\n"
    "  flutter build linux --release")
endif()

# Include Flutter's CMake configuration
include("${FLUTTER_CMAKE_FILE}")

# Application source files
add_executable(${BINARY_NAME} "main.cc" "my_application.cc")

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

# Link against Flutter and GTK
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

# Ensure plugins are built before the executable
if(TARGET FlutterGeneratedPluginTarget)
  add_dependencies(${BINARY_NAME} FlutterGeneratedPluginTarget)
endif()

# Link plugin wrapper if available
if(TARGET flutter_wrapper_plugin)
  target_link_libraries(${BINARY_NAME} PRIVATE flutter_wrapper_plugin)
endif()

# Installation target
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION bin)

#
# Flutter CMake configuration file  
# Loads Flutter-generated configuration and plugin setup
#

# Minimum CMake version
cmake_minimum_required(VERSION 3.10)

# Set binary name for plugin linking
set(BINARY_NAME "iot_manager")

# Include Flutter-generated configuration (created by flutter pub get)
set(GENERATED_CONFIG_CMAKE "${CMAKE_CURRENT_LIST_DIR}/ephemeral/generated_config.cmake")
if(EXISTS "${GENERATED_CONFIG_CMAKE}")
  include("${GENERATED_CONFIG_CMAKE}" NO_POLICY_SCOPE)
endif()

# Include generated plugin registrant if it exists
set(GENERATED_PLUGINS_CMAKE "${CMAKE_CURRENT_LIST_DIR}/generated_plugins.cmake")
if(EXISTS "${GENERATED_PLUGINS_CMAKE}")
  include("${GENERATED_PLUGINS_CMAKE}")
else()
  # Empty plugin lists if generated file not found
  list(APPEND FLUTTER_PLUGIN_LIST)
  list(APPEND FLUTTER_FFI_PLUGIN_LIST)
endif()

# Initialize plugin bundled libraries list
set(PLUGIN_BUNDLED_LIBRARIES)

# Process standard plugins
foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(ephemeral/.plugin_symlinks/${plugin}/linux plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

# Process FFI plugins
foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(ephemeral/.plugin_symlinks/${ffi_plugin}/linux plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)

# Create placeholder target for plugin linking if it doesn't exist
if(NOT TARGET FlutterGeneratedPluginTarget)
  add_custom_target(FlutterGeneratedPluginTarget ALL)
endif()

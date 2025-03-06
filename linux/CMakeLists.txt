# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "double_free_race_mre")
project(${PROJECT_NAME} LANGUAGES CXX)

#target_link_libraries(${PLUGIN_NAME} INTERFACE
#  "${CMAKE_CURRENT_SOURCE_DIR}/lib/libnative.so"
#)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(double_free_race_mre_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/lib/libnative.so"
  PARENT_SCOPE
)

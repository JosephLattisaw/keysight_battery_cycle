cmake_minimum_required(VERSION 3.0.0)
project(keysight_backend VERSION 0.1.0)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

SET(CMAKE_INSTALL_RPATH "$ORIGIN/")

add_subdirectory(logger)
add_subdirectory(visa_handler)
add_subdirectory(backend)

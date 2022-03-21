project(find_devices)
cmake_minimum_required(VERSION 2.8)

find_library(VISA_LIBRARY
    NAMES ktvisa32
    HINTS "/opt/keysight/iolibs"
)

if(NOT VISA_LIBRARY)
    message(FATAL_ERROR "could not find visa library")
endif()

add_executable(find_devices FindDevices.cpp stdafx.cpp)
target_link_libraries(find_devices ${VISA_LIBRARY})


project(error_handling)
cmake_minimum_required(VERSION 2.8)

find_library(VISA_LIBRARY
    NAMES ktvisa32
    HINTS "/opt/keysight/iolibs"
)

if(NOT VISA_LIBRARY)
    message(FATAL_ERROR "could not find visa library")
endif()

add_executable(error_handling ErrorHandling.cpp stdafx.cpp)
target_link_libraries(error_handling ${VISA_LIBRARY})


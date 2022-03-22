cmake_minimum_required(VERSION 3.0.0)
project(keysight_controller VERSION 0.1.0)

include(CTest)
enable_testing()

find_library(VISA_LIBRARY
    NAMES ktvisa32
    HINTS "/opt/keysight/iolibs"
)

if(NOT VISA_LIBRARY)
    message(FATAL_ERROR "could not find visa library")
endif()

add_executable(keysight_controller main.cpp)
target_link_libraries(keysight_controller ${VISA_LIBRARY})

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

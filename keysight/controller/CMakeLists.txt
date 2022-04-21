cmake_minimum_required(VERSION 3.0.0)
project(keysight_controller VERSION 0.1.0)

find_package(Boost 1.74.0 REQUIRED)

add_definitions(-std=c++17)

include(CTest)
enable_testing()

find_library(VISA_LIBRARY
    NAMES ktvisa32
    HINTS "/opt/keysight/iolibs"
)

if(NOT VISA_LIBRARY)
    message(FATAL_ERROR "could not find visa library")
endif()

set(command_handler_src sequence_commands.cpp keysight.cpp)

add_executable(keysight_controller main.cpp controller.cpp logger.cpp common.cpp ${command_handler_src})
target_link_libraries(keysight_controller ${VISA_LIBRARY} ${Boost_LIBRARIES} pthread)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

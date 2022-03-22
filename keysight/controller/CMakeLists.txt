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

set(command_handler_src calibration_commands.cpp cell_commands.cpp digital_commands.cpp ieee488_common_commands.cpp 
lxi_commands.cpp measure_commands.cpp output_commands.cpp root_commands.cpp sequence_commands.cpp status_commands.cpp
system_commands.cpp)

add_executable(keysight_controller main.cpp controller.cpp logger.cpp ${command_handler_src})
target_link_libraries(keysight_controller ${VISA_LIBRARY})

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

cmake_minimum_required(VERSION 3.0.0)
project(backend VERSION 0.1.0)

include(CTest)
enable_testing()

set(Boost_USE_STATIC_LIBS        OFF)
ADD_DEFINITIONS("-DBOOST_ALL_NO_LIB")

find_package(Boost 1.74.0 REQUIRED COMPONENTS date_time)

if (WIN32)
set(visa_library_location "C:/Program Files/IVI Foundation/VISA/Win64/ktvisa/Lib_x64/msc")
set(visa_include_directory "C:/Program Files/IVI Foundation/VISA/Win64/Include")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17")
set(external_libraries "")
else()
set(visa_library_location "/opt/keysight/iolibs")
set(visa_include_directory "/opt/keysight/iolibs/include")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
set(external_libraries pthread -lrt)
endif()

find_library(VISA_LIBRARY
    NAMES ktvisa32
    HINTS ${visa_library_location}
)

if(NOT VISA_LIBRARY)
    message(FATAL_ERROR "could not find visa library")
endif()

include_directories(${Boost_INCLUDE_DIRS}) 
include_directories(${visa_include_directory})
include_directories(../logger)
include_directories(../visa_handler)

set(sequence_parsing_SRC sequences/sequence_parser.cpp sequences/sequence_step.cpp sequences/sequence_test.cpp sequences/sequence.cpp)
set(battery_cycling_SRC battery_cycler/battery_cell.cpp battery_cycler/keysight.cpp battery_cycler/module_card.cpp)
set(keysight_backend_SRC include/dart_api_dl.c keysight_backend.cpp backend.cpp ${sequence_parsing_SRC} ${battery_cycling_SRC})

add_library(keysight_backend SHARED ${keysight_backend_SRC})
target_link_libraries(keysight_backend ${VISA_LIBRARY} ${external_libraries} ${Boost_LIBRARIES} logger visa_handler)

set_target_properties(keysight_backend PROPERTIES
        BUILD_WITH_INSTALL_RPATH FALSE
        LINK_FLAGS "-Wl,-rpath,$ORIGIN/")

install(TARGETS keysight_backend LIBRARY DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

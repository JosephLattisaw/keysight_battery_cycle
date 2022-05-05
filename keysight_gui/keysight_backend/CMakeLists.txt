cmake_minimum_required(VERSION 3.0.0)
project(keysight_backend VERSION 0.1.0)

include(CTest)
enable_testing()

find_package(Boost 1.74.0 REQUIRED)

include_directories(${Boost_INCLUDE_DIRS}) 

find_library(VISA_LIBRARY
    NAMES ktvisa32
    HINTS "/opt/keysight/iolibs" "C:/Program Files/IVI Foundation/VISA/Win64/ktvisa/Lib_x64/msc"
)

if(NOT VISA_LIBRARY)
    message(FATAL_ERROR "could not find visa library")
ELSE()

IF (WIN32)
include_directories("C:/Program Files/IVI Foundation/VISA/Win64/Include")
ENDIF()

endif()

IF (WIN32)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17")
ELSE()
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std:c++17")
ENDIF()

set(keysight_backend_SRC include/dart_api_dl.c keysight_backend.cpp backend.cpp sequence_parser.cpp logger.cpp common.cpp keysight.cpp)

add_library(keysight_backend SHARED ${keysight_backend_SRC})
target_link_libraries(keysight_backend ${VISA_LIBRARY} ${Boost_LIBRARIES} pthread -lrt)

add_executable(keysight_backend_test ${keysight_backend_SRC})
target_link_libraries(keysight_backend_test ${VISA_LIBRARY} ${Boost_LIBRARIES} pthread -lrt)

install(TARGETS keysight_backend LIBRARY DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

cmake_minimum_required(VERSION 3.0.0)
project(keysight_backend VERSION 0.1.0)

include(CTest)
enable_testing()

find_package(Boost 1.74.0 REQUIRED)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")

set(keysight_backend_SRC include/dart_api_dl.c keysight_backend.cpp backend.cpp sequence_parser.cpp logger.cpp)

add_library(keysight_backend SHARED ${keysight_backend_SRC})
target_link_libraries(keysight_backend ${Boost_LIBRARIES} pthread)

add_executable(keysight_backend_test ${keysight_backend_SRC})
target_link_libraries(keysight_backend_test ${Boost_LIBRARIES} pthread)

install(TARGETS keysight_backend LIBRARY DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

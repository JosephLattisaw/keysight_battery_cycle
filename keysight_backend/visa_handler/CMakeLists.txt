cmake_minimum_required(VERSION 3.0.0)
project(visa_handler VERSION 0.1.0)

include(CTest)
enable_testing()

include_directories(../logger)

add_library(visa_handler SHARED visa_handler.cpp)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

set_target_properties(visa_handler PROPERTIES
        BUILD_WITH_INSTALL_RPATH FALSE
        LINK_FLAGS "-Wl,-rpath,$ORIGIN/")

install(TARGETS visa_handler LIBRARY DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")

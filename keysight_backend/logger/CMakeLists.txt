cmake_minimum_required(VERSION 3.0.0)
project(logger VERSION 0.1.0)

include(CTest)
enable_testing()

add_library(logger SHARED logger.cpp)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

set_target_properties(logger PROPERTIES
        BUILD_WITH_INSTALL_RPATH FALSE
        LINK_FLAGS "-Wl,-rpath,$ORIGIN/")
        
install(TARGETS logger LIBRARY DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")

project(project_x LANGUAGES CXX)

find_package(Poco REQUIRED)

configure_file(Platform.h.in "${CMAKE_CURRENT_BINARY_DIR}/include/project_x/Platform.h" @ONLY)
configure_file(Version.h.in "${CMAKE_CURRENT_BINARY_DIR}/include/project_x/Version.h" @ONLY)

set(SOURCES
        src/Clock.cpp
        )

set(PUBLIC_HEADERS
        include/project_x/Common.h
        include/project_x/Clock.h
        )

add_library(project_x ${LIB_MODE} ${SOURCES} ${PUBLIC_HEADERS})

target_include_directories(project_x
        PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        )

target_compile_options(project_x
        PRIVATE
        $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra -Wpedantic>
        )

target_link_libraries(project_x
        PRIVATE
        Poco::Foundation
        )

target_compile_definitions(project_x
        PUBLIC
        -DPOCO_WIN32_UTF8
        -DUNICODE -D_UNICODE
        )

if(ENABLE_TESTS)
    add_subdirectory(testsuite)
endif()

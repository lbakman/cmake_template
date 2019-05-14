project(project_y LANGUAGES CXX)

find_package(Poco REQUIRED Util)

set(SOURCES
        src/ProjectApp.h
        src/ProjectApp.cpp
        )

add_executable(project_y ${SOURCES} main.cpp)

target_include_directories(project_y
        PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
        )

target_compile_options(project_y
        PRIVATE
        $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra -Wpedantic>
        )

target_compile_definitions(project_y
        PRIVATE
        -DUNICODE -D_UNICODE
        -DMINGW_HAS_SECURE_API
        )

target_link_libraries(project_y
        PRIVATE
        Poco::Util Poco::Foundation project_x
        )

target_link_options(project_y
        PRIVATE
        -municode)

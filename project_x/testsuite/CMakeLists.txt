find_package(GMock REQUIRED COMPONENTS GMock)

set(SOURCES
        src/Clock_test.cpp
        )

add_executable(project_x_test ${SOURCES})

target_include_directories(project_x_test
        PRIVATE
        ${project_x_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        )

target_link_libraries(project_x_test
        PRIVATE
        GMock::Main project_x
        )

target_compile_definitions(project_x_test
        PRIVATE
        -DTEST_WORKING_DIR=\"${CMAKE_CURRENT_SOURCE_DIR}\"
        )

add_test(NAME project_x_test WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND $<TARGET_FILE:project_x_test>)
add_dependencies(check project_x_test)

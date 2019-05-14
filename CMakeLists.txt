cmake_minimum_required (VERSION 3.14)
project(my_project VERSION 1.0.0.0)

list(INSERT CMAKE_MODULE_PATH 0
        "${CMAKE_SOURCE_DIR}/cmake"
        "${CMAKE_BINARY_DIR}"
        )
include(ProjectSettings)

conan_cmake_run(CONANFILE conanfile.txt
        BASIC_SETUP
        OPTIONS ${CONAN_RUN_OPTIONS} UPDATE
        BUILD missing)

add_subdirectory(project_x)
add_subdirectory(project_y)

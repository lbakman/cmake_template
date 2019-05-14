set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_DEBUG_POSTFIX "d")
set(CMAKE_RELWITHDEBINFO_POSTFIX "rd")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
string(TIMESTAMP PROJECT_BUILD_DATE "%d.%m.%Y")
string(TIMESTAMP PROJECT_BUILD_TIME "%H:%M:%S")

# Conan sets the following CMAKE variable by default. This cases cmake to display a warning about not being used.
# The following line marks the variable as being referenced from the project and hence the warning disappears
set(ignoreWarningAbout "${CMAKE_EXPORT_NO_PACKAGE_REGISTRY}")

option(CMAKE_ENABLE_CONAN  
  "Enable support for Conan within CMake" ON)

option(BUILD_STATIC
  "Set to OFF|ON (default is ON) to control build of libraries as STATIC library" ON)

option(ENABLE_TESTS
  "Set to OFF|ON (default is ON) to control build of project tests" ON)

option(ENABLE_LOGGING
        "Set to OFF|ON (default is ON) to disable or enable logging" ON)

# Prepare for testing using ctest when running "make check"
set(CMAKE_CTEST_COMMAND ${CMAKE_CTEST_COMMAND} -V)
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND})

# Uncomment from next two lines to force static or dynamic library, default is autodetection
if(BUILD_STATIC)
    # set( LIB_MODE_DEFINITIONS -DPOCO_STATIC -DPOCO_NO_AUTOMATIC_LIBS)
    set( LIB_MODE STATIC )
    message(STATUS "Building static libraries")
else(BUILD_STATIC)
    set( LIB_MODE SHARED )
    # set( LIB_MODE_DEFINITIONS -DPOCO_NO_AUTOMATIC_LIBS)
    message(STATUS "Building dynamic libraries")
endif(BUILD_STATIC)
  
include(ProjectCheckPlatform)

if(CMAKE_ENABLE_CONAN)
    # Download automatically, you can also just copy the conan.cmake file
    if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
        message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan/cmake-conan")
        file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/v0.14/conan.cmake"
            "${CMAKE_BINARY_DIR}/conan.cmake")
    endif()

    include(${CMAKE_BINARY_DIR}/conan.cmake)
endif(CMAKE_ENABLE_CONAN)

message(STATUS "Project: ${PROJECT_NAME}")

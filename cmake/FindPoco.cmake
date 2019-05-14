# FindPoco
# --------
#
# Find the native Poco includes and libraries.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
# This module defines the following :prop_tgt:`IMPORTED` targets:
#
# ``Poco::Foundation``
#   The Poco ``Foundation`` library, if found; adds additional dependencies automatically
# ``Poco::<component>``
#   The Poco ``component`` library, if found
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
#   Poco_INCLUDE_DIRS     - where to find Poco includes.
#   Poco_LIBRARIES        - List of libraries when using Poco.
#   Poco_FOUND            - True if Poco is found.
#
# Hints
# ^^^^^
#
# A user may set ``Poco_ROOT`` to a Poco installation root to tell this
# module where to look.
include(CMakeParseArguments)
include(CMakeFindDependencyMacro)

set(Poco_TARGETS "")

set(_poco_release_suffix "")
set(_poco_debug_suffix "d")

# Determine library suffix for Visual Studio compiler
function(_poco_detect_vs_runtime result build_type)
    string(TOUPPER "${build_type}" build_type)
    set(variables CMAKE_CXX_FLAGS_${build_type} CMAKE_C_FLAGS_${build_type} CMAKE_CXX_FLAGS CMAKE_C_FLAGS)
    foreach(variable ${variables})
        #message(WARNING "${variable}: ${${variable}}")
        string(REPLACE " " ";" flags ${${variable}})
        foreach (flag ${flags})
            if(${flag} STREQUAL "/MD" OR ${flag} STREQUAL "/MDd" OR ${flag} STREQUAL "/MT" OR ${flag} STREQUAL "/MTd")
                string(SUBSTRING ${flag} 1 -1 runtime)
                string(TOLOWER ${runtime} runtime)
                #message("!!! Runtime: ${runtime}")
                set(${result} ${runtime} PARENT_SCOPE)
                return()
            endif()
        endforeach()
    endforeach()
    if(${build_type} STREQUAL "DEBUG")
        set(${result} "mdd" PARENT_SCOPE)
    else()
        set(${result} "md" PARENT_SCOPE)
    endif()
endfunction()

if(MSVC)
    _poco_detect_vs_runtime(_poco_vs_runtime_release "Release")
    _poco_detect_vs_runtime(_poco_vs_runtime_debug "Debug")

    if(_poco_vs_runtime_release)
        set(_poco_release_suffix "${_poco_vs_runtime_release}")
    endif(_poco_vs_runtime_release)
    if(_poco_vs_runtime_debug)
        set(_poco_debug_suffix "${_poco_vs_runtime_debug}")
    endif(_poco_vs_runtime_debug)
endif(MSVC)

# Macro to help define targets for Poco components.
macro(_poco_define_target)
    cmake_parse_arguments(
            _POCO_TARGET
            ""
            "TYPE;NAME;COMPONENT"
            "DEPS"
            ${ARGN}
    )

    if(NOT _POCO_TARGET_NAME)
        message(FATAL_ERROR "You must provide a name")
    endif(NOT _POCO_TARGET_NAME)
    if(NOT _POCO_TARGET_TYPE)
        set(_POCO_TARGET_TYPE UNKNOWN)
    endif(NOT _POCO_TARGET_TYPE)

    if(NOT TARGET Poco::${_POCO_TARGET_NAME})
        # message(STATUS "Defining target: Poco::${_POCO_TARGET_NAME}" )
        add_library(Poco::${_POCO_TARGET_NAME} ${_POCO_TARGET_TYPE} IMPORTED)
        list(APPEND Poco_TARGETS "Poco::${_POCO_TARGET_NAME}")
    endif()

    if(_POCO_TARGET_COMPONENT)
        if(Poco_INCLUDE_DIRS)
            set_target_properties(Poco::${_POCO_TARGET_NAME} PROPERTIES
                    INTERFACE_INCLUDE_DIRECTORIES "${Poco_INCLUDE_DIRS}")
        endif()

        if(EXISTS "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY}")
            # message(STATUS "Adding Library: ${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY}")
            set_target_properties(Poco::${_POCO_TARGET_NAME} PROPERTIES
                    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
                    IMPORTED_LOCATION "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY}")
            list(APPEND Poco_LIBRARIES "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY}")
        endif()
        if(EXISTS "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_DEBUG}")
            # message(STATUS "Adding Library: ${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_DEBUG}")
            set_property(TARGET Poco::${_POCO_TARGET_NAME} APPEND PROPERTY
                    IMPORTED_CONFIGURATIONS DEBUG)
            set_target_properties(Poco::${_POCO_TARGET_NAME} PROPERTIES
                    IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
                    IMPORTED_LOCATION_DEBUG "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_DEBUG}")
            list(APPEND Poco_LIBRARIES "debug" "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_DEBUG}" )
        endif()
        if(EXISTS "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_RELEASE}")
            # message(STATUS "Adding Library: ${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_RELEASE}")
            set_property(TARGET Poco::${_POCO_TARGET_NAME} APPEND PROPERTY
                    IMPORTED_CONFIGURATIONS RELEASE)
            set_target_properties(Poco::${_POCO_TARGET_NAME} PROPERTIES
                    IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
                    IMPORTED_LOCATION_RELEASE "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_RELEASE}")
            list(APPEND Poco_LIBRARIES "optimized" "${POCO_${_POCO_TARGET_COMPONENT}_LIBRARY_RELEASE}" )
        endif()
    endif(_POCO_TARGET_COMPONENT)

    foreach(_dep ${_POCO_TARGET_DEPS})
        # message(STATUS "Adding dependency ${_dep} to Poco::${_POCO_TARGET_NAME}")
        set_property(TARGET Poco::${_POCO_TARGET_NAME} APPEND PROPERTY
                INTERFACE_LINK_LIBRARIES "${_dep}")
    endforeach(_dep)
endmacro(_poco_define_target)

# Debug function for dumping a property for a target
function(_poco_dump_property _target _name _property)
    get_property(propval TARGET ${_target} PROPERTY ${_property} SET)
    if (propval)
        get_target_property(propval ${_target} ${_property})
        message (" - ${_name}: ${propval}")
    else()
        message (" - ${_name}: None")
    endif()
endfunction()

# Debug function for dumping all properties for a target
function(_poco_dump_target _target)
    if(NOT TARGET "${_target}")
        message(WARNING "Target ${_target} does not exist")
    endif()

    get_target_property(_poco_target_type ${_target} TYPE)

    message("Target: ${_target}")
    _poco_dump_property("${_target}" "Include" INTERFACE_INCLUDE_DIRECTORIES)
    _poco_dump_property("${_target}" "Library" INTERFACE_LINK_LIBRARIES)
    if(NOT ${_poco_target_type} STREQUAL "INTERFACE_LIBRARY")
        _poco_dump_property("${_target}" "Release" IMPORTED_LOCATION_RELEASE)
        _poco_dump_property("${_target}" "Debug"   IMPORTED_LOCATION_DEBUG)
    endif ()
endfunction()

# Debug function for dumping all properties for a component
function(_poco_dump_component _component)
    # Create a variable containing the name of the component only
    _poco_dump_target("Poco::${_component}")
endfunction()

# Macro to help find the library components for Poco.
macro(_poco_find_library _component)
    find_library(POCO_${_component}_LIBRARY_RELEASE
            NAMES
            "Poco${_component}"
            "Poco${_component}${_poco_release_suffix}"
            NAMES_PER_DIR
            HINTS ${_POCO_SEARCHES}
            PATH_SUFFIXES lib
            CMAKE_FIND_ROOT_PATH_BOTH)
    find_library(POCO_${_component}_LIBRARY_DEBUG
            NAMES
            "Poco${_component}d"
            "Poco${_component}${_poco_debug_suffix}"
            NAMES_PER_DIR
            HINTS ${_POCO_SEARCHES}
            PATH_SUFFIXES lib
            CMAKE_FIND_ROOT_PATH_BOTH)

    if(POCO_${_component}_LIBRARY_RELEASE OR POCO_${_component}_LIBRARY_DEBUG )
        _poco_define_target(NAME "${_component}" COMPONENT "${_component}")
    endif()

    mark_as_advanced(POCO_${_component}_LIBRARY_RELEASE)
    mark_as_advanced(POCO_${_component}_LIBRARY_DEBUG)
endmacro(_poco_find_library)

# Search POCO_ROOT first if it is set.
if(Poco_ROOT)
    set(_POCO_SEARCH_ROOT PATHS ${Poco_ROOT} NO_DEFAULT_PATH)
    list(APPEND _POCO_SEARCHES _POCO_SEARCH_ROOT)
endif()
# We need an empty entry to make sure we trigger the find_path
list(APPEND _POCO_SEARCHES " ")

# Find the main header file for Poco.
foreach(search ${_POCO_SEARCHES})
    find_path(Poco_INCLUDE_DIRS
            NAMES Poco/Poco.h
            ${${search}}
            PATH_SUFFIXES include
            CMAKE_FIND_ROOT_PATH_BOTH)
endforeach()

# Build a list of requested Poco components.
# If "Poco" is not provided as part of the component name, we add it.
# Make sure we do not have any duplicates.
set( _POCO_REQUESTED )
foreach( _poco_component ${Poco_FIND_COMPONENTS})
    if(${_poco_component} MATCHES "^Poco")
        string(REGEX REPLACE "^Poco" "" _poco_component "${_poco_component}")
    endif()
    list( APPEND _POCO_REQUESTED "${_poco_component}")
endforeach()
list( APPEND _POCO_REQUESTED "Foundation")
list( REMOVE_DUPLICATES _POCO_REQUESTED)

# For each of the requested components, try to locate the library file
# And create a TARGET for it in the form Poco::"component" as well as a TARGET Poco::Poco
# containing all requested components.
foreach( _poco_component ${_POCO_REQUESTED})
    _poco_find_library("${_poco_component}")
endforeach()

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( Poco DEFAULT_MSG Poco_INCLUDE_DIRS Poco_LIBRARIES )

if(Poco_FOUND)
    # We found Poco, now we attempt to set up the dependencies
    find_dependency(Threads)
    foreach( _poco_component ${_POCO_REQUESTED})
        list(APPEND Poco_COMPONENT_TARGETS "Poco::${_poco_component}")
    endforeach()

    set(Poco_DEPENDENCY_LIBRARIES "Threads::Threads")
    if(WIN32)
        list(APPEND Poco_DEPENDENCY_LIBRARIES "ws2_32" "Iphlpapi")
    else()
        list(APPEND Poco_DEPENDENCY_LIBRARIES "dl" "rt")
    endif()

    _poco_define_target(NAME "Foundation" DEPS ${Poco_DEPENDENCY_LIBRARIES})
    _poco_define_target(NAME "Poco" TYPE INTERFACE DEPS ${Poco_COMPONENT_TARGETS} ${Poco_DEPENDENCY_LIBRARIES})

    mark_as_advanced(Poco_DEPENDENCY_LIBRARIES)
    mark_as_advanced(Poco_COMPONENT_TARGETS)
endif(Poco_FOUND)

mark_as_advanced(Poco_INCLUDE_DIRS Poco_TARGETS)

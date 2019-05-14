include(CheckIncludeFileCXX)
include(CheckLibraryExists)
include(CheckFunctionExists)
include(TestBigEndian)

test_big_endian(TC_BIG_ENDIAN)

check_include_file_cxx(windows.h HAVE_WINDOWS_H)
check_include_file_cxx(sys/types.h HAVE_SYS_TYPES_H)

set (CMAKE_REQUIRED_INCLUDES unistd.h)
check_function_exists(fork HAVE_FORK)
set (CMAKE_REQUIRED_INCLUDES)

set (CMAKE_REQUIRED_LIBRARIES rt)
check_function_exists(clock_gettime HAVE_CLOCK_GETTIME)
check_function_exists(clock_nanosleep HAVE_CLOCK_NANOSLEEP)
set (CMAKE_REQUIRED_LIBRARIES)

set (CMAKE_REQUIRED_INCLUDES sys/time.h)
check_function_exists(gethrtime HAVE_GETHRTIME)
set (CMAKE_REQUIRED_INCLUDES)

if(MSVC)
    add_definitions(-DHAVE_MSVC)
endif (MSVC)

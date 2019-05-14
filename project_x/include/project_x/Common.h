#ifndef PROJECT_X_COMMON_H
#define PROJECT_X_COMMON_H

#include "Poco/Bugcheck.h"
#include <errno.h>
#include <cstring>
#include <memory>

#if defined(NDEBUG)
#define MY_ASSERT(x)
#define MY_ASSERT_MSG(x, msg) (void)(x)
//  Provides convenient way to check for errno-style errors.
#define MY_ASSERT_ERRNO(x) (void)(x)
//  Provides convenient way to check whether memory allocation have succeeded.
#define MY_CHECK_PTR(x)
#else // defined(NDEBUG)
#define MY_ASSERT(x) poco_assert(x)
#define MY_ASSERT_MSG(x, msg) poco_assert_msg(x, msg)
//  Provides convenient way to check for errno-style errors.
#define MY_ASSERT_ERRNO(x) poco_assert_msg(x, std::strerror(errno))
//  Provides convenient way to check whether memory allocation have succeeded.
#define MY_CHECK_PTR(x) poco_check_ptr(x)
#endif // defined(NDEBUG)

#endif //PROJECT_X_COMMON_H

#include "project_x/Clock.h"
#include "project_x/Common.h"

#if defined _MSC_VER
#if defined _WIN32_WCE
#include <cmnintrin.h>
#else
#include <intrin.h>
#endif
#endif

#if !defined HAVE_WINDOWS_H
#include <sys/time.h>
#endif

#if defined HAVE_CLOCK_GETTIME || defined HAVE_GETHRTIME
#include <time.h>
#endif

#include <cmath>
#include <limits>

namespace ProjectX {

uint64_t Clock::nowUs() {
#if defined HAVE_WINDOWS_H
	//  Get the high resolution counter's accuracy.
	LARGE_INTEGER ticksPerSecond;
	QueryPerformanceFrequency (&ticksPerSecond);

	//  What time is it?
	LARGE_INTEGER tick;
	QueryPerformanceCounter (&tick);

	//  Convert the tick number into the number of seconds
	//  since the system was started.
	double ticks_div = ticksPerSecond.QuadPart / 1000000.0;
	return (uint64_t) (tick.QuadPart / ticks_div);
#elif defined HAVE_CLOCK_GETTIME && defined CLOCK_MONOTONIC
	//  Use POSIX clock_gettime function to get precise monotonic time.
	struct timespec ts = {0, 0};
	int32_t rc = clock_gettime(CLOCK_MONOTONIC, &ts);
	if (rc != 0) {
		//  Use POSIX gettimeofday function to get precise time.
		struct timeval tv = {0, 0};
		rc = gettimeofday(&tv, nullptr);
		MY_ASSERT_ERRNO(rc == 0);
		return (tv.tv_sec * 1000000U + tv.tv_usec);
	}
	return (ts.tv_sec * 1000000U + ts.tv_nsec / 1000U);
#elif defined HAVE_GETHRTIME
	return (gethrtime () / 1000);
#else
	//  Use POSIX gettimeofday function to get precise time.
	struct timeval tv = {0, 0};
	int rc = gettimeofday (&tv, nullptr);
	MY_ASSERT_ERRNO(rc == 0);
	return (tv.tv_sec * 1000000U + tv.tv_usec);
#endif

}

uint32_t Clock::nowMs() {
	return static_cast<uint32_t>(nowUs() / 1000);
}

uint64_t Clock::rdtsc()
{
#if (defined _MSC_VER && (defined _M_IX86 || defined _M_X64))
	return __rdtsc ();
#elif (defined __GNUC__ && (defined __i386__ || defined __x86_64__))
	uint32_t low, high;
	__asm__ volatile ("rdtsc" : "=a" (low), "=d" (high));
	return static_cast<uint64_t>(high) << 32U | low;
#elif (defined __SUNPRO_CC && (__SUNPRO_CC >= 0x5100) && (defined __i386 || \
		defined __amd64 || defined __x86_64))
	union {
		uint64_t u64val;
		uint32_t u32val [2];
	} tsc;
	asm("rdtsc" : "=a" (tsc.u32val [0]), "=d" (tsc.u32val [1]));
	return tsc.u64val;
#elif defined(__s390__)
	uint64_t tsc;
	asm("\tstck\t%0\n" : "=Q" (tsc) : : "cc");
	return(tsc);
#elif defined HAVE_CLOCK_GETTIME && defined CLOCK_MONOTONIC
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return (uint64_t)(ts.tv_sec) * 1000000000U + ts.tv_nsec;
#else
	return nowUs();
#endif
}

void Clock::sleep(uint32_t ms) {
#if defined HAVE_WINDOWS_H
	::Sleep(ms);
#else
	struct timespec req = {0, 0};
	req.tv_sec = ms / 1000;
	req.tv_nsec = (ms % 1000) * (1000 * 1000);
	while (clock_nanosleep(CLOCK_MONOTONIC, 0, &req, &req) == -1 && (errno == EINTR))
		continue;
#endif
}

uint64_t Clock::toMs(double time) {
	const static double FACTOR = 1000.0;

	if (time <= 0.0)
		return 0;

	time = time * FACTOR;
	if (time > std::numeric_limits<uint64_t>::max())
		time = std::numeric_limits<uint64_t>::max();

	return static_cast<uint64_t>(time);
}

uint64_t Clock::toUs(double time) {
	const static double FACTOR = 1000000.0;

	if (time <= 0.0)
		return 0;

	time = time * FACTOR;
	if (time > std::numeric_limits<uint64_t>::max())
		time = std::numeric_limits<uint64_t>::max();

	return static_cast<uint64_t>(time);
}

}

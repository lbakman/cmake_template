#ifndef PROJECT_X_CLOCK_H
#define PROJECT_X_CLOCK_H

#include <stdint.h>

namespace ProjectX {

class Clock {
public:
    Clock() = delete;
    ~Clock() = delete;
    Clock(const Clock &) = delete;
    Clock& operator=(const Clock &) = delete;

    /**
     * Get the CPU Time Stamp Counter (TSC) if available.
     * @return The TSC if available, 0 otherwise.
     */
    static uint64_t rdtsc();

    /**
     * Convert a time expressed using a double to milliseconds
     * @param time A timestamp expressed as a double.
     * @return An unsigned integer value holding the time in milliseconds.
     */
    static uint64_t toMs(double time);

    /**
     * Convert a time expressed using a double to microseconds
     * @param time A timestamp expressed as a double.
     * @return An unsigned integer value holding the time in microseconds.
     */
    static uint64_t toUs(double time);

    /**
     * Get a monotonic incrementing timestamp in microsecond resolution.
     * @return A time stamp in microsecond resolution.
     */
    static uint64_t nowUs();

    /**
     * Get a monotonic incrementing timestamp in millisecond resolution.
     * @return A time stamp in millisecond resolution.
     */
    static uint32_t nowMs();

    /**
     * Sleep for the specified number of milliseconds.
     * @param ms The number of milliseconds to sleep for.
     */
    static void sleep(uint32_t ms);
};

}

#endif //PROJECT_X_CLOCK_H

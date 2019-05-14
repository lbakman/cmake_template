#include "project_x/Clock.h"
#include <gtest/gtest.h>

using ProjectX::Clock;

TEST(Clock, time_us) {
	EXPECT_NE(Clock::nowUs(), 0U);
}

TEST(Clock, time_ms) {
	EXPECT_NE(Clock::nowMs(), 0U);
}

TEST(Clock, convert_us) {
	uint64_t us = Clock::toUs(1.58473653875687536583);
	EXPECT_EQ(us, 1584736);
}

TEST(Clock, convert_ms) {
	uint32_t ms = Clock::toMs(1.58473653875687536583);
	EXPECT_EQ(ms, 1584);
}

TEST(Clock, rdtsc) {
	uint64_t rdtsc1 = Clock::rdtsc();
	uint64_t rdtsc2 = Clock::rdtsc();
	EXPECT_GT(rdtsc2, rdtsc1);
}

TEST(Clock, sleep_us) {
	uint64_t average = 0;
	for(int i=0;i<100;i++)
	{
		uint64_t begin = Clock::nowUs();
		Clock::sleep(10);
		uint64_t end = Clock::nowUs();
		if (i > 0)
		{
			uint32_t diff = end - begin;
			average = (average + diff) >> 1U;
		} else
		{
			average = end - begin;
		}
	}
	// The timeout should be within at least a tenth of the timeout
	EXPECT_NEAR(average, 10 * 1000, 1000);
}

TEST(Clock, sleep_ms) {
	uint32_t average = 0;
	for(int i=0;i<100;i++)
	{
		uint64_t begin = Clock::nowMs();
		Clock::sleep(10);
		uint64_t end = Clock::nowMs();
		if(i > 0) {
			uint32_t diff = end - begin;
			average = (average + diff) >> 1U;
		}
		else {
			average = end - begin;
		}
	}
	// The timeout should be within at least a tenth of the timeout
	EXPECT_NEAR(average, 10, 1);
}

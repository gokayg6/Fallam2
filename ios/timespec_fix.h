// Fix for timespec incomplete type error on iOS 26.1 SDK / Xcode 16+
// This header ensures timespec is defined before C++ headers try to use it

#ifndef TIMESPEC_FIX_H
#define TIMESPEC_FIX_H

// Include time.h early to ensure timespec is defined
#include <time.h>
#include <sys/time.h>
#include <sys/types.h>

// Ensure the C11 timespec_get is available
#ifdef __cplusplus
extern "C" {
#endif

#ifndef TIME_UTC
#define TIME_UTC 1
#endif

#ifdef __cplusplus
}
#endif

#endif /* TIMESPEC_FIX_H */


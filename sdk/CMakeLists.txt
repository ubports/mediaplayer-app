project(sdkhelper)

set(sdkhelper_HDRS
    sharefile.h)

set(sdkhelper_SRCS
    sharefile.cpp)

add_library(sdkhelper STATIC
    ${sdkhelper_SRCS})

qt5_use_modules(sdkhelper Core)

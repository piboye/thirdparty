##
## Copyright (C) XXX. All rights reserved.
##
## \file     CMakeLists.txt
## \author   RainVan(Yunfeng.Xiao)
## \date     Jan 2010
## \version  1.0
## \brief    Detail cmake build script
##

cmake_minimum_required(VERSION 2.8)

set(TARGET mod_json)

include_directories(./include)
file(GLOB TARGET_SRCS ./src/*.c ./src/*.cc)
add_library(${TARGET} STATIC ${TARGET_SRCS})

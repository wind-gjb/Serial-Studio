#
# Copyright (c) 2024 Alex Spataru <https://github.com/alex-spataru>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

cmake_minimum_required(VERSION 3.19)

add_library(simde INTERFACE)
target_include_directories(simde INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})

#
# ARM64 processor optimizations
#
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm|aarch64)")
 message(STATUS "Detected ARM architecture")

 include(CheckCXXCompilerFlag)
 check_cxx_compiler_flag("-mfpu=neon" COMPILER_SUPPORTS_NEON)
 check_cxx_compiler_flag("-march=armv8-a+simd" COMPILER_SUPPORTS_ARMV8_SIMD)

 if(COMPILER_SUPPORTS_ARMV8_SIMD)
  target_compile_options(simde INTERFACE -march=armv8-a+simd -DCPU_ARM64)
  message(STATUS "Using ARMv8 Advanced SIMD optimizations")
 elseif(COMPILER_SUPPORTS_NEON)
  target_compile_options(simde INTERFACE -mfpu=neon -DCPU_ARM64)
  message(STATUS "Using ARM NEON optimizations")
 else()
  message(WARNING "No SIMD support detected on ARM; falling back to portable mode")
  add_compile_definitions(SIMDE_NO_NATIVE)
 endif()

#
# Intel/AMD processor optimizations
#
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86|x86_64|AMD64)")
 message(STATUS "Detected x86 architecture") 
 if(MSVC)
  target_compile_options(simde INTERFACE /arch:AVX2 /DCPU_X86_64)
  message(STATUS "Enabled AVX2 optimizations for MSVC")
 else()
  target_compile_options(simde INTERFACE -mavx2 -DCPU_X86_64)
  message(STATUS "Enabled AVX2 optimizations for GCC & LLVM")
 endif()

#
# Emulate SIMD instructions on unknown processors
#
else()
 message(WARNING "Unknown architecture; enabling portable fallback")
 add_compile_definitions(SIMDE_NO_NATIVE)
 target_compile_options(simde INTERFACE -DSIMDE_NO_NATIVE)
 
endif()

#
# macOS OpenMP (use homebrew port)
#
if(APPLE)
 include_directories(
  "/opt/homebrew/opt/libomp/include"
  "/opt/homebrew/opt/llvm/include"
 )
 link_directories(
  "/opt/homebrew/opt/libomp/lib"
  "/opt/homebrew/opt/llvm/lib"
 )
endif()

#
# Enable OpenMP SIMD support globally
#
find_package(OpenMP QUIET)
if(OpenMP_CXX_FOUND)
 if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  add_compile_options(/openmp:experimental)
 elseif(CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM")
  add_compile_options(-qopenmp-simd)
 else()
  add_compile_options(${OpenMP_CXX_FLAGS})
 endif()
 add_compile_definitions(SIMDE_ENABLE_OPENMP)
 message(STATUS "OpenMP SIMD support enabled globally")
else()
 message(WARNING "OpenMP not found; SIMD performance may be suboptimal")
endif()

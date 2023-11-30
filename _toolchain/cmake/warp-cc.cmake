# 
# INPUTs:
#   KERNEL: (BOOL) Use freestanding setting
#

include(${CMAKE_CURRENT_LIST_DIR}/_arginput.cmake)

set(me0 ${CMAKE_CURRENT_LIST_DIR})
get_filename_component(sdkdir ${me0}/../.. ABSOLUTE)

set(IN_LINK true)

set(userargs)
foreach(e ${args})
  if("${e}" STREQUAL -c OR "${e}" STREQUAL -E OR
      "${e}" STREQUAL -r)
    set(IN_LINK)
  endif()
  if("${e}" STREQUAL "-Wl,--start-group"
      OR "${e}" STREQUAL "-Wl,--end-group")
  else()
    list(APPEND userargs "${e}")
  endif()
endforeach()

if(KERNEL)
  set(argprefix --target=wasm32 -ffreestanding -Xclang -target-feature
    -Xclang +atomics)
else()
  set(argprefix --target=wasm32 -fPIC -nostdinc -isystem ${sdkdir}/host/lib/clang/18/include
    -isystem ${sdkdir}/prefix/include)
endif()

if(IN_LINK)
  if(KERNEL)

  else()
    list(APPEND argprefix -nostdlib -shared
      -L${sdkdir}/prefix/lib -lm -Wl,--no-entry -Wl,--export=_start_c
      ${sdkdir}/prefix/lib/crt1.o -lc)
  endif()
endif()

execute_process(
  COMMAND ${sdkdir}/host/bin/clang
  ${argprefix}
  ${userargs}
  RESULT_VARIABLE rr)

if(rr)
  message(FATAL_ERROR "Err: ${rr}")
endif()

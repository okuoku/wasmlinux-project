set(root ${CMAKE_CURRENT_LIST_DIR}/..)                                                                                      
set(musl ${root}/musl)
set(dummym ${root}/dummym)
set(prefix ${root}/prefix)
set(toolchain ${root}/_toolchain)
set(host ${root}/host)

# Build Musl

if(NOT EXISTS ${musl}/config.mak)
  execute_process(
    COMMAND ./configure
    --enable-debug --disable-shared
    --build=wasm32 --prefix=${prefix}
    AR=${toolchain}/bin/warp-ar
    RANLIB=${host}/bin/llvm-ranlib
    CC=${toolchain}/bin/warp-cc
    CFLAGS=-fPIC
    WORKING_DIRECTORY ${musl}
    RESULT_VARIABLE rr
    )
  if(rr)
    message(FATAL_ERROR "configure error: ${rr}")
  endif()
endif()

execute_process(
  COMMAND make -j10
  WORKING_DIRECTORY ${musl}
  RESULT_VARIABLE rr
  )

if(rr)
  message(FATAL_ERROR "build error: ${rr}")
endif()

execute_process(
  COMMAND make install
  WORKING_DIRECTORY ${musl}
  RESULT_VARIABLE rr)

if(rr)
  message(FATAL_ERROR "install error: ${rr}")
endif()

# Build Dummy math

execute_process(
  COMMAND ${toolchain}/bin/warp-cc -nostdlib -nostdinc -fPIC
  -g -c -o dummymath.o dummymath.c
  WORKING_DIRECTORY ${dummym}
  RESULT_VARIABLE rr)

if(rr)
  message(FATAL_ERROR "dummym build error: ${rr}")
endif()

execute_process(
  COMMAND rm -f ${prefix}/lib/libm.a
  COMMAND ${toolchain}/bin/warp-ar crs ${prefix}/lib/libm.a dummymath.o
  WORKING_DIRECTORY ${dummym}
  RESULT_VARIABLE rr)

if(rr)
  message(FATAL_ERROR "dummym archive error: ${rr}")
endif()




 

set(root ${CMAKE_CURRENT_LIST_DIR}/..)                                                                                      
set(musl ${root}/musl)
set(prefix ${root}/prefix)
set(toolchain ${root}/_toolchain)
set(host ${root}/host)
 
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


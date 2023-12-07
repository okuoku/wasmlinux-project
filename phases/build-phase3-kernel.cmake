set(root ${CMAKE_CURRENT_LIST_DIR}/..)
set(stubs ${root}/runner/kmwrap/stubs)
set(linux ${root}/lkl-wasm)
set(vmlinuxa ${linux}/vmlinux.a)
set(prefix ${root}/prefix)
set(toolchain ${root}/_toolchain)
set(host ${root}/host)
set(kmdist ${root}/kmdist)

file(MAKE_DIRECTORY ${kmdist})
 
# Generate source
set(update)
if(${vmlinuxa} IS_NEWER_THAN ${stubs}/initsyms.gen.c)
  set(update ON)
endif()
if(NOT EXISTS ${stubs}/initsyms.gen.c)
  set(update ON)
endif()

if(update)
  execute_process(
    COMMAND ${CMAKE_COMMAND} 
    -DNM=${host}/bin/llvm-nm
    -Dvmlinuxa=${vmlinuxa}
    -P ${stubs}/geninittbl.cmake
    WORKING_DIRECTORY ${stubs}
    RESULT_VARIABLE rr)
  if(rr)
    message(FATAL_ERROR "Could not generate initsyms.gen.c: ${rr}")
  endif()
endif()

execute_process(
  COMMAND ${toolchain}/bin/warp-cc
  -c -g -I ${linux}/include -I ${linux}/include/uapi -I ${linux}/arch/lkl/include -I ${linux}/arch/lkl/include/generated
  -I ${linux}/arch/lkl/include/generated/uapi -o initschedclasses.o initschedclasses.c
  WORKING_DIRECTORY ${stubs}
  RESULT_VARIABLE rr)

if(rr)
  message(FATAL_ERROR "Could not build initschedclasses.o: ${rr}")
endif()

execute_process(
  COMMAND ${toolchain}/bin/warp-cc
  -g -nostdlib -Wl,--no-entry -Wl,--error-limit=0
  -Wl,--Map=${kmdist}/lin.map -o ${kmdist}/lin.wasm
  -I ${linux}/arch/lkl/include ${linux}/lib/lib.a
  ${linux}/vmlinux.a initschedclasses.o
  hostwasm_main.c hostwasm_lklops.c hostwasm_nisys.c 
  initsyms.gen.c
  WORKING_DIRECTORY ${stubs}
  RESULT_VARIABLE rr
  )

if(rr)
  message(FATAL_ERROR "Could not link kernel: ${rr}")
endif()


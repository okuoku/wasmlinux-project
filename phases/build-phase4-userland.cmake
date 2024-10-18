set(root ${CMAKE_CURRENT_LIST_DIR}/..)
set(busybox ${root}/busybox)
set(prefix ${root}/prefix)
set(toolchain ${root}/_toolchain)
set(host ${root}/host)
set(umdist ${root}/umdist)

if(NOT EXISTS ${umdist})
  file(MAKE_DIRECTORY ${umdist}/bin)
endif()
 
# Copy .config
if(NOT EXISTS ${busybox}/.config)
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy
    ${root}/configs/busybox.config.mk
    ${busybox}/.config)
endif()
 
execute_process(
  COMMAND make -j10
  AR=${toolchain}/bin/warp-ar
  CC=${toolchain}/bin/warp-hosted-cc
  busybox_unstripped
  WORKING_DIRECTORY ${busybox}
  RESULT_VARIABLE rr
  )

if(rr)
  message(FATAL_ERROR "Err: ${rr}")
endif()

# Don't strip busybox binary
execute_process(
  COMMAND ${CMAKE_COMMAND} -E copy
  ${busybox}/busybox_unstripped ${busybox}/busybox)


execute_process(
  COMMAND make -j10
  AR=${toolchain}/bin/warp-ar
  CC=${toolchain}/bin/warp-hosted-cc
  install
  WORKING_DIRECTORY ${busybox}
  RESULT_VARIABLE rr
  )

execute_process(
  COMMAND ${CMAKE_COMMAND} -E copy
  ${busybox}/busybox ${umdist}/bin/busybox)

if(rr)
  message(FATAL_ERROR "Err: ${rr}")
endif()


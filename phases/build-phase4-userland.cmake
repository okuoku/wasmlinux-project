set(root ${CMAKE_CURRENT_LIST_DIR}/..)
set(busybox ${root}/busybox)
set(prefix ${root}/prefix)
set(toolchain ${root}/_toolchain)
set(host ${root}/host)
 
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

execute_process(
  COMMAND ${CMAKE_COMMAND} -E copy
  ${busybox}/busybox_unstripped ${root}/umdist/bin/busybox)


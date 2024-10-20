set(root ${CMAKE_CURRENT_LIST_DIR}/..)
set(lkl ${root}/lkl-wasm)
set(prefix ${root}/prefix)
set(toolchain ${root}/_toolchain)
set(host ${root}/host)

# Copy .config
if(NOT EXISTS ${lkl}/.config)
  execute_process(COMMAND ${CMAKE_COMMAND}
    -E copy ${root}/configs/linux.config.mk
    ${lkl}/.config)
endif()

# Build linux (ignore error)
# FIXME Adjust path on Cygwin
if(CYGWIN)
  get_filename_component(cmakebin ${CMAKE_COMMAND} DIRECTORY)
  set(ENV{PATH} "${cmakebin}:/usr/bin")
elseif(APPLE)
  set(ENV{PATH} "${root}/_macfixup/bin:$ENV{PATH}")
endif()

execute_process(
  COMMAND make 
  ARCH=lkl CC=${toolchain}/bin/warp-cc
  LD=${toolchain}/bin/warp-ld
  AR=${toolchain}/bin/warp-ar
  NM=${toolchain}/bin/warp-nm
  OBJCOPY=${host}/bin/llvm-objcopy
  KALLSYMS_EXTRA_PASS=1
  CONFIG_OUTPUT_FORMAT=wasm32
  CROSS_COMPILE=wasm32
  olddefconfig
  WORKING_DIRECTORY ${lkl}
  )

execute_process(
  COMMAND make -j10 -C tools/lkl
  ARCH=lkl CC=${toolchain}/bin/warp-cc
  LD=${toolchain}/bin/warp-ld
  AR=${toolchain}/bin/warp-ar
  NM=${toolchain}/bin/warp-nm
  OBJCOPY=${host}/bin/llvm-objcopy
  KALLSYMS_EXTRA_PASS=1
  CONFIG_OUTPUT_FORMAT=wasm32
  CROSS_COMPILE=wasm32
  WORKING_DIRECTORY ${lkl}
  )

execute_process(
  COMMAND make -j10 
  ARCH=lkl
  CROSS_COMPILE=wasm32
  INSTALL_HDR_PATH=${prefix}
  headers_install
  WORKING_DIRECTORY ${lkl}
  )

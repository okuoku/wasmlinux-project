# 
# INPUTs:
#   hdr: full path to wasm2c generated source
#

if(NOT EXISTS ${hdr})
  message(FATAL_ERROR "${hdr} not found")
endif()

file(APPEND ${hdr} "\n#include \"w2cfixup.h\"\n")

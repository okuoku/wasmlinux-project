set(inarg)
set(args)
set(cnt 1)

while(DEFINED CMAKE_ARGV${cnt})
  set(arg ${CMAKE_ARGV${cnt}})
  #message(STATUS "RAWARG: ${arg}")
  if(inarg)
    list(APPEND args "${arg}")
  elseif("${arg}" STREQUAL "__WARPTOOL__")
    set(inarg TRUE)
  endif()
  math(EXPR cnt "${cnt}+1")
endwhile()

#foreach(e ${args})
#  message(STATUS "ARG: ${e}")
#endforeach()


# WasmLinux project (prototype)

WasmLinux project is an effort that create WebAssembly "native" Linux
environment, both kernel and userland.

- WasmLinux kernel is patched LKL kernel. 
- WasmLinux userland is patched Musl libc and BusyBox
- Toolchain is stock Clang + LLVM without any patches
- "Runner" is the integration component that implements syscall
  entrypoint etc.

## Demo

https://wasmlinux-demo.pages.dev/

## Build

Note: Currently, this project is in early PoC phase. 

Entire build dependencies are contained as submodules.
Please make sure thie repository is cloned with `--recursive` option.

On Windows or macOS, case sensitive filesystem is required to build Linux 
kernel.

### Host tool setup

Install `llvm-project` and `wabt` to `host/` directory.

### WasmLinux kernel and userland

Kernel build scripts are written in CMake. You can invoke it with:

```
cmake -P phases/build-phase1-kernel.cmake
cmake -P phases/build-phase2-libc.cmake
cmake -P phases/build-phase3-kernel.cmake
cmake -P phases/build-phase4-userland.cmake
```

Phase5 is standard CMake project.

### Runner

`runner/hostrunner` contains Runner sources and it is standard CMake project.

To build Web version of WasmLinux, build Runner with Emscripten.
Otherwise, Runner is just a standard C++20 project and it should run on
anywhere supporting both libuv and C++20.

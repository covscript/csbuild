# Covariant Script Build System
[![schedule_release](https://github.com/covscript/csbuild/actions/workflows/schedule_release.yml/badge.svg)](https://github.com/covscript/csbuild/actions/workflows/schedule_release.yml) [![schedule](https://github.com/covscript/csbuild/actions/workflows/schedule.yml/badge.svg)](https://github.com/covscript/csbuild/actions/workflows/schedule.yml)  
CSBuild is a system used for parallel building, automatic releasing and continuous integration of officially maintained packages.

## Latest Release

v3.4.3-patch4 (updated on 2025.09.08)

## Supported Operating System
|Platform|Architectural|Toolchain|Installer|Build Tool|Package Tool|
|----|----|----|----|----|----|
|Microsoft Windows|x86, x86_64|MinGW-w64|Microsoft Installer|`auto-build.bat`|`package_tools/wix/make.bat`|
|Canonical Ubuntu|x86, x86_64, ARM, ARM64, MIPS64EL (LoongISA for GS464E)|GCC, LLVM Clang|Debian Packager|`auto-build.sh`|`package_tools/deb/make.sh`|
|Google Android (Termux)|ARM64|LLVM Clang|Debian Packager|`auto-build.sh`|`package_tools/deb/make.sh`|
|Apple macOS|x86_64, ARM64|Apple Clang|Apple Disk Image|`auto-build.sh`|`package_tools/dmg/make.sh [--no-gui]`|

To build release version rather than nightly version, please add `release` argument when running build tool command.
## Setup build environment
### Windows
You need to install Git and CMake on your system first.

For building environment, please download [official maintained MinGW-w64 environment](https://github.com/covscript-archives/mingw-w64).

Otherwise, you need to install libffi, libglfw3 and libcurl manually.
### Linux
```
sudo apt install -y git cmake p7zip build-essential
sudo apt install -y libffi-dev unixodbc-dev libglfw3-dev libcurl4-openssl-dev
```
### Termux
```
pkg install x11-repo
pkg install -y git cmake wget p7zip clang
pkg install -y libffi unixodbc xorgproto mesa-dev glfw libcurl
```
### macOS
```
brew install git cmake wget p7zip
brew install glfw libffi unixodbc
```
## Build your package with CSBuild
### Step 1: Write your Package Description File
#### Package Description File Template:
```json
{
    "Type": "Package",
    "Name": "test",
    "Info": "Test Package",
    "Author": "Anonymous",
    "Version": "1.0.0",
    "Target": "Path to your package(*.cse|*.csp)",
    "Source": "Path to your source file(*.cpp)",
    "Dependencies": []
}

```
+ `Type` is the type of your package, can be `Package`(\*.csp) or `Extension`(\*.cse)
+ `Name` is the unique identifier of the package and cannot be repeated.
+ `Info` is the description of your package, should be short in one sentence.
+ `Author` is the name of the package author.
+ `Version` is the version of your package, which will be sorted in lexicographical order.
+ `Target` is the path to your package file(base to the repository directory).
+ `Source` is the path to your source file(base to the repository directory).
  + Note that if you need a more complicated method to configure your project like `cmake`, this field is optional.
  + Currently this method for building is **experimental** and can't be bundled in CSBuild directly. Please use it for debugging only before this method is merged into mainline support.
+ `Dependencies` is an array of package names you depend on.
  + A standard extension **should not** have any dependencies. 

#### Example:
```json
{
    "Type": "Extension",
    "Name": "analysis_impl",
    "Info": "Data Analysis Implementation",
    "Author": "CovScript Organization",
    "Version": "1.1.0",
    "Source": "analysis_impl.cpp",
    "Target": "analysis_impl.cse",
    "Dependencies": []
}
```
### Step 2: Put your json file into the `csbuild` folder of your repository
A legal `csbuild` folder should contain the following files:
+ JSON files: Package Description File, can be multiple.
+ *Build Scripts*: Extensions Only
  + make.bat: Build script on Windows
  + make.sh: Build script on Unix Systems
### Step 3: Write your build script (for Extensions)
Build scripts are variable between different projects, but at least you should follow these basic rules:
+ No extra effect on system.
+ Can be executed in parallel.
+ Will not occupy an unreasonable amount of time.

Based on basic rules, a good build script should follow these rules additionally:
+ Use building tools, such as CMake
+ Output files into the standard path structure:
    + Binaries -> build/bin
    + Packages -> build/imports
+ Provide the same experience across different platforms
#### Example of CMakeLists.txt for CovScript Extension
```
cmake_minimum_required(VERSION 3.16)

project(covscript-mypackage)
include_directories(include)

if (DEFINED ENV{CS_DEV_PATH})
    message("-- CovScript SDK detected at $ENV{CS_DEV_PATH}")
    include("$ENV{CS_DEV_PATH}/csbuild.cmake")
    include_directories($ENV{CS_DEV_PATH}/include)
    link_directories($ENV{CS_DEV_PATH}/lib)
else ()
    message(FATAL_ERROR "-- CovScript SDK not detected. Please set environment variable CS_DEV_PATH")
endif ()

add_library(mypackage SHARED mypackage.cpp)

target_link_libraries(mypackage covscript)

set_target_properties(mypackage PROPERTIES OUTPUT_NAME mypackage)
set_target_properties(mypackage PROPERTIES PREFIX "")
set_target_properties(mypackage PROPERTIES SUFFIX ".cse")
```
We usually locate the development files via `CS_DEV_PATH` environment variable. If you are using Windows or Linux, the `CS_DEV_PATH` should be placed correctly with official CovScript Runtime Installer.
### Step 4: Configure CSBuild
CSBuild has 3 phases: Fetch -> Build -> Install. The full build (`auto-build`) includes all three; the minimal build (`build_minimal`) skips Install.

#### 1. Add your package to Fetch and Build (all builds)
Edit the JSON config used by `misc/parallel_build.csc`:
+ **Full build**: `misc/parallel_config.json`
+ **Minimal build**: `misc/parallel_config_minimal.json`

Append your package to the `repos` and `build` arrays:
```json
{
    "max_parallel": 4,
    "git_repo": "https://github.com/",
    "repos": [
        ...,
        "<User>/<Repository Name>"
    ],
    "build": [
        ...,
        "<Repository Name>"
    ]
}
```
+ `repos` — repositories to clone into `build-cache/`
+ `build` — packages to compile via `misc/auto_build.csc`

Note: core packages (`cspkg`, `covscript`, `covscript-regex`, `covscript-codec`, `covscript-process`) are handled directly by the build scripts and should not be added here.

#### 2. Add your package to Install (full build only)
Edit both `misc/cspkg_config.json` (release) and `misc/cspkg_nightly_config.json` (nightly). Append your package to the `install` array:
```json
{
    "remote_base": "...",
    "install": [
        ...,
        "<Repository Name>"
    ]
}
```

#### 3. Test CSBuild script
Run `auto-build.bat` on Windows or `auto-build.sh` on Unix, wait for final output.

If CSBuild was configured correctly, you can see these output without error report.
```
...
csbuild: building package csdbc(1.0.1)...
...
```
### Step 5: Submit to official CSBuild repository(Optional)
If your test runs smoothly and you want Official release including your package, you can submit your package to our official CSBuild repository via Pull Request.

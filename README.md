# Covariant Script Build System
[![Action Status](https://github.com/covscript/csbuild/workflows/schedule/badge.svg)](https://github.com/covscript/csbuild/actions)  
CSBuild is a system used for parallel building, automatic releasing and continues integration of official maintained packages.
## Supported Platforms
|Platform|Architectural|Toolchain|Installer|Build Tool|Package Tool|
|----|----|----|----|----|----|
|Microsoft Windows|x86, x86_64|MinGW-w64|Microsoft Installer|auto-build.bat|package_tools/wix/make.bat|
|Canonical Ubuntu|x86, x86_64, ARM, MIPS64EL|GCC, LLVM Clang|Debian Packager|auto-build.sh|package_tools/deb/make.sh
|Apple macOS|x86_64|Apple Clang|Apple Disk Image|auto-build.sh|package_tools/dmg/make.sh [--no-gui]
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
    "Target": "Path to your package",
    "Dependencies": []
}

```
+ `Type` is the type of your package, can be `Package`(\*.csp) or `Extension`(\*.cse)
+ `Name` is the unique identifier of the package and cannot be repeated.
+ `Info` is the description of your package, should be short in one sentence.
+ `Author` is the name of the package author.
+ `Version` is the version of your package, which will be sorted in lexicographical order.
+ `Target` is the path to your package file(base to the repository directory).
+ `Dependencies` is an array of package names you depend on.

#### Example:
```json
{
    "Type": "Package",
    "Name": "csdbc_mysql",
    "Info": "CSDBC MySQL Driver",
    "Author": "CovScript Organization",
    "Version": "1.0.1",
    "Target": "csdbc_mysql.csp",
    "Dependencies": [
        "database",
        "codec",
        "csdbc",
        "regex"
    ]
}
```
### Step 2: Put your json file into the `csbuild` folder of your repository
An legal `csbuild` folder should contains following files:
+ JSON files: Package Description File, can be multiple.
+ make.bat: Build script on Windows(Extensions only)
+ make.sh: Build script on Unix(Extensions only)
### Step 3: Write your build script(for Extensions)
Build scripts are variable between different projects, but at least you should follow these basic rules:
+ No extra effect on system.
+ Can be executed paralleled.
+ Will not occupy unreasonable time.

Based on basic rules, a good build script should follow these rules additionally:
+ Use building tools, such as CMake
+ Output the files into standard path structural:
    + Binaries -> build/bin
    + Packages -> build/imports
+ Providing same experience in different platforms
#### Example of CMakeLists.txt for CovScript Extension
```
cmake_minimum_required(VERSION 3.4)

project(covscript-regex)

if(DEFINED ENV{CS_DEV_PATH})
    include_directories($ENV{CS_DEV_PATH}/include)
    link_directories($ENV{CS_DEV_PATH}/lib)
endif()

if(DEFINED ENV{CS_DEV_OUTPUT})
    set(LIBRARY_OUTPUT_PATH $ENV{CS_DEV_OUTPUT})
    set(EXECUTABLE_OUTPUT_PATH $ENV{CS_DEV_OUTPUT})
endif()

# Compiler Options
set(CMAKE_CXX_STANDARD 14)

if (MSVC)
    set(CMAKE_CXX_FLAGS "/O2 /EHsc /utf-8 /w")
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
elseif (CMAKE_COMPILER_IS_GNUCXX)
    if (WIN32)
        set(CMAKE_C_FLAGS "--static -fPIC -s -O3")
        set(CMAKE_CXX_FLAGS "--static -fPIC -s -O3")
    else ()
        set(CMAKE_C_FLAGS "-fPIC -s -O3")
        set(CMAKE_CXX_FLAGS "-fPIC -s -O3")
    endif ()
else ()
    set(CMAKE_C_FLAGS "-fPIC -O3")
    set(CMAKE_CXX_FLAGS "-fPIC -O3")
endif ()

add_library(regex SHARED regex.cpp)

target_link_libraries(regex covscript)

set_target_properties(regex PROPERTIES OUTPUT_NAME regex)
set_target_properties(regex PROPERTIES PREFIX "")
set_target_properties(regex PROPERTIES SUFFIX ".cse")
```
We usually locate the development files via `CS_DEV_PATH` environment variable. If you are using Windows or Linux, the `CS_DEV_PATH` should be placed correctly with official CovScript Runtime Installer.
### Step 4: Configure CSBuild
CSBuild have 3 phases: Fetch -> Build -> Install
#### 1. Add your package to each phase of CSBuild
+ Fetch
    + Windows -> misc/win32_config.json -> append a record in `repos` field:
        + `<User>/<Repository Name>`
    + Unix -> misc/unix_build.sh -> append a record after `fetch_git` commands:
        + `fetch_git <User>/<Repository Name> &`
+ Build
    + Windows -> misc/win32_config.json -> append a record in `build` field:
        + `<Repository Name>`
    + Unix -> misc/unix_build.sh -> append a record after `start` commands:
        + `start <Repository Name> "./csbuild/make.sh" &`
+ Install
    + All -> misc/cspkg_config.json -> append a record in `install` field:
        + `<Repository Name>`
#### 2. Test CSBuild script
Run `auto-build.bat` in Windows or `auto-build.sh` in Unix, wait for final output.

If CSBuild was configured correctly, you can see these output without error report.
```
...
csbuild: building package csdbc(1.0.1)...
...
```
### Step 5: Submit to official CSBuild repository(Optional)
If your test runs smoothly and you want Official release including your package, you can submit your package to our official CSBuild repository via Pull Request.
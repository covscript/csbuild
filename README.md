# Covariant Script Official Build System
Travis CI Status: [![Build Status](https://travis-ci.org/covscript/csbuild.svg?branch=master)](https://travis-ci.org/covscript/csbuild)
## Supported Platform
1. Apple macOS (Xcode)
2. Debian-like Linux (Dpkg)
3. Microsoft Windows (MinGW-w64)

## Tested Platform
OS|Kernel|Architecture|Compiler|Target|Build Tool
:---:|:---:|:---:|:---:|:---:|:---:
Apple macOS Mojave 10.14.6|Apple Darwin 18.7.0|x86_64|Apple Clang 10.0.1|x86_64-apple-darwin18.7.0|mac_tools
Microsoft Windows 10 Professional 1809|Windows NT 10.0.17763.615|x86_64|GCC 8.1.0 (i686-posix-sjlj-rev0)|i686-w64-mingw32|win_tools
Microsoft Windows 10 Professional 1809|Windows NT 10.0.17763.615|x86_64|GCC 8.1.0 (x86_64-posix-seh-rev0)|x86_64-w64-mingw32|win_tools
Deepin Linux 15.11 Desktop|GNU/Linux 4.15.0-29deepin-generic|x86_64|GCC 7.3.0|x86_64-linux-gnu|deb_tools
Deepin Linux 15.11 Desktop|GNU/Linux 4.15.0-29deepin-generic|x86_64|Clang 7.0.1|x86_64-linux-gnu|deb_tools
Deepin Linux 15.5 SP2 Professional|GNU/Linux 4.4.32-deepin-loongson-3-generic|mips64|GCC 6.3.0|mips64el-linux-gnuabi64|deb_tools
Deepin Linux 15.5 SP2 Professional|GNU/Linux 4.4.32-deepin-loongson-3-generic|mips64|Clang 6.0.0|mips64el-unknown-linux-gnu|deb_tools
## Xcode Platform
### Dependencies
1. Install Xcode Command Line Tools using command `xcode-select --install`
2. Install [Brew Package Manager](https://brew.sh/) with its official guide.
3. Install `bash`, `binutils`, `coreutils`, `cmake`, `git` and `glfw` via `brew` and attach them to `PATH` environment.
### Prepare
1. Ensure your computer's **performance** is good enough -- at least 2 cores CPU and 4 gigabytes RAM.
2. Recheck your **internet access**, which is required to fetch the source code from github.
3. Keep the local clone of this repository is **up to date**.
4. Ensure you have no image mounted in Finder. If you have, unmount them all.
### Compile
Enter the `mac_tools` folder and run
```sh
bash ./auto-build.sh
```
The first step will be very time-consuming. You will get the `.dmg` file under `mac_tools` which contains the specialized build version which depends on your machine.

## Dpkg Platform
> Although we support all platforms theoretically, we only guarantee it can work with the platform we tested.

### Dependencies
Install `cmake`, `pkg-config`, `build-essential`, `git` and `libglfw3-dev` via `apt-get`.
### Prepare
1. Ensure your computer's **performance** is good enough -- at least 2 cores CPU and 4 gigabytes RAM.
2. Recheck your **internet access**, which is required to fetch the source code from github.
3. Keep the local clone of this repository is **up to date**.
### Compile
Enter the `deb_tools` folder and run
```sh
bash ./auto-build.sh
```
The first step will be very time-consuming. You will get the `.deb` file under `deb_tools/deb-src` which contains the specialized build version which depends on your machine.

## MinGW-w64 Platform
### Dependencies
1. 32bit and 64bit version of [MinGW-w64](https://sourceforge.net/projects/mingw-w64/)(i686-posix-sjlj and x86_64-posix-seh)
2. 32bit and 64bit version of [GLFW3](https://www.glfw.org/download.html)(Windows pre-compiled binaries)
3. [Git on Windows](https://git-scm.com/)
4. [7-Zip](https://www.7-zip.org/)
5. [CMake](https://cmake.org/)
6. [Windows SDK](./sign_tools), provided but no guarantee
### Prepare
> It is very complex due to Microsoft Windows' lack of package managers, please be patient. Why we're not using the MSVC compiler? It was not supported before. Now it's supported but too slow (slower than MinGW-w64) to be used.

1. Ensure your computer's **performance** is good enough -- at least 2 cores CPU and 4 gigabytes RAM.
2. Recheck your **internet access**, which is required to fetch the source code from github.
3. Keep the local clone of this repository is **up to date**.
4. Enter the `sign_tools` folder, execute `gen.bat` to generate the certificates manually. **Do not set the password, leave it blank.**
5. **Set the `PATH` environment variable correctly**, the executables of `7-Zip`, `CMake` and `Git-SCM` should be included.
6. Unzip the two versions of MinGW-w64 you have downloaded into two folders, rename the 32bit version to `mingw32` and the 64bit version to `mingw64`, put them into the `win_tools` folder.
7. Unzip the two versions of GLFW3 you have downloaded into two folders and install them into two versions of MinGW-w64 separately:
    - MinGW-w64 data folder position:
        - For 32bit version, it is `mingw32/i686-w64-mingw32` folder
        - For 64bit version, it is `mingw64/x86_64-w64-mingw32` folder
    - Apply these two steps to both 32bit and 64bit versions separately:
        1) Copy the contents of `include` folder of GLFW3 into `include` folder of MinGW-w64 data folder
        2) Copy the contents of `lib-mingw-w64` folder  of GLFW3 into `lib` folder of MinGW-w64 data folder
### Compile
Just follow the files' name under the `win_tools` folder. The first step will be very time-consuming. You will get the 32bit and 64bit executables under `win_tools/builds`.

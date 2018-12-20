# Covariant Script Official Build System
## Supported Platform
1. Microsoft Windows(Win32)
2. Debian Linux and its derivations like Ubuntu Linux(Dpkg)
## Win32 Platform
### Dependencies
1. 32bit and 64bit version of [MinGW-w64](https://sourceforge.net/projects/mingw-w64/)(i686-posix-sjlj and x86_64-posix-seh)
2. 32bit and 64bit version of [GLFW3](https://www.glfw.org/download.html)(Windows pre-compiled binaries)
3. [Git on Windows](https://git-scm.com/)
4. [7-Zip](https://www.7-zip.org/)
5. [Windows SDK](./sign_tools), provided but no guarantee
### Prepare
> It is very complex due to Microsoft Windows' lack of package managers, please be patient. But why we don't use MSVC compiler? At first the reason is that we dont't support that shit, but now because its performance even worse than MinGW-w64.

1. **Make sure** your computer is **powerful enough** to compile the whole project, at least 2 cores CPU and 4 gigabytes RAM.
2. Recheck your **network**. Internet access is required to fetch the source code from github.
3. Keep the local clone of this repository is **up to date**.
4. Enter the `sign_tools` folder, execute `gen.bat` to generate the certificates manually. **Do not set the password, just leave it blank.**
5. **Set the `PATH` environment variable correctly**, you need to add the executor path of `7-Zip` and `Git-SCM` to system `PATH` variable.
6. Unzip the two versions of MinGW-w64 you have downloaded into two folders, rename the 32bit version to `mingw32` and the 64bit version to `mingw64` and then put them into `win_tools` folder.
7. Unzip the two versions of GLFW3 you have downloaded into two folders and install them into two versions of MinGW-w64 separately:
    - MinGW-w64 data folder position:
        - For 32bit version, it is `mingw32/i686-w64-mingw32` folder
        - For 64bit version, it is `mingw64/x86_64-w64-mingw32` folder
    - Apply these two steps to both 32bit and 64bit versions separately:
        1) Copy the contents of `include` folder of GLFW3 into `include` folder of MinGW-w64 data folder
        2) Copy the contents of `lib-mingw-w64` folder  of GLFW3 into `lib` folder of MinGW-w64 data folder
### Compile
Just follow the files' name which located in `win_tools` folder. The first step will take a long period of time which depends on the speed of your local ISP and the performance of your computer. Finally you will get the `builds` folder in `win_tools` which contains both 32bit and 64bit executor.
## Dpkg Platform
### Dependencies
Use `apt-get` command install the following packages: `pkg-config build-essential git libglfw3-dev`
### Prepare
1. **Make sure** your computer is **powerful enough** to compile the whole project, at least 2 cores CPU and 4 gigabytes RAM.
2. Recheck your **network**. Internet access is required to fetch the source code from github.
3. Keep the local clone of this repository is **up to date**.
### Compile
Enter the `deb_tools` folder and run
```sh
bash ./auto-build.sh
```
This will take a long period of time which depends on the speed of your local ISP and the performance of your computer. Finally you will get the `.deb` file in `deb_tools/deb-src` which contains the specialized build version which depends on your machine.

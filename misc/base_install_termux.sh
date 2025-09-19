#!/bin/bash
pkg update
pkg install x11-repo
pkg install -y git cmake wget p7zip clang
pkg install -y libffi unixodbc xorgproto mesa-dev glfw libcurl
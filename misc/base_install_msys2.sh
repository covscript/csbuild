#!/usr/bin/env bash
set -e

if ! command -v pacman >/dev/null 2>&1; then
	echo "This script must be run inside MSYS2."
	exit 1
fi

pacman -Syu --needed --noconfirm
pacman -S --needed --noconfirm \
	git \
	base-devel \
	mingw-w64-ucrt-x86_64-toolchain \
	mingw-w64-ucrt-x86_64-cmake \
	mingw-w64-ucrt-x86_64-pkgconf \
	mingw-w64-ucrt-x86_64-7zip \
	mingw-w64-ucrt-x86_64-libffi \
	mingw-w64-ucrt-x86_64-unixodbc \
	mingw-w64-ucrt-x86_64-glfw \
	mingw-w64-ucrt-x86_64-curl \
	mingw-w64-ucrt-x86_64-SDL2
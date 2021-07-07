#!/bin/bash

set -eu

download() {
    if [[ ! -e "$1" ]]; then
        echo "Downloading $1"
        wget "$2" -O "$1"
    fi
}

download PortableGit-2.32.0.2-64-bit.7z.exe https://github.com/git-for-windows/git/releases/download/v2.32.0.windows.2/PortableGit-2.32.0.2-64-bit.7z.exe
download make-4.3-1-x86_64.pkg.tar.xz https://mirror.msys2.org/msys/x86_64/make-4.3-1-x86_64.pkg.tar.xz
download sdcc-4.1.0-x64-setup.exe https://sourceforge.net/projects/sdcc/files/sdcc-win64/4.1.0/sdcc-4.1.0-x64-setup.exe/download
download rgbds-0.5.1-win64.zip https://github.com/gbdev/rgbds/releases/download/v0.5.1/rgbds-0.5.1-win64.zip
download mingw-w64-x86_64-python3.9-3.9.6-3-any.pkg.tar.zst https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-python3.9-3.9.6-3-any.pkg.tar.zst

rm -rf env
mkdir env
cd env

# Extract all the tools we need
7z x ../PortableGit-2.32.0.2-64-bit.7z.exe
tar -xJf ../make-4.3-1-x86_64.pkg.tar.xz
tar -I zstd -xvf ../mingw-w64-x86_64-python3.9-3.9.6-3-any.pkg.tar.zst
cd usr
7z x ../../sdcc-4.1.0-x64-setup.exe
unzip ../../rgbds-0.5.1-win64.zip -d bin
cd ..

# Remove vim, it's a big chunk of the install size.
rm -rf usr/share/vim usr/share/licenses/vim bin/vim.exe bin/rvim.exe bin/rvimdiff.exe
# Remove the non-free and other parts of sdcc, which are pretty large
rm -rf usr/non-free usr/lib/pic16
# Remove the tests from python, which strips another 50MB
rm -rf mingw64/usr/lib/python3.9/test

# Make the command "python" run our installed python version
cp mingw64/bin/python3.9.exe mingw64/bin/python3.exe

# Rename the git-bash.exe into gbsdk-bash.exe
mv git-bash.exe gbsdk-bash.exe
mv git-cmd.exe gbsdk-cmd.exe

# Package up the result
cd ..
rm -rf gbsdk-windows-environment.zip
zip -r gbsdk-windows-environment.zip env

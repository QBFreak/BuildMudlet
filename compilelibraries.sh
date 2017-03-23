#!/bin/sh

pushd ~/src || exit 1

### Compile libraries

## Hunspell
echo
echo "** Compiling Hunspell"
echo
# We're using pushd/popd so that failure to find a directory doesn't leave us
#  off in some strange state and throw off the rest of the process.
pushd hunspell-1.4.1 || exit 2
./configure --prefix=/c/mingw32
make -j 2
make install
popd # hunspell-1.4.1

echo
echo "** YAJL"
echo
## YAJL
pushd lloyd-yajl-f4b2b1a || exit 3
# I'm having trouble with all the powershell commands, so they're getting replaced with perl
perl -npe 's/ \/W4//' CMakeLists.txt > CMakeLists.tmp
perl -npe 's/(\(linkFlags)[^\)]+/\1/' CMakeLists.tmp > CMakeLists.tmp.1
perl -npe 's/ \/wd4996 \/wd4255 \/wd4130 \/wd4100 \/wd4711//' CMakeLists.tmp.1 > CMakeLists.tmp
perl -npe 's/(\(CMAKE_C_FLAGS_DEBUG ")\/D DEBUG \/Od \/Z7/\1-g/' CMakeLists.tmp > CMakeLists.tmp.1
perl -npe 's/(\(CMAKE_C_FLAGS_RELEASE \")\/D NDEBUG \/O2/\1-O2/' CMakeLists.tmp.1 > CMakeLists.txt
rm CMakeLists.tmp
rm CMakeLists.tmp.1
# Carry on!
mkdir build
pushd build || exit 4
cmake -G "MSYS Makefiles" ..
make
cp yajl-2.0.1/lib/* /c/mingw32/lib/
cp -R yajl-2.0.1/include/* /c/mingw32/include/
popd # build
popd # lloyd-yajl-f4b2b1a

echo
echo "** Lua"
echo
## Lua
pushd lua-5.1.5 || exit 5
#  edit the Makefile, change INSTALL_TOP= /usr/local to INSTALL_TOP= /c/mingw32, change TO_LIB= liblua.a to TO_LIB= liblua.a lua51.dll
perl -npe 's/(INSTALL_TOP= )\/usr\/local/\1\/c\/mingw32/' Makefile > Makefile.tmp
perl -npe 's/(TO_LIB= liblua.a)$/\1 lua51.dll/' Makefile.tmp > Makefile
rm Makefile.tmp
make mingw
make install
popd # lua-5.1.5

echo
echo "** PCRE"
echo
## PCRE
pushd pcre-8.38 || exit 6
./configure --prefix=/c/mingw32
make -j 2
make install
popd # pcre-8.38

echo
echo "** Sqlite"
echo
## Sqlite
pushd sqlite-autoconf-3071700 || exit 7
./configure --prefix=/c/mingw32
make -j 2
make install
popd # sqlite-autoconf-3071700

echo
echo "** Zlib"
echo
## Zlib
pushd zlib-1.2.11 || exit 8
make -f win32/Makefile.gcc
export INCLUDE_PATH=/c/mingw32/include/
export LIBRARY_PATH=/c/mingw32/lib/
export BINARY_PATH=/c/mingw32/bin/
make -f win32/Makefile.gcc install
cp zlib1.dll /c/mingw32/bin
cp libz.dll.a /c/mingw32/lib
popd # zlib-1.2.11

echo
echo "** LibZip"
echo
## LibZip
pushd libzip-0.11.2 || exit 9
./configure --prefix=/c/mingw32
make -j 2
make install
cp lib/zipconf.h /c/mingw32/include
popd # libzip-0.11.2

echo
echo "** ZZIPlib"
echo
## ZZIPlib
pushd zziplib-0.13.62 || exit 10
#powershell -Command "(gc configure) -replace 'uname -msr', 'uname -ms' | Out-File -encoding ASCII configure"
perl -npe 's/(uname -ms)r/\1/' configure > configure.tmp
mv configure.tmp configure

configure --disable-mmap --prefix=c:/mingw32/
make -j 2
make install
popd # zziplib-0.13.62

popd # ~/src

echo
echo "** DONE!"
echo
exit 0
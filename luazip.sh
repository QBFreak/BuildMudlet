#!/bin/sh

### Building LuaZip
cd ~/src
wget --no-check-certificate https://github.com/rjpcomputing/luazip/archive/master.zip
unzip master
cd luazip-master/
gcc -O2 -c -o src/luazip.o -IC:/mingw32/include/ src/luazip.c 
gcc -shared -o zip.dll src/luazip.o -Lc:\mingw32\lib -lzzip -lz c:/mingw32/bin/lua51.dll -lm
cp zip.dll ~/src/Mudlet/src/debug
cp zip.dll ~/src/Mudlet/src/release
cp -r /c/mingw32/lib/lua/5.1/* ~/src/Mudlet/src/debug
cp -r /c/mingw32/lib/lua/5.1/* ~/src/Mudlet/src/release

#!/bin/sh

### Building Mudlet
cd ~/src/Mudlet/src
# Updated to include Lua src in the include path
qmake CONFIG+=debug INCPATH+=/c/mingw32/msys/home/$USERNAME/src/lua-5.1.5/src
make -j 2

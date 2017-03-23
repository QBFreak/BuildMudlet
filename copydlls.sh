#!/bin/sh

### Copy DLLs

pushd ~/src/Mudlet/src || exit 1

echo
echo "** Copying files for debug build"
# Copy DLLs for Debug
pushd debug/ || exit 2
cp /c/Qt/5.6/mingw49_32/bin/icudt54.dll .
cp /c/Qt/5.6/mingw49_32/bin/icuin54.dll .
cp /c/Qt/5.6/mingw49_32/bin/icuuc54.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Cored.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Guid.dll .
cp /c/Qt/5.6/mingw49_32/bin/libEGLd.dll .
cp /c/Qt/5.6/mingw49_32/bin/libGLESv2d.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Networkd.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5OpenGLd.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Widgetsd.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Multimediad.dll .
cp /c/Qt/5.6/mingw49_32/bin/libgcc_s_dw2-1.dll .
cp /c/Qt/5.6/mingw49_32/bin/libstdc++-6.dll .
cp /c/Qt/5.6/mingw49_32/bin/libwinpthread-1.dll .
cp /c/mingw32/lib/libyajl.dll .
cp $HOME/src/lua-5.1.5/src/lua51.dll .
cp $HOME/src/lua-5.1.5/src/lua51.dll /c/mingw32/bin
cp $HOME/src/openssl-1.0.2k/libeay32.dll .
cp $HOME/src/openssl-1.0.2k/ssleay32.dll .
cp /c/mingw32/bin/libzip-2.dll .
cp /c/mingw32/bin/libhunspell-1.4-0.dll .
cp /c/mingw32/bin/libpcre-1.dll .
cp /c/mingw32/bin/libsqlite3-0.dll .
cp /c/mingw32/bin/zlib1.dll .
cp -r ../mudlet-lua/ .
cp ../*.dic .
cp -r /c/Qt/5.6/mingw49_32/plugins/audio .
cp -r /c/Qt/5.6/mingw49_32/plugins/mediaservice .
cp -r /c/Qt/5.6/mingw49_32/plugins/platforms .
cp -r /c/Qt/5.6/mingw49_32/plugins/imageformats .
popd # debug/

echo
echo "** Copying files for release build"
# Copy DLLs for Release
pushd release/ || exit 3
cp /c/Qt/5.6/mingw49_32/bin/icudt54.dll .
cp /c/Qt/5.6/mingw49_32/bin/icuin54.dll .
cp /c/Qt/5.6/mingw49_32/bin/icuuc54.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Core.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Gui.dll .
cp /c/Qt/5.6/mingw49_32/bin/libEGL.dll .
cp /c/Qt/5.6/mingw49_32/bin/libGLESv2.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Network.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5OpenGL.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Widgets.dll .
cp /c/Qt/5.6/mingw49_32/bin/Qt5Multimedia.dll .
cp /c/Qt/5.6/mingw49_32/bin/libgcc_s_dw2-1.dll .
cp /c/Qt/5.6/mingw49_32/bin/libstdc++-6.dll .
cp /c/Qt/5.6/mingw49_32/bin/libwinpthread-1.dll .
cp /c/mingw32/lib/libyajl.dll .
cp $HOME/src/lua-5.1.5/src/lua51.dll .
cp $HOME/src/lua-5.1.5/src/lua51.dll /c/mingw32/bin
cp $HOME/src/openssl-1.0.2k/libeay32.dll .
cp $HOME/src/openssl-1.0.2k/ssleay32.dll .
cp /c/mingw32/bin/libzip-2.dll .
cp /c/mingw32/bin/libhunspell-1.4-0.dll .
cp /c/mingw32/bin/libpcre-1.dll .
cp /c/mingw32/bin/libsqlite3-0.dll .
cp /c/mingw32/bin/zlib1.dll .
cp -r ../mudlet-lua/ .
cp ../*.dic .
cp -r /c/Qt/5.6/mingw49_32/plugins/audio .
cp -r /c/Qt/5.6/mingw49_32/plugins/mediaservice .
cp -r /c/Qt/5.6/mingw49_32/plugins/platforms .
cp -r /c/Qt/5.6/mingw49_32/plugins/imageformats .
popd # release/

popd # ~/src/Mudlet/src

echo

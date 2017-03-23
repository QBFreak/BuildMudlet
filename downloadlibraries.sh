#!/bin/bash
pushd ~/ || exit 1
mkdir src
pushd src/ || exit 2

echo
echo "** Downloading libraries"
echo

# Download files
wget --no-check-certificate --output-document hunspell-1.4.1.tar.gz https://github.com/hunspell/hunspell/archive/v1.4.1.tar.gz
wget http://www.lua.org/ftp/lua-5.1.5.tar.gz
wget --no-check-certificate https://sourceforge.net/projects/pcre/files/pcre/8.38/pcre-8.38.tar.gz/download
wget http://zlib.net/zlib-1.2.11.tar.gz
wget http://www.sqlite.org/2013/sqlite-autoconf-3071700.tar.gz
wget --no-check-certificate https://launchpad.net/ubuntu/+archive/primary/+files/libzip_0.11.2.orig.tar.gz
wget --no-check-certificate --output-document yajl-2.0.1.tar.gz https://github.com/lloyd/yajl/tarball/2.0.1
wget --no-check-certificate https://sourceforge.net/projects/zziplib/files/zziplib13/0.13.62/zziplib-0.13.62.tar.bz2/download
wget --no-check-certificate -P openssl-1.0.2k https://indy.fulgan.com/SSL/openssl-1.0.2k-i386-win32.zip

echo
echo "** Unpacking files"
echo

# Unpack files
for a in `ls -1 *.tar.gz`; do tar -zxvf $a; done
for a in `ls -1 *.tar.bz2`; do tar xvfj $a; done
# The wiki forgot to specify the path for this zip!
/c/Program\ Files/7-Zip/7z -oopenssl-1.0.2k e openssl-1.0.2k/openssl-1.0.2k-i386-win32.zip

echo
echo "** Downloading and unpacking Boost"
echo

# Boost - WHY are we using 7zip for this when we have tar? to flatten the archive? Surely tar lets us to that too!
wget --no-check-certificate https://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.gz/download
/c/Program\ Files/7-Zip/7z e boost_1_60_0.tar.gz && /c/Program\ Files/7-Zip/7z x boost_1_60_0.tar
cp -r boost_1_60_0/boost /c/mingw32/include

popd # src/
popd # ~/

echo
echo "** Done"
echo


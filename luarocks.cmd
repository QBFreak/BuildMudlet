@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:: Use PUSHD and POPD so we can quickly undo any directory changes
PUSHD C:\mingw32\msys\home\%USERNAME%\src\luarocks-2.4.0-win32
:: We are launching install.bat with 'start /wait' instead of 'CALL'
::  because it's going to spawn a new command window with admin privs
::  and we need to wait for THAT to close.
CALL install.bat /P C:\LuaRocks /MW
POPD REM C:\...\luarocks-2.4.0-win32

PUSHD C:\LuaRocks\lua\luarocks
:: Looks like we're not entirely free of Powershell's evil influences
powershell -Command "(gc cfg.lua) -replace 'mingw32-gcc', 'gcc' | Out-File -encoding ASCII cfg.lua"
POPD REM C:\LuaRocks\lua\luarocks

PUSHD C:\LuaRocks
CALL C:\LuaRocks\luarocks.bat install LuaFileSystem
CALL C:\LuaRocks\luarocks.bat install LuaSQL-SQLite3 SQLITE_INCDIR="c:\mingw32\include" SQLITE_LIBDIR="c:\mingw32\lib"
CALL C:\LuaRocks\luarocks.bat install lrexlib-pcre PCRE_LIBDIR="c:\mingw32\lib" PCRE_INCDIR="c:\mingw32\include"
POPD REM C:\LuaRocks

@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
SET appTitle=BuildMudlet
COLOR 1F
CLS
ECHO.
CALL :Update
SET REVAL=0

:: SET PATH=%PATH%;C:\Python27;C:\mingw32\bin;C:\mingw32\msys\bin;C:\Program Files (x86)\CMake\bin;C:\Qt\5.6\mingw49_32\bin
CALL :Perl path.pl
 
CALL :Update Downloading and installing prerequisites
cmd /c DownloadPrereq.exe /autoclose

CALL :Update Downloading libraries
CALL :Bash downloadlibraries.sh || GOTO :Done

CALL :Update Compiling libraries
CALL :Bash compilelibraries.sh || GOTO :Done

CALL :Update Downloading Mudlet Sources
CALL :Bash downloadmudletsrc.sh || GOTO :Done

CALL :Update Building Mudlet
CALL :Bash buildmudlet.sh || GOTO :Done

CALL :Update Copying DLLs
CALL :Bash copydlls.sh || GOTO :Done

CALL :Update Setting up Lua Libraries
CALL :Bash setuplibraries.sh || GOTO :Done

CALL :Update Installing LuaRocks
CALL :Elevate luarocks.cmd || GOTO :Done

ECHO Once LuaRocks is done installing,
pause

CALL :Update Building LuaZip
CALL :Bash luazip.sh || GOTO :Done

CALL :Update Complete

:Done

PAUSE
CLS
COLOR
EXIT /B !RETVAL!

GOTO :EOF

:Update
	IF "%*" NEQ "" (
		TITLE %appTitle% - %*
		ECHO %*
	) ELSE (
		TITLE %appTitle%
		ECHO.
	)
GOTO :EOF

:Bash
	C:\mingw32\msys\bin\bash -l "%CD%/%1"
	SET RETVAL=%ERRORLEVEL%
	IF "!RETVAL!" GTR "0" (
		CALL :Error %1
		EXIT /B !RETVAL!
	)
GOTO :EOF


:Perl
	C:\mingw32\msys\bin\perl "%CD%/%1"
	SET RETVAL=%ERRORLEVEL%
	IF "!RETVAL!" GTR "0" (
		CALL :Error %1
		EXIT /B !RETVAL!
	)
GOTO :EOF

:Elevate
	START /WAIT PowerShell -Command (New-Object -com 'Shell.Application').ShellExecute('%CD%\%1', '', '', 'runas')
	:: I'd do error handling here, but START returns success if it launches
	::  the application. So it's an exercise in futility.
GOTO :EOF

:Error
	COLOR 4F
	TITLE %appTitle% - ERROR
	ECHO.
	ECHO ** Error !RETVAL! while processing %1
	ECHO Stopping build.
	ECHO.
	EXIT /B !RETVAL!
GOTO :EOF

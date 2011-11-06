@echo off

set NVMW_HOME=%~dp0
set NVMW_CMD=%1

if "%NVMW_CMD%" == "install" (
  call :install %2
  if not %ERRORLEVEL% == 1 call :use %2
) else if "%NVMW_CMD%" == "use" (
  call :use %2
) else (
  echo usage: nvmw.bat install [version]
  exit /b 1
)
exit /b %ERRORLEVEL%

::===========================================================
:: Install function
::===========================================================
:install
setlocal

set NODE_VERSION=%1
set NODE_EXE_URL=http://nodejs.org/dist/%NODE_VERSION%/node.exe

echo Start installing Node %NODE_VERSION%

mkdir %NVMW_HOME%\%NODE_VERSION%
set NODE_HOME=%NVMW_HOME%\%NODE_VERSION%
set NODE_EXE_FILE=%NODE_HOME%\node.exe
set PATH=%PATH%;%NODE_HOME%

:: Download node.exe
cscript %NVMW_HOME%\fget.js %NODE_EXE_URL% %NODE_EXE_FILE%
if not exist %NODE_EXE_FILE% (
   echo Download %NODE_EXE_FILE% from %NODE_EXE_URL% failed
   rd /Q /S %NODE_HOME%
   endlocal
   exit /b 1
) else (
    :: Install npm
    echo Start install npm
    cmd /c git config --system http.sslcainfo /bin/curl-ca-bundle.crt
    cmd /c git clone --recursive git://github.com/isaacs/npm.git %NODE_HOME%\npm
    cmd /c node %NODE_HOME%\npm\cli.js install npm -gf

    echo Finished
    endlocal
    exit /b 0
)

::===========================================================
:: Use function
::===========================================================
:use
setlocal

set NODE_VERSION=%1
set NODE_HOME=%NVMW_HOME%\%NODE_VERSION%

if not exist %NODE_HOME% (
    echo Node %NODE_VERSION% is not installed
    exit /b 1
)

endlocal

echo Use Node %1
set PATH=%PATH%;%NVMW_HOME%\%1
exit /b 0
@echo off

if not defined NVMW_HOME (
  set "NVMW_HOME=%~dp0"
)

if not defined PATH_ORG (
  set "PATH_ORG=%PATH%"
)

if "%1" == "install" (
  call :install %2
  if not ERRORLEVEL == 1 call :use %2
) else if "%1" == "use" (
  call :use %2
) else if "%1" == "ls" (
  call :ls
) else if "%1" == "uninstall" (
  call :uninstall %2
) else (
  call :help
)
exit /b %ERRORLEVEL%

::===========================================================
:: help : Show help message
::===========================================================
:help
echo;
echo Node Version Manager for Windows
echo;
echo Usage:
echo   nvmw help                    Show this message
echo   nvmw install [version]       Download and install a [version]
echo   nvmw uninstall [version]     Uninstall a [version]
echo   nvmw use [version]           Modify PATH to use [version]
echo   nvmw ls                      List installed versions
echo;
echo Example:
echo   nvmw install v0.6.0          Install a specific version number
echo   nvmw use v0.6.0              Use the specific version
exit /b 0

::===========================================================
:: install : Install specified version node and npm
::===========================================================
:install
setlocal

set NODE_VERSION=%1
set NODE_EXE_URL=http://nodejs.org/dist/%NODE_VERSION%/node.exe
echo Start installing Node %NODE_VERSION%

set "NODE_HOME=%NVMW_HOME%%NODE_VERSION%"
mkdir "%NODE_HOME%"
set "NODE_EXE_FILE=%NODE_HOME%\node.exe"
set "NPM_ZIP_FILE=%NODE_HOME%\npm.zip"

if not exist "%NODE_EXE_FILE%" (
  :: download node.exe
  cscript "%NVMW_HOME%\fget.js" %NODE_EXE_URL% "%NODE_EXE_FILE%"
)

if not exist "%NODE_EXE_FILE%" (
  echo Download %NODE_EXE_FILE% from %NODE_EXE_URL% failed
  goto install_error
) else (
  echo Start install npm

  "%NODE_EXE_FILE%" "%NVMW_HOME%\get_npm.js" "%NODE_HOME%" %NODE_VERSION%

  set "CD_ORG=%CD%"
  cd "%NODE_HOME%"
  cscript "%NVMW_HOME%\unzip.js" "%NPM_ZIP_FILE%" "%NODE_HOME%"  
  cd "%CD_ORG%"
  if not exist "%NODE_HOME%\npm.cmd" goto install_error  
  echo npm %NPM_VERSION% install ok

  echo Finished
  endlocal
  exit /b 0
)
:install_error
  rd /Q /S "%NODE_HOME%"
  endlocal
  exit /b 1

::===========================================================
:: uninstall : Uninstall specified version
::===========================================================
:uninstall
setlocal

set NODE_VERSION=%1

if "%NVMW_CURRENT%" == "%NODE_VERSION%" (
  echo Cannot uninstall currently-active Node version, %NODE_VERSION%
  exit /b 1
)

set "NODE_HOME=%NVMW_HOME%\%NODE_VERSION%"
set "NODE_EXE_FILE=%NODE_HOME%\node.exe"

if not exist "%NODE_HOME%" (
  echo %NODE_VERSION% is not installed
  exit /b 1
) else (
  rd /Q /S "%NODE_HOME%"
  if ERRORLEVEL == 1 (
    echo Cannot uninstall Node version, %NODE_VERSION%
    exit /b 1
  ) else (
    echo Uninstalled Node %NODE_VERSION%
    endlocal
    exit /b 0
  )
)

::===========================================================
:: use : Change current version
::===========================================================
:use
setlocal
set NODE_VERSION=%1
set "NODE_HOME=%NVMW_HOME%%NODE_VERSION%"

if not exist "%NODE_HOME%" (
  echo Node %NODE_VERSION% is not installed
  exit /b 1
)

endlocal

echo Now using Node %1
set NVMW_CURRENT=%1
set "PATH=%PATH_ORG%;%NVMW_HOME%;%NVMW_HOME%\%1"
exit /b 0

::===========================================================
:: ls : List installed versions
::===========================================================
:ls
setlocal
dir "%NVMW_HOME%\v*" /b /ad
if not defined NVMW_CURRENT (
  set NVMW_CURRENT_V=none
) else (
  set NVMW_CURRENT_V=%NVMW_CURRENT%
)
echo Current: %NVMW_CURRENT_V%
endlocal
exit /b 0

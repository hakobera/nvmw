@echo off

if not defined NVMW_HOME (
  set "NVMW_HOME=%~dp0"
)

if not defined PATH_ORG (
  set "PATH_ORG=%PATH%"
)

if exist "%PROGRAMFILES(X86)%" if not "%3" == "x86" (
  set OS_ARCH=64
) else (
  set OS_ARCH=32
)

if not defined NVMW_NODEJS_ORG_MIRROR (
  set "NVMW_NODEJS_ORG_MIRROR=http://nodejs.org/dist"
)

if "%1" == "install" if not "%2" == "" (
  call :install %2
  if not ERRORLEVEL == 1 call :use %2
  exit /b %ERRORLEVEL%
)

if "%1" == "use" if not "%2" == "" (
  call :use %2
  exit /b %ERRORLEVEL%
)

if "%1" == "ls" (
  call :ls
  exit /b %ERRORLEVEL%
)

if "%1" == "uninstall" if not "%2" == "" (
  call :uninstall %2
  exit /b %ERRORLEVEL%
)

call :help
exit /b %ERRORLEVEL%

::===========================================================
:: help : Show help message
::===========================================================
:help
echo;
echo Node Version Manager for Windows
echo;
echo Usage:
echo   nvmw help                          Show this message
echo   nvmw install [version] [arch]      Download and install a [version]
echo                                        for [arch] architecture (optional)
echo   nvmw uninstall [version]           Uninstall a [version]
echo   nvmw use [version]                 Modify PATH to use [version]
echo   nvmw ls                            List installed versions
echo;
echo Example:
echo   nvmw install v0.10.21        Install a specific version number
echo   nvmw use v0.10.21            Use the specific version
echo
echo   nvmw install v0.10.29 x86    Install a 32-bit version
exit /b 0

::===========================================================
:: install : Install specified version node and npm
::===========================================================
:install
setlocal

set NODE_VERSION=%1
if not %NODE_VERSION:~0,1% == v (
  set NODE_VERSION=v%1
)

if %OS_ARCH% == 32 (
  set NODE_EXE_URL=%NVMW_NODEJS_ORG_MIRROR%/%NODE_VERSION%/node.exe
) else (
  set NODE_EXE_URL=%NVMW_NODEJS_ORG_MIRROR%/%NODE_VERSION%/x64/node.exe
)

echo Start installing Node %NODE_VERSION% (x%OS_ARCH%)

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
  if not exist %NPM_ZIP_FILE% (
    exit /b 0;
  )

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
if not %NODE_VERSION:~0,1% == v (
  set NODE_VERSION=v%1
)

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
if not %NODE_VERSION:~0,1% == v (
  set NODE_VERSION=v%1
)
set "NODE_HOME=%NVMW_HOME%%NODE_VERSION%"

if not exist "%NODE_HOME%" (
  echo Node %NODE_VERSION% is not installed
  exit /b 1
)

endlocal

set NVMW_CURRENT=%1
if not %NVMW_CURRENT:~0,1% == v (
  set NVMW_CURRENT=v%1
)
echo Now using Node %NVMW_CURRENT%
set "PATH=%NVMW_HOME%;%NVMW_HOME%\%NVMW_CURRENT%;%PATH_ORG%"
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

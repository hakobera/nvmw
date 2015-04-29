@echo off

if not defined NVMW_HOME (
  set "NVMW_HOME=%~dp0"
)

if not defined PATH_ORG (
  set "PATH_ORG=%PATH%"
)

set IS64=FALSE
if exist "%PROGRAMFILES(X86)%" (
  set IS64=TRUE
)

if %IS64% == TRUE (
  set OS_ARCH=x64
) else (
  set OS_ARCH=x32
)

if not defined NVMW_NODEJS_ORG_MIRROR (
  set "NVMW_NODEJS_ORG_MIRROR=https://nodejs.org/dist"
)

if not defined NVMW_IOJS_ORG_MIRROR (
  set "NVMW_IOJS_ORG_MIRROR=https://iojs.org/dist"
)

if "%1" == "install" if not "%2" == "" (
  call :install %2 %3
  if not ERRORLEVEL == 1 call :use %2 %3
  exit /b %ERRORLEVEL%
)

if "%1" == "use" if not "%2" == "" (
  call :use %2 %3
  exit /b %ERRORLEVEL%
)

if "%1" == "ls" (
  call :ls
  exit /b %ERRORLEVEL%
)

if "%1" == "uninstall" if not "%2" == "" (
  call :uninstall %2 %3
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
echo   nvmw install v0.10.21        Install a specific version number of node.js
echo   nvmw use v0.10.21            Use the specific version
echo   nvmw install iojs            Install the latest version of io.js
echo   nvmw install iojs-v1.0.2     Install a specific version number of io.js
echo   nvmw use iojs-v1.0.2         Use the specific version io.js
echo;
echo   nvmw install v0.10.35 x86    Install a 32-bit version
exit /b 0

::===========================================================
:: install : Install specified version node and npm
::===========================================================
:install
setlocal

set ARCH=%OS_ARCH%

if not "%2" == "" (
  set ARCH=%2
  :: x86, ia32 alias x32
  if "%2" == "x86" (
    set ARCH=x32
  )
  if "%2" == "ia32" (
    set ARCH=x32
  )
)

set NODE_TYPE=node
set NODE_VERSION=%1

:: nvmw install iojs-v1.0.2
if "%NODE_VERSION:~4,1%" == "-" (
  for /f "tokens=1,2,* delims=-" %%a in ("%NODE_VERSION%") do (
    set NODE_TYPE=%%a
    set NODE_VERSION=%%b
  )
)

:: nvmw install iojs
if %NODE_VERSION% == iojs (
  set NODE_TYPE=iojs
  set NODE_VERSION=latest
)

:: nvmw install node
if %NODE_VERSION% == node (
  set NODE_TYPE=node
  set NODE_VERSION=latest
)

:: iojs-1.0.0, iojs-latest
if not %NODE_VERSION:~0,1% == v if not %NODE_VERSION:~0,1% == l (
  set NODE_VERSION=v%NODE_VERSION%
)

if %NODE_TYPE% == iojs (
  set DIST_URL=%%
  if %ARCH% == x32 (
    set NODE_EXE_URL=%NVMW_IOJS_ORG_MIRROR%/%NODE_VERSION%/win-x86/iojs.exe
  ) else (
    set NODE_EXE_URL=%NVMW_IOJS_ORG_MIRROR%/%NODE_VERSION%/win-x64/iojs.exe
  )
) else (
  if %ARCH% == x32 (
    set NODE_EXE_URL=%NVMW_NODEJS_ORG_MIRROR%/%NODE_VERSION%/node.exe
  ) else (
    set NODE_EXE_URL=%NVMW_NODEJS_ORG_MIRROR%/%NODE_VERSION%/x64/node.exe
  )
)

set "NODE_HOME=%NVMW_HOME%%NODE_VERSION%"
if %NODE_TYPE% == iojs (
  set "NODE_HOME=%NVMW_HOME%%NODE_TYPE%\%NODE_VERSION%"
)

if not %ARCH% == %OS_ARCH% (
  set "NODE_HOME=%NODE_HOME%-%ARCH%"
)

set "NODE_EXE_FILE=%NODE_HOME%\%NODE_TYPE%.exe"
set "NPM_ZIP_FILE=%NODE_HOME%\npm.zip"

if exist "%NODE_EXE_FILE%" (
  endlocal
  echo "%NODE_TYPE%/%NODE_VERSION% (%ARCH%)" already exists, please uninstall it first
  exit /b 1
)

mkdir "%NODE_HOME%"

echo Start installing %NODE_TYPE%/%NODE_VERSION% (%ARCH%) to %NODE_HOME%

cscript //nologo "%NVMW_HOME%\fget.js" %NODE_EXE_URL% "%NODE_EXE_FILE%"

if not exist "%NODE_EXE_FILE%" (
  echo Download %NODE_EXE_FILE% from %NODE_EXE_URL% failed
  goto install_error
) else (
  if %NODE_TYPE% == iojs (
    copy "%NVMW_HOME%\alias-node.cmd" "%NODE_HOME%\node.cmd"
  )

  echo Start install npm

  "%NODE_EXE_FILE%" "%NVMW_HOME%\get_npm.js" "%NODE_HOME%" "%NODE_TYPE%/%NODE_VERSION%"
  if not exist "%NPM_ZIP_FILE%" goto install_error

  set "CD_ORG=%CD%"
  %~d0
  cd "%NODE_HOME%"
  echo Start unzip "%NPM_ZIP_FILE%" to "%NODE_HOME%"
  cscript //nologo "%NVMW_HOME%\unzip.js" "%NPM_ZIP_FILE%" "%NODE_HOME%"
  mkdir "%NODE_HOME%\node_modules"
  rmdir /s /q "%NODE_HOME%\node_modules\npm"
  move npm-* "%NODE_HOME%\node_modules\npm"
  copy "%NODE_HOME%\node_modules\npm\bin\npm.cmd" "%NODE_HOME%\npm.cmd"
  cd "%CD_ORG%"
  if not exist "%NODE_HOME%\npm.cmd" goto install_error
  echo npm install ok

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

set ARCH=%OS_ARCH%

if not "%2" == "" (
  set ARCH=%2
  :: x86, ia32 alias x32
  if "%2" == "x86" (
    set ARCH=x32
  )
  if "%2" == "ia32" (
    set ARCH=x32
  )
)

set NODE_TYPE=node
set NODE_VERSION=%1

if "%NODE_VERSION:~4,1%" == "-" (
  for /f "tokens=1,2,* delims=-" %%a in ("%NODE_VERSION%") do (
    set NODE_TYPE=%%a
    set NODE_VERSION=%%b
  )
)

:: nvmw uninstall iojs
if %NODE_VERSION% == iojs (
  set NODE_TYPE=iojs
  set NODE_VERSION=latest
)

:: nvmw uninstall node
if %NODE_VERSION% == node (
  set NODE_TYPE=node
  set NODE_VERSION=latest
)

if not %NODE_VERSION:~0,1% == v if not %NODE_VERSION:~0,1% == l (
  set NODE_VERSION=v%NODE_VERSION%
)

if "%NVMW_CURRENT_TYPE%" == "%NODE_TYPE%" if "%NVMW_CURRENT%" == "%NODE_VERSION%" if "%NVMW_CURRENT_ARCH%" == "%ARCH%" (
  echo Cannot uninstall currently-active %NODE_TYPE%/%NODE_VERSION% %ARCH%
  exit /b 1
)

set "NODE_HOME=%NVMW_HOME%%NODE_VERSION%"
if %NODE_TYPE% == iojs (
  set "NODE_HOME=%NVMW_HOME%%NODE_TYPE%\%NODE_VERSION%"
)

if not %ARCH% == %OS_ARCH% (
  set "NODE_HOME=%NODE_HOME%-%ARCH%"
)

if not exist "%NODE_HOME%" (
  echo %NODE_TYPE%/%NODE_VERSION% %ARCH% is not installed
  exit /b 1
) else (
  rd /Q /S "%NODE_HOME%"
  if ERRORLEVEL == 1 (
    echo Cannot uninstall %NODE_TYPE%/%NODE_VERSION% %ARCH%
    exit /b 1
  ) else (
    echo Uninstalled %NODE_TYPE%/%NODE_VERSION% %ARCH%
    endlocal
    exit /b 0
  )
)

::===========================================================
:: use : Change current version
::===========================================================
:use
setlocal

set ARCH=%OS_ARCH%

if not "%2" == "" (
  set ARCH=%2
  :: x86, ia32 alias x32
  if "%2" == "x86" (
    set ARCH=x32
  )
  if "%2" == "ia32" (
    set ARCH=x32
  )
)

set NODE_TYPE=node
set NODE_VERSION=%1

if "%NODE_VERSION:~4,1%" == "-" (
  for /f "tokens=1,2,* delims=-" %%a in ("%NODE_VERSION%") do (
    set NODE_TYPE=%%a
    set NODE_VERSION=%%b
  )
)

:: nvmw use iojs
if %NODE_VERSION% == iojs (
  set NODE_TYPE=iojs
  set NODE_VERSION=latest
)

:: nvmw use node
if %NODE_VERSION% == node (
  set NODE_TYPE=node
  set NODE_VERSION=latest
)

if not %NODE_VERSION:~0,1% == v if not %NODE_VERSION:~0,1% == l (
  set NODE_VERSION=v%NODE_VERSION%
)

set "NODE_HOME=%NVMW_HOME%%NODE_VERSION%"
if %NODE_TYPE% == iojs (
  set "NODE_HOME=%NVMW_HOME%%NODE_TYPE%\%NODE_VERSION%"
)

if not %ARCH% == %OS_ARCH% (
  set "NODE_HOME=%NODE_HOME%-%ARCH%"
)

if not exist "%NODE_HOME%" (
  echo %NODE_TYPE%/%NODE_VERSION% is not installed
  exit /b 1
)

endlocal

set NVMW_CURRENT_ARCH=%OS_ARCH%
if not "%2" == "" (
  set NVMW_CURRENT_ARCH=%2
  :: x86, ia32 alias x32
  if "%2" == "x86" (
    set NVMW_CURRENT_ARCH=x32
  )
  if "%2" == "ia32" (
    set NVMW_CURRENT_ARCH=x32
  )
)

set NVMW_CURRENT_TYPE=node
set NVMW_CURRENT=%1
if "%NVMW_CURRENT:~4,1%" == "-" (
  for /f "tokens=1,2,* delims=-" %%a in ("%NVMW_CURRENT%") do (
    set NVMW_CURRENT_TYPE=%%a
    set NVMW_CURRENT=%%b
  )
)

if %NVMW_CURRENT% == iojs (
  set NVMW_CURRENT_TYPE=iojs
  set NVMW_CURRENT=latest
)

if %NVMW_CURRENT% == node (
  set NVMW_CURRENT_TYPE=node
  set NVMW_CURRENT=latest
)

if not %NVMW_CURRENT:~0,1% == v if not %NVMW_CURRENT:~0,1% == l (
  set NVMW_CURRENT=v%NVMW_CURRENT%
)

echo Now using %NVMW_CURRENT_TYPE% %NVMW_CURRENT% %NVMW_CURRENT_ARCH%

set "NODE_HOME=%NVMW_HOME%%NODE_VERSION%"
if %NVMW_CURRENT_TYPE% == iojs (
  set "NODE_HOME=%NVMW_HOME%%NODE_TYPE%\%NODE_VERSION%"
)

if not %NVMW_CURRENT_ARCH% == %OS_ARCH% (
  set NVMW_CURRENT_ARCH_PADDING=-%NVMW_CURRENT_ARCH%
) else (
  set NVMW_CURRENT_ARCH_PADDING=
)

if %NVMW_CURRENT_TYPE% == iojs (
  set "PATH=%NVMW_HOME%;%NVMW_HOME%%NVMW_CURRENT_TYPE%\%NVMW_CURRENT%%NVMW_CURRENT_ARCH_PADDING%;%PATH_ORG%"
  set "NODE_PATH=%NVMW_HOME%%NVMW_CURRENT_TYPE%\%NVMW_CURRENT%%NVMW_CURRENT_ARCH_PADDING%\node_modules"
) else (
  set "PATH=%NVMW_HOME%;%NVMW_HOME%\%NVMW_CURRENT%%NVMW_CURRENT_ARCH_PADDING%;%PATH_ORG%"
  set "NODE_PATH=%NVMW_HOME%\%NVMW_CURRENT%%NVMW_CURRENT_ARCH_PADDING%\node_modules"
)

exit /b 0

::===========================================================
:: ls : List installed versions
::===========================================================
:ls
setlocal

echo node:
if exist "%NVMW_HOME%" (
  dir "%NVMW_HOME%v*" /b /ad
)
echo;
echo iojs:
if exist "%NVMW_HOME%iojs" (
  dir "%NVMW_HOME%iojs\*" /b /ad
)
echo;

if not defined NVMW_CURRENT (
  set NVMW_CURRENT_V=none
) else (
  set NVMW_CURRENT_V=%NVMW_CURRENT%
)
echo Current: %NVMW_CURRENT_TYPE%/%NVMW_CURRENT_V% %NVMW_CURRENT_ARCH%
endlocal
exit /b 0

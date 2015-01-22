:: Created by nvmw, please don't edit manually.
@IF EXIST "%~dp0\iojs.exe" (
  "%~dp0\iojs.exe" %*
) ELSE (
  iojs %*
)

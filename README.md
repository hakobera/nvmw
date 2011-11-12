Node Version Manager for Windows
================================
nvmw is a simple Node Version Manager for Windows.

Prerequisites
-------------

You'll need to install the following software before installing nvmw:

- [git](http://code.google.com/p/msysgit/ "msysgit")
- [python 2.7](http://www.activestate.com/activepython "ActivePython")

Installation
------------

Clone this repository:

    git clone git://github.com/hakobera/nvmw.git "%HOMEDRIVE%%HOMEPATH%\.nvmw"

To activate nvmw, you need to set NVMW_HOME, and add it to your PATH environment variable

    set "PATH=%PATH%;%HOMEDRIVE%%HOMEPATH%\.nvmw"

Usage
-----

    Usage:
      nvmw help                    Show this message
      nvmw install [version]       Download and install a [version]
      nvmw use [version]           Modify PATH to use [version]
      nvmw ls                      List installed versions

    Example:
      nvmw install v0.6.0          Install a specific version number
      nvmw use v0.6.0              Use the specific version

LICENSE
-------
(The MIT License)

Copyright (c) 2011 Kazuyuki Honda <hakobera@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

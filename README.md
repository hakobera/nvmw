Node Version Manager for Windows
================================
nvmw is a simple Node Version Manager for Windows.

Prerequirements
---------------

You'll need to following software, before installing nvmw.

- [msysgit](http://code.google.com/p/msysgit/ "msysgit")
- [python 2.5+)(http://www.activestate.com/activepython "ActivePython")

Installation
------------

Clone this repository

    git clone git://github.com/hakobera/nvmw.git %HOMEPATH%\.nvmw

To activate nvm, you need to set NVMW_HOME, and add it to PATH environment variable

    set PATH=%HOMEPATH%\.nvmw

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

LISENCE
-------
    Copyright (c) 2011 Kazuyuki Honda <hakobera@gmail.com>
    All rights reserved.

    Redistribution and use in source and binary forms are permitted
    provided that the above copyright notice and this paragraph are
    duplicated in all such forms and that any documentation,
    advertising materials, and other materials related to such
    distribution and use acknowledge that the software was developed
    by the <organization>.  The name of the
    University may not be used to endorse or promote products derived
    from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
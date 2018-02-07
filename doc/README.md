

# Claws FCM #

Copyright (c) 2017 Yan Guiborat

__Authors:__ "Manuel Rubio" ([`manuel@altenwald.com`](mailto:manuel@altenwald.com)), "Yan Guiborat" ([`yan.guiborat@veon.com`](mailto:yan.guiborat@veon.com)).

[![Build Status](https://img.shields.io/travis/snatch-xmpp/claws_fcm/master.svg)](https://travis-ci.org/snatch-xmpp/claws_fcm)
[![Codecov](https://img.shields.io/codecov/c/github/snatch-xmpp/claws_fcm.svg)](https://codecov.io/gh/snatch-xmpp/claws_fcm)
[![License: Apache 2.0](https://img.shields.io/github/license/snatch-xmpp/claws_fcm.svg)](https://raw.githubusercontent.com/snatch-xmpp/claws_fcm/master/LICENSE)
[![Hex](https://img.shields.io/hexpm/v/claws_fcm.svg)](https://hex.pm/packages/claws_fcm)

Claws FCM is an extension for [snatch](https://github.com/snatch-xmpp/snatch) to provide to the system of a way to perform FCM requests and recieve notifications back via Snatch.

Installation
------------

The system requires OTP 19+ and we prefer to use [rebar3](http://www.rebar3.org) instead of older versions. To install claws_rest only needs:

```erlang
{deps, [
    {claws_fcm, "0.1.0"}
]}
```

Or if you are using [erlang.mk](https://erlang.mk) instead, you can use:

```Makefile
DEPS += claws_fcm
dep_snatch = git https://github.com/snatch-xmpp/claws_fcm.git 0.1.0
```

You'll need a C/C++ compiler installed in your system for [fast_xml](https://github.com/processone/fast_xml) and [stringprep](https://github.com/processone/stringprep).

For further information [check this doc](doc/how-to/claws_fcm.md).

Troubleshooting
---------------

Feel free to create an issue in github to point a bug, flaw or improvement and even send a pull request with a specific change. Read the [LICENSE](LICENSE) if you have doubts about what you can do with the code.

Enjoy!


## Modules ##


<table width="100%" border="0" summary="list of modules">
<tr><td><a href="claws_fcm.md" class="module">claws_fcm</a></td></tr></table>




# Snatch PHP #

Copyright (c) 2017 Manuel Rubio

__Authors:__ "Manuel Rubio" ([`manuel@altenwald.com`](mailto:manuel@altenwald.com)).

[![Build Status](https://img.shields.io/travis/snatch-xmpp/snatch_php/master.svg)](https://travis-ci.org/snatch-xmpp/snatch_php)
[![Codecov](https://img.shields.io/codecov/c/github/snatch-xmpp/snatch_php.svg)](https://codecov.io/gh/snatch-xmpp/snatch_php)
[![License: Apache 2.0](https://img.shields.io/github/license/snatch-xmpp/snatch_php.svg)](https://raw.githubusercontent.com/snatch-xmpp/snatch_php/master/LICENSE)
[![Hex](https://img.shields.io/hexpm/v/snatch_php.svg)](https://hex.pm/packages/snatch_php)

Snatch PHP is an extension for [snatch](https://github.com/snatch-xmpp/snatch) to provide to the system of a way use PHP to handle the incoming information from the claws.

Installation
------------

The system requires OTP 19+ and we prefer to use [rebar3](http://www.rebar3.org) instead of older versions. To install claws_rest only needs:

```erlang
{deps, [
    {snatch_php, {git, "https://github.com/snatch-xmpp/snatch-php", "0.2.0"}}
]}
```

Or if you are using [erlang.mk](https://erlang.mk) instead, you can use:

```Makefile
DEPS += snatch_php 
dep_snatch = git https://github.com/snatch-xmpp/snatch_php.git 0.2.0
```

You'll need a C/C++ compiler installed in your system for [fast_xml](https://github.com/processone/fast_xml) and [stringprep](https://github.com/processone/stringprep).

For further information [check this doc](doc/how-to/snatch_php.md).

Troubleshooting
---------------

Feel free to create an issue in github to point a bug, flaw or improvement and even send a pull request with a specific change. Read the [LICENSE](LICENSE) if you have doubts about what you can do with the code.

Enjoy!


## Modules ##


<table width="100%" border="0" summary="list of modules">
<tr><td><a href="ephp_lib_snatch.md" class="module">ephp_lib_snatch</a></td></tr>
<tr><td><a href="snatch_php.md" class="module">snatch_php</a></td></tr></table>


-module(snatch_php_tests).
-author('manuel@altenwald.com').

-include_lib("eunit/include/eunit.hrl").

echo_reverse_test_() ->
    snatch_fun_test:check([
        "simple_response",
        "not_supported",
        "echo_reverse",
        "reply_to_bare"
    ]).

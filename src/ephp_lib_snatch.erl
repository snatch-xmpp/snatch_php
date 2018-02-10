-module(ephp_lib_snatch).
-author('manuel@altenwald.com').

-behaviour(ephp_func).

-export([init_func/0,
         init_config/0,
         init_const/0]).

-export([snatch_send/5,
         snatch_jid_is_full/3,
         snatch_bare_jid/3]).

-include_lib("fast_xml/include/fxml.hrl").
-include_lib("ephp/include/ephp.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    {snatch_send, [{args, [array,
                           {any, <<"unknown">>},
                           {string, undefined}]}]},
    {snatch_jid_is_full, [{args, [string]}]},
    {snatch_bare_jid, [{args, [string]}]}
].

-spec init_config() -> ephp_func:php_config_results().

init_config() -> [].

-spec init_const() -> ephp_func:php_const_results().

init_const() -> [].

snatch_send(_Ctx, _Line, {_, Array}, {_, JID}, {_, undefined}) ->
    ok =:= snatch:send(to_xml(Array), JID);

snatch_send(_Ctx, _Line, {_, Array}, {_, JID}, {_, ID}) ->
    ok =:= snatch:send(to_xml(Array), JID, ID).

to_xml(Array) ->
    fxml:element_to_binary(array_to_xml(Array)).

array_to_xml(Binary) when is_binary(Binary) ->
    {xmlcdata, Binary};
array_to_xml(Array) when ?IS_ARRAY(Array) ->
    Name = ephp_array:find(<<"name">>, Array, undefined),
    Attrs = ephp_array:to_list(ephp_array:find(<<"attrs">>, Array,
                               ephp_array:new())),
    #xmlel{name = Name, attrs = Attrs, children = get_children(Array)}.

get_children(Array) when ?IS_ARRAY(Array) ->
    Children = ephp_array:find(<<"children">>, Array, ephp_array:new()),
    [ array_to_xml(Tag) || {_, Tag} <- ephp_array:to_list(Children) ].

snatch_jid_is_full(_Ctx, _Line, {_, JID}) ->
    snatch_jid:is_full(JID).

snatch_bare_jid(_Ctx, _Line, {_, JID}) ->
    snatch_jid:to_bare(JID).

-module(ephp_lib_snatch).
-author('manuel@altenwald.com').

-behaviour(ephp_func).

-export([init_func/0,
         init_config/0,
         init_const/0]).

-export([snatch_send/5,
         snatch_send_binary/5,
         snatch_jid_is_full/3,
         snatch_bare_jid/3,
         snatch_iq/7,
         snatch_iq_resp/3,
         snatch_iq_error/4,
         snatch_message/7,
         snatch_message_error/7]).

-include_lib("fast_xml/include/fxml.hrl").
-include_lib("ephp/include/ephp.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    {snatch_send, [{args, [array,
                           {any, <<"unknown">>},
                           {string, undefined}]}]},
    {snatch_send_binary, [{args, [string,
                                  {any, <<"unknown">>},
                                  {string, undefined}]}]},
    {snatch_jid_is_full, [{args, [string]}]},
    {snatch_bare_jid, [{args, [string]}]},
    {snatch_iq, [{args, [string, string, string, string, array]}]},
    {snatch_iq_resp, [{args, [array]}]},
    {snatch_iq_error, [{args, [array, string]}]},
    {snatch_message, [{args, [string, string, string, string, array]}]},
    {snatch_message_error, [{args, [string, string, string, array, string]}]}
].

-spec init_config() -> ephp_func:php_config_results().

init_config() -> [].

-spec init_const() -> ephp_func:php_const_results().

init_const() -> [].

snatch_send(_Ctx, _Line, {_, Array}, {_, JID}, {_, undefined}) ->
    ok =:= snatch:send(to_xml(Array), JID);

snatch_send(_Ctx, _Line, {_, Array}, {_, JID}, {_, ID}) ->
    ok =:= snatch:send(to_xml(Array), JID, ID).

snatch_send_binary(_Ctx, _Line, {_, XML}, {_, JID}, {_, undefined}) ->
    ok =:= snatch:send(XML, JID);

snatch_send_binary(_Ctx, _Line, {_, XML}, {_, JID}, {_, ID}) ->
    ok =:= snatch:send(XML, JID, ID).

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

snatch_iq(_Ctx, _Line, {_, From}, {_, To}, {_, ID}, {_, Type}, {_, Payload}) ->
    XML = [ array_to_xml(P) || {_, P} <- ephp_array:to_list(Payload) ],
    snatch_stanza:iq(From, To, ID, Type, XML).

snatch_iq_resp(_Ctx, _Line, {_, IQ}) ->
    XML = array_to_xml(IQ),
    snatch_stanza:iq_resp(XML).

snatch_iq_error(_Ctx, _Line, {_, IQ}, {_, Error}) ->
    XML = array_to_xml(IQ),
    snatch_stanza:iq_error(XML, Error).

snatch_message(_Ctx, _Line, {_, From}, {_, To}, {_, ID}, {_, Type},
               {_, Payload}) ->
    XML = [ array_to_xml(P) || {_, P} <- ephp_array:to_list(Payload) ],
    snatch_stanza:message(From, To, ID, Type, XML).

snatch_message_error(_Ctx, _Line, {_, From}, {_, To}, {_, ID}, {_, Payload},
                     {_, Error}) ->
    XML = [ array_to_xml(P) || {_, P} <- ephp_array:to_list(Payload) ],
    snatch_stanza:message_error(From, To, ID, XML, Error).

-module(snatch_php).

-behaviour(snatch).

-export([init/1, handle_info/2, terminate/2]).

-include_lib("snatch/include/snatch.hrl").
-include_lib("fast_xml/include/fxml.hrl").
-include_lib("ephp/include/ephp.hrl").

-record(state, {
    code,
    name :: binary()
}).

init([{file, Script}]) ->
    application:set_env(ephp, modules, ?MODULES),
    PhpIni = application:get_env(snatch_php, php_ini, ?PHP_INI_FILE),
    ephp_config:start_link(PhpIni),
    case catch ephp_parser:file(Script) of
        {error, eparse, Line, _ErrorLevel, Data} ->
            error_logger:error_msg("parse error line ~p: ~p", [Line, Data]),
            erlang:error(badarg);
        Compiled ->
            AbsFilename = list_to_binary(filename:absname(Script)),
            {ok, #state{code = Compiled, name = AbsFilename}}
    end.

handle_info({connected, _Claw}, State) ->
    {noreply, State};

handle_info({disconnected, _Claw}, State) ->
    {noreply, State};

handle_info({received, Packet, #via{} = Via}, State) ->
    spawn(fun() ->
        run(Packet, Via, State)
    end),
    {noreply, State};

handle_info({received, Packet}, State) ->
    spawn(fun() ->
        run(Packet, undefined, State)
    end),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

output(_Ctx, <<>>) ->
    ok;
output(_Ctx, Text) ->
    error_logger:info_msg("PHP Output: ~s", [Text]),
    ok.

run(Packet, Via, #state{code = Code, name = Filename}) ->
    {ok, Ctx} = ephp:context_new(Filename),
    OutputRef = ephp_context:get_output_handler(Ctx),
    case application:get_env(snatch_php, output, true) of
        true ->
            ephp_output:set_output_handler(OutputRef, fun output/2);
        false ->
            ephp_output:set_output_handler(OutputRef, undefined)
    end,
    ephp_output:set_flush_handler(OutputRef, fun(_) -> ok end),
    %% register superglobals
    ephp:register_var(Ctx, <<"_SERVER">>, get_server_var(Via)),
    ephp:register_var(Ctx, <<"_REQUEST">>, tr(Packet)),
    ephp:register_module(Ctx, ephp_lib_snatch),
    case catch ephp_interpr:process(Ctx, Code, false) of
        {ok, _Return} ->
            ok;
        {error, Reason, _Index, Level, _Data} ->
            error_logger:error_msg("PHP Error: ~s: ~s", [Level, Reason])
    end,
    ephp_shutdown:shutdown(Ctx),
    ephp_context:destroy_all(Ctx),
    ok.

get_server_var(undefined) ->
    ephp_array:from_list([{<<"METHOD">>, <<"unknown">>}]);
get_server_var(#via{claws = Claws, jid = JID, id = ID, exchange = Exchange}) ->
    ephp_array:from_list([{<<"METHOD">>, atom_to_binary(Claws, utf8)},
                          {<<"JID">>, JID},
                          {<<"ID">>, ID},
                          {<<"EXCHANGE">>, Exchange}]).


tr(Bool) when is_boolean(Bool) -> Bool;
tr(undefined) -> undefined;
tr(Atom) when is_atom(Atom) -> atom_to_binary(Atom, utf8);
tr(#xmlel{name = Name, attrs = Attrs, children = Children}) ->
    ephp_array:from_list([
        {<<"name">>, Name},
        {<<"attrs">>, ephp_array:from_list(Attrs)},
        {<<"children">>, ephp_array:from_list([ tr(C) || C <- Children ])}
    ]);
tr({xmlcdata, Text}) ->
    Text;
tr(Binary) when is_binary(Binary) -> Binary.

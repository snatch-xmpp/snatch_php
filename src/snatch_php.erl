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
-include_lib("eunit/include/eunit.hrl").
run(Packet, Via, #state{code = Code, name = Filename}) ->
    {ok, Ctx} = ephp:context_new(Filename),
    %% register superglobals
    ephp:register_var(Ctx, <<"packet">>, tr(Packet)),
    ephp:register_var(Ctx, <<"via">>, tr(Via)),
    ephp:register_module(Ctx, ephp_lib_snatch),
    case catch ephp_interpr:process(Ctx, Code, false) of
        {ok, _Return} ->
            ok;
        {error, Reason, _Index, Level, _Data} ->
            error_logger:error_msg("PHP ~s: ~s", [Level, Reason])
    end,
    ephp_shutdown:shutdown(Ctx),
    ok.

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
tr(Binary) when is_binary(Binary) -> Binary;
tr(#via{jid = JID, exchange = Exchange, id = ID, claws = Claws}) ->
    ephp_array:from_list([
        {<<"claws">>, atom_to_binary(Claws, utf8)},
        {<<"id">>, ID},
        {<<"exchange">>, Exchange},
        {<<"jid">>, JID}
    ]).

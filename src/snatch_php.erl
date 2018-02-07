-module(snatch_php).

-behaviour(snatch).

-export([init/1, handle_info/2, terminate/2]).

-include_lib("snatch/include/snatch.hrl").
-include_lib("fast_xml/include/fxml.hrl").

-record(state, {
    code,
    name :: binary()
}).

init({file, Script}) ->
    case catch ephp_parser:file(Script) of
        {error, eparse, Line, _ErrorLevel, Data} ->
            error_logger:error_msg("parse error line ~p: ~p", [Line, Data]),
            erlang:error(badarg);
        Compiled ->
            {ok, #state{code = Compiled, name = Script}}
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

run(Packet, Via, #state{code = Code}) ->
    {ok, Ctx} = ephp:context_new(),
    publish(Ctx, <<"packet">>, Packet),
    publish(Ctx, <<"via">>, Via),
    catch ephp_interpr:process(Ctx, Code, false),
    ephp_shutdown:shutdown(Ctx),
    ok.

publish(Ctx, VarName, Content) ->
    ephp:register_var(Ctx, VarName, tr(Content)),
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
tr(#via{jid = JID, exchange = Exchange, id = ID, claws = Claws}) ->
    ephp_array:from_list([
        {<<"claws">>, atom_to_binary(Claws, utf8)},
        {<<"id">>, ID},
        {<<"exchange">>, Exchange},
        {<<"jid">>, JID}
    ]).

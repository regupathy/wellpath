%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jun 2019 3:28 PM
%%%-------------------------------------------------------------------
-module(xml_builder).
-author("regupathy").
-behavior(event_handler).

%% API
-export([kv_pairs/3]).
-record(state,{path,data}).

-export([beginning/1,process/2,ending/1]).

-define(OutFILE(Path),filename:join(Path,"XMLResult.xml")).
%%================================================================
%%                    callback Functions
%%================================================================

beginning(Path) ->  catch file:delete(?OutFILE(Path)),
  {ok,#state{path = Path,data = <<>>}}.

process({new_coordinate,{X,Y,Z}},#state{data = Acc}= State) ->
  {ok,State#state{data = kv_pairs("data",["x","y","z"],[[X,Y,Z]],Acc)}}.

ending(#state{path = Path,data=Bin}) ->
  XML = key_value(results,key_value(data_values,Bin)),
  {ok,Fd} = file:open(?OutFILE(Path),[write]),
  file:write(Fd,<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n",XML/binary>>),
  file:close(Fd),
  io:format("XML output in : ~p~n ",[?OutFILE(Path)]).

%%================================================================
%%                    API Functions
%%================================================================

key_value(Key,Value) -> <<(open_tag(Key))/binary,(to_binary(Value))/binary,(close_tag(Key))/binary>>.

kv_pairs(RootKey,Keys,Values) -> kv_pairs(RootKey,Keys,Values,<<>>).
kv_pairs(_,_,[],Acc) -> Acc;
kv_pairs(RootKey,Keys,[Values|Rest],Acc)when length(Keys) == length(Values) ->
  Bin = lists:foldl(fun({Key,Val},Bin) -> <<Bin/binary,(key_value(Key,Val))/binary>>end,<<>>,lists:zip(Keys,Values)),
  kv_pairs(RootKey,Keys,Rest,<<Acc/binary,(key_value(RootKey,Bin))/binary,"\n">>);
kv_pairs(RootKKeys,Keys,[_|Rest],Acc) -> kv_pairs(RootKKeys,Keys,Rest,Acc).

%%================================================================
%%                    Helper Functions
%%================================================================

open_tag(Key) -> <<"<",(to_binary(Key))/binary,">">>.

close_tag(Key) -> <<"</",(to_binary(Key))/binary,">">>.

to_binary(Int) when is_integer(Int) -> integer_to_binary(Int);
to_binary(Float) when is_float(Float) -> list_to_binary(io_lib:format("~f",[Float]));
to_binary(String) when is_list(String) -> list_to_binary(String);
to_binary(Atom) when is_atom(Atom) -> atom_to_binary(Atom,utf8);
to_binary(Binary) when is_binary(Binary) -> Binary.


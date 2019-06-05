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

%% API
-export([kv_pairs/3]).

%%================================================================
%%                    API Functions
%%================================================================

key_value(Key,Value,Acc) -> ok.

kv_pairs(RootKey,Keys,Values) -> kv_pairs(RootKey,Keys,Values,<<>>).
kv_pairs(_,_,[],Acc) -> Acc;
kv_pairs(RootKey,Keys,[Values|Rest],Acc)when length(Keys) == length(Values) ->
  Acc2 = lists:foldl(fun({Key,Value},Bin) ->
                <<Bin/binary,(open_tag(Key))/binary,(to_binary(Value))/binary,(close_tag(Key))/binary>>
              end,<<>>,lists:zip(Keys,Values)),
  kv_pairs(RootKey,Keys,Rest,<<Acc/binary,(open_tag(RootKey))/binary,Acc2/binary,(close_tag(RootKey))/binary>>);
kv_pairs(RootKKeys,Keys,[_|Rest],Acc) -> kv_pairs(RootKKeys,Keys,Rest,Acc).

%%================================================================
%%                    Helper Functions
%%================================================================

open_tag(Key) -> <<"<",(to_binary(Key))/binary,">">>.

close_tag(Key) -> <<"</",(to_binary(Key))/binary,">">>.

to_binary(Int) when is_integer(Int) -> integer_to_binary(Int);
to_binary(Float) when is_float(Float) -> float_to_binary(Float);
to_binary(String) when is_list(String) -> list_to_binary(String);
to_binary(Binary) when is_binary(Binary) -> Binary.


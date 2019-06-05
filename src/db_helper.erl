%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jun 2019 2:16 PM
%%%-------------------------------------------------------------------
-module(db_helper).
-author("regupathy").

%% API
-export([read/0]).

read() ->
  {ok,Connection} = esqlite3:open("priv/petrolink_challenge.db"),
  esqlite3:q("select * from Data",Connection).









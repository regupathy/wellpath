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
-export([read/0,create_result_table/1]).

read() ->
  {ok,Connection} = esqlite3:open("priv/petrolink_challenge.db"),
  esqlite3:q("select * from Data",Connection).


create_result_table(Connection) ->
  try esqlite3:q("CREATE TABLE Results(x REAL, y REAL, z REAL)",Connection) of
    [] -> {create_table,success}
    catch
      error:{sqlite_error,Reason} -> {create_table,{error,Reason}}
  end.








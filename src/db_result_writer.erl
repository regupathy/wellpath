%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Jun 2019 12:35 AM
%%%-------------------------------------------------------------------
-module(db_result_writer).
-author("regupathy").
-behavior(event_handler).
%% API
-export([]).

-export([beginning/1,process/2,ending/1]).

%%================================================================
%%                    callback Functions
%%================================================================

beginning(_) ->
  db_connection:create_result_table("Results"),
  db_connection:clear_table("Results"),
  {ok,[]}.

process({new_coordinate,{X,Y,Z}},State) ->
  db_connection:write_in_result({X,Y,Z}),
  {ok,State}.

ending([]) -> ok.

%%===============================================================
%%                    Internal Functions
%%================================================================





%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jun 2019 6:17 PM
%%%-------------------------------------------------------------------
-module(csv_builder).
-author("regupathy").
-behavior(event_handler).
-export([beginning/1,process/2,ending/1]).

%%================================================================
%%                    callback Functions
%%================================================================

beginning([{path,Path}]) ->  {ok,#state{path = Path,data = <<>>}}.

process({new_coordinate,{X,Y,Z}},State) -> {ok,State}.

ending(State) -> ok.

%%================================================================
%%                    Internal Functions
%%================================================================






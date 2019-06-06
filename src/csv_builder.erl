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

-record(state,{file}).
-define(OutFILE(Path),filename:join(Path,"CSVResult.csv")).
%%================================================================
%%                    callback Functions
%%================================================================

beginning([Path]) ->
  catch file:delete(?OutFILE(Path)),
  {ok, File} = file:open(?OutFILE(Path), [write]),
  csv_gen:row(File, ["Results"]),
  csv_gen:row(File, ["X","Y","Z"]),
  {ok,#state{file = File}}.

process({new_coordinate,{X,Y,Z}},#state{file = File} = State) ->
  csv_gen:row(File, [X,Y,Z]),
  {ok,State}.

ending(#state{file = Fd}) -> file:close(Fd).

%%================================================================
%%                    Internal Functions
%%================================================================






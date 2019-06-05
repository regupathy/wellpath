%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jun 2019 11:51 PM
%%%-------------------------------------------------------------------
-module(data_processor).
-author("regupathy").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {db_connection}).

-define(DB_PATH,"priv/petrolink_chanllenge.db").

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
  db_connection:start_link(get_db_path()),
  event_handler:start_link(get_out_dir()),
  self() ! start,
  {ok, #state{}}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(start, State) ->
  List = db_connection:read("Data"),
  [{X,Y,Z}] = db_connection:read("InitialCoordinates"),
  process_data(List,{X,Y,Z}),
  dls_data(List),
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

get_db_path() ->
  case init:get_argument("db_path") of
    {ok,[Path|_]} -> Path;
    _ -> ?DB_PATH
  end.

get_out_dir() ->
  case init:get_argument("out_dir") of
    {ok,[Path|_]} -> Path;
    _ -> "output"
  end.

process_data([Set1,Set2|Rest],{X,Y,Z}) ->
  {X1,Y1,Z1} = calculation:cal_coordinate(Set1,Set2),
  event_handler:publish_coordinate({X+X1,Y+Y1,Z+Z1}),
  process_data([Set2|Rest],{X,Y,Z});
process_data(_,_) -> ok.


dls_data(List)when length(List) >= 2 ->
  Val = calculation:dogleg_severity(hd(List),lists:last(List)),
  event_handler:publish_dls(Val).

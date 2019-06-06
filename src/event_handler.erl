%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jun 2019 6:49 PM
%%%-------------------------------------------------------------------
-module(event_handler).
-author("regupathy").

-behaviour(gen_server).

%% API
-export([start_link/1,
  publish_coordinate/1,
  publish_dls/1,
  event_begin/0,
  event_end/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {modstates,path}).

-callback beginning(Args::term()) -> {ok,State::any()} | {error,Reason::term()}.
-callback ending(State::any()) -> ok.
-callback process(Message::term(),State::any()) -> {ok,NewState::any()}.

%%%===================================================================
%%% API
%%%===================================================================

start_link(CallBackMod) -> gen_server:start_link({local,?SERVER},?MODULE, [CallBackMod], []).

publish_coordinate({_,_,_} =Val) -> gen_server:cast(?SERVER,{new_coordinate,Val}).

publish_dls(DLS) -> gen_server:cast(?SERVER,{dls,DLS}).

event_begin()-> gen_server:cast(?SERVER,event_begin).

event_end() -> gen_server:cast(?SERVER,event_end).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Path]) ->
  {ok, #state{path = Path,modstates = [{db_result_writer,Path,[]},{csv_builder,Path,[]},{xml_builder,Path,[]}]}}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast({new_coordinate,Val}, #state{modstates = ModState} =State) ->
  NewModState = lists:map(fun({Mod,A,Stat}) -> {ok,NewStat}= Mod:process({new_coordinate,Val},Stat),{Mod,A,NewStat} end,ModState),
  {noreply, State#state{modstates = NewModState}};

handle_cast(event_begin, #state{modstates = ModState} =State) ->
  NewModState = lists:map(fun({Mod,A,_}) -> {ok,NewStat}= Mod:beginning(A),{Mod,A,NewStat} end,ModState),
  {noreply, State#state{modstates = NewModState}};

handle_cast(event_end, #state{modstates = ModState} =State) ->
  NewModState = lists:map(fun({Mod,A,Stat}) -> Mod:ending(Stat),{Mod,A,[]} end,ModState),
  {noreply,State#state{modstates = NewModState}};

handle_cast({dls,DLS}, State) ->
  io:format("DLS value is : ~p~n",[DLS]),
  {noreply, State};

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->  {noreply, State}.

terminate(_Reason, _State) ->  ok.

code_change(_OldVsn, State, _Extra) ->  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================



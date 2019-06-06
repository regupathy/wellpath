%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Jun 2019 12:03 AM
%%%-------------------------------------------------------------------
-module(db_connection).
-author("regupathy").

-behaviour(gen_server).

%% API
-export([start_link/1,read/1,create_result_table/1,delete_table/1,write_in_result/1]).
-export([clear_table/1]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {connection,result_table}).

%%%===================================================================
%%% API
%%%===================================================================

start_link(DbPath) ->
  io:format("PWD is :~p~n",[os:cmd("pwd")]),
  gen_server:start_link({local, ?SERVER}, ?MODULE, [DbPath], []).

read(TableName) -> gen_server:call(?SERVER,{read,TableName}).

create_result_table(TableName) -> gen_server:cast(?SERVER,{create_result_table,TableName}).

delete_table(Table) -> gen_server:cast(?SERVER,{delete_table,Table}).

write_in_result(Value) -> gen_server:cast(?SERVER,{write_in_result,Value}).

clear_table(TableName) -> gen_server:cast(?SERVER,{clear_table,TableName}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([DbPath]) ->
  process_flag(trap_exit,true),
  {ok,Connection} = esqlite3:open(DbPath),
  io:format("Sqlite DB located in : ~p~n ",[DbPath]),
  {ok, #state{connection = Connection}}.

handle_call({read,TableName}, _From, #state{connection = Connection}= State) ->
  Value = esqlite3:q("select * from "++TableName,Connection),
  {reply, Value, State}.

handle_cast({create_result_table,TableName},  #state{connection = Connection}= State) ->
  catch esqlite3:q("CREATE TABLE "++TableName++"(x REAL, y REAL, z REAL)",Connection),
  {noreply, State#state{result_table = TableName}};

handle_cast({write_in_result,{X,Y,Z}}, #state{connection = Connection,result_table = Tab}= State) ->
  [Xstr,Ystr,Zstr] = [float_to_list(V) || V <- [X,Y,Z]],
  esqlite3:q("INSERT INTO "++Tab++"(x,y,z) VALUES ("++Xstr++","++Ystr++","++Zstr++")",Connection),
  {noreply, State};

handle_cast({delete_table,TableName}, #state{connection = Connection}= State) ->
  catch esqlite3:q("DROP TABLE "++TableName,Connection),
  {noreply, State};

handle_cast({clear_table,TableName}, #state{connection = Connection}= State) ->
  catch esqlite3:q("DELETE FROM "++TableName,Connection),
  {noreply, State};

handle_cast(_Request, State) ->  {noreply, State}.

handle_info(_Info, State) ->  {noreply, State}.

terminate(_Reason, _State) ->  ok.

code_change(_OldVsn, State, _Extra) ->  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

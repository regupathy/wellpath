%%%-------------------------------------------------------------------
%%% @author regupathy
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jun 2019 9:09 PM
%%%-------------------------------------------------------------------
-module(calculation).
-author("regupathy").
-import(math,[cos/1,sin/1,acos/1,tan/1]).
%% API
-export([cal/2,beta/2]).

-compile([export_all]).

cal({MD1,A1,I1},{MD2,A2,I2}) ->
  MD = MD2-MD1,
  Beta = beta({radian(I1),radian(I2)},{radian(A1),radian(A2)}),
  RF = rf(Beta),
  North = north(MD,RF,{I1,I2},{A1,A2}),
  East = east(MD,RF,{I1,I2},{A1,A2}),
  TVD =tvd(MD,RF,{I1,I2}),
  io:format("data received as {MD1,A1,I1},{MD2,A2,I2}: ~p ~n~n",[{{MD1,A1,I1},{MD2,A2,I2}}]),
  io:format("values got ~p~n",[{MD,Beta,RF,{north,North},{east,East}}]),
  {North,East,TVD}
  .


beta({I1,I2},{A1,A2}) -> acos(cos(I2-I1)-((sin(I1)*sin(I2))*(1-cos(A2-A1)))).

rf(Beta) -> 2/Beta * (tan(degree(Beta)/2)).

north(MD,RF,{I1,I2},{A1,A2})-> MD/2 * (sin(I1)*cos(A1)+sin(I2)*cos(A2))*RF.

east(MD,RF,{I1,I2},{A1,A2})-> MD/2 * (sin(I1)*sin(A1)+sin(I2)*sin(A2))*RF.

tvd(MD,RF,{I1,I2})-> MD/2*(cos(I1)+cos(I2))*RF.

radian(Deg) -> Deg * 3.141/180.

degree(Rad) -> Rad * 180/3.141.


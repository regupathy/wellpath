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
-export([cal_coordinate/2,dogleg_severity/2]).

%%================================================================
%%                    API Functions
%%================================================================

dogleg_severity({MD1,A1,I1},{MD2,A2,I2}) ->
  [I1r,I2r,A1r,A2r] = [radian(X) || X <- [I1,I2,A1,A2]],
  MD = MD2-MD1,
  acos((cos(I1r)*cos(I2r))+(sin(I1r)*sin(I2r))*cos(A2r-A1r))*(100/MD) .

cal_coordinate({MD1,A1,I1},{MD2,A2,I2}) ->
  [I1r,I2r,A1r,A2r] = [radian(X) || X <- [I1,I2,A1,A2]],
  MD = MD2-MD1,
  Beta = beta({I1r,I2r},{A1r,A2r}),
  RF = rf(Beta),
  North = north(MD,RF,{I1r,I2r},{A1r,A2r}),
  East = east(MD,RF,{I1r,I2r},{A1r,A2r}),
  TVD = tvd(MD,RF,{I1r,I2r}),
  {East,North,TVD}.

%%================================================================
%%                    Helper Functions
%%================================================================

beta({I1,I2},{A1,A2}) -> acos(cos(I2-I1)-((sin(I1)*sin(I2))*(1-cos(A2-A1)))).

rf(Beta) -> 2/Beta * (tan(Beta/2)).

north(MD,RF,{I1,I2},{A1,A2})-> MD/2 * (sin(I1)*cos(A1)+sin(I2)*cos(A2))*RF.

east(MD,RF,{I1,I2},{A1,A2})-> MD/2 * (sin(I1)*sin(A1)+sin(I2)*sin(A2))*RF.

tvd(MD,RF,{I1,I2})-> MD/2*(cos(I1)+cos(I2))*RF.

radian(Deg) -> Deg * 3.141/180.


